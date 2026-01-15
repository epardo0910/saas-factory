# 🤖 CLAUDE.md - Contexto del Proyecto

## Información del Proyecto

**Nombre:** {{PROJECT_NAME}}
**Stack:** Next.js 14 + PostgreSQL + NextAuth.js + TypeScript
**Generado con:** SaaS Factory

---

## Estructura del Proyecto

```
{{PROJECT_NAME}}/
├── src/
│   └── app/              # App Router de Next.js
│       ├── (auth)/       # Rutas de autenticación (login, signup)
│       ├── (dashboard)/  # Rutas protegidas (dashboard, projects)
│       └── api/          # API routes
├── components/           # Componentes React
│   └── ui/               # Componentes UI reutilizables
├── lib/                  # Librerías y utilidades
│   ├── db/               # Cliente Prisma
│   └── validations/      # Schemas Zod
├── prisma/               # Schema y migraciones de DB
└── .mcp.json             # Configuración MCP servers
```

---

## Base de Datos

- **ORM:** Prisma
- **DB:** PostgreSQL (puerto 5434 Docker, 5432 local)
- **Modelos principales:** User, Project, Task

### Comandos útiles:
```bash
npx prisma studio          # Ver DB en browser
npx prisma migrate dev     # Crear migración
npx prisma generate        # Regenerar cliente
```

---

## Autenticación

- **Librería:** NextAuth.js v5
- **Provider:** Credentials (email/password)
- **Middleware:** Protege rutas /dashboard/*

---

## MCP Servers Disponibles

Este proyecto tiene configurados estos MCP servers en `.mcp.json`:
- **filesystem** - Acceso a archivos
- **postgres** - Acceso a base de datos
- **git** - Gestión de repositorio
- **github** - Issues, PRs
- **n8n** - Automatizaciones
- **brave-search** - Búsquedas web
- **memory** - Persistencia de contexto
- **puppeteer** - Automatización de browser

---

## Instrucciones para Claude

1. **Usa Prisma** para todas las operaciones de base de datos
2. **Usa Zod** para validación de datos (schemas en lib/validations/)
3. **Usa los componentes UI** existentes en components/ui/
4. **Sigue el patrón App Router** de Next.js 14
5. **El puerto de la app** está en la variable PORT del .env.local

---

**Generado por SaaS Factory**
