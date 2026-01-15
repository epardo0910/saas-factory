# 🚀 Quickstart: De Cero a Producción en Minutos

Esta guía te lleva paso a paso desde cero hasta tener una aplicación SaaS completa en producción con SSL y subdominio personalizado.

**✨ Nuevo en v2.0:** Con los flags `--create-db`, `--tunnel` y `--deploy`, el proceso es casi 100% automático.

## 🎯 Flujos Disponibles

### Flujo Rápido (Recomendado - 5 minutos)
```bash
# Todo automático: DB + Tunnel + Deploy
saas-factory mi-app mi_db --create-db --tunnel --deploy

cd mi-app
# ✅ Ya está en producción con SSL!
# https://mi-app.emanuel-server.com
```

### Flujo Manual (Control total - 10 minutos)
Sigue esta guía paso a paso para entender cada parte del proceso.

## ✅ Prerequisitos

Verifica que tienes todo configurado:

```bash
# 1. PostgreSQL funcionando
psql --version
# Debería mostrar: psql (PostgreSQL) 14.x o superior

# 2. Node.js y npm
node --version  # v18.x o superior
npm --version   # 9.x o superior

# 3. PM2 instalado globalmente
pm2 --version
# Si no está instalado: npm install -g pm2

# 4. Caddy instalado
caddy version
# Si no está instalado, sigue: docs/deployment_servidor_propio.md

# 5. Cloudflare configurado
echo $CLOUDFLARE_API_TOKEN
echo $CLOUDFLARE_ZONE_ID
# Si están vacíos, ejecuta: source ~/.bashrc
```

## 🎯 Paso a Paso Completo

### 1️⃣ Crear el Proyecto (2 minutos)

```bash
# OPCIÓN A: Con base de datos automática (Recomendado v2.0)
saas-factory mi-primera-app mi_primera_app_db --create-db --tunnel

# Esto ejecuta automáticamente:
# [1-5]  Crear proyecto Next.js + deps + estructura
# [6]    Crear base de datos PostgreSQL
# [7]    Ejecutar migración inicial de Prisma
# [8]    Configurar MCP (8 servers para Claude/IA)
# [9]    (Tests si usas --with-tests)
# [10]   Git commit inicial (incluye TODO)
# [Post] Cloudflare Tunnel configurado

cd mi-primera-app
```

**OPCIÓN B: Sin base de datos automática (control manual)**
```bash
# Crear proyecto con Cloudflare Tunnel
saas-factory mi-primera-app mi_primera_app_db --tunnel

cd mi-primera-app
```

**Resultado esperado (con --create-db):**
```
✅ Proyecto Next.js creado: mi-primera-app
🗄️  Base de datos: mi_primera_app_db [✓ Creada y migrada]
🔌 MCP: 8 servers configurados [✓]
🌐 Tunnel: https://mi-primera-app.emanuel-server.com [✓]

Para empezar:
  cd mi-primera-app
  npm run dev
```

### 2️⃣ Configurar Base de Datos (Solo si NO usaste --create-db)

**⚠️ Puedes saltar este paso si usaste `--create-db` en el paso anterior.**

```bash
# Crear base de datos PostgreSQL manualmente
docker exec jscamp-infojobs-strapi-db psql -U strapi -d postgres -c "CREATE DATABASE mi_primera_app_db;"

# Ejecutar migraciones de Prisma
npx prisma migrate dev --name init

# Verificar que se crearon las tablas
npx prisma studio
# Se abrirá en http://localhost:5555
# Deberías ver las tablas: User, Project, Task, Account, Session, etc.
```

### 3️⃣ Configurar Variables de Entorno (2 minutos)

```bash
# El archivo .env.local ya fue creado por saas-factory
# Solo necesitas actualizar el NEXTAUTH_SECRET

# Generar secret seguro
openssl rand -base64 32

# Editar .env.local
nano .env.local
```

Actualiza estas líneas:

