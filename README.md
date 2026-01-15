# 🏭 SaaS Factory

> Build Software, Not Just Automations

**SaaS Factory** es un generador CLI que crea aplicaciones SaaS full-stack completas en minutos, diseñado para desarrollo agéntico con IA (Claude, Gemini Antigravity, etc.).

Inspirado en el paradigma de desarrollo agéntico presentado en videos sobre construcción de software con IA, pero optimizado para usar **PostgreSQL directo** en lugar de servicios cloud, dándote control total de tu infraestructura.

## ⚡ Quick Start

```bash
# Instalar
git clone https://github.com/epardo0910/saas-factory.git
cd saas-factory
chmod +x saas-factory.sh

# Crear alias global (opcional)
echo "alias saas-factory='$(pwd)/saas-factory.sh'" >> ~/.bashrc
source ~/.bashrc

# Usar
saas-factory mi-proyecto

# Con subdominio automático (requiere configuración de Cloudflare)
saas-factory mi-proyecto mi_proyecto_db --dns
# Crea: mi-proyecto.emanuel-server.com
```

## 🎯 ¿Qué genera?

En **2 minutos** genera un proyecto completo con:

- ✅ **Next.js 14** con App Router y Server Components
- ✅ **PostgreSQL + Prisma ORM** con migraciones automáticas
- ✅ **NextAuth.js v5** sistema completo de autenticación
- ✅ **TypeScript** con type-safety end-to-end
- ✅ **Tailwind CSS** con tema personalizado
- ✅ **Radix UI** componentes accesibles
- ✅ **Zod** validación de schemas
- ✅ **Estructura optimizada** para desarrollo con IA
- ✅ **Cloudflare DNS** creación automática de subdominios (opcional)

### Stack Completo

```
📦 Tu Proyecto
├── app/
│   ├── (auth)/          # Login, Signup, Forgot Password
│   ├── (dashboard)/     # Dashboard, Projects, Team, Settings
│   └── api/auth/        # NextAuth.js routes
├── components/
│   ├── ui/              # Button, Input, Label
│   ├── auth/            # Auth components
│   └── dashboard/       # Dashboard components
├── lib/
│   ├── db/              # Prisma client
│   ├── auth/            # Auth utilities
│   ├── validations/     # Zod schemas
│   └── utils/           # Helper functions
├── prisma/
│   └── schema.prisma    # Database schema con modelos completos
├── types/               # TypeScript definitions
└── .env.local           # Environment variables (auto-generated)
```

## 📊 Modelo de Datos Incluido

El schema de Prisma ya incluye:

### Autenticación (NextAuth.js)
- `User` - Usuarios con roles (OWNER, MANAGER, DEVELOPER, CLIENT)
- `Account` - Proveedores OAuth
- `Session` - Sesiones de usuario
- `VerificationToken` - Tokens de verificación

### Aplicación
- `Project` - Proyectos con estados (ACTIVE, PAUSED, COMPLETED, ARCHIVED)
- `ProjectMember` - Miembros de proyectos con roles
- `Task` - Tareas con sistema Kanban (TODO, IN_PROGRESS, DONE)
- Prioridades (LOW, MEDIUM, HIGH, URGENT)

## 🚀 Uso Básico

### 1. Generar Proyecto

```bash
# Sintaxis
saas-factory <nombre-proyecto> [nombre-db]

# Ejemplos
saas-factory mi-app                    # DB: mi_app_db
saas-factory crm-acme acme_crm_db     # DB: acme_crm_db
```

### 2. Configurar Base de Datos

```bash
cd mi-app

# Crear base de datos PostgreSQL
createdb mi_app_db

# Ejecutar migraciones de Prisma
npx prisma migrate dev --name init

# Ver base de datos (GUI en localhost:5555)
npx prisma studio
```

### 3. Desarrollo

```bash
# Iniciar servidor de desarrollo
npm run dev
# → http://localhost:3000

# En otra terminal: Ver base de datos
npx prisma studio
# → http://localhost:5555
```

## 🤖 Uso con Editores Agénticos (IA)

