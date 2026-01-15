#!/bin/bash

# Cloudflare DNS Manager para SaaS Factory
# Crea y gestiona subdominios automáticamente

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Función para mostrar uso
show_usage() {
    echo -e "${CYAN}Uso: $0 <comando> <subdominio> [opciones]${NC}"
    echo ""
    echo "Comandos:"
    echo "  create <subdominio> <ip>     - Crear registro DNS A"
    echo "  delete <subdominio>           - Eliminar registro DNS"
    echo "  list                          - Listar todos los registros"
    echo "  verify <subdominio>           - Verificar si existe el subdominio"
    echo ""
    echo "Ejemplos:"
    echo "  $0 create mi-app 192.168.1.100"
    echo "  $0 delete mi-app"
    echo "  $0 verify mi-app"
}

# Verificar que existan las credenciales de Cloudflare
check_credentials() {
    if [ -z "$CLOUDFLARE_API_TOKEN" ] && [ -z "$CLOUDFLARE_API_KEY" ]; then
        echo -e "${RED}❌ Error: Variables de Cloudflare no configuradas${NC}"
        echo ""
        echo -e "${YELLOW}Configura tus credenciales de Cloudflare:${NC}"
        echo ""
        echo "# Opción 1: API Token (Recomendado)"
        echo "export CLOUDFLARE_API_TOKEN='tu_api_token'"
        echo "export CLOUDFLARE_ZONE_ID='tu_zone_id'"
        echo ""
        echo "# Opción 2: API Key"
        echo "export CLOUDFLARE_API_KEY='tu_api_key'"
        echo "export CLOUDFLARE_EMAIL='tu_email@example.com'"
        echo "export CLOUDFLARE_ZONE_ID='tu_zone_id'"
        echo ""
        echo -e "${CYAN}Para obtener estas credenciales:${NC}"
        echo "1. Ve a: https://dash.cloudflare.com/profile/api-tokens"
        echo "2. Crea un API Token con permisos de DNS Edit"
        echo "3. El Zone ID lo encuentras en el dashboard de tu dominio"
        exit 1
    fi

    if [ -z "$CLOUDFLARE_ZONE_ID" ]; then
        echo -e "${RED}❌ Error: CLOUDFLARE_ZONE_ID no configurado${NC}"
        exit 1
    fi

    if [ -z "$CLOUDFLARE_DOMAIN" ]; then
        export CLOUDFLARE_DOMAIN="emanuel-server.com"
    fi
}

# Hacer petición a Cloudflare API
cf_api_call() {
    local method=$1
    local endpoint=$2
    local data=$3

    if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
        # Usar API Token
        if [ -n "$data" ]; then
            curl -s -X "$method" "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}${endpoint}" \
                -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
                -H "Content-Type: application/json" \
                -d "$data"
        else
            curl -s -X "$method" "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}${endpoint}" \
                -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
                -H "Content-Type: application/json"
        fi
    else
        # Usar API Key
        if [ -n "$data" ]; then
            curl -s -X "$method" "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}${endpoint}" \
                -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
                -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
                -H "Content-Type: application/json" \
                -d "$data"
        else
            curl -s -X "$method" "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}${endpoint}" \
                -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
                -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
                -H "Content-Type: application/json"
        fi
    fi
}