```env
# PostgreSQL (Local) - Ya está correcto
DATABASE_URL="postgresql://localhost:5432/mi_primera_app_db"

# NextAuth - Actualizar el secret
NEXTAUTH_URL=https://mi-primera-app.emanuel-server.com
NEXTAUTH_SECRET=tu_secret_generado_aqui  # ← Pegar el resultado de openssl

# App Info - Ya está correcto
NEXT_PUBLIC_APP_NAME=Mi Primera App
NEXT_PUBLIC_APP_URL=https://mi-primera-app.emanuel-server.com
```

### 4️⃣ Desarrollo Local (Opcional - 2 minutos)

```bash
# Instalar dependencias
npm install

# Iniciar en modo desarrollo
npm run dev

# Visita: http://localhost:3000
# Deberías ver la página de inicio con el login
```

**Prueba rápida:**
- La página carga correctamente
- Puedes navegar a `/login`
- No hay errores en la consola

### 5️⃣ Build de Producción (2 minutos)

```bash
# Build optimizado para producción
npm run build

# Debería completarse sin errores
# Mostrará estadísticas de bundles y rutas

# Test local del build
npm start
# Visita: http://localhost:3000
```

### 6️⃣ Deploy con PM2 (1 minuto)

```bash
# Iniciar aplicación con PM2
pm2 start npm --name "mi-primera-app" -- start

# Verificar que está corriendo
pm2 status

# Deberías ver:
# ┌─────┬──────────────────┬─────────┬─────────┬─────────┐
# │ id  │ name             │ status  │ cpu     │ memory  │
# ├─────┼──────────────────┼─────────┼─────────┼─────────┤
# │ 0   │ mi-primera-app   │ online  │ 0%      │ 50.2mb  │
# └─────┴──────────────────┴─────────┴─────────┴─────────┘

# Ver logs en tiempo real
pm2 logs mi-primera-app

# Guardar configuración de PM2
pm2 save

# Configurar auto-start en reinicio del servidor
pm2 startup
# Copia y ejecuta el comando que te muestra
```

### 7️⃣ Configurar Reverse Proxy con Caddy (2 minutos)

```bash
# Editar Caddyfile
sudo nano /etc/caddy/Caddyfile
```

**Agregar al final del archivo:**

```caddyfile
mi-primera-app.emanuel-server.com {
    reverse_proxy localhost:3000
    encode gzip

    # Headers de seguridad
    header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }

    # Logs
    log {
        output file /var/log/caddy/mi-primera-app.log
    }
}
```

**Guardar y recargar Caddy:**

```bash
# Verificar configuración
sudo caddy validate --config /etc/caddy/Caddyfile

# Si está todo OK, recargar
sudo systemctl reload caddy

# Verificar estado
sudo systemctl status caddy
# Debería mostrar: active (running)
```

**Caddy automáticamente:**
- ✅ Obtiene certificado SSL de Let's Encrypt (~30 segundos)
- ✅ Configura HTTPS automáticamente
- ✅ Redirige HTTP → HTTPS

### 8️⃣ Verificar Deployment (1 minuto)

```bash
# Test HTTPS
curl -I https://mi-primera-app.emanuel-server.com

# Deberías ver:
# HTTP/2 200
# server: Caddy
# ...

# Verificar en navegador
# Abre: https://mi-primera-app.emanuel-server.com
```

**Checklist final:**
- ✅ La página carga con HTTPS (candado verde)
- ✅ Puedes navegar a `/login`
- ✅ No hay errores en la consola del navegador
- ✅ El certificado SSL es válido

## 🎉 ¡Listo! Tu Aplicación Está en Producción

Has desplegado con éxito:
- ✅ Aplicación Next.js 14 con TypeScript
- ✅ PostgreSQL con Prisma ORM
- ✅ NextAuth.js v5 para autenticación
- ✅ Subdominio personalizado con DNS
- ✅ SSL automático con Let's Encrypt
- ✅ Process manager con PM2
- ✅ Reverse proxy con Caddy

## 📊 Gestión de la Aplicación

### Ver Estado