SaaS Factory genera la estructura perfecta para desarrollo con IA:

### Con Claude Code

```bash
saas-factory mi-crm
cd mi-crm
createdb mi_crm_db
npx prisma migrate dev --name init
claude .
```

**Prompts sugeridos:**

```
"Implementa el sistema completo de login y signup usando los schemas
de Zod en lib/validations/auth.ts. Diseño profesional con gradientes."

"Crea el dashboard mostrando estadísticas de proyectos. Usa Prisma
para obtener datos reales de la base de datos."

"Implementa un tablero Kanban con drag & drop usando los estados
TODO, IN_PROGRESS, DONE del modelo Task."
```

### Con Gemini Antigravity

```bash
saas-factory app-gemini
cd app-gemini
./scripts/setup-database.sh
antigravity .
```

## 💡 Ventajas vs Otras Soluciones

### vs Supabase

| Aspecto | Supabase | SaaS Factory |
|---------|----------|--------------|
| Setup inicial | 5 min | 2 min ✅ |
| Costo mensual | $25-100 | $0 ✅ |
| Velocidad | 50-200ms | <5ms ✅ |
| Control | Limitado | Total ✅ |
| Vendor lock-in | Sí | No ✅ |
| Ideal para | MVPs rápidos | Enterprise ✅ |

### vs Setup Manual

| Tarea | Manual | SaaS Factory |
|-------|--------|--------------|
| Setup Next.js + Auth | 4-8 horas | 2 minutos ✅ |
| Configurar Prisma | 2-4 horas | Incluido ✅ |
| Crear modelos de BD | 2-3 horas | Incluido ✅ |
| Setup UI components | 4-6 horas | Incluido ✅ |
| **TOTAL** | **12-21 horas** | **2 minutos** ✅ |

## 📚 Documentación

- **[SAAS_FACTORY_INDEX.md](docs/SAAS_FACTORY_INDEX.md)** - Índice maestro
- **[SAAS_FACTORY_QUICKSTART.md](docs/SAAS_FACTORY_QUICKSTART.md)** - Guía rápida de 5 minutos
- **[saas_factory_guia.md](docs/saas_factory_guia.md)** - Guía completa
- **[saas_factory_ejemplo_uso.md](docs/saas_factory_ejemplo_uso.md)** - Caso de uso real con IA
- **[saas_factory_cheatsheet.md](docs/saas_factory_cheatsheet.md)** - Comandos de referencia
- **[supabase_vs_postgresql_comparacion.md](docs/supabase_vs_postgresql_comparacion.md)** - Comparación técnica
- **[cloudflare_dns_guide.md](docs/cloudflare_dns_guide.md)** - Guía de Cloudflare DNS

## 🛠️ Comandos Útiles

```bash
# Ver base de datos en navegador
npx prisma studio

# Crear nueva migración
npx prisma migrate dev --name nombre_cambio

# Resetear base de datos (⚠️ elimina datos)
npx prisma migrate reset

# Build de producción
npm run build

# Desplegar a Vercel
vercel --prod

# Gestión de DNS (Cloudflare)
./scripts/cloudflare-dns.sh create mi-app 192.168.1.100
./scripts/cloudflare-dns.sh list
./scripts/cloudflare-dns.sh delete mi-app
```

## 🔧 Requisitos

- Node.js 18+
- PostgreSQL instalado y corriendo
- Git

## 📦 Instalación

### Opción 1: Clonar repositorio

```bash
git clone https://github.com/epardo0910/saas-factory.git
cd saas-factory
chmod +x saas-factory.sh

# Agregar alias global
echo "alias saas-factory='$(pwd)/saas-factory.sh'" >> ~/.bashrc
source ~/.bashrc
```

### Opción 2: Download directo

```bash
curl -O https://raw.githubusercontent.com/epardo0910/saas-factory/main/saas-factory.sh
chmod +x saas-factory.sh

# Mover a /usr/local/bin para uso global
sudo mv saas-factory.sh /usr/local/bin/saas-factory
```

## 🎯 Casos de Uso

