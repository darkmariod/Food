# Conexión WhatsApp — Evolution API + n8n

Arquitectura (misma que [sistema-pedidos-whatsapp-ia](https://github.com/GinoRobla/sistema-pedidos-whatsapp-ia)):

```
WhatsApp → Evolution API → Webhook n8n → Cerebro del Bot (estado + Supabase) → Evolution API responde
```

Workflow canónico: **`monkey-food-evolution.json`**.
Los archivos `monkey-food-bot*.json` y `monkey-food-openwa.json` están **obsoletos** (OpenWA/Whapi no se usan más) — no los importes.

## ⚠️ Seguridad primero

Los workflows viejos tenían la service_role key de Supabase y un token de Whapi hardcodeados, y el repo es público. **Antes de usar nada:**

1. Rotar la service_role key: Supabase Dashboard → Settings → API → *Reset* (JWT secret / API keys).
2. Revocar el token de Whapi.Cloud (si esa cuenta sigue activa).
3. El workflow nuevo lee todo desde variables de entorno — nunca vuelvas a pegar keys en un workflow.

## 1. Configuración

Crear `n8n/.env` (está en `.gitignore`, nunca se commitea) con:

```bash
# Evolution API — generar con: openssl rand -hex 32
EVOLUTION_API_KEY=
EVOLUTION_INSTANCE=monkeyfood

# Postgres interno de Evolution
POSTGRES_PASSWORD=

# Supabase (Dashboard → Settings → API) — usar la key YA ROTADA
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=

# Solo en producción (VPS):
# N8N_PUBLIC_URL=https://n8n.tudominio.com
# EVOLUTION_PUBLIC_URL=https://wa.tudominio.com
```

Y correr en el SQL editor de Supabase: `supabase/conversation-state.sql` (tabla de estado de conversación).

## 2. Levantar el stack

```bash
cd monkey-food/n8n
docker compose up -d
```

| Servicio | URL |
|----------|-----|
| n8n | http://localhost:5678 |
| Evolution API | http://localhost:8080 |
| Evolution Manager (UI) | http://localhost:8080/manager |

## 3. Importar y activar el workflow

1. Abrir n8n → http://localhost:5678
2. Import from File → `n8n/monkey-food-evolution.json`
3. Activar (toggle **Active**) — el webhook queda en `POST /webhook/monkey-food-whatsapp`

## 4. Crear la instancia de WhatsApp y escanear QR

Opción recomendada — **Evolution Manager** (http://localhost:8080/manager, login con tu `EVOLUTION_API_KEY`):

1. Create Instance → nombre `monkeyfood`, integración **Baileys**
2. Escanear el QR con el WhatsApp del negocio
3. En la instancia → **Webhook**: activar, URL `http://n8n:5678/webhook/monkey-food-whatsapp`, evento **MESSAGES_UPSERT**

Opción por API:

```bash
curl -X POST http://localhost:8080/instance/create \
  -H "apikey: $EVOLUTION_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"instanceName": "monkeyfood", "integration": "WHATSAPP-BAILEYS", "qrcode": true}'
```

> La URL del webhook usa `http://n8n:5678` (nombre del servicio Docker), no `localhost`, porque Evolution llama a n8n desde adentro de la red de Docker.

## 5. Flujo del bot

```
hola / menú          → saludo + menú dinámico (products de Supabase)
número (1..N)        → elige bowl → pregunta Delivery o Retiro
1 (delivery)         → pide dirección → guarda pedido → confirma
2 (retiro)           → guarda pedido → confirma
cancelar             → vuelve al menú
```

El estado de cada conversación vive en la tabla `conversation_state` (por teléfono), así el bot atiende varios clientes a la vez sin mezclarse. Los pedidos se guardan en `orders` + `order_items` con status `pending` y aparecen en el panel admin (`/admin/pedidos`) vía Supabase Realtime.

## 6. Probar sin WhatsApp

```bash
./n8n/test-manual.sh                  # simula "hola"
MENSAJE="1" ./n8n/test-manual.sh      # simula elegir bowl 1
```

## 7. Deploy a producción

- **Nuxt (tienda + admin)** → Vercel (o similar). Solo necesita las keys públicas de Supabase.
- **n8n + Evolution** → un VPS con Docker (DigitalOcean/Hetzner/Railway, ~$5-7/mes). WhatsApp necesita una sesión viva 24/7 — esto NO puede ir en Vercel.
  1. Copiar `n8n/` al VPS, crear `.env` con `N8N_PUBLIC_URL` y `EVOLUTION_PUBLIC_URL` públicos (con HTTPS via Caddy/Traefik/nginx).
  2. `docker compose up -d`, importar workflow, crear instancia, escanear QR.
  3. El webhook de la instancia sigue siendo `http://n8n:5678/...` (red interna).
- **Supabase** → ya está en la nube, no cambia nada.

## 8. Troubleshooting

| Problema | Causa posible | Solución |
|----------|---------------|----------|
| n8n no recibe mensajes | Webhook mal configurado en la instancia | Manager → instancia → Webhook: URL `http://n8n:5678/webhook/monkey-food-whatsapp` + evento MESSAGES_UPSERT |
| 400 en sendText | Versión vieja de Evolution (v1 usa `textMessage.text`) | Usar imagen `evoapicloud/evolution-api:latest` (v2, body plano `{number, text}`) |
| 401 en Evolution | apikey incorrecta | Debe coincidir con `EVOLUTION_API_KEY` del `.env` |
| Bot responde "problema técnico" | Supabase URL/key mal, o falta la tabla `conversation_state` | Revisar env vars del contenedor n8n y correr `conversation-state.sql` |
| `$env` vacío en Code node | Variable no llegó al contenedor | `docker compose down && up -d` después de editar `.env` |
| QR no aparece / sesión caída | Instancia desconectada | Manager → instancia → Restart / volver a escanear QR |