```bash
# Estado de PM2
pm2 status

# Logs en tiempo real
pm2 logs mi-primera-app

# Logs de Caddy
sudo tail -f /var/log/caddy/mi-primera-app.log

# Monitoreo interactivo
pm2 monit
```

### Operaciones Comunes

```bash
# Reiniciar aplicación
pm2 restart mi-primera-app

# Recargar sin downtime (zero-downtime deploy)
pm2 reload mi-primera-app

# Detener aplicación
pm2 stop mi-primera-app

# Eliminar aplicación
pm2 delete mi-primera-app
pm2 save

# Actualizar código
cd /home/epardo/mi-primera-app
git pull origin main
npm install
npm run build
pm2 reload mi-primera-app
```

### Backup de Base de Datos

```bash
# Backup manual
pg_dump mi_primera_app_db > backup_$(date +%Y%m%d).sql

# Backup comprimido
pg_dump mi_primera_app_db | gzip > backup_$(date +%Y%m%d).sql.gz

# Restaurar backup
psql mi_primera_app_db < backup_20260115.sql
```

## 🚀 Próximas Mejoras

### Agregar Funcionalidad

```bash
# 1. Edita los modelos de Prisma
nano prisma/schema.prisma

# 2. Crea migración
npx prisma migrate dev --name agregar_nueva_funcionalidad

# 3. Actualiza código
# ... edita componentes y páginas ...

# 4. Build y deploy
npm run build
pm2 reload mi-primera-app
```

### Múltiples Ambientes

```bash
# Crear ambiente de staging
saas-factory mi-primera-app-staging staging_db --dns
# → mi-primera-app-staging.emanuel-server.com

# Deploy staging en puerto 3001
cd mi-primera-app-staging
npm run build
PORT=3001 pm2 start npm --name "mi-primera-app-staging" -- start

# Agregar a Caddy
sudo nano /etc/caddy/Caddyfile
# mi-primera-app-staging.emanuel-server.com { reverse_proxy localhost:3001 }
sudo systemctl reload caddy
```

### Monitoreo Avanzado

```bash
# PM2 Plus (opcional - gratis para 1 servidor)
pm2 plus

# Uptime monitoring simple con curl
watch -n 60 'curl -I https://mi-primera-app.emanuel-server.com'
```

## 🔧 Troubleshooting

### La aplicación no carga

```bash
# 1. Verificar PM2
pm2 status
pm2 logs mi-primera-app --lines 50

# 2. Verificar Caddy
sudo systemctl status caddy
sudo tail -f /var/log/caddy/mi-primera-app.log

# 3. Verificar DNS
dig mi-primera-app.emanuel-server.com +short
# Debería mostrar: 192.168.1.135

# 4. Verificar puerto
netstat -tulpn | grep :3000
```

### Error de base de datos

```bash
# Verificar PostgreSQL
sudo systemctl status postgresql

# Conectar a DB
psql -d mi_primera_app_db

# Verificar tablas
\dt

# Re-ejecutar migraciones
cd /home/epardo/mi-primera-app
npx prisma migrate reset
npx prisma migrate deploy
```

### SSL no funciona

```bash
# Ver logs de Caddy
sudo journalctl -u caddy -f

# Verificar configuración
sudo caddy validate --config /etc/caddy/Caddyfile

# Reiniciar Caddy
sudo systemctl restart caddy
```

## 🤖 Uso con IA (Claude/Gemini)

SaaS Factory genera proyectos diseñados para desarrollo agéntico. Cada proyecto incluye archivos MCP configurados ([CLAUDE.md](template/CLAUDE.md), [GEMINI.md](template/GEMINI.md)) con instrucciones específicas.

### Ejemplo: Implementar Autenticación

```
Implementa el sistema de login en app/(auth)/login/page.tsx:
- Formulario con email y password
- Validación con Zod (lib/validations/auth.ts)
- Diseño profesional con gradientes
- Redirección a /dashboard después de login
Usa los componentes UI existentes (Button, Input, Label).
```

### Ejemplo: Dashboard

