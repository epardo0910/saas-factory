# 🔐 Caddy - Reverse Proxy y SSL Automático

**Configuración recomendada para SaaS Factory**

---

## 🚀 Integración Automática con SaaS Factory v2.0

SaaS Factory puede configurar Caddy automáticamente usando el flag `--deploy`:

```bash
# Deploy automático completo
saas-factory mi-app mi_db --create-db --tunnel --deploy

# Esto ejecuta automáticamente:
# [1-8]  Crear proyecto + DB + MCP
# [9]    Build de producción (npm run build)
# [10]   PM2 start en puerto asignado
# [11]   Configuración de Caddyfile
# [12]   Reload de Caddy (SSL automático)
```

**Resultado:**
- ✅ App corriendo con PM2
- ✅ Reverse proxy configurado en Caddy
- ✅ SSL automático de Let's Encrypt
- ✅ Disponible en `https://mi-app.emanuel-server.com`

**Flujo automático del flag --deploy:**

1. **Build de producción**: `npm run build`
2. **PM2 Start**: Inicia la app en el puerto configurado
3. **Caddy Config**: Agrega entrada al Caddyfile
4. **SSL Automático**: Caddy obtiene certificado de Let's Encrypt

**⚠️ Recomendación:** Usa `--deploy` junto con `--create-db` para un deploy completamente automático:

```bash
saas-factory mi-app mi_db --create-db --tunnel --deploy
# ↑ Todo listo en un solo comando
```

**Sin --deploy (manual):** Sigue la guía de "Workflow con SaaS Factory" más abajo para configurar manualmente.

---

## ⚡ ¿Por qué Caddy?

| Aspecto | Nginx | Caddy |
|---------|-------|-------|
| **SSL Automático** | ❌ Manual (certbot) | ✅ Automático |
| **Configuración** | ~25 líneas | ~3 líneas |
| **Renovación SSL** | Cronjob | Automática |
| **Hot Reload** | Manual | Automático |

---

## 🚀 Quick Start

### Instalar Caddy

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

### Verificar Instalación

```bash
caddy version
sudo systemctl status caddy
```

---

## 📝 Configuración Básica

Edita el Caddyfile:

```bash
sudo nano /etc/caddy/Caddyfile
```

### Una Aplicación

```caddyfile
mi-app.emanuel-server.com {
    reverse_proxy localhost:3000
}
```

**¡Eso es todo!** Caddy automáticamente:
- ✅ Obtiene certificado SSL de Let's Encrypt
- ✅ Configura HTTPS
- ✅ Redirige HTTP → HTTPS
- ✅ Renueva certificados automáticamente

### Múltiples Aplicaciones

```caddyfile
# App 1
app-1.emanuel-server.com {
    reverse_proxy localhost:3000
}

# App 2
app-2.emanuel-server.com {
    reverse_proxy localhost:3001
}

# App 3
app-3.emanuel-server.com {
    reverse_proxy localhost:3002
}
```

---

## 🛠️ Workflow con SaaS Factory (Manual)

**Si NO usaste el flag `--deploy`, sigue estos pasos:**

### Opción A: Con base de datos automática (Recomendado v2.0)

```bash
# 1. Crear proyecto con DB automática
saas-factory mi-crm crm_db --create-db --tunnel

# 2. Setup (ya está casi todo listo)
cd mi-crm
npm run build

# 3. PM2
pm2 start npm --name "mi-crm" -- start
pm2 save

# 4. Caddy (agregar al Caddyfile)
sudo nano /etc/caddy/Caddyfile
```

Agregar:
```caddyfile
mi-crm.emanuel-server.com {
    reverse_proxy localhost:3000
}
```

```bash
# 5. Recargar Caddy
sudo systemctl reload caddy

# ✅ Listo! https://mi-crm.emanuel-server.com
```

### Opción B: Sin base de datos automática

