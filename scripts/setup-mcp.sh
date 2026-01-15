#!/bin/bash

# Setup MCP Servers para Proyecto SaaS Factory
# Configura Model Context Protocol para trabajar con Claude/IA

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="$1"
DB_NAME="$2"

# Banner
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║         🔌 MCP Setup - SaaS Factory              ║
║                                                   ║
║    Model Context Protocol Configuration          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar argumentos
if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Error: Debes proporcionar el directorio del proyecto${NC}"
    echo -e "${YELLOW}Uso: $0 <directorio-proyecto> <nombre-db>${NC}"
    echo -e "${CYAN}Ejemplo: $0 mi-app mi_app_db${NC}"
    exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Error: El directorio '$PROJECT_DIR' no existe${NC}"
    exit 1
fi

if [ -z "$DB_NAME" ]; then
    echo -e "${YELLOW}⚠️  No se proporcionó nombre de DB. Usando nombre genérico.${NC}"
    DB_NAME="${PROJECT_DIR//-/_}_db"
fi

echo -e "${BLUE}📁 Proyecto: ${GREEN}$PROJECT_DIR${NC}"
echo -e "${BLUE}🗄️  Base de datos: ${GREEN}$DB_NAME${NC}"
echo ""

# Copiar template .mcp.json
echo -e "${BLUE}[1/4]${NC} Copiando configuración MCP..."

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/template"

if [ ! -f "$TEMPLATE_DIR/.mcp.json" ]; then
    echo -e "${RED}❌ Error: Template .mcp.json no encontrado${NC}"
    exit 1
fi

# Reemplazar DB_NAME en el template
sed "s/{{DB_NAME}}/$DB_NAME/g" "$TEMPLATE_DIR/.mcp.json" > "$PROJECT_DIR/.mcp.json"

echo -e "${GREEN}✅ Archivo .mcp.json creado${NC}"

# Copiar .claudeignore
echo -e "${BLUE}[2/5]${NC} Copiando .claudeignore..."

if [ -f "$TEMPLATE_DIR/.claudeignore" ]; then
    cp "$TEMPLATE_DIR/.claudeignore" "$PROJECT_DIR/.claudeignore"
    echo -e "${GREEN}✅ Archivo .claudeignore creado${NC}"
else
    echo -e "${YELLOW}⚠️  Template .claudeignore no encontrado, omitiendo...${NC}"
fi

# Copiar CLAUDE.md
echo -e "${BLUE}[3/5]${NC} Copiando CLAUDE.md..."

if [ -f "$TEMPLATE_DIR/CLAUDE.md" ]; then
    sed "s/{{PROJECT_NAME}}/$PROJECT_DIR/g; s/{{DB_NAME}}/$DB_NAME/g" "$TEMPLATE_DIR/CLAUDE.md" > "$PROJECT_DIR/CLAUDE.md"
    echo -e "${GREEN}✅ Archivo CLAUDE.md creado${NC}"
else
    echo -e "${YELLOW}⚠️  Template CLAUDE.md no encontrado, omitiendo...${NC}"
fi

# Copiar GEMINI.md
echo -e "${BLUE}[4/5]${NC} Copiando GEMINI.md..."

if [ -f "$TEMPLATE_DIR/GEMINI.md" ]; then
    sed "s/{{PROJECT_NAME}}/$PROJECT_DIR/g; s/{{DB_NAME}}/$DB_NAME/g" "$TEMPLATE_DIR/GEMINI.md" > "$PROJECT_DIR/GEMINI.md"
    echo -e "${GREEN}✅ Archivo GEMINI.md creado${NC}"
else
    echo -e "${YELLOW}⚠️  Template GEMINI.md no encontrado, omitiendo...${NC}"
fi

# Verificar npx disponible
echo -e "${BLUE}[5/5]${NC} Verificando dependencias..."

if ! command -v npx &> /dev/null; then
    echo -e "${RED}❌ Error: npx no encontrado${NC}"
    echo -e "${YELLOW}Instala Node.js primero${NC}"
    exit 1
fi

echo -e "${GREEN}✅ npx disponible${NC}"

# Crear archivo de README para MCP
echo -e "${BLUE}[6/6]${NC} Creando documentación MCP..."

cat > "$PROJECT_DIR/MCP_SETUP.md" << 'EOFMD'
# 🔌 MCP (Model Context Protocol) Configurado

Este proyecto tiene configurados los siguientes MCP servers para trabajar con Claude y otros agentes IA.

## 🛠️ Servidores MCP Configurados

