# 🔌 MCP (Model Context Protocol) - Configuración

**SaaS Factory** configura automáticamente Model Context Protocol para que puedas trabajar con Claude y otros agentes IA de forma más eficiente.

---

## ⚡ Quick Start

Los proyectos generados con SaaS Factory incluyen automáticamente:

```bash
saas-factory mi-app mi_db --dns --create-db
# ✅ MCP configurado automáticamente
```

Para deshabilitar MCP:
```bash
saas-factory mi-app mi_db --no-mcp
```

---

## 🛠️ MCP Servers Configurados

Cada proyecto incluye estos servidores MCP:

### 1. Filesystem Server ✅

**Propósito:** Acceso completo a los archivos del proyecto

**Capacidades:**
- Leer archivos y directorios
- Listar contenidos
- Buscar archivos por patrón
- Obtener información de archivos

**Uso con Claude:**
```
"Muéstrame todos los archivos en src/components"
"Lee el contenido de app/page.tsx"
"Busca archivos que contengan 'Button'"
```

### 2. PostgreSQL Server ✅

**Propósito:** Acceso directo a la base de datos PostgreSQL

**Configuración:**
- Conecta al contenedor Docker: `jscamp-infojobs-strapi-db`
- Puerto: 5434
- Usuario: strapi
- Base de datos: Tu DB específica del proyecto

**Capacidades:**
- Ejecutar queries SQL
- Listar tablas y schemas
- Ver estructura de la base de datos
- Ejecutar migraciones
- Consultar datos

**Uso con Claude:**
```
"Muéstrame todas las tablas de la base de datos"
"Ejecuta SELECT * FROM User LIMIT 10"
"Describe la estructura de la tabla Project"
"¿Cuántos usuarios hay en la base de datos?"
```

### 3. Git Server ✅

**Propósito:** Gestión completa de Git

**Capacidades:**
- Ver status del repositorio
- Crear commits
- Ver diffs
- Gestionar branches
- Ver histórico
- Gestionar remotes

**Uso con Claude:**
```
"Muéstrame el estado de Git"
"Crea un commit con el mensaje 'feat: add login'"
"¿Qué archivos han cambiado?"
"Muéstrame el diff de los cambios actuales"
```

### 4. GitHub Server ✅

**Propósito:** Integración con GitHub

**Estado:** Habilitado (token configurado)

**Capacidades:**
- Listar issues y PRs
- Crear issues
- Comentar en PRs
- Ver información del repositorio
- Gestionar labels

**Uso con Claude:**
```
"Lista los issues abiertos"
"Crea un issue para reportar un bug"
"Muéstrame los últimos PRs"
```

### 5. n8n Server ✅

**Propósito:** Integración con n8n workflows

**Configuración:**
- URL: `http://localhost:5678/api/v1`
- API Key: Configurada automáticamente

**Capacidades:**
- Listar workflows
- Ejecutar workflows
- Ver ejecuciones
- Gestionar credenciales
- Activar/desactivar workflows

**Uso con Claude:**
```
"Muéstrame todos los workflows de n8n"
"Ejecuta el workflow 'backup-diario'"
"¿Cuáles workflows están activos?"
"Muéstrame las últimas ejecuciones del workflow X"
```

---

## 📁 Archivos de Configuración

Cada proyecto genera estos archivos:

### `.mcp.json`

Configuración principal de MCP:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "postgres": {
      "command": "docker",
      "args": [
        "exec", "-i", "jscamp-infojobs-strapi-db",
        "npx", "-y", "@modelcontextprotocol/server-postgres",
        "postgresql://strapi:supersecretstrapi@localhost:5432/mi_db"
      ]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"]
    }
  }
}
```

### `.claudeignore`

Archivos que Claude debe ignorar:

```
node_modules/
.next/
.env.local
*.log
dist/
build/
```

### `MCP_SETUP.md`

Documentación específica del proyecto sobre MCP.

---

## 🚀 Uso con Claude

### Abrir Proyecto

```bash
# Opción 1: Desde el directorio del proyecto
cd mi-app
claude .

# Opción 2: Especificar ruta
claude /home/epardo/mi-app
```

### Verificar MCP

Una vez en Claude, pregunta:

```
"¿Qué MCP servers tienes disponibles?"
```

Claude responderá con la lista de servers configurados.

### Ejemplos de Uso

**Explorar el Proyecto:**
```
"Muéstrame la estructura del proyecto"
"Lee el schema de Prisma"
"¿Qué componentes tengo en /components/ui?"
```

**Trabajar con Base de Datos:**
```
"Muéstrame todas las tablas"
"Crea un usuario de prueba en la tabla User"
"¿Cuántos proyectos hay con status ACTIVE?"
```

**Gestión de Git:**
```
"Muéstrame los cambios actuales"
"Crea un commit con todos los cambios"
"¿En qué branch estoy?"
```

**Desarrollo:**
```
"Lee app/page.tsx y crea un componente Hero similar"
"Agrega un campo 'description' a la tabla Project"
"Crea una migración de Prisma para el cambio"
```

---

## 🔧 Personalización

### Agregar Más MCP Servers

Edita `.mcp.json` en tu proyecto:

```json
{
  "mcpServers": {
    // ... servers existentes ...

    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "tu_token"
      }
    },

    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

