#!/bin/bash

# PostgreSQL Helper para SaaS Factory
# Automatiza la creación y gestión de bases de datos en contenedor Docker

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuración del contenedor PostgreSQL
POSTGRES_CONTAINER="jscamp-infojobs-strapi-db"
POSTGRES_USER="strapi"
POSTGRES_PASSWORD="supersecretstrapi"
POSTGRES_PORT="5434"

# Función para verificar si el contenedor existe y está corriendo
check_postgres_container() {
    if ! docker ps --format '{{.Names}}' | grep -q "^${POSTGRES_CONTAINER}$"; then
        echo -e "${RED}❌ Error: Contenedor PostgreSQL '${POSTGRES_CONTAINER}' no está corriendo${NC}"
        echo -e "${YELLOW}Contenedores PostgreSQL disponibles:${NC}"
        docker ps --format '{{.Names}}' | grep postgres || echo "No hay contenedores PostgreSQL corriendo"
        return 1
    fi
    return 0
}

# Crear base de datos
create_database() {
    local db_name=$1

    if [ -z "$db_name" ]; then
        echo -e "${RED}❌ Error: Debes proporcionar un nombre de base de datos${NC}"
        return 1
    fi

    echo -e "${BLUE}🗄️  Creando base de datos: ${CYAN}${db_name}${NC}"

    # Verificar contenedor
    if ! check_postgres_container; then
        return 1
    fi

    # Verificar si la base de datos ya existe
    local exists=$(docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$db_name'" 2>/dev/null)

    if [ "$exists" = "1" ]; then
        echo -e "${YELLOW}⚠️  La base de datos '${db_name}' ya existe${NC}"
        return 0
    fi

    # Crear la base de datos
    if docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d postgres -c "CREATE DATABASE $db_name;" 2>&1 | grep -q "CREATE DATABASE"; then
        echo -e "${GREEN}✅ Base de datos '${db_name}' creada exitosamente${NC}"
        echo -e "${CYAN}Connection string: ${NC}postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_PORT}/${db_name}"
        return 0
    else
        echo -e "${RED}❌ Error al crear la base de datos${NC}"
        return 1
    fi
}

# Eliminar base de datos
drop_database() {
    local db_name=$1

    if [ -z "$db_name" ]; then
        echo -e "${RED}❌ Error: Debes proporcionar un nombre de base de datos${NC}"
        return 1
    fi

    echo -e "${YELLOW}⚠️  Eliminando base de datos: ${db_name}${NC}"

    # Verificar contenedor
    if ! check_postgres_container; then
        return 1
    fi

    # Terminar conexiones activas
    docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d postgres -c "
        SELECT pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
        WHERE pg_stat_activity.datname = '$db_name'
        AND pid <> pg_backend_pid();
    " 2>/dev/null

    # Eliminar la base de datos
    if docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d postgres -c "DROP DATABASE IF EXISTS $db_name;" 2>&1 | grep -q "DROP DATABASE"; then
        echo -e "${GREEN}✅ Base de datos '${db_name}' eliminada${NC}"
        return 0
    else
        echo -e "${RED}❌ Error al eliminar la base de datos${NC}"
        return 1
    fi
}

# Listar bases de datos
list_databases() {
    echo -e "${BLUE}📊 Listando bases de datos...${NC}"

    if ! check_postgres_container; then
        return 1
    fi

    docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d postgres -c "\l"
}

# Verificar si existe una base de datos
verify_database() {
    local db_name=$1

    if [ -z "$db_name" ]; then
        echo -e "${RED}❌ Error: Debes proporcionar un nombre de base de datos${NC}"
        return 1
    fi

    if ! check_postgres_container; then
        return 1
    fi

    local exists=$(docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$db_name'" 2>/dev/null)

    if [ "$exists" = "1" ]; then
        echo -e "${GREEN}✅ La base de datos '${db_name}' existe${NC}"

        # Mostrar información
        local size=$(docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d postgres -tAc "SELECT pg_size_pretty(pg_database_size('$db_name'))" 2>/dev/null)
        echo -e "${CYAN}Tamaño: ${NC}${size}"

        return 0
    else
        echo -e "${YELLOW}⚠️  La base de datos '${db_name}' no existe${NC}"
        return 1
    fi
}

# Obtener connection string
get_connection_string() {
    local db_name=$1

    if [ -z "$db_name" ]; then
        echo -e "${RED}❌ Error: Debes proporcionar un nombre de base de datos${NC}"
        return 1
    fi

    echo "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_PORT}/${db_name}"
}

# Mostrar información de conexión
show_info() {
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}📊 Información de PostgreSQL${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Contenedor:${NC} $POSTGRES_CONTAINER"
    echo -e "${YELLOW}Usuario:${NC}     $POSTGRES_USER"
    echo -e "${YELLOW}Password:${NC}   $POSTGRES_PASSWORD"
    echo -e "${YELLOW}Puerto:${NC}     $POSTGRES_PORT"
    echo -e "${YELLOW}Host:${NC}       localhost"
    echo ""
    echo -e "${CYAN}Connection String Template:${NC}"
    echo "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_PORT}/{database_name}"
    echo ""
}

# Mostrar uso
show_usage() {
    echo -e "${CYAN}Uso: $0 <comando> [opciones]${NC}"
    echo ""
    echo "Comandos:"
    echo "  create <db_name>      - Crear base de datos"
    echo "  drop <db_name>        - Eliminar base de datos"
    echo "  list                  - Listar todas las bases de datos"
    echo "  verify <db_name>      - Verificar si existe una base de datos"
    echo "  connection <db_name>  - Obtener connection string"
    echo "  info                  - Mostrar información de conexión"
    echo ""
    echo "Ejemplos:"
    echo "  $0 create mi_app_db"
    echo "  $0 list"
    echo "  $0 verify mi_app_db"
    echo "  $0 connection mi_app_db"
    echo "  $0 drop mi_app_db"
}

# Main
main() {
    case "$1" in
        create)
            create_database "$2"
            ;;
        drop)
            drop_database "$2"
            ;;
        list)
            list_databases
            ;;
        verify)
            verify_database "$2"
            ;;
        connection)
            get_connection_string "$2"
            ;;
        info)
            show_info
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