### 1. CRM para Agencias
```bash
saas-factory crm-agency
# Tiempo: 2 min setup + 4-8 horas con IA
# vs 40-80 horas manual
```

### 2. Gestión de Proyectos
```bash
saas-factory project-manager
# Incluye: Projects, Tasks, Team, Kanban
```

### 3. Portal de Clientes
```bash
saas-factory client-portal
# Incluye: Auth, Roles, Dashboard
```

## 🔐 Seguridad

- ✅ Contraseñas hasheadas con bcrypt
- ✅ Session-based auth con NextAuth.js
- ✅ CSRF protection incluida
- ✅ XSS protection via React
- ✅ SQL injection protection via Prisma
- ✅ Environment variables para secretos

## 🌐 Cloudflare DNS (Opcional)

SaaS Factory puede crear automáticamente subdominios en **emanuel-server.com** para cada proyecto.

### Configuración Rápida

```bash
# 1. Configurar credenciales de Cloudflare
export CLOUDFLARE_API_TOKEN="tu_api_token"
export CLOUDFLARE_ZONE_ID="tu_zone_id"
export CLOUDFLARE_DOMAIN="emanuel-server.com"

# 2. Crear proyecto con DNS automático
saas-factory mi-app mi_app_db --dns

# Resultado: mi-app.emanuel-server.com creado automáticamente
```

### Obtener Credenciales

1. Ve a: https://dash.cloudflare.com/profile/api-tokens
2. Crea un API Token con permiso **"Edit zone DNS"**
3. Obtén el Zone ID del dashboard de emanuel-server.com
4. Configura las variables en `~/.bashrc`:

```bash
echo 'export CLOUDFLARE_API_TOKEN="tu_token"' >> ~/.bashrc
echo 'export CLOUDFLARE_ZONE_ID="tu_zone_id"' >> ~/.bashrc
source ~/.bashrc
```

Ver guía completa: **[cloudflare_dns_guide.md](docs/cloudflare_dns_guide.md)**

## 🚀 Deployment

### Vercel (Recomendado)

```bash
# En tu proyecto generado
npm i -g vercel
vercel

# Configurar variables de entorno
vercel env add DATABASE_URL
vercel env add NEXTAUTH_SECRET
vercel env add NEXTAUTH_URL

# Deploy a producción
vercel --prod
```

### Otras Plataformas

- **Railway** - Deploy PostgreSQL + Next.js
- **DigitalOcean App Platform**
- **AWS Amplify**
- **Tu propio servidor VPS**

## 🤝 Contribuir

Las contribuciones son bienvenidas! Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/amazing-feature`)
3. Commit tus cambios (`git commit -m 'Add amazing feature'`)
4. Push a la rama (`git push origin feature/amazing-feature`)
5. Abre un Pull Request

## 📝 Roadmap

- [ ] Soporte para MySQL/MariaDB
- [ ] Opción para usar Drizzle ORM
- [ ] Templates de páginas pre-construidas
- [ ] Componentes de dashboard pre-hechos
- [ ] Docker compose para desarrollo
- [ ] Scripts de CI/CD
- [ ] Testing setup (Jest + Playwright)
- [ ] Generación de seeders automáticos

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para más detalles

## 🙏 Agradecimientos

- Inspirado en el paradigma de desarrollo agéntico con IA
- Next.js por el framework increíble
- Prisma por el ORM type-safe
- NextAuth.js por la autenticación robusta
- Vercel por el hosting gratuito

## 📞 Soporte

- 📖 [Documentación completa](docs/SAAS_FACTORY_INDEX.md)
- 💬 [Discussions](https://github.com/epardo0910/saas-factory/discussions)
- 🐛 [Issues](https://github.com/epardo0910/saas-factory/issues)

---

**🏭 SaaS Factory - De 40-80 horas a 2 minutos**

Hecho con ❤️ para la comunidad de desarrollo agéntico

```
                    🏭
              SaaS Factory

    Next.js + PostgreSQL + NextAuth
           Prisma + TypeScript

         Build Software, Fast.
```
