# 🏭 SaaS Factory - Cheat Sheet v2.0

## 🚀 Comandos Principales

### Crear Proyecto (v2.0)

```bash
# Comando básico (MCP incluido por defecto)
saas-factory mi-app mi_db

# Con base de datos automática (Recomendado)
saas-factory mi-app mi_db --create-db

# Con Cloudflare Tunnel (más seguro que --dns)
saas-factory mi-app mi_db --create-db --tunnel

# Deploy automático completo
saas-factory mi-app mi_db --create-db --tunnel --deploy

# Con tests (Vitest + Playwright + CI/CD)
saas-factory mi-app mi_db --create-db --with-tests

# Sin MCP (si no usas Claude/IA)
saas-factory mi-app mi_db --no-mcp
```

### Flags Disponibles (v2.0)

| Flag | Descripción |
|------|-------------|
| `--create-db` | Crea DB PostgreSQL automáticamente |
| `--dns` | Crea registro DNS A en Cloudflare |
| `--tunnel` | Configura Cloudflare Tunnel (más seguro) |
| `--deploy` | Deploy automático (PM2 + Caddy + SSL) |
| `--with-tests` | Configura Vitest + Playwright + CI/CD |
| `--no-mcp` | Desactiva MCP servers (por defecto activos) |

**⚠️ Validaciones:**
- ❌ No puedes usar `--dns` y `--tunnel` juntos
- ⚠️ `--deploy` funciona mejor con `--create-db`

### Flujo v2.0 (10 pasos)

```
[1-5]  Crear proyecto + deps + estructura
[6]    Crear base de datos (si --create-db)
[7]    Prisma migrate + generate
[8]    Configurar MCP (por defecto, 8 servers)
[9]    Configurar tests (si --with-tests)
[10]   Git commit inicial (incluye TODO)
```

---

## 🗄️ PostgreSQL

```bash
# Crear DB (manual, si NO usaste --create-db)
docker exec jscamp-infojobs-strapi-db psql -U strapi -d postgres -c "CREATE DATABASE mi_db;"

# Verificar PostgreSQL
pg_isready

# Conectar a DB
psql -d mi_db

# Listar bases de datos
psql -U postgres -c "\l"

# Backup
pg_dump mi_db > backup.sql

# Restore
psql mi_db < backup.sql
```

---

## 🔷 Prisma

### Desarrollo

```bash
# Generar cliente (después de cambios en schema)
npx prisma generate

# Crear migración
npx prisma migrate dev --name descripcion

# Resetear DB (⚠️ elimina datos)
npx prisma migrate reset

# Ver DB en navegador
npx prisma studio

# Formatear schema
npx prisma format

# Validar schema
npx prisma validate
```

### Producción

```bash
# Aplicar migraciones
npx prisma migrate deploy

# Ver estado de migraciones
npx prisma migrate status
```

### Queries Comunes

```typescript
// Buscar
await prisma.user.findUnique({ where: { id } })
await prisma.user.findMany({ where: { role: 'OWNER' } })

// Crear
await prisma.user.create({ data: { email, name, password } })

// Actualizar
await prisma.user.update({ where: { id }, data: { name } })

// Eliminar
await prisma.user.delete({ where: { id } })

// Contar
await prisma.user.count()

// Con relaciones
await prisma.project.findMany({ include: { members: true, tasks: true } })
```

---

## ⚛️ Next.js

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

## 🔐 Caddy (con --deploy)

```bash
# Ver estado
sudo systemctl status caddy

# Recargar configuración
sudo systemctl reload caddy

# Verificar configuración
sudo caddy validate --config /etc/caddy/Caddyfile

# Ver logs
sudo journalctl -u caddy -f

# Ver certificados SSL
sudo caddy list-certificates
```

### Configuración Manual (si NO usaste --deploy)

```bash
# Editar Caddyfile
sudo nano /etc/caddy/Caddyfile
```

Agregar:
```caddyfile
mi-app.emanuel-server.com {
    reverse_proxy localhost:3000
}
```

```bash
# Recargar
sudo systemctl reload caddy
```

---

## 🔄 PM2

```bash
# Iniciar app
pm2 start npm --name "mi-app" -- start

# Ver estado
pm2 status

# Ver logs
pm2 logs mi-app

# Reiniciar
pm2 restart mi-app

# Reload (zero-downtime)
pm2 reload mi-app

# Detener
pm2 stop mi-app

# Eliminar
pm2 delete mi-app

# Guardar configuración
pm2 save

# Auto-start en reinicio
pm2 startup
```

---

## 📦 Git

```bash
# Ver estado
git status

# Agregar cambios
git add .

# Commit
git commit -m "mensaje"

# Ver historia
git log --oneline

# Crear branch
git checkout -b feature/nueva

# Subir a GitHub
git remote add origin https://github.com/user/repo.git
git push -u origin main
```

