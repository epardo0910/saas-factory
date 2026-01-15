# 🌐 Guía de Cloudflare DNS para SaaS Factory

## Introducción

**SaaS Factory** puede crear automáticamente subdominios en tu dominio **emanuel-server.com** usando la API de Cloudflare. Esto te permite tener URLs personalizadas para cada proyecto inmediatamente después de crearlo.

## ⚡ Quick Start

### 1. Configurar Credenciales de Cloudflare

```bash
# Agregar al final de ~/.bashrc o ~/.zshrc

# API Token (Recomendado)
export CLOUDFLARE_API_TOKEN="tu_api_token_aqui"
export CLOUDFLARE_ZONE_ID="tu_zone_id_aqui"
export CLOUDFLARE_DOMAIN="emanuel-server.com"

# Recargar configuración
source ~/.bashrc
```

### 2. Crear Proyecto con DNS

```bash
# Sintaxis
saas-factory <nombre-proyecto> [db-name] --dns

# Ejemplo
saas-factory mi-crm crm_db --dns
# Crea: mi-crm.emanuel-server.com → IP de tu servidor
```

## 📋 Obtener Credenciales de Cloudflare

### Paso 1: Obtener API Token

1. Ve a: https://dash.cloudflare.com/profile/api-tokens
2. Click en **"Create Token"**
3. Usa el template **"Edit zone DNS"**
4. Configura:
   - **Permissions**:
     - Zone → DNS → Edit
     - Zone → Zone → Read
   - **Zone Resources**:
     - Include → Specific zone → emanuel-server.com
5. Click **"Continue to summary"** → **"Create Token"**
6. **Copia el token** (solo se muestra una vez)

### Paso 2: Obtener Zone ID

1. Ve a tu dashboard de Cloudflare
2. Selecciona el dominio **emanuel-server.com**
3. En la barra lateral derecha, busca **"Zone ID"**
4. Copia el ID

### Paso 3: Configurar Variables de Entorno

```bash
# Opción 1: Configuración permanente (Recomendado)
echo 'export CLOUDFLARE_API_TOKEN="tu_token"' >> ~/.bashrc
echo 'export CLOUDFLARE_ZONE_ID="tu_zone_id"' >> ~/.bashrc
echo 'export CLOUDFLARE_DOMAIN="emanuel-server.com"' >> ~/.bashrc
source ~/.bashrc

# Opción 2: Solo para sesión actual
export CLOUDFLARE_API_TOKEN="tu_token"
export CLOUDFLARE_ZONE_ID="tu_zone_id"
export CLOUDFLARE_DOMAIN="emanuel-server.com"

# Verificar configuración
echo $CLOUDFLARE_API_TOKEN
echo $CLOUDFLARE_ZONE_ID
```

## 🛠️ Uso del Script de Cloudflare DNS

SaaS Factory incluye un script standalone para gestionar DNS:

### Crear Subdominio

```bash
# Sintaxis
./scripts/cloudflare-dns.sh create <subdominio> <ip>

# Ejemplo
./scripts/cloudflare-dns.sh create mi-app 192.168.1.100
# Crea: mi-app.emanuel-server.com → 192.168.1.100
```

### Eliminar Subdominio

```bash
./scripts/cloudflare-dns.sh delete mi-app
```

### Listar Subdominios

```bash
./scripts/cloudflare-dns.sh list
```

### Verificar Subdominio

```bash
./scripts/cloudflare-dns.sh verify mi-app
```

## 🚀 Flujo Completo de Trabajo

### Escenario 1: Proyecto para Cliente

```bash
# 1. Crear proyecto con DNS automático
saas-factory crm-acme acme_crm_db --dns
# Resultado: crm-acme.emanuel-server.com

# 2. Configurar proyecto
cd crm-acme
createdb acme_crm_db
npx prisma migrate dev --name init

# 3. Desplegar
npm run build
pm2 start npm --name "crm-acme" -- start

# 4. Configurar proxy reverso (Nginx/Caddy)
# Ya tienes el subdominio listo!
```

### Escenario 2: Múltiples Ambientes

```bash
# Desarrollo
saas-factory myapp-dev myapp_dev_db --dns
# myapp-dev.emanuel-server.com

# Staging
saas-factory myapp-staging myapp_staging_db --dns
# myapp-staging.emanuel-server.com

# Producción
saas-factory myapp-prod myapp_prod_db --dns
# myapp-prod.emanuel-server.com
```

### Escenario 3: Crear DNS Después

```bash
# Crear proyecto sin DNS
saas-factory mi-app

# Después, crear DNS manualmente
cd mi-app
../scripts/cloudflare-dns.sh create mi-app $(hostname -I | awk '{print $1}')
```

## ⚙️ Configuración Avanzada

### Usar IP Específica

```bash
# En lugar de la IP automática, especificar una IP
saas-factory mi-app mi_app_db --dns

# Luego actualizar con IP específica
./scripts/cloudflare-dns.sh create mi-app 203.0.113.10
```

### Configurar con IP Pública

```bash
# Obtener tu IP pública
MY_PUBLIC_IP=$(curl -s ifconfig.me)

# Crear DNS con IP pública
./scripts/cloudflare-dns.sh create mi-app $MY_PUBLIC_IP
```

