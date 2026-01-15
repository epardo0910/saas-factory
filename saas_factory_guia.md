# 🏭 SaaS Factory - Guía Completa

## ¿Qué es SaaS Factory?

**SaaS Factory** es un comando CLI personalizado que genera automáticamente la estructura completa de un proyecto SaaS full-stack en segundos, similar al sistema mencionado en el video de YouTube sobre desarrollo agéntico con IA.

## Stack Tecnológico

### ✅ PostgreSQL Directo (en lugar de Supabase)

**Ventajas de usar PostgreSQL self-hosted:**

1. **Control Total**: Tienes control completo sobre tu base de datos sin depender de servicios externos
2. **Sin Vendor Lock-in**: No estás atado a ningún proveedor específico
3. **Mayor Velocidad**: Conexión directa sin latencia de servicios remotos
4. **Cero Costos**: No pagas por servicios de terceros
5. **Ideal para Enterprise**: Mejor para ambientes corporativos y desarrollo local
6. **Sin Limitaciones**: No hay límites de API calls, storage, o funciones

**Componentes del Stack:**

- **Next.js 14**: Framework React con App Router y Server Components
- **PostgreSQL**: Base de datos relacional (tu instalación local)
- **Prisma ORM**: Type-safe database client con migraciones automáticas
- **NextAuth.js v5 (Auth.js)**: Sistema completo de autenticación
- **TypeScript**: Type safety en todo el proyecto
- **Tailwind CSS**: Utility-first CSS framework
- **Radix UI**: Componentes UI accesibles y sin estilos
- **Zod**: Validación de schemas
- **bcryptjs**: Hashing de contraseñas

## Instalación

El script ya está instalado en tu sistema. Para activarlo en la sesión actual:

```bash
source ~/.bashrc
```

## Uso del Comando

### Sintaxis Básica

```bash
saas-factory <nombre-proyecto> [nombre-base-datos]
```

### Ejemplos

```bash
# Ejemplo 1: Nombre simple (crea BD automáticamente)
saas-factory app-gemini
# Crea proyecto: app-gemini
# Crea BD: app_gemini_db

# Ejemplo 2: Con nombre de BD personalizado
saas-factory app-claude claude_database
# Crea proyecto: app-claude
# Crea BD: claude_database

# Ejemplo 3: Para un cliente
saas-factory crm-acme-corp acme_crm_prod
```

## Lo Que Genera Automáticamente

### 1. Estructura de Carpetas Completa

```
tu-proyecto/
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   ├── signup/
│   │   └── forgot-password/
│   ├── (dashboard)/
│   │   ├── dashboard/
│   │   ├── projects/
│   │   ├── team/
│   │   └── settings/
│   └── api/
│       └── auth/[...nextauth]/
├── components/
│   ├── ui/
│   ├── auth/
│   └── dashboard/
├── lib/
│   ├── db/
│   ├── auth/
│   ├── utils/
│   ├── hooks/
│   └── validations/
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── types/
├── public/
└── scripts/
```

### 2. Configuración de Base de Datos (Prisma)

**Schema completo incluido:**

- ✅ Tablas de NextAuth.js (User, Account, Session, VerificationToken)
- ✅ Modelo de aplicación (Projects, Tasks, ProjectMembers)
- ✅ Sistema de roles (OWNER, MANAGER, DEVELOPER, CLIENT)
- ✅ Enums de TypeScript
- ✅ Índices optimizados
- ✅ Relaciones configuradas

### 3. Sistema de Autenticación Completo

- ✅ NextAuth.js v5 configurado
- ✅ Credentials provider
- ✅ Middleware de protección de rutas
- ✅ Schemas de validación con Zod
- ✅ Tipos TypeScript extendidos

### 4. Componentes UI Base

- ✅ Button component con variantes
- ✅ Input component styled
- ✅ Label component
- ✅ Utility function `cn()` para clases Tailwind

### 5. Página Landing con Gradient Mesh

- ✅ Diseño profesional estilo Stripe/Linear
- ✅ Animaciones de gradiente
- ✅ Responsive design
- ✅ Call-to-actions

### 6. Configuración de Desarrollo