```
Crea el dashboard en app/(dashboard)/dashboard/page.tsx:
- Verificar autenticación con auth() de @/auth
- Navbar con nombre del usuario y logout
- Sidebar con navegación
- Cards de estadísticas (Projects, Tasks, Members)
- Lista de proyectos recientes con datos de Prisma
```

### Ejemplo: Kanban

```
Implementa tablero Kanban en app/(dashboard)/projects/[id]/page.tsx:
- Columnas: TODO, IN_PROGRESS, DONE
- Drag & drop con @dnd-kit/core
- Crear/editar tareas con modal
- Prioridades con colores (LOW=verde, HIGH=rojo)
- Actualizar estado en DB con Prisma
```

## 📊 Tiempo Estimado con IA

| Fase | Tradicional | Con SaaS Factory + IA |
|------|-------------|------------------------|
| Setup inicial | 2-4h | 2 min |
| Autenticación | 4-8h | 30 min |
| Dashboard | 8-16h | 1-2h |
| Kanban | 16-32h | 2-4h |
| **TOTAL** | **30-60h** | **4-8h** |

**Ahorro:** 85-90% del tiempo de desarrollo inicial.

## 📝 Script de Deploy Automatizado

Crea un script para futuros deploys:

```bash
# Crear script
nano ~/deploy-mi-primera-app.sh
```

```bash
#!/bin/bash

APP_NAME="mi-primera-app"
APP_DIR="/home/epardo/$APP_NAME"

echo "🚀 Deploying $APP_NAME..."

cd $APP_DIR

# Pull changes (si usas Git)
git pull origin main

# Install dependencies
npm ci --production

# Run migrations
npx prisma migrate deploy

# Build
npm run build

# Restart
pm2 reload $APP_NAME

# Verify
sleep 2
pm2 status $APP_NAME

echo "✅ Deploy completado!"
echo "🌐 URL: https://$APP_NAME.emanuel-server.com"
```

```bash
chmod +x ~/deploy-mi-primera-app.sh

# Usar para futuros deploys
~/deploy-mi-primera-app.sh
```

## 🎓 Recursos

### Documentación Oficial
- [Next.js 14 App Router](https://nextjs.org/docs)
- [Prisma ORM](https://www.prisma.io/docs)
- [NextAuth.js v5](https://authjs.dev)
- [PM2 Process Manager](https://pm2.keymetrics.io/docs)
- [Caddy Server](https://caddyserver.com/docs)

### Documentación SaaS Factory
- [README.md](README.md) - Documentación principal v2.0
- [CHANGELOG.md](CHANGELOG.md) - Cambios v2.0
- [docs/saas_factory_cheatsheet.md](docs/saas_factory_cheatsheet.md) - Comandos rápidos
- [docs/mcp_configuration.md](docs/mcp_configuration.md) - Guía MCP servers
- [docs/postgresql_automatizado.md](docs/postgresql_automatizado.md) - Guía PostgreSQL
- [docs/cloudflare_dns_guide.md](docs/cloudflare_dns_guide.md) - Guía DNS/Tunnel
- [CADDY_CONFIG.md](CADDY_CONFIG.md) - Configuración Caddy

---

**🏭 SaaS Factory v2.0 - De idea a producción en minutos**

¿Necesitas crear otra aplicación? Con v2.0 es aún más rápido:

```bash
# Proyecto completo con todo automático
saas-factory mi-segundo-proyecto mi_segundo_db --create-db --tunnel --deploy

# Con tests incluidos
saas-factory mi-tercer-proyecto mi_tercer_db --create-db --tunnel --with-tests

# Sin MCP (si no usas IA)
saas-factory mi-cuarto-proyecto mi_cuarto_db --create-db --no-mcp
```

**¿Qué hay de nuevo en v2.0?**
- ✅ Base de datos creada y migrada automáticamente
- ✅ MCP configurado por defecto (8 servers)
- ✅ Validación de flags (no más errores)
- ✅ Flujo optimizado de 10 pasos
- ✅ Todo incluido en el commit inicial

¡Y repite el proceso!