### MCP Servers Disponibles

Repositorio oficial: https://github.com/modelcontextprotocol/servers

**Populares:**
- `@modelcontextprotocol/server-slack` - Slack integration
- `@modelcontextprotocol/server-puppeteer` - Browser automation
- `@modelcontextprotocol/server-memory` - Persistent memory
- `@modelcontextprotocol/server-brave-search` - Web search
- `@modelcontextprotocol/server-sqlite` - SQLite databases
- Y muchos más...

### Deshabilitar un Server

Cambia `disabled` a `true`:

```json
"github": {
  "disabled": true
}
```

---

## 📊 Casos de Uso

### Caso 1: Desarrollo Guiado por IA

```bash
# 1. Crear proyecto
saas-factory crm-acme acme_db --dns --create-db

# 2. Abrir con Claude
cd crm-acme
claude .

# 3. Desarrollar con IA
# Claude tiene acceso a:
# - Archivos (filesystem server)
# - Base de datos (postgres server)
# - Git (git server)

# Puedes pedirle:
"Crea un CRUD completo para clientes"
"Agrega autenticación con NextAuth"
"Optimiza las queries de la página de dashboard"
```

### Caso 2: Debugging con IA

```
"Muéstrame los logs de error en el servidor"
"¿Por qué falla la query de usuarios?"
"Compara el schema de Prisma con las tablas reales"
```

### Caso 3: Migraciones de DB

```
"Muéstrame el schema actual de la base de datos"
"Agrega un campo 'avatar' a la tabla User"
"Crea la migración de Prisma"
"Ejecuta la migración"
```

---

## 🔍 Troubleshooting

### MCP Servers no aparecen

**Verificar:**
```bash
# 1. Archivo .mcp.json existe
ls -la .mcp.json

# 2. npx disponible
which npx

# 3. Abrir proyecto con Claude desde el directorio correcto
cd mi-app
claude .
```

### PostgreSQL MCP no funciona

**Verificar:**
```bash
# 1. Contenedor Docker corriendo
docker ps | grep postgres

# 2. Base de datos existe
./scripts/postgres-helper.sh verify mi_db

# 3. Connection string correcta en .mcp.json
cat .mcp.json | grep postgresql
```

### Git MCP no funciona

**Verificar:**
```bash
# 1. Repositorio Git inicializado
git status

# 2. npx puede ejecutar el server
npx -y @modelcontextprotocol/server-git
```

---

## 🔒 Seguridad

### Mejores Prácticas

1. **No compartir tokens**
   - `.mcp.json` puede contener tokens sensibles
   - Agregar a `.gitignore` si incluyes tokens

2. **Scope mínimo**
   - Solo habilita servers que necesites
   - GitHub server solo si realmente lo usas

3. **Tokens con permisos mínimos**
   - GitHub: Solo scopes necesarios
   - Slack: Solo canales específicos

4. **Review de comandos**
   - Claude mostrará qué va a ejecutar
   - Revisa antes de aprobar

### Agregar .mcp.json a .gitignore

Si agregas tokens sensibles:

```bash
echo ".mcp.json" >> .gitignore
```

---

## 📚 Referencias

### Documentación Oficial

- [MCP Documentation](https://modelcontextprotocol.io)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [Claude MCP Guide](https://docs.anthropic.com/claude/docs/model-context-protocol)
- [MCP Specification](https://spec.modelcontextprotocol.io)

### Scripts SaaS Factory

- `scripts/setup-mcp.sh` - Setup automático de MCP
- `template/.mcp.json` - Template de configuración
- `template/.claudeignore` - Template de archivos ignorados

---

## ✅ Resumen

**MCP está configurado automáticamente** en todos los proyectos SaaS Factory.

**Servers incluidos:**
- ✅ Filesystem - Acceso a archivos
- ✅ PostgreSQL - Acceso a DB (puerto 5434)
- ✅ Git - Gestión de Git
- ✅ GitHub - Issues, PRs, repositorios
- ✅ n8n - Workflows y automatizaciones

**Para usar:**
```bash
cd mi-proyecto
claude .
# Pregunta: "¿Qué MCP servers tienes disponibles?"
```

**Para personalizar:**
- Editar `.mcp.json`
- Agregar más servers del repositorio oficial
- Configurar tokens para servers opcionales

**MCP hace que Claude sea mucho más poderoso para desarrollo.** 🚀

---

**Última actualización:** 2026-01-15
**Estado:** ✅ CONFIGURADO AUTOMÁTICAMENTE
