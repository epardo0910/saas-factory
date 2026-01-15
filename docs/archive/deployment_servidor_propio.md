# 🚀 Deployment en Tu Propio Servidor

## Ventajas de Tu Setup Actual

Tu infraestructura es **superior** a servicios como Vercel para este tipo de proyectos:

| Aspecto | Vercel | Tu Servidor |
|---------|--------|-------------|
| **Control** | Limitado | Total ✅ |
| **PostgreSQL** | Externo (costo) | Local (gratis) ✅ |
| **Velocidad DB** | 50-200ms | <5ms ✅ |
| **Costo mensual** | $20-100+ | $0 ✅ |
| **Subdominios** | Manual | Automático ✅ |
| **Escalabilidad** | Limitada | Ilimitada ✅ |
| **Ideal para** | MVPs rápidos | Producción ✅ |

## 🎯 Stack de Deployment Recomendado

```
Internet
    ↓
Cloudflare (Proxy + SSL + DDoS Protection)
    ↓
emanuel-server.com
    ↓
Caddy (Reverse Proxy + SSL automático)
    ↓
PM2 (Process Manager)
    ↓
Next.js App (Node.js)
    ↓
PostgreSQL (Local)
```

## 📋 Guía Completa de Deployment

### Paso 1: Crear Proyecto con DNS

```bash
saas-factory mi-app mi_app_db --dns
cd mi-app
```

**Resultado:**
- ✅ Proyecto Next.js completo
- ✅ DNS: `mi-app.emanuel-server.com` → `192.168.1.135`

### Paso 2: Configurar Base de Datos

```bash
# Crear base de datos
createdb mi_app_db

# Ejecutar migraciones
npx prisma migrate dev --name init

# Verificar
npx prisma studio
```

### Paso 3: Configurar Variables de Entorno

```bash
# Editar .env.local
nano .env.local
```

```env
# PostgreSQL (Local)
DATABASE_URL="postgresql://localhost:5432/mi_app_db"

# NextAuth
NEXTAUTH_URL=https://mi-app.emanuel-server.com
NEXTAUTH_SECRET=tu_secret_aqui

# App
NEXT_PUBLIC_APP_NAME=Mi App
NEXT_PUBLIC_APP_URL=https://mi-app.emanuel-server.com
```

### Paso 4: Build de Producción

```bash
# Instalar dependencias de producción
npm ci --production

# Build
npm run build

# Test local
npm start
# → http://localhost:3000
```

### Paso 5: Deploy con PM2

```bash
# Instalar PM2 globalmente (si no lo tienes)
npm install -g pm2

# Iniciar app con PM2
pm2 start npm --name "mi-app" -- start

# Verificar estado
pm2 status

# Ver logs
pm2 logs mi-app

# Guardar configuración
pm2 save

# Auto-start en boot del servidor
pm2 startup
# → Copia y ejecuta el comando que te da
```

### Paso 6: Configurar Caddy (Reverse Proxy)

#### Instalar Caddy (si no lo tienes)

```bash
# Ubuntu/Debian
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

#### Configurar Caddyfile

```bash
sudo nano /etc/caddy/Caddyfile
```

**Agregar tu sitio:**

```caddyfile
mi-app.emanuel-server.com {
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
        output file /var/log/caddy/mi-app.log
    }
}
```

#### Recargar Caddy

```bash
# Verificar configuración
sudo caddy validate --config /etc/caddy/Caddyfile

# Recargar
sudo systemctl reload caddy

# Verificar estado
sudo systemctl status caddy
```

**¡Listo!** SSL automático con Let's Encrypt en ~30 segundos.

### Paso 7: Verificar Deployment

```bash
# Test HTTPS
curl https://mi-app.emanuel-server.com

# Verificar certificado SSL
curl -vI https://mi-app.emanuel-server.com 2>&1 | grep -i ssl
```

## 🔧 Configuración Avanzada

### Múltiples Apps en Puertos Diferentes

```bash
# App 1 en puerto 3000
pm2 start npm --name "app-1" -- start

# App 2 en puerto 3001
cd ../app-2
npm run build
PORT=3001 pm2 start npm --name "app-2" -- start

# App 3 en puerto 3002
cd ../app-3
npm run build
PORT=3002 pm2 start npm --name "app-3" -- start
```

**Caddyfile para múltiples apps:**

```caddyfile
app-1.emanuel-server.com {
    reverse_proxy localhost:3000
}

app-2.emanuel-server.com {
    reverse_proxy localhost:3001
}

app-3.emanuel-server.com {
    reverse_proxy localhost:3002
}
```

### Auto-Deploy con Git Hooks

```bash
# En tu servidor, crear bare repository
mkdir -p ~/repos/mi-app.git
cd ~/repos/mi-app.git
git init --bare

# Crear post-receive hook
nano hooks/post-receive
```

```bash
#!/bin/bash
TARGET="/home/epardo/mi-app"
GIT_DIR="/home/epardo/repos/mi-app.git"

while read oldrev newrev ref
do
    if [[ $ref =~ .*/main$ ]]; then
        echo "Deploying main branch..."
        git --work-tree=$TARGET --git-dir=$GIT_DIR checkout -f main
        cd $TARGET
        npm install
        npm run build
        pm2 restart mi-app
        echo "Deploy completed!"
    fi
done
```

```bash
chmod +x hooks/post-receive
```

**En tu máquina local:**

```bash
git remote add production epardo@emanuel-server.com:~/repos/mi-app.git
git push production main
```

### Monitoreo con PM2

```bash
# Dashboard en tiempo real
pm2 monit

