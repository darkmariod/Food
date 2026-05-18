#!/bin/bash
# =========================================================
# Prueba Manual — Monkey Food + OpenWA + n8n + Supabase
# =========================================================
# Simula el webhook que OpenWA envía a n8n cuando alguien
# escribe "menú" por WhatsApp.
#
# Uso:
#   ./n8n/test-manual.sh                # probar "menú"
#   MENSAJE="hola" ./n8n/test-manual.sh  # probar otro texto
#
# Requisitos:
#   - n8n corriendo en http://localhost:5678
#   - Workflow "Monkey Food - OpenWA" importado y activo
# =========================================================

set -euo pipefail

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
echo "  n8n webhook : ${WEBHOOK_URL}"
echo "  mensaje     : ${MENSAJE}"
echo "  chatId      : ${CHAT_ID}"
echo "  pushName    : ${PUSH_NAME}"
echo ""

# 1. Verificar que n8n está corriendo
echo "🔍 Verificando n8n..."
if curl -sf "${N8N_URL}/healthz" > /dev/null 2>&1; then
  echo "   ✅ n8n está corriendo"
else
  echo "   ❌ n8n NO responde en ${N8N_URL}"
  echo "      Ejecutá: docker run -d --name n8n -p 5678:5678 n8nio/n8n"
  exit 1
fi

# 2. Simular webhook de OpenWA
echo ""
echo "📤 Enviando mensaje a n8n..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${WEBHOOK_URL}" \
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

HTTP_CODE=$(echo "${RESPONSE}" | tail -1)
BODY=$(echo "${RESPONSE}" | sed '$d')

if [ "${HTTP_CODE}" -ge 200 ] && [ "${HTTP_CODE}" -lt 300 ]; then
  echo "   ✅ n8n respondió con HTTP ${HTTP_CODE}"
else
  echo "   ❌ n8n respondió con HTTP ${HTTP_CODE}"
  echo "      Body: ${BODY}"
  echo ""
  echo "   Posibles causas:"
  echo "     - Workflow no activo"
  echo "     - Webhook path incorrecto"
  echo "     - Error en el workflow"
  exit 1
fi

echo ""
echo "========================================"
echo " Resultado"
echo "========================================"
echo ""
echo "   ✅ Webhook entregado a n8n"
echo "   🔍 Revisá las ejecuciones en n8n:"
echo "      ${N8N_URL}/workflow/monkey-food-openwa"
echo ""
echo "   Si OpenWA está conectado y el QR fue"
echo "   escaneado, el mensaje de respuesta"
echo "   debería llegar al chat ${CHAT_ID}"
echo ""
echo "   Para ver logs del workflow:"
echo "      ${N8N_URL}/executions"
echo ""
echo "========================================"
