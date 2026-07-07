#!/bin/bash
# =========================================================
# Prueba Manual — Monkey Food + n8n + Supabase
# =========================================================
# Simula el webhook que Evolution API enviaría a n8n cuando
# alguien escribe por WhatsApp.
#
# Sin Evolution conectado: el cerebro del bot corre igual
# (consulta Supabase, guarda estado); el envío final falla
# (esperado). Se ve el detalle en n8n → Executions.
#
# Uso:
#   ./n8n/test-manual.sh                 # probar "hola"
#   MENSAJE="1" ./n8n/test-manual.sh     # elegir bowl 1
#   MENSAJE="2" ./n8n/test-manual.sh     # retiro (tras elegir bowl)
#
# Requisitos:
#   - n8n corriendo en http://localhost:5678 (ver docker-compose.yml)
#   - Workflow "Monkey Food - Evolution" importado y ACTIVO
# =========================================================

set -uo pipefail

N8N_URL="${N8N_URL:-http://localhost:5678}"
WEBHOOK_PATH="webhook/monkey-food-whatsapp"
WEBHOOK_URL="${N8N_URL}/${WEBHOOK_PATH}"
MENSAJE="${MENSAJE:-hola}"
CHAT_ID="${CHAT_ID:-593999999999@s.whatsapp.net}"
PUSH_NAME="${PUSH_NAME:-Test}"

echo "========================================"
echo " Monkey Food — Test de Integración"
echo "========================================"
echo ""
echo "  📤 mensaje  : \"${MENSAJE}\""
echo "  📍 webhook  : ${WEBHOOK_URL}"
echo "  👤 chatId   : ${CHAT_ID}"
echo ""

# ── 1. Verificar n8n ──────────────────────────────────
echo "🔍 1. Verificando n8n..."
if curl -sf "${N8N_URL}/healthz" > /dev/null 2>&1; then
  echo "   ✅ n8n responde en ${N8N_URL}"
else
  echo "   ❌ n8n no está corriendo"
  echo ""
  echo "   Para arrancarlo:"
  echo "   docker compose -f n8n/docker-compose.yml up -d"
  echo "   Luego importá el workflow desde la UI:"
  echo "   http://localhost:5678 → Import → n8n/monkey-food-evolution.json"
  exit 1
fi

# ── 2. Enviar webhook simulado ─────────────────────────
echo ""
echo "📤 2. Enviando webhook simulado..."
echo "     (simula el evento MESSAGES_UPSERT de Evolution API)"

HTTP_CODE=$(curl -s -o /tmp/monkey-food-test-resp.json -w "%{http_code}" \
  -X POST "${WEBHOOK_URL}" \
  -H "Content-Type: application/json" \
  -d "{
    \"event\": \"messages.upsert\",
    \"instance\": \"monkeyfood\",
    \"data\": {
      \"key\": { \"remoteJid\": \"${CHAT_ID}\", \"fromMe\": false },
      \"pushName\": \"${PUSH_NAME}\",
      \"message\": { \"conversation\": \"${MENSAJE}\" }
    }
  }")

echo "     HTTP ${HTTP_CODE}"

# ── 3. Interpretar resultado ──────────────────────────
echo ""
echo "📋 3. Resultado"
echo ""

case "${HTTP_CODE}" in
  200)
    echo "   ✅ Webhook recibido y procesado sin errores"
    echo "      (Evolution está corriendo y el mensaje se envió)"
    echo ""
    echo "   📬 Revisá el WhatsApp ${CHAT_ID%%@*} para ver la respuesta"
    ;;
  202)
    echo "   ✅ Webhook recibido (procesamiento asíncrono)"
    ;;
  404)
    echo "   ⚠️  Webhook no encontrado (HTTP 404)"
    echo "      Posibles causas:"
    echo "      - El workflow no está ACTIVO (toggle Active en n8n)"
    echo "      - El path del webhook no es 'monkey-food-whatsapp'"
    exit 1
    ;;
  *)
    echo "   ⚠️  Webhook respondió con HTTP ${HTTP_CODE}"
    echo "      (esperado si Evolution no está conectado todavía)"
    echo ""
    echo "   🔍 Revisá la ejecución en n8n para ver el resultado parcial:"
    echo "      ${N8N_URL}/executions"
    echo ""
    echo "   Deberías ver:"
    echo "     ✅ Webhook → Parsear Mensaje →"
    echo "     ✅ Cerebro del Bot (Supabase: estado + productos)"
    echo "     ❌ Enviar WhatsApp (falla sin Evolution — normal)"
    ;;
esac

echo ""
echo "   Setup completo (Evolution + QR): ver n8n/README.md"
echo "========================================"
