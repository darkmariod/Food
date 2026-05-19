#!/bin/bash
# =========================================================
# Prueba Manual — Monkey Food + n8n + Supabase
# =========================================================
# Simula el webhook que OpenWA enviaría a n8n cuando alguien
# escribe "menú" por WhatsApp.
#
# Sin OpenWA: la consulta a Supabase funciona, el envío
# falla (esperado). Se ve el resultado en n8n.
#
# Uso:
#   ./n8n/test-manual.sh                 # probar "menú"
#   MENSAJE="hola" ./n8n/test-manual.sh  # probar otro texto
#
# Requisitos:
#   - n8n corriendo en http://localhost:5678 (ver docker-compose.yml)
#   - Workflow "Monkey Food - OpenWA" importado y ACTIVO
# =========================================================

set -uo pipefail

N8N_URL="${N8N_URL:-http://localhost:5678}"
WEBHOOK_PATH="webhook/monkey-food-whatsapp"
WEBHOOK_URL="${N8N_URL}/${WEBHOOK_PATH}"
MENSAJE="${MENSAJE:-menú}"
CHAT_ID="${CHAT_ID:-593999999999@c.us}"
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
  echo "   http://localhost:5678 → Settings → Import → n8n/monkey-food-openwa.json"
  exit 1
fi

# ── 2. Enviar webhook simulado ─────────────────────────
echo ""
echo "📤 2. Enviando webhook simulado..."
echo "     (simula lo que OpenWA enviaría a n8n)"

HTTP_CODE=$(curl -s -o /tmp/monkey-food-test-resp.json -w "%{http_code}" \
  -X POST "${WEBHOOK_URL}" \
  -H "Content-Type: application/json" \
  -d "{
    \"event\": \"message\",
    \"session\": \"default\",
    \"payload\": {
      \"key\": { \"remoteJid\": \"${CHAT_ID}\" },
      \"message\": { \"conversation\": \"${MENSAJE}\" },
      \"pushName\": \"${PUSH_NAME}\"
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
    echo "      (OpenWA está corriendo y el mensaje se envió)"
    echo ""
    echo "   📬 Revisá el WhatsApp ${CHAT_ID} para ver la respuesta"
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
    echo "      (esperado si OpenWA no está corriendo)"
    echo ""
    echo "   🔍 Revisá la ejecución en n8n para ver el resultado parcial:"
    echo "      ${N8N_URL}/executions"
    echo ""
    echo "   Deberías ver:"
    echo "     ✅ Webhook → Parsear Mensaje → Router →"
    echo "     ✅ Armar Menú Dinámico (consulta a Supabase)"
    echo "     ❌ Enviar a OpenWA (falla porque no hay OpenWA — normal)"
    ;;
esac

# ── 4. Próximos pasos ─────────────────────────────────
echo ""
echo "========================================"
echo " Próximos pasos"
echo "========================================"
echo ""
echo "   Para la prueba COMPLETA (con respuesta WhatsApp):"
echo ""
echo "   1) Agregá OpenWA al docker-compose:"
echo ""
echo "   openwa:"
echo "     image: openwa/openwa:latest"
echo "     ports:"
echo "       - \"2886:2886\""
echo "     environment:"
echo "       - OPENWA_API_KEY=monkey_food_secure_key"
echo ""
echo "   2) Configurá el webhook en OpenWA:"
echo '      curl -X POST http://localhost:2886/api/sessions/default/webhook \'
echo '        -H "X-API-Key: monkey_food_secure_key" \'
echo '        -H "Content-Type: application/json" \'
echo '        -d "{\"url\": \"http://host.docker.internal:5678/webhook/monkey-food-whatsapp\"}"'
echo ""
echo "   3) Escaneá el QR:"
echo "      http://localhost:2886/api/sessions/default/qr"
echo ""
echo "   4) Enviá 'menú' desde tu WhatsApp al número conectado"
echo ""
echo "========================================"