- ✅ TypeScript configurado
- ✅ ESLint configurado
- ✅ Tailwind CSS con tema personalizado
- ✅ Variables de entorno (.env.local)
- ✅ Git inicializado con commit inicial
- ✅ Scripts de setup de base de datos

## Flujo de Trabajo Completo

### Paso 1: Generar Proyecto

```bash
saas-factory mi-saas-app
cd mi-saas-app
```

### Paso 2: Configurar Base de Datos

**Opción A: Automático**
```bash
./scripts/setup-database.sh
```

**Opción B: Manual**
```bash
# Crear base de datos
createdb mi_saas_app_db

# Ejecutar migraciones
npx prisma migrate dev --name init

# Ver base de datos
npx prisma studio
```

### Paso 3: Desarrollo

```bash
# Iniciar servidor
npm run dev

# En otra terminal: Ver base de datos
npx prisma studio
```

### Paso 4: Trabajar con IA (Gemini/Claude)

Una vez generado el proyecto base, puedes usar Antigravity u otros editores agénticos:

```bash
# Para Gemini Antigravity
antigravity mi-saas-app

# Para Claude Code
claude mi-saas-app
```

**Prompts sugeridos para la IA:**

```
"Implementa el sistema de login y signup con validación de formularios.
Usa los schemas de Zod que están en lib/validations/auth.ts"

"Crea el dashboard principal mostrando proyectos del usuario autenticado.
Usa el modelo Project de Prisma"

"Implementa un sistema Kanban para las tareas con drag & drop.
Las tareas tienen estados: TODO, IN_PROGRESS, DONE"
```

## Comandos Prisma Útiles

```bash
# Ver datos en navegador (localhost:5555)
npx prisma studio

# Crear nueva migración
npx prisma migrate dev --name add_new_feature

# Formatear schema
npx prisma format

# Resetear BD (⚠️ elimina datos)
npx prisma migrate reset

# Generar cliente de Prisma
npx prisma generate

# Aplicar migraciones en producción
npx prisma migrate deploy
```

## Comparación: Supabase vs PostgreSQL Directo

| Característica | Supabase | PostgreSQL + Prisma |
|----------------|----------|---------------------|
| **Base de Datos** | PostgreSQL managed | PostgreSQL self-hosted |
| **Autenticación** | Supabase Auth | NextAuth.js |
| **ORM/Client** | supabase-js | Prisma |
| **Migraciones** | SQL manual | Prisma Migrate |
| **Type Safety** | Generación de tipos | Prisma Client nativo |
| **Dashboard** | Supabase Dashboard | Prisma Studio |
| **Dependencias** | Servicio externo | Sin dependencias |
| **Costo** | Freemium + Pago | Gratis (solo hosting) |
| **Control** | Limitado | Total |
| **Velocidad** | API remota | Conexión directa |
| **Ideal para** | MVPs rápidos | Enterprise/Producción |

## Estructura del Modelo de Datos

### Tablas de Autenticación (NextAuth.js)

```prisma
model User {
  id            String    @id @default(cuid())
  email         String    @unique
  password      String?
  role          UserRole  @default(CLIENT)
  // ... relaciones
}

model Account { ... }  // OAuth providers
model Session { ... }  // Sesiones activas
model VerificationToken { ... }  // Email verification
```

### Tablas de Aplicación

```prisma
model Project {
  id          String          @id @default(cuid())
  name        String
  status      ProjectStatus   @default(ACTIVE)
  members     ProjectMember[]
  tasks       Task[]
}

model Task {
  status      TaskStatus      @default(TODO)
  priority    TaskPriority    @default(MEDIUM)
  // ... campos
}
```

### Roles del Sistema

- **OWNER**: Dueño de la agencia (acceso total)
- **MANAGER**: Project Manager (gestión de proyectos)
- **DEVELOPER**: Desarrollador (acceso a tareas)
- **CLIENT**: Cliente (vista limitada)

## Configuración para Producción

### Variables de Entorno Necesarias