# Crear registro DNS A
create_dns_record() {
    local subdomain=$1
    local ip=$2
    local full_domain="${subdomain}.${CLOUDFLARE_DOMAIN}"

    echo -e "${BLUE}Creando registro DNS...${NC}"
    echo -e "${CYAN}Subdominio: ${GREEN}${full_domain}${NC}"
    echo -e "${CYAN}IP: ${GREEN}${ip}${NC}"

    # Verificar si ya existe
    local existing=$(cf_api_call "GET" "/dns_records?name=${full_domain}")
    local record_id=$(echo "$existing" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$record_id" ]; then
        echo -e "${YELLOW}⚠️  El registro ya existe. Actualizando...${NC}"

        local data=$(cat <<EOF
{
  "type": "A",
  "name": "${subdomain}",
  "content": "${ip}",
  "ttl": 1,
  "proxied": false
}
EOF
)
        local response=$(cf_api_call "PUT" "/dns_records/${record_id}" "$data")
    else
        local data=$(cat <<EOF
{
  "type": "A",
  "name": "${subdomain}",
  "content": "${ip}",
  "ttl": 1,
  "proxied": false
}
EOF
)
        local response=$(cf_api_call "POST" "/dns_records" "$data")
    fi

    # Verificar resultado
    if echo "$response" | grep -q '"success":true'; then
        echo -e "${GREEN}✅ Registro DNS creado/actualizado exitosamente${NC}"
        echo -e "${CYAN}URL: ${GREEN}http://${full_domain}${NC}"
        return 0
    else
        echo -e "${RED}❌ Error al crear registro DNS${NC}"
        echo "$response" | grep -o '"message":"[^"]*"' | cut -d'"' -f4
        return 1
    fi
}

# Eliminar registro DNS
delete_dns_record() {
    local subdomain=$1
    local full_domain="${subdomain}.${CLOUDFLARE_DOMAIN}"

    echo -e "${BLUE}Eliminando registro DNS...${NC}"
    echo -e "${CYAN}Subdominio: ${YELLOW}${full_domain}${NC}"

    # Buscar el registro
    local existing=$(cf_api_call "GET" "/dns_records?name=${full_domain}")
    local record_id=$(echo "$existing" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -z "$record_id" ]; then
        echo -e "${YELLOW}⚠️  El registro no existe${NC}"
        return 1
    fi

    # Eliminar
    local response=$(cf_api_call "DELETE" "/dns_records/${record_id}")

    if echo "$response" | grep -q '"success":true'; then
        echo -e "${GREEN}✅ Registro DNS eliminado exitosamente${NC}"
        return 0
    else
        echo -e "${RED}❌ Error al eliminar registro DNS${NC}"
        return 1
    fi
}

# Listar registros DNS
list_dns_records() {
    echo -e "${BLUE}Listando registros DNS para ${CLOUDFLARE_DOMAIN}...${NC}"
    echo ""

    local response=$(cf_api_call "GET" "/dns_records?per_page=100")

    # Parsear y mostrar registros
    echo "$response" | grep -o '"name":"[^"]*","type":"[^"]*","content":"[^"]*"' | while read -r line; do
        local name=$(echo "$line" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
        local type=$(echo "$line" | grep -o '"type":"[^"]*"' | cut -d'"' -f4)
        local content=$(echo "$line" | grep -o '"content":"[^"]*"' | cut -d'"' -f4)
        echo -e "${CYAN}${name}${NC} (${type}) → ${GREEN}${content}${NC}"
    done
}

# Verificar si existe un subdominio
verify_subdomain() {
    local subdomain=$1
    local full_domain="${subdomain}.${CLOUDFLARE_DOMAIN}"

    local existing=$(cf_api_call "GET" "/dns_records?name=${full_domain}")
    local record_id=$(echo "$existing" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$record_id" ]; then
        echo -e "${GREEN}✅ El subdominio existe${NC}"
        local content=$(echo "$existing" | grep -o '"content":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo -e "${CYAN}Apunta a: ${GREEN}${content}${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  El subdominio no existe${NC}"
        return 1
    fi
}

# Main
main() {
    check_credentials

    case "$1" in
        create)
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo -e "${RED}Error: Faltan argumentos${NC}"
                show_usage
                exit 1
            fi
            create_dns_record "$2" "$3"
            ;;
        delete)
            if [ -z "$2" ]; then
                echo -e "${RED}Error: Falta el subdominio${NC}"
                show_usage
                exit 1
            fi
            delete_dns_record "$2"
            ;;
        list)
            list_dns_records
            ;;
        verify)
            if [ -z "$2" ]; then
                echo -e "${RED}Error: Falta el subdominio${NC}"
                show_usage
                exit 1
            fi
            verify_subdomain "$2"
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

# Si el script no se está "sourcing", ejecutar main
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