### Usar Proxy de Cloudflare

Editar `scripts/cloudflare-dns.sh` y cambiar:

```bash
"proxied": false  →  "proxied": true
```

Beneficios del proxy:
- ✅ DDoS protection
- ✅ CDN global
- ✅ Certificado SSL automático
- ✅ Oculta tu IP real

## 🔒 Seguridad

### Mejores Prácticas

1. **Usa API Token en lugar de API Key**
   - Más seguro y específico
   - Puede ser revocado sin afectar otros servicios

2. **Permisos Mínimos**
   - Solo `Zone DNS Edit` + `Zone Read`
   - Específico para emanuel-server.com

3. **No compartas tokens**
   - No los subas a Git
   - Usa archivos `.env` en `.gitignore`

4. **Rota tokens periódicamente**
   - Crea nuevo token cada 3-6 meses
   - Revoca el anterior

### Almacenamiento Seguro

```bash
# Opción 1: Variables de entorno en .bashrc
# (Ya configurado)

# Opción 2: Archivo de configuración
mkdir -p ~/.config/saas-factory
cat > ~/.config/saas-factory/cloudflare.conf <<EOF
CLOUDFLARE_API_TOKEN=tu_token
CLOUDFLARE_ZONE_ID=tu_zone_id
CLOUDFLARE_DOMAIN=emanuel-server.com
EOF
chmod 600 ~/.config/saas-factory/cloudflare.conf

# Cargar en scripts
source ~/.config/saas-factory/cloudflare.conf
```

## 🌐 Integración con Nginx/Caddy

### Nginx

```nginx
# /etc/nginx/sites-available/mi-app.emanuel-server.com

server {
    listen 80;
    server_name mi-app.emanuel-server.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Activar sitio
sudo ln -s /etc/nginx/sites-available/mi-app.emanuel-server.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Caddy (Recomendado)

```caddyfile
# /etc/caddy/Caddyfile

mi-app.emanuel-server.com {
    reverse_proxy localhost:3000
    encode gzip

    # SSL automático (Let's Encrypt)
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
}
```

```bash
sudo systemctl reload caddy
```

## 📊 Ejemplos de Uso

### Crear múltiples subdominios

```bash
# Script para crear múltiples apps
APPS=("crm" "dashboard" "api" "admin")

for app in "${APPS[@]}"; do
    saas-factory "${app}-app" "${app}_db" --dns
    echo "✅ ${app}-app.emanuel-server.com creado"
done
```

### Automatizar con CI/CD

```yaml
# .github/workflows/deploy.yml
name: Deploy to emanuel-server.com

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Create DNS Record
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          CLOUDFLARE_ZONE_ID: ${{ secrets.CLOUDFLARE_ZONE_ID }}
        run: |
          curl -X POST "https://api.cloudflare.com/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records" \
            -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
            -H "Content-Type: application/json" \
            --data '{"type":"A","name":"'${{ github.event.repository.name }}'","content":"'${{ secrets.SERVER_IP }}'","ttl":1,"proxied":false}'

      - name: Deploy App
        # ... resto del deploy
```

## 🐛 Troubleshooting

### Error: "API Token no configurado"

```bash
# Verificar variables
echo $CLOUDFLARE_API_TOKEN
echo $CLOUDFLARE_ZONE_ID

# Si están vacías, configurar de nuevo
export CLOUDFLARE_API_TOKEN="tu_token"
export CLOUDFLARE_ZONE_ID="tu_zone_id"
```

### Error: "Subdominio ya existe"

```bash
# Verificar si existe
./scripts/cloudflare-dns.sh verify mi-app

# Si existe y quieres actualizarlo, el script lo actualiza automáticamente
./scripts/cloudflare-dns.sh create mi-app nueva_ip
```

### Error: "Zone ID inválido"

1. Ve al dashboard de Cloudflare
2. Selecciona emanuel-server.com
3. Copia el Zone ID correcto
4. Actualiza la variable:
   ```bash
   export CLOUDFLARE_ZONE_ID="el_id_correcto"
   ```

### DNS no propaga

```bash
# Verificar DNS
dig mi-app.emanuel-server.com

# Forzar actualización DNS local
sudo systemd-resolve --flush-caches  # Linux
sudo dscacheutil -flushcache          # macOS

# Verificar en Cloudflare
./scripts/cloudflare-dns.sh verify mi-app
```

## 📚 Recursos Adicionales

- [Cloudflare API Docs](https://developers.cloudflare.com/api/)
- [Cloudflare DNS API](https://developers.cloudflare.com/api/operations/dns-records-for-a-zone-create-dns-record)
- [API Tokens Best Practices](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)

## 🎯 Próximas Mejoras

- [ ] Soporte para registros CNAME
- [ ] Soporte para SSL automático con Let's Encrypt
- [ ] Dashboard web para gestionar subdominios
- [ ] Integración con PM2 para auto-deploy
- [ ] Wildcard subdomain support
- [ ] Automatic Nginx/Caddy config generation

---

**🌐 Ahora tus proyectos tienen URLs personalizadas en segundos**
