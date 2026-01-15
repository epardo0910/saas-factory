# 🏭 SaaS Factory - Cheat Sheet

## Comandos Principales

### Crear Nuevo Proyecto

```bash
# Forma 1: Usar alias (después de source ~/.bashrc)
saas-factory nombre-proyecto [nombre-db]

# Forma 2: Ruta completa (siempre funciona)
/home/epardo/scripts/saas-factory.sh nombre-proyecto [nombre-db]

# Ejemplos
saas-factory mi-app                    # DB: mi_app_db
saas-factory crm-app crm_production    # DB: crm_production
```

### Setup Rápido (Copy-Paste)

```bash
# Todo en uno - Crear y configurar proyecto
PROJECT_NAME="mi-saas"
/home/epardo/scripts/saas-factory.sh $PROJECT_NAME && \
cd $PROJECT_NAME && \
createdb ${PROJECT_NAME//-/_}_db && \
npx prisma migrate dev --name init && \
npm run dev
```

---

## Comandos PostgreSQL

```bash
# Iniciar PostgreSQL
sudo service postgresql start           # Linux
brew services start postgresql          # macOS

# Verificar que esté corriendo
pg_isready

# Crear base de datos
createdb nombre_db

# Eliminar base de datos
dropdb nombre_db

# Conectar a base de datos
psql -d nombre_db

# Listar bases de datos
psql -U postgres -c "\l"

# Backup
pg_dump nombre_db > backup.sql

# Restore
psql nombre_db < backup.sql
```

---

## Comandos Prisma

### Desarrollo

```bash
# Generar Prisma Client (después de cambios en schema)
npx prisma generate

# Crear migración (después de editar schema.prisma)
npx prisma migrate dev --name nombre_descriptivo

# Aplicar migraciones pendientes
npx prisma migrate dev

# Resetear base de datos (⚠️ ELIMINA TODOS LOS DATOS)
npx prisma migrate reset

# Ver base de datos en navegador
npx prisma studio

# Formatear schema.prisma
npx prisma format

# Validar schema
npx prisma validate
```

### Producción

```bash
# Aplicar migraciones en producción
npx prisma migrate deploy

# Generar cliente optimizado
npx prisma generate

# Ver estado de migraciones
npx prisma migrate status
```

### Utilidades

```bash
# Introspección (generar schema desde DB existente)
npx prisma db pull

# Sincronizar schema a DB (⚠️ puede perder datos)
npx prisma db push

# Ver diff de cambios pendientes
npx prisma migrate diff
```

---

## Comandos Next.js

```bash
# Desarrollo
npm run dev

# Build de producción
npm run build

# Iniciar producción
npm start

# Linting
npm run lint

# Type checking
npx tsc --noEmit
```

---

## Estructura de Carpetas

```bash
# Ver árbol completo
tree -L 3 -I node_modules

# Ver solo archivos TypeScript
find . -name "*.ts" -o -name "*.tsx" | grep -v node_modules

# Ver tamaño del proyecto
du -sh .
du -sh node_modules
```

---

## Editar Schema de Prisma

### Agregar nuevo campo a modelo existente

```prisma
model User {
  id       String @id @default(cuid())
  email    String @unique
  // ↓ Agregar nuevo campo
  phone    String?
  bio      String? @db.Text
}
```

Luego:
```bash
npx prisma migrate dev --name add_phone_and_bio_to_users
```

### Crear nuevo modelo

```prisma
model Comment {
  id        String   @id @default(cuid())
  content   String
  authorId  String
  taskId    String
  createdAt DateTime @default(now())

  author User @relation(fields: [authorId], references: [id])
  task   Task @relation(fields: [taskId], references: [id])

  @@index([taskId])
  @@index([authorId])
}
```

Luego:
```bash
npx prisma migrate dev --name add_comments
```

---

## Queries Prisma Comunes

### Buscar

