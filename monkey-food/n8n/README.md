# Conexión WhatsApp — OpenWA + n8n

Arquitectura: WhatsApp → OpenWA → Webhook n8n → Supabase → n8n envía respuesta por OpenWA

## Requisitos

| Herramienta | Versión | Puerto |
|-------------|---------|--------|
| [OpenWA](https://openwa.dev) | última | 2886 |
| [n8n](https://n8n.io) | última | 5678 |
| Docker | 24+ | — |

## 1. Levantar OpenWA

```bash
docker run -d \
  --name openwa \
  -p 2886:2886 \
  -e OPENWA_API_KEY=monkey_food_secure_key \
  openwa/openwa:latest
```

Configurar webhook para que OpenWA envíe los mensajes entrantes a n8n:

```
POST http://localhost:5678/webhook/monkey-food-whatsapp
```

Esto se configura en el panel de OpenWA o vía API:
```bash
curl -X POST http://localhost:2886/api/sessions/default/webhook \
  -H "X-API-Key: monkey_food_secure_key" \
  -H "Content-Type: application/json" \
  -d '{"url": "http://localhost:5678/webhook/monkey-food-whatsapp"}'
```

Escanear QR:
```
http://localhost:2886/api/sessions/default/qr
```

## 2. Importar workflow en n8n

1. Abrir n8n → http://localhost:5678
2. Settings → Import → From File
3. Seleccionar `n8n/monkey-food-openwa.json`
4. Revisar configuración (ver sección 3)
5. Activar workflow (toggle Active)

## 3. Variables de configuración

Dentro del workflow, los Code nodes tienen secciones de configuración al inicio:

### En "Armar Menú Dinámico" (Supabase)

| Variable | Valor por defecto |
|----------|-------------------|
| `SUPABASE_URL` | `https://almfsjxrajxmyfygrtdj.supabase.co` |
| `SUPABASE_KEY` | `eyJ...` (service_role key) |

### En "Enviar a OpenWA" (OpenWA)

| Variable | Valor por defecto |
|----------|-------------------|
| `OPENWA_BASE_URL` | `http://localhost:2886` |
| `OPENWA_API_KEY` | `monkey_food_secure_key` |
| `OPENWA_SESSION_ID` | `default` |

## 4. Flujo del workflow

```
Webhook POST /monkey-food-whatsapp
    │
    ▼
Parsear Mensaje (extrae chatId, text, pushName)
    │
    ▼
Router (Switch)
    ├── "hola" / "buenas" / "inicio"
    │       └── Responder Saludo ──┐
    ├── "menú"
    │       └── Armar Menú Dinámico ──┐
    │               ├── GET /rest/v1/products (Supabase)
    │               └── Build menu con emoji + precio
    └── default
            └── No Entendí ──┐
                             ▼
                    Enviar a OpenWA
                    POST /api/sessions/{session}/messages/send-text
```

### Payload que OpenWA envía a n8n

```json
{
  "event": "message",
  "session": "default",
  "payload": {
    "key": { "remoteJid": "593999999999@c.us" },
    "message": { "conversation": "menú" },
    "pushName": "Cliente"
  }
}
```

### Payload que n8n envía a OpenWA

```json
{
  "chatId": "593999999999@c.us",
  "text": "🍲 *MENÚ MONKEY FOOD* 🍲\n\nBowls disponibles:\n\n1. 🍗 *Pollo Power* - $4..."
}
```

## 5. Comandos del bot

| Mensaje | Respuesta |
|---------|-----------|
| `hola` / `buenas` / `inicio` | Saludo de bienvenida + menú de opciones |
| `menú` / `menu` | Menú dinámico con productos desde Supabase |
| cualquier otra cosa | Mensaje "no entendí" + sugerencia |

## 6. Probar sin WhatsApp

```bash
# Test desde terminal simulando el webhook de OpenWA
./n8n/test-manual.sh
```

## 7. Troubleshooting

| Problema | Causa posible | Solución |
|----------|---------------|----------|
| n8n no recibe webhook | OpenWA no configura webhook | Revisar configuración webhook en OpenWA |
| Error 401 en OpenWA | API key incorrecta | Verificar OPENWA_API_KEY en .env y workflow |
| Error 404 en productos | Supabase URL o key incorrecta | Verificar SUPABASE_URL y SUPABASE_KEY |
| n8n no arranca | Puerto ocupado | `lsof -i :5678` y matar proceso |
| Sesión no conectada | QR no escaneado | Abrir `http://localhost:2886/api/sessions/default/qr` |