### 1. Filesystem Server ✅
**Propósito:** Acceso a archivos del proyecto
**Comando:** `@modelcontextprotocol/server-filesystem`

**Capacidades:**
- Leer archivos
- Listar directorios
- Buscar archivos
- Obtener información de archivos

### 2. PostgreSQL Server ✅
**Propósito:** Acceso a la base de datos
**Comando:** `@modelcontextprotocol/server-postgres`
**Conexión:** PostgreSQL en Docker (puerto 5434)

**Capacidades:**
- Ejecutar queries SQL
- Listar tablas y schemas
- Ver estructura de DB
- Ejecutar migraciones

### 3. Git Server ✅
**Propósito:** Gestión de Git
**Comando:** `@modelcontextprotocol/server-git`

**Capacidades:**
- Ver status de Git
- Crear commits
- Ver diff
- Gestionar branches

### 4. GitHub Server (Deshabilitado por defecto)
**Propósito:** Integración con GitHub
**Comando:** `@modelcontextprotocol/server-github`
**Estado:** Requiere token de acceso personal

**Para habilitar:**
1. Crear GitHub Personal Access Token
2. Editar `.mcp.json`
3. Agregar token en `env.GITHUB_PERSONAL_ACCESS_TOKEN`
4. Cambiar `disabled: false`

## 🚀 Uso con Claude

Una vez configurado, Claude puede:

```
# Ejemplos de prompts que usan MCP:

"Muéstrame la estructura de la base de datos"
→ Usa PostgreSQL MCP server

"¿Qué archivos hay en src/components?"
→ Usa Filesystem MCP server

"Crea un commit con los cambios actuales"
→ Usa Git MCP server

"Lista los issues abiertos en GitHub"
→ Usa GitHub MCP server (si está habilitado)
```

## 📝 Configuración

Los archivos de configuración son:

- `.mcp.json` - Configuración de MCP servers
- `.claudeignore` - Archivos a ignorar por Claude

## 🔧 Personalización

### Agregar más MCP servers

Edita `.mcp.json` y agrega nuevos servers:

```json
{
  "mcpServers": {
    "tu-servidor": {
      "command": "npx",
      "args": ["-y", "@namespace/server-name"],
      "disabled": false
    }
  }
}
```

### MCP Servers Disponibles

Explora más en: https://github.com/modelcontextprotocol/servers

- `@modelcontextprotocol/server-slack` - Slack
- `@modelcontextprotocol/server-puppeteer` - Browser automation
- `@modelcontextprotocol/server-memory` - Persistent memory
- Y muchos más...

## ✅ Verificación

Para verificar que MCP está funcionando:

1. Abre el proyecto con Claude
2. Pregunta: "¿Qué MCP servers tienes disponibles?"
3. Claude debería listar los servers configurados

## 📚 Referencias

- [MCP Documentation](https://modelcontextprotocol.io)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [Claude MCP Guide](https://docs.anthropic.com/claude/docs/model-context-protocol)

---

**Configurado automáticamente por SaaS Factory** 🏭
EOFMD

echo -e "${GREEN}✅ Documentación MCP_SETUP.md creada${NC}"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                   ║${NC}"
echo -e "${GREEN}║           ✅ MCP Setup Completado                 ║${NC}"
echo -e "${GREEN}║                                                   ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📁 Archivos creados:${NC}"
echo -e "  ${GREEN}✓${NC} $PROJECT_DIR/.mcp.json"
echo -e "  ${GREEN}✓${NC} $PROJECT_DIR/.claudeignore"
echo -e "  ${GREEN}✓${NC} $PROJECT_DIR/CLAUDE.md"
echo -e "  ${GREEN}✓${NC} $PROJECT_DIR/GEMINI.md"
echo -e "  ${GREEN}✓${NC} $PROJECT_DIR/MCP_SETUP.md"
echo ""
echo -e "${CYAN}🔌 MCP Servers configurados:${NC}"
echo -e "  ${GREEN}✓${NC} Filesystem Server"
echo -e "  ${GREEN}✓${NC} PostgreSQL Server (DB: $DB_NAME)"
echo -e "  ${GREEN}✓${NC} Git Server"
echo -e "  ${YELLOW}○${NC} GitHub Server (deshabilitado)"
echo ""
echo -e "${BLUE}📖 Para más información, lee: $PROJECT_DIR/MCP_SETUP.md${NC}"
echo ""
echo -e "${YELLOW}💡 Próximo paso:${NC}"
echo -e "   ${CYAN}Abre el proyecto con Claude y pregunta:${NC}"
echo -e "   ${GREEN}\"¿Qué MCP servers tienes disponibles?\"${NC}"
echo ""