```env
# PostgreSQL (usar DB remota en producción)
DATABASE_URL="postgresql://user:password@host:5432/dbname"

# NextAuth
NEXTAUTH_URL="https://tudominio.com"
NEXTAUTH_SECRET="tu-secret-super-seguro"

# App
NEXT_PUBLIC_APP_NAME="Tu SaaS"
NEXT_PUBLIC_APP_URL="https://tudominio.com"
```

### Opciones de Base de Datos para Producción

1. **Railway** - PostgreSQL managed con free tier
2. **Vercel Postgres** - Integración directa con Vercel
3. **Neon** - Serverless PostgreSQL
4. **Supabase** - Solo usar PostgreSQL (no sus servicios)
5. **DigitalOcean Managed DB**
6. **Tu propio servidor VPS** (ya tienes PostgreSQL instalado)

### Desplegar en Vercel

```bash
# Instalar Vercel CLI
npm i -g vercel

# Configurar variables de entorno
vercel env add DATABASE_URL
vercel env add NEXTAUTH_SECRET
vercel env add NEXTAUTH_URL

# Desplegar
vercel --prod
```

## Integración con MCP (Model Context Protocol)

Para usar con editores agénticos como Antigravity:

### 1. PostgreSQL MCP Server

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://localhost:5432/tu_db"
      }
    }
  }
}
```

### 2. Playwright MCP (Para testing)

```json
{
  "playwright": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-playwright"]
  }
}
```

### 3. Next.js Dev Server MCP

```json
{
  "nextjs": {
    "command": "node",
    "args": ["path/to/nextjs-mcp-server.js"],
    "env": {
      "PROJECT_PATH": "/home/epardo/tu-proyecto"
    }
  }
}
```

## Ventajas de Este Approach

### 🎯 Para Desarrollo con IA

1. **Estructura Consistente**: La IA conoce exactamente dónde están las cosas
2. **Type Safety**: Prisma + TypeScript = menos errores
3. **Migraciones Automáticas**: La IA puede modificar el schema y aplicar cambios
4. **Validación Built-in**: Zod schemas listos para usar

### 🚀 Para Producción

1. **Escalabilidad**: PostgreSQL es enterprise-grade
2. **Sin Vendor Lock-in**: Puedes mover tu base de datos a cualquier lugar
3. **Performance**: Conexión directa sin middlewares
4. **Costo**: Solo pagas hosting, no servicios adicionales

### 💼 Para Enterprise

1. **Compliance**: Control total sobre datos
2. **Security**: Tu infraestructura, tus reglas
3. **Auditoría**: Logs completos de Prisma
4. **Backups**: Gestión directa de respaldos

## Próximas Mejoras al Script

Posibles adiciones futuras:

- [ ] Soporte para Drizzle ORM como alternativa a Prisma
- [ ] Templates de páginas de autenticación completas
- [ ] Componentes de dashboard pre-construidos
- [ ] Configuración de testing (Jest + Playwright)
- [ ] Docker compose para desarrollo
- [ ] Scripts de deployment para diferentes plataformas
- [ ] Generación de seeders de datos
- [ ] Configuración de CI/CD

## Troubleshooting

### Error: "PostgreSQL no está corriendo"

```bash
# Linux
sudo service postgresql start

# macOS
brew services start postgresql

# Verificar
pg_isready
```

### Error: "Database does not exist"

```bash
# Crear base de datos manualmente
createdb nombre_base_datos

# O con psql
psql -U postgres -c "CREATE DATABASE nombre_base_datos;"
```

### Error: "Prisma Client not generated"

```bash
npx prisma generate
```

### Error: "Migration failed"

```bash
# Resetear migraciones (⚠️ elimina datos)
npx prisma migrate reset

# Aplicar de nuevo
npx prisma migrate dev
```

## Recursos

- [Documentación de Prisma](https://www.prisma.io/docs)
- [Documentación de NextAuth.js](https://authjs.dev)
- [PostgreSQL Tutorial](https://www.postgresql.org/docs/current/tutorial.html)
- [Next.js App Router](https://nextjs.org/docs/app)
- [Tailwind CSS](https://tailwindcss.com/docs)

---

**Generado por SaaS Factory**
Versión: 1.0.0
Última actualización: 2026-01-15