```bash
# 1. Crear proyecto
saas-factory mi-crm crm_db --tunnel

# 2. Setup DB manualmente
cd mi-crm
docker exec jscamp-infojobs-strapi-db psql -U strapi -d postgres -c "CREATE DATABASE crm_db;"
npx prisma migrate dev --name init

# 3. Build y PM2
npm run build
pm2 start npm --name "mi-crm" -- start
pm2 save

# 4. Caddy
sudo nano /etc/caddy/Caddyfile
# (agregar configuración como arriba)
sudo systemctl reload caddy
```

---

## 🔧 Configuración Avanzada

### Con Headers de Seguridad

```caddyfile
mi-app.emanuel-server.com {
    reverse_proxy localhost:3000
    
    header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
}
```

### Con Logs

```caddyfile
mi-app.emanuel-server.com {
    reverse_proxy localhost:3000
    encode gzip
    
    log {
        output file /var/log/caddy/mi-app.log
    }
}
```

### WebSockets (Next.js Hot Reload)

```caddyfile
mi-app.emanuel-server.com {
    reverse_proxy localhost:3000 {
        header_up X-Real-IP {remote_host}
        header_up X-Forwarded-For {remote_host}
        header_up X-Forwarded-Proto {scheme}
    }
}
```

---

## 📊 Comandos Útiles

```bash
# Ver estado
sudo systemctl status caddy

# Recargar configuración (sin downtime)
sudo systemctl reload caddy

# Reiniciar
sudo systemctl restart caddy

# Verificar configuración
sudo caddy validate --config /etc/caddy/Caddyfile

# Ver logs
sudo journalctl -u caddy -f

# Ver certificados
sudo caddy list-certificates
```

---

## 🔄 Script de Deploy Automatizado

Crea un script para deployment con Caddy:

```bash
nano ~/deploy-with-caddy.sh
```

```bash
#!/bin/bash

APP_NAME=$1
APP_PORT=${2:-3000}
DOMAIN="${APP_NAME}.emanuel-server.com"

if [ -z "$APP_NAME" ]; then
    echo "Uso: $0 <app-name> [port]"
    exit 1
fi

echo "🚀 Deploying $APP_NAME..."

# 1. Build y PM2
cd "/home/epardo/$APP_NAME"
npm run build
PORT=$APP_PORT pm2 start npm --name "$APP_NAME" -- start
pm2 save

# 2. Agregar a Caddyfile si no existe
if ! grep -q "$DOMAIN" /etc/caddy/Caddyfile; then
    echo "
$DOMAIN {
    reverse_proxy localhost:$APP_PORT
    encode gzip
}
" | sudo tee -a /etc/caddy/Caddyfile > /dev/null
fi

# 3. Recargar Caddy
sudo systemctl reload caddy

echo "✅ Deployed!"
echo "🌐 URL: https://$DOMAIN"
```

```bash
chmod +x ~/deploy-with-caddy.sh

# Uso
~/deploy-with-caddy.sh mi-app 3000
```

---

## 🆚 Migrar de Nginx a Caddy

Si tienes apps con Nginx:

```bash
# 1. Detener Nginx
sudo systemctl stop nginx
sudo systemctl disable nginx

# 2. Activar Caddy
sudo systemctl enable caddy
sudo systemctl start caddy

# 3. Configurar apps en Caddyfile
sudo nano /etc/caddy/Caddyfile
```

---

## ✅ Resumen

### Con SaaS Factory v2.0

**Deploy automático (Recomendado):**
```bash
saas-factory mi-app mi_db --create-db --tunnel --deploy
# ✅ Todo configurado: DB + MCP + PM2 + Caddy + SSL
```

**Deploy manual:**
- **Caddy** es la opción recomendada para SaaS Factory
- **SSL automático** sin configuración adicional
- **3 líneas** por aplicación en Caddyfile
- **Zero downtime** en recargas

```caddyfile
# Configuración mínima
mi-app.emanuel-server.com {
    reverse_proxy localhost:3000
}
```

### Ventajas de Caddy

- ✅ SSL automático de Let's Encrypt
- ✅ Renovación automática de certificados
- ✅ Configuración simple (vs 25 líneas de Nginx)
- ✅ Hot reload sin downtime
- ✅ Redirección HTTP → HTTPS automática

---

**🏭 SaaS Factory v2.0 + Caddy = Deploy en un comando**
