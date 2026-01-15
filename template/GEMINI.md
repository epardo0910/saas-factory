# 🤖 GEMINI.md - Contexto del Proyecto para Antigravity

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
│       ├── (auth)/       # Login, Signup, Forgot Password
│       ├── (dashboard)/  # Dashboard, Projects, Team, Settings
│       └── api/          # API routes (auth, etc.)
├── components/           # Componentes React
│   └── ui/               # Button, Input, Label
├── lib/                  # Librerías
│   ├── db/               # Prisma client
│   └── validations/      # Zod schemas
├── prisma/               # Schema y migrations
└── .mcp.json             # MCP servers config
```

---

## Base de Datos PostgreSQL

- **ORM:** Prisma
- **Puerto Docker:** 5434
- **Usuario:** strapi
- **DB:** {{DB_NAME}}

### Modelos Prisma:
- `User` - Usuarios con roles (OWNER, MANAGER, DEVELOPER, CLIENT)
- `Project` - Proyectos
- `Task` - Tareas (TODO, IN_PROGRESS, DONE)
- `ProjectMember` - Miembros de proyectos

### Comandos:
```bash
npx prisma studio          # Ver datos
npx prisma migrate dev     # Migrar
```

---

## Autenticación NextAuth.js

- Configuración en `auth.ts` y `auth.config.ts`
- Middleware en `middleware.ts`
- Provider: Credentials (email/password con bcrypt)

---

## MCP Servers (.mcp.json)

Tienes acceso a:
1. **filesystem** - Leer/escribir archivos
2. **postgres** - Queries SQL directos
3. **git** - Commits, branches, diffs
4. **github** - Issues y PRs
5. **n8n** - Ejecutar workflows
6. **brave-search** - Buscar en internet
7. **memory** - Guardar contexto
8. **puppeteer** - Controlar browser

---

## Instrucciones para Gemini

1. **Prisma** para DB, no SQL directo
2. **Zod** para validación (lib/validations/)
3. **Componentes UI** en components/ui/
4. **App Router** pattern (not Pages Router)
5. **Server Components** por defecto, "use client" solo cuando necesario

---

## Puerto de la Aplicación

El puerto asignado está en `.env.local` variable `PORT`.
Usar `npm run dev` para desarrollo.

---

**SaaS Factory Project**