```typescript
// Por ID
const user = await prisma.user.findUnique({ where: { id } })

// Por email
const user = await prisma.user.findUnique({ where: { email } })

// Buscar o lanzar error
const user = await prisma.user.findUniqueOrThrow({ where: { id } })

// Buscar primero
const user = await prisma.user.findFirst({ where: { role: 'OWNER' } })

// Buscar muchos
const users = await prisma.user.findMany({
  where: { role: 'DEVELOPER' },
  orderBy: { createdAt: 'desc' },
  take: 10,
})

// Buscar muchos con relaciones
const projects = await prisma.project.findMany({
  include: {
    members: {
      include: { user: true }
    },
    tasks: true,
  }
})
```

### Crear

```typescript
// Crear uno
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    name: 'John Doe',
    password: hashedPassword,
  }
})

// Crear con relaciones
const project = await prisma.project.create({
  data: {
    name: 'New Project',
    members: {
      create: {
        userId: userId,
        role: 'OWNER',
      }
    }
  }
})
```

### Actualizar

```typescript
// Actualizar uno
const user = await prisma.user.update({
  where: { id },
  data: { name: 'New Name' }
})

// Actualizar muchos
await prisma.task.updateMany({
  where: { status: 'TODO' },
  data: { priority: 'LOW' }
})

// Upsert (update o create)
const user = await prisma.user.upsert({
  where: { email },
  update: { name },
  create: { email, name, password }
})
```

### Eliminar

```typescript
// Eliminar uno
await prisma.user.delete({ where: { id } })

// Eliminar muchos
await prisma.task.deleteMany({ where: { status: 'DONE' } })
```

### Contar

```typescript
// Contar todos
const count = await prisma.user.count()

// Contar con filtro
const activeProjects = await prisma.project.count({
  where: { status: 'ACTIVE' }
})
```

### Agregaciones

```typescript
// Promedio, suma, min, max
const stats = await prisma.task.aggregate({
  _count: true,
  _avg: { priority: true },
  where: { projectId }
})

// Agrupar
const tasksByStatus = await prisma.task.groupBy({
  by: ['status'],
  _count: true,
})
```

---

## Comandos Git

```bash
# Inicializar (ya hecho por saas-factory)
git init

# Ver estado
git status

# Agregar cambios
git add .

# Commit
git commit -m "mensaje"

# Ver historia
git log --oneline

# Crear branch
git checkout -b feature/nueva-funcionalidad

# Cambiar branch
git checkout main

# Merge
git merge feature/nueva-funcionalidad

# Subir a GitHub
git remote add origin https://github.com/usuario/repo.git
git push -u origin main
```

---

## Comandos Vercel (Deployment)

```bash
# Instalar CLI
npm i -g vercel

# Login
vercel login

# Deploy a preview
vercel

# Deploy a producción
vercel --prod

# Ver logs
vercel logs

# Agregar variable de entorno
vercel env add DATABASE_URL

# Listar deployments
vercel ls

# Eliminar deployment
vercel rm deployment-url
```

---

## Scripts de Base de Datos

### Seed de datos de prueba

Crear `prisma/seed.ts`:

```typescript
import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  // Limpiar datos existentes
  await prisma.task.deleteMany()
  await prisma.projectMember.deleteMany()
  await prisma.project.deleteMany()
  await prisma.user.deleteMany()

  // Crear usuarios
  const password = await bcrypt.hash('password123', 10)

  const owner = await prisma.user.create({
    data: {
      email: 'owner@example.com',
      name: 'Agency Owner',
      password,
      role: 'OWNER',
    },
  })

  const developer = await prisma.user.create({
    data: {
      email: 'dev@example.com',
      name: 'Lead Developer',
      password,
      role: 'DEVELOPER',
    },
  })

  // Crear proyecto
  const project = await prisma.project.create({
    data: {
      name: 'Demo Project',
      description: 'A sample project',
      status: 'ACTIVE',
      members: {
        create: [
          { userId: owner.id, role: 'OWNER' },
          { userId: developer.id, role: 'MEMBER' },
        ],
      },
      tasks: {
        create: [
          {
            title: 'Setup project',
            description: 'Initialize repository',
            status: 'DONE',
            priority: 'HIGH',
          },
          {
            title: 'Implement auth',
            status: 'IN_PROGRESS',
            priority: 'HIGH',
          },
          {
            title: 'Create dashboard',
            status: 'TODO',
            priority: 'MEDIUM',
          },
        ],
      },
    },
  })

  console.log('✅ Seed completed!')
  console.log({ owner, developer, project })
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
```

