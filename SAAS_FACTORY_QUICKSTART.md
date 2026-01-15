# 🏭 SaaS Factory - Quick Start

## Activar el Comando (Solo primera vez)

```bash
source ~/.bashrc
```

## Uso Básico

```bash
# Sintaxis
saas-factory <nombre-proyecto> [nombre-db]

# Ejemplo 1: Simple
saas-factory mi-app

# Ejemplo 2: Con DB custom
saas-factory app-gemini gemini_db
```

## Demo Completa (5 minutos)

```bash
# 1. Generar proyecto
saas-factory test-app

# 2. Entrar al proyecto
cd test-app

# 3. Crear base de datos
createdb test_app_db

# 4. Ejecutar migraciones
npx prisma migrate dev --name init

# 5. Iniciar servidor
npm run dev

# 6. (En otra terminal) Ver base de datos
npx prisma studio
```

## Abrir en Navegador

- **App**: http://localhost:3000
- **Database Studio**: http://localhost:5555

## Stack Generado

✅ Next.js 14 (App Router)
✅ PostgreSQL + Prisma ORM
✅ NextAuth.js v5
✅ TypeScript
✅ Tailwind CSS
✅ Radix UI Components
✅ Zod Validation

## Estructura Generada

```
tu-proyecto/
├── app/
│   ├── (auth)/          # Login, Signup
│   ├── (dashboard)/     # Dashboard, Projects, Team
│   └── api/auth/        # NextAuth routes
├── components/ui/       # Button, Input, Label
├── lib/
│   ├── db/             # Prisma client
│   ├── auth/           # Auth helpers
│   └── validations/    # Zod schemas
├── prisma/
│   └── schema.prisma   # Database schema
├── .env.local          # Variables (auto-generado)
└── README.md           # Docs completas
```

## Modelo de Datos Incluido

- ✅ User (con roles: OWNER, MANAGER, DEVELOPER, CLIENT)
- ✅ Account (OAuth providers)
- ✅ Session (NextAuth sessions)
- ✅ Project (con estados)
- ✅ ProjectMember (relaciones)
- ✅ Task (sistema Kanban: TODO, IN_PROGRESS, DONE)

## Siguiente Paso: Usar con IA

Una vez generado el proyecto, puedes usar Claude, Gemini u otro editor agéntico:

```bash
# Ejemplo con Claude Code
claude test-app
```

**Prompt sugerido:**

> "Implementa el sistema completo de login y signup usando los schemas
> de validación que están en lib/validations/auth.ts. Usa los componentes
> UI que ya existen. Diseño profesional con gradientes estilo Stripe."

## Comandos Útiles

```bash
# Ver base de datos
npx prisma studio

# Nueva migración
npx prisma migrate dev --name nombre

# Resetear BD (⚠️ borra datos)
npx prisma migrate reset

# Build producción
npm run build

# Formatear schema
npx prisma format
```

## Documentación Completa

📖 Ver: [/home/epardo/docs/saas_factory_guia.md](/home/epardo/docs/saas_factory_guia.md)

## Comparación con Supabase

📊 Ver: [/home/epardo/docs/supabase_vs_postgresql_comparacion.md](/home/epardo/docs/supabase_vs_postgresql_comparacion.md)

## Ejemplo Completo de Uso

📝 Ver: [/home/epardo/docs/saas_factory_ejemplo_uso.md](/home/epardo/docs/saas_factory_ejemplo_uso.md)

---

**¿Problemas?**

```bash
# PostgreSQL no está corriendo
sudo service postgresql start  # Linux
brew services start postgresql # macOS

# Verificar PostgreSQL
pg_isready

# Ver logs del script
bash -x /home/epardo/scripts/saas-factory.sh test-app
```

**🏭 Ready to build software, not just automations!**