# Logs en tiempo real
pm2 logs mi-app --lines 100

# Reiniciar app
pm2 restart mi-app

# Recargar sin downtime
pm2 reload mi-app

# Detener app
pm2 stop mi-app

# Eliminar app
pm2 delete mi-app

# Listar todas las apps
pm2 list
```

### Backup Automático de Base de Datos

```bash
# Crear script de backup
nano ~/scripts/backup-db.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/home/epardo/backups/databases"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="mi_app_db"

mkdir -p $BACKUP_DIR

# Backup
pg_dump $DB_NAME | gzip > $BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz

# Mantener solo últimos 7 días
find $BACKUP_DIR -name "${DB_NAME}_*.sql.gz" -mtime +7 -delete

echo "Backup completado: ${DB_NAME}_${DATE}.sql.gz"
```

```bash
chmod +x ~/scripts/backup-db.sh

# Agregar a crontab (diario a las 3 AM)
crontab -e
```

```cron
0 3 * * * /home/epardo/scripts/backup-db.sh
```

## 🔒 Seguridad

### Firewall (UFW)

```bash
# Habilitar firewall
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable

# Verificar
sudo ufw status
```

### Fail2Ban para SSH

```bash
# Instalar
sudo apt install fail2ban

# Configurar
sudo nano /etc/fail2ban/jail.local
```

```ini
[sshd]
enabled = true
port = 22
maxretry = 3
bantime = 3600
```

```bash
sudo systemctl restart fail2ban
```

### Variables de Entorno Seguras

```bash
# NO subir .env.local a Git
echo ".env.local" >> .gitignore

# Usar permisos restrictivos
chmod 600 .env.local
```

## 📊 Monitoreo y Logs

### Ver Logs de Aplicación

```bash
# PM2 logs
pm2 logs mi-app --lines 200

# Logs de Caddy
sudo tail -f /var/log/caddy/mi-app.log

# Logs de PostgreSQL
sudo tail -f /var/log/postgresql/postgresql-*.log
```

### Métricas con PM2 Plus (Opcional)

```bash
pm2 plus
# Seguir instrucciones para monitoring avanzado
```

## 🚀 Script de Deploy Completo

```bash
# deploy.sh
#!/bin/bash

APP_NAME="mi-app"
APP_DIR="/home/epardo/$APP_NAME"
DB_NAME="${APP_NAME//-/_}_db"

echo "🚀 Deploying $APP_NAME..."

# 1. Pull latest changes
cd $APP_DIR
git pull origin main

# 2. Install dependencies
npm ci --production

# 3. Run migrations
npx prisma migrate deploy

# 4. Build
npm run build

# 5. Restart app
pm2 restart $APP_NAME

# 6. Verificar estado
pm2 status $APP_NAME

echo "✅ Deploy completado!"
```

## 🎯 Workflow Completo

```bash
# 1. Crear proyecto
saas-factory mi-crm crm_db --dns

# 2. Desarrollo local
cd mi-crm
createdb crm_db
npx prisma migrate dev --name init
npm run dev

# 3. Commit cambios
git add .
git commit -m "feat: Initial version"

# 4. Deploy a producción
npm run build
pm2 start npm --name "mi-crm" -- start
pm2 save

# 5. Configurar proxy
sudo nano /etc/caddy/Caddyfile
# Agregar: mi-crm.emanuel-server.com { reverse_proxy localhost:3000 }
sudo systemctl reload caddy

# 6. Verificar
curl https://mi-crm.emanuel-server.com
```

## 💡 Tips Pro

### 1. Usar diferentes puertos por proyecto

```bash
# package.json
{
  "scripts": {
    "start": "next start -p 3001"
  }
}
```

### 2. Variables de entorno en PM2

```bash
pm2 start npm --name "mi-app" -- start \
  --update-env \
  --env production
```

### 3. Cluster mode para apps de alto tráfico

```bash
pm2 start npm --name "mi-app" -i max -- start
# -i max = usa todos los CPUs disponibles
```

### 4. Health checks automáticos

```bash
# ecosystem.config.js
module.exports = {
  apps: [{
    name: 'mi-app',
    script: 'npm',
    args: 'start',
    instances: 2,
    exec_mode: 'cluster',
    max_memory_restart: '500M',
    env: {
      NODE_ENV: 'production'
    }
  }]
}

pm2 start ecosystem.config.js
```

## 📈 Escalabilidad

Tu servidor puede manejar **múltiples aplicaciones SaaS** simultáneamente:

```
emanuel-server.com (192.168.1.135)
├── crm-acme.emanuel-server.com → :3000
├── dashboard-beta.emanuel-server.com → :3001
├── api-gamma.emanuel-server.com → :3002
├── admin-delta.emanuel-server.com → :3003
└── ...hasta 65535 puertos disponibles
```

---

## 🎉 Resultado Final

Con este setup tienes:

- ✅ **Deploy en segundos** con PM2
- ✅ **SSL automático** con Caddy
- ✅ **Subdominios automáticos** con Cloudflare
- ✅ **PostgreSQL local** (sin latencia)
- ✅ **Logs centralizados** con PM2 y Caddy
- ✅ **Auto-restart** en crashes
- ✅ **Zero downtime** deploys
- ✅ **Costo $0** (todo en tu servidor)

**Tu infraestructura es enterprise-grade. 🚀**