---

## 🛠️ Comandos Útiles

### Setup Rápido Post-Creación (si NO usaste --create-db)

```bash
cd mi-app
docker exec jscamp-infojobs-strapi-db psql -U strapi -d postgres -c "CREATE DATABASE mi_db;"
npx prisma migrate dev --name init
npm run dev
```

### Deploy Manual (si NO usaste --deploy)

```bash
cd mi-app
npm run build
pm2 start npm --name "mi-app" -- start
pm2 save

# Configurar Caddy manualmente (ver sección Caddy arriba)
```

### Actualizar Código en Producción

```bash
cd mi-app
git pull origin main
npm install
npm run build
pm2 reload mi-app
```

### Backup de DB

```bash
# Backup
pg_dump mi_db > backup_$(date +%Y%m%d).sql

# Backup comprimido
pg_dump mi_db | gzip > backup_$(date +%Y%m%d).sql.gz

# Restore
psql mi_db < backup_20260115.sql
gunzip -c backup_20260115.sql.gz | psql mi_db
```

---

## 🔧 Variables de Entorno

### .env.local (Desarrollo)

```env
DATABASE_URL="postgresql://localhost:5432/mi_db"
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=secret-generado-con-openssl
NEXT_PUBLIC_APP_NAME=Mi App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### .env.local (Producción)

```env
DATABASE_URL="postgresql://localhost:5432/mi_db"
NEXTAUTH_URL=https://mi-app.emanuel-server.com
NEXTAUTH_SECRET=secret-super-seguro-produccion
NEXT_PUBLIC_APP_NAME=Mi App
NEXT_PUBLIC_APP_URL=https://mi-app.emanuel-server.com
```

**Generar secret:**
```bash
openssl rand -base64 32
```

---

## 🤖 MCP Servers (Configurados por defecto)

Si NO usaste `--no-mcp`, tu proyecto incluye 8 MCP servers:

1. **filesystem** - Operaciones de archivos
2. **postgres** - Consultas SQL directas
3. **git** - Operaciones Git
4. **github** - Integración GitHub
5. **n8n** - Automatizaciones
6. **brave-search** - Búsquedas web
7. **memory** - Sistema de memoria persistente
8. **puppeteer** - Web scraping y automatización

**Archivos generados:**
- `.mcp.json` - Configuración MCP
- `.claudeignore` - Archivos ignorados por Claude
- `CLAUDE.md` - Instrucciones para Claude
- `GEMINI.md` - Instrucciones para Gemini

---

## 🧪 Tests (si usaste --with-tests)

```bash
# Vitest (unit tests)
npm run test

# Playwright (e2e tests)
npm run test:e2e

# Ver coverage
npm run test:coverage
```

**Archivos generados:**
- `vitest.config.ts` - Configuración Vitest
- `playwright.config.ts` - Configuración Playwright
- `.github/workflows/test.yml` - CI/CD con GitHub Actions

---

## 🔍 Troubleshooting

### DB no existe
```bash
docker exec jscamp-infojobs-strapi-db psql -U strapi -d postgres -c "CREATE DATABASE mi_db;"
npx prisma migrate dev --name init
```

### Prisma Client error
```bash
npx prisma generate
```

### Puerto en uso
```bash
# Ver qué usa el puerto 3000
lsof -i :3000

# Matar proceso
kill -9 <PID>
```

### Caddy no funciona
```bash
# Verificar configuración
sudo caddy validate --config /etc/caddy/Caddyfile

# Ver logs
sudo journalctl -u caddy -f

# Reiniciar
sudo systemctl restart caddy
```

### PM2 app caída
```bash
pm2 logs mi-app
pm2 restart mi-app
```

---

## 📚 Recursos

- [README.md](../README.md) - Documentación principal v2.0
- [QUICKSTART.md](../QUICKSTART.md) - Guía completa
- [CHANGELOG.md](../CHANGELOG.md) - Cambios v2.0
- [docs/mcp_configuration.md](mcp_configuration.md) - Guía MCP
- [docs/postgresql_automatizado.md](postgresql_automatizado.md) - Guía PostgreSQL
- [docs/cloudflare_dns_guide.md](cloudflare_dns_guide.md) - Guía DNS/Tunnel
- [CADDY_CONFIG.md](../CADDY_CONFIG.md) - Configuración Caddy

### Documentación Oficial
- [Next.js Docs](https://nextjs.org/docs)
- [Prisma Docs](https://www.prisma.io/docs)
- [NextAuth.js](https://authjs.dev)
- [Caddy Server](https://caddyserver.com/docs)

---

**🏭 SaaS Factory v2.0 - Deploy en un comando**

```bash
saas-factory mi-app mi_db --create-db --tunnel --deploy
# ✅ Listo en 2 minutos!
```
