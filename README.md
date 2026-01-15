# 🏭 SaaS Factory v2.0

> Build Software, Not Just Automations

**SaaS Factory** es un generador CLI que crea aplicaciones SaaS full-stack completas en minutos, diseñado para desarrollo agéntico con IA (Claude, Gemini Antigravity, etc.).

Inspirado en el paradigma de desarrollo agéntico presentado en videos sobre construcción de software con IA, pero optimizado para usar **PostgreSQL directo** en lugar de servicios cloud, dándote control total de tu infraestructura.

**✨ Nuevo en v2.0:** Flujo optimizado con validación de flags, MCP por defecto, y DB migrada automáticamente antes del commit inicial.

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

# Con subdominio automático (Cloudflare DNS)
saas-factory mi-proyecto mi_proyecto_db --dns

# Con creación automática de base de datos (PostgreSQL)
saas-factory mi-proyecto mi_proyecto_db --create-db

# Con Cloudflare Tunnel (más seguro que DNS directo)
saas-factory mi-proyecto mi_proyecto_db --create-db --tunnel

# Con tests + CI/CD
saas-factory mi-proyecto mi_proyecto_db --create-db --with-tests

# Deploy automático completo (PM2 + Caddy + SSL)
saas-factory mi-proyecto mi_proyecto_db --create-db --tunnel --deploy

# Sin MCP servers (si no usas Claude/IA)
saas-factory mi-proyecto mi_proyecto_db --no-mcp
```

**📖 ¿Primera vez?** Lee la **[Guía Quickstart](QUICKSTART.md)** - De cero a producción en 10 minutos.

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
- ✅ **Cloudflare DNS/Tunnel** creación automática de subdominios (opcional)
- ✅ **MCP Servers** 8 servidores configurados por defecto (filesystem, postgres, git, github, n8n, etc.)
- ✅ **Testing** Vitest + Playwright + CI/CD (opcional con --with-tests)
- ✅ **Auto-deploy** PM2 + Caddy + SSL (opcional con --deploy)
- ✅ **Flujo optimizado v2.0** DB migrada antes de commit, MCP en commit inicial

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
saas-factory <nombre-proyecto> [nombre-db] [flags]

# Ejemplos básicos
saas-factory mi-app                    # DB: mi_app_db (MCP incluido)
saas-factory crm-acme acme_crm_db     # DB: acme_crm_db (MCP incluido)

# Con auto-creación de DB (recomendado)
saas-factory mi-app mi_app_db --create-db

# Completo: DB + Tunnel + Deploy
saas-factory mi-app mi_app_db --create-db --tunnel --deploy
```

### 2. Flags Disponibles (v2.0)

| Flag | Descripción |
|------|-------------|
| `--create-db` | Crea DB PostgreSQL automáticamente |
| `--dns` | Crea registro DNS A en Cloudflare |
| `--tunnel` | Configura Cloudflare Tunnel (más seguro) |
| `--deploy` | Deploy automático (PM2 + Caddy + SSL) |
| `--with-tests` | Configura Vitest + Playwright + CI/CD |
| `--no-mcp` | Desactiva MCP servers (por defecto están activos) |

**⚠️ Validaciones:**
- ❌ No puedes usar `--dns` y `--tunnel` juntos
- ⚠️  `--deploy` funciona mejor con `--create-db`

### 3. Flujo Optimizado v2.0

Cuando usas `--create-db`, el flujo es completamente automático:

```
[1-5]  Crear proyecto Next.js + deps + estructura
[6]    Crear base de datos PostgreSQL
[7]    Ejecutar migración inicial de Prisma
[8]    Configurar MCP (8 servers)
[9]    Configurar tests (si --with-tests)
[10]   Git commit (incluye TODO lo anterior)
```

**Resultado:**
- ✅ DB creada y migrada
- ✅ MCP configurado en commit inicial
- ✅ Tests configurados (si solicitaste)
- ✅ Listo para: `cd mi-app && npm run dev`

### 4. Desarrollo

```bash
# Con --create-db (recomendado)
cd mi-app
npm run dev  # ¡Ya funciona! DB ya está migrada

# Sin --create-db (manual)
cd mi-app
createdb mi_app_db
npx prisma migrate dev --name init
npm run dev

# Ver base de datos (GUI)
npx prisma studio  # → http://localhost:5555
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

### Comenzar
- **[QUICKSTART.md](QUICKSTART.md)** - De cero a producción en 10 minutos 🚀
- **[CHANGELOG.md](CHANGELOG.md)** - Historial de cambios v2.0

### Configuración y Deploy
- **[CADDY_CONFIG.md](CADDY_CONFIG.md)** - 🔐 Reverse proxy y SSL automático (usa con --deploy)
- **[mcp_configuration.md](docs/mcp_configuration.md)** - 🔌 8 MCP servers configurados por defecto
- **[postgresql_automatizado.md](docs/postgresql_automatizado.md)** - Base de datos automática (--create-db)
- **[cloudflare_dns_guide.md](docs/cloudflare_dns_guide.md)** - DNS/Tunnel automático

### Referencias
- **[saas_factory_cheatsheet.md](docs/saas_factory_cheatsheet.md)** - Comandos rápidos v2.0
- **[supabase_vs_postgresql_comparacion.md](docs/supabase_vs_postgresql_comparacion.md)** - Comparación técnica
- **[SAAS_FACTORY_INDEX.md](docs/SAAS_FACTORY_INDEX.md)** - Índice completo

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

### Tu Propio Servidor (Recomendado) ✅

Si tienes tu propio servidor (como este caso), es la mejor opción:

**Ventajas:**
- ✅ Control total de infraestructura
- ✅ PostgreSQL ya instalado localmente
- ✅ Sin costos adicionales de hosting
- ✅ Mejor performance (sin latencia de red)
- ✅ Cloudflare DNS integrado (subdominios automáticos)

```bash
# 1. Build del proyecto
npm run build

# 2. Iniciar con PM2 (auto-restart)
pm2 start npm --name "mi-app" -- start
pm2 save
pm2 startup  # Auto-start en boot

# 3. Configurar proxy reverso (Caddy recomendado)
sudo nano /etc/caddy/Caddyfile
```

```caddyfile
mi-app.emanuel-server.com {
    reverse_proxy localhost:3000
    encode gzip
}
```

```bash
sudo systemctl reload caddy
# ✅ SSL automático con Let's Encrypt
# ✅ Listo en https://mi-app.emanuel-server.com
```

### Vercel (Alternativa para proyectos específicos)

Solo si necesitas deploy externo:

```bash
npm i -g vercel
vercel --prod
```

**Nota:** Necesitarás PostgreSQL accesible desde internet (Railway, Neon, etc.)

### Otras Plataformas

- **Railway** - PostgreSQL + Deploy
- **DigitalOcean App Platform**
- **AWS Amplify**

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