Agregar a `package.json`:

```json
{
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

Ejecutar:

```bash
npm install -D tsx
npx prisma db seed
```

---

## Variables de Entorno

### Desarrollo (.env.local)

```env
# PostgreSQL
DATABASE_URL="postgresql://localhost:5432/mi_db"

# NextAuth
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=super-secret-key-here

# App
NEXT_PUBLIC_APP_NAME=Mi SaaS
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### Producción

```env
# PostgreSQL (usar DB remota)
DATABASE_URL="postgresql://user:pass@host.com:5432/prod_db"

# NextAuth
NEXTAUTH_URL=https://tudominio.com
NEXTAUTH_SECRET=super-secret-production-key

# App
NEXT_PUBLIC_APP_NAME=Mi SaaS
NEXT_PUBLIC_APP_URL=https://tudominio.com
```

---

## Debugging

### Ver queries SQL que ejecuta Prisma

```typescript
// lib/db/index.ts
export const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error'],
})
```

### Ver errores de NextAuth

```typescript
// auth.ts
export const { auth, signIn, signOut } = NextAuth({
  debug: process.env.NODE_ENV === 'development',
  // ...
})
```

### Logs en servidor Next.js

```bash
# Ver logs en tiempo real
npm run dev | tee logs.txt
```

---

## Alias Útiles (Agregar a ~/.bashrc)

```bash
# Prisma shortcuts
alias pstudio="npx prisma studio"
alias pmigrate="npx prisma migrate dev"
alias pgenerate="npx prisma generate"
alias preset="npx prisma migrate reset"

# Next.js shortcuts
alias ndev="npm run dev"
alias nbuild="npm run build"

# PostgreSQL shortcuts
alias pg-start="sudo service postgresql start"
alias pg-status="pg_isready"

# Recargar bashrc
alias reload="source ~/.bashrc"
```

---

## Tips de Productividad

### 1. Usar Prisma Studio

```bash
# Siempre deja Prisma Studio abierto en una terminal
npx prisma studio
```

Beneficios:
- Ver datos en tiempo real
- Editar datos sin SQL
- Navegar relaciones visualmente

### 2. Hot Reload en Next.js

El servidor de desarrollo recarga automáticamente:
- Cambios en código → Recarga instantánea
- Cambios en .env.local → Reiniciar servidor

### 3. TypeScript IntelliSense

```typescript
// Prisma genera tipos automáticamente
const user = await prisma.user.findUnique({ where: { id } })
//    ^? User | null

user.email // ← Autocomplete!
```

### 4. Usar Zod para validación

```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
})

const result = schema.safeParse(data)
if (result.success) {
  // result.data es type-safe
}
```

---

## Recursos Quick Links

| Recurso | URL |
|---------|-----|
| Next.js Docs | https://nextjs.org/docs |
| Prisma Docs | https://www.prisma.io/docs |
| NextAuth Docs | https://authjs.dev |
| PostgreSQL Docs | https://www.postgresql.org/docs |
| Tailwind CSS | https://tailwindcss.com/docs |
| Radix UI | https://www.radix-ui.com |
| Zod | https://zod.dev |

---

## One-Liners Útiles

```bash
# Crear proyecto y setup completo
/home/epardo/scripts/saas-factory.sh myapp && cd myapp && createdb myapp_db && npx prisma migrate dev --name init && npm run dev

# Ver todas las tablas de la BD
psql -d myapp_db -c "\dt"

# Contar registros en todas las tablas
psql -d myapp_db -c "SELECT schemaname,relname,n_live_tup FROM pg_stat_user_tables ORDER BY n_live_tup DESC;"

# Backup rápido
pg_dump myapp_db | gzip > backup-$(date +%Y%m%d).sql.gz

# Restore desde backup
gunzip -c backup-20260115.sql.gz | psql myapp_db

# Ver tamaño de base de datos
psql -d myapp_db -c "SELECT pg_size_pretty(pg_database_size('myapp_db'));"

# Eliminar proyecto completo (⚠️ CUIDADO)
rm -rf myapp && dropdb myapp_db
```

---

**🏭 SaaS Factory Cheat Sheet v1.0**
