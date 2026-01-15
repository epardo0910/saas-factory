#!/bin/bash

# Script interactivo para configurar Cloudflare DNS

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear

echo -e "${MAGENTA}"
cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║     🌐 Cloudflare DNS Setup para SaaS Factory        ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${CYAN}Este script te ayudará a configurar Cloudflare DNS${NC}"
echo ""

# Paso 1: Obtener Zone ID
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Paso 1: Obtener Zone ID${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Para obtener tu Zone ID:${NC}"
echo ""
echo "1. Ve a: ${GREEN}https://dash.cloudflare.com${NC}"
echo "2. Haz clic en: ${GREEN}emanuel-server.com${NC}"
echo "3. En la barra lateral derecha, busca la sección ${GREEN}API${NC}"
echo "4. Verás ${GREEN}Zone ID${NC} - cópialo"
echo ""
echo -e "${YELLOW}El Zone ID tiene este formato:${NC} ${GREEN}abc123def456789...${NC} (32 caracteres)"
echo ""
read -p "$(echo -e ${CYAN}Ingresa tu Zone ID:${NC} )" ZONE_ID

# Validar formato Zone ID (32 caracteres hexadecimales)
if [[ ! "$ZONE_ID" =~ ^[a-f0-9]{32}$ ]]; then
    echo -e "${YELLOW}⚠️  Advertencia: El Zone ID debería tener 32 caracteres${NC}"
    read -p "$(echo -e ${YELLOW}¿Continuar de todos modos? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Cancelado.${NC}"
        exit 1
    fi
fi

echo ""

# Paso 2: API Token
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Paso 2: API Token${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}¿Ya tienes un API Token válido?${NC}"
echo ""
echo "Si tu token actual no funciona, necesitas crear uno nuevo con estos permisos:"
echo ""
echo -e "${GREEN}Permisos necesarios:${NC}"
echo "  ✅ Zone → DNS → Edit"
echo "  ✅ Zone → Zone → Read"
echo ""
echo -e "${GREEN}Zone Resources:${NC}"
echo "  ✅ Specific zone → emanuel-server.com"
echo ""
echo "Para crear uno nuevo:"
echo "1. Ve a: ${GREEN}https://dash.cloudflare.com/profile/api-tokens${NC}"
echo "2. ${GREEN}Create Token${NC} → ${GREEN}Edit zone DNS${NC} (template)"
echo "3. Configura los permisos mencionados arriba"
echo "4. ${GREEN}Create Token${NC} y copia el token"
echo ""
read -p "$(echo -e ${CYAN}Ingresa tu API Token:${NC} )" API_TOKEN

echo ""

# Paso 3: Verificar conectividad
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Paso 3: Verificar Configuración${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Probando conexión con Cloudflare...${NC}"
echo ""

# Probar API
RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/v4/zones/${ZONE_ID}" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json")

# Verificar si fue exitoso
if echo "$RESPONSE" | grep -q '"success":true'; then
    ZONE_NAME=$(echo "$RESPONSE" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo -e "${GREEN}✅ Conexión exitosa!${NC}"
    echo -e "${CYAN}Zona detectada:${NC} ${GREEN}$ZONE_NAME${NC}"

    if [ "$ZONE_NAME" != "emanuel-server.com" ]; then
        echo -e "${YELLOW}⚠️  Advertencia: La zona no es emanuel-server.com${NC}"
        read -p "$(echo -e ${YELLOW}¿Continuar de todos modos? [y/N]:${NC} )" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Cancelado.${NC}"
            exit 1
        fi
    fi
else
    echo -e "${RED}❌ Error al conectar con Cloudflare${NC}"
    echo ""
    ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$ERROR_MSG" ]; then
        echo -e "${RED}Mensaje de error:${NC} $ERROR_MSG"
    fi
    echo ""
    echo -e "${YELLOW}Posibles problemas:${NC}"
    echo "  1. API Token sin permisos correctos"
    echo "  2. Zone ID incorrecto"
    echo "  3. Token expirado o revocado"
    echo ""
    echo "Por favor, verifica tus credenciales y vuelve a intentar."
    exit 1
fi

echo ""

# Paso 4: Guardar configuración
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Paso 4: Guardar Configuración${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Crear backup de bashrc
cp ~/.bashrc ~/.bashrc.backup_$(date +%Y%m%d_%H%M%S)

# Verificar si ya existe configuración anterior
if grep -q "CLOUDFLARE_API_TOKEN" ~/.bashrc; then
    echo -e "${YELLOW}Ya existe una configuración de Cloudflare en ~/.bashrc${NC}"
    read -p "$(echo -e ${YELLOW}¿Sobrescribir? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remover configuración anterior
        sed -i '/CLOUDFLARE_API_TOKEN/d' ~/.bashrc
        sed -i '/CLOUDFLARE_ZONE_ID/d' ~/.bashrc
        sed -i '/CLOUDFLARE_DOMAIN/d' ~/.bashrc
    else
        echo -e "${YELLOW}Usando configuración manual...${NC}"
    fi
fi

# Agregar nueva configuración
cat >> ~/.bashrc << EOF

# Cloudflare DNS Configuration for SaaS Factory
export CLOUDFLARE_API_TOKEN="${API_TOKEN}"
export CLOUDFLARE_ZONE_ID="${ZONE_ID}"
export CLOUDFLARE_DOMAIN="emanuel-server.com"
EOF

echo -e "${GREEN}✅ Configuración guardada en ~/.bashrc${NC}"
echo ""

# Cargar configuración en sesión actual
export CLOUDFLARE_API_TOKEN="${API_TOKEN}"
export CLOUDFLARE_ZONE_ID="${ZONE_ID}"
export CLOUDFLARE_DOMAIN="emanuel-server.com"

# Paso 5: Test final
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Paso 5: Test de DNS${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "$(echo -e ${CYAN}¿Quieres crear un subdominio de prueba? [Y/n]:${NC} )" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    TEST_SUBDOMAIN="test-saas-$(date +%s)"
    TEST_IP=$(hostname -I | awk '{print $1}')

    echo ""
    echo -e "${CYAN}Creando subdominio de prueba:${NC}"
    echo -e "  ${GREEN}${TEST_SUBDOMAIN}.emanuel-server.com${NC} → ${GREEN}${TEST_IP}${NC}"
    echo ""

    # Usar el script de DNS
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$SCRIPT_DIR/cloudflare-dns.sh" ]; then
        if "$SCRIPT_DIR/cloudflare-dns.sh" create "$TEST_SUBDOMAIN" "$TEST_IP"; then
            echo ""
            echo -e "${GREEN}✅ Subdominio de prueba creado exitosamente!${NC}"
            echo ""

            read -p "$(echo -e ${YELLOW}¿Eliminar el subdominio de prueba? [Y/n]:${NC} )" -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                "$SCRIPT_DIR/cloudflare-dns.sh" delete "$TEST_SUBDOMAIN"
                echo -e "${GREEN}✅ Subdominio de prueba eliminado${NC}"
            fi
        else
            echo ""
            echo -e "${RED}❌ Error al crear subdominio de prueba${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Script de Cloudflare DNS no encontrado${NC}"
    fi
fi

# Resumen final
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Configuración Completa${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Variables configuradas:${NC}"
echo -e "  ${GREEN}CLOUDFLARE_API_TOKEN${NC} = ${API_TOKEN:0:10}...${API_TOKEN: -4}"
echo -e "  ${GREEN}CLOUDFLARE_ZONE_ID${NC}   = ${ZONE_ID}"
echo -e "  ${GREEN}CLOUDFLARE_DOMAIN${NC}    = emanuel-server.com"
echo ""
echo -e "${CYAN}Para usar en nuevas terminales:${NC}"
echo -e "  ${YELLOW}source ~/.bashrc${NC}"
echo ""
echo -e "${CYAN}Ahora puedes usar SaaS Factory con DNS:${NC}"
echo -e "  ${YELLOW}saas-factory mi-app mi_app_db --dns${NC}"
echo ""
echo -e "${CYAN}Comandos útiles:${NC}"
echo -e "  ${YELLOW}./scripts/cloudflare-dns.sh list${NC}              # Listar subdominios"
echo -e "  ${YELLOW}./scripts/cloudflare-dns.sh create app IP${NC}     # Crear subdominio"
echo -e "  ${YELLOW}./scripts/cloudflare-dns.sh delete app${NC}        # Eliminar subdominio"
echo ""
echo -e "${GREEN}🌐 ¡Listo para crear subdominios automáticamente!${NC}"
echo ""
