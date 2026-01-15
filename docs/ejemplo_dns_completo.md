# 🌐 Ejemplo Completo: Proyecto con DNS Automático

## Caso de Uso: CRM para Cliente con Subdominio Personalizado

Vamos a crear un CRM completo para un cliente llamado "Acme Corp" con su propio subdominio en tu servidor.

## Paso 1: Configurar Cloudflare (Solo una vez)

```bash
# Obtener credenciales de Cloudflare
# 1. API Token: https://dash.cloudflare.com/profile/api-tokens
# 2. Zone ID: Dashboard de emanuel-server.com

# Configurar variables permanentemente
echo 'export CLOUDFLARE_API_TOKEN="tu_api_token_real"' >> ~/.bashrc
echo 'export CLOUDFLARE_ZONE_ID="tu_zone_id_real"' >> ~/.bashrc
echo 'export CLOUDFLARE_DOMAIN="emanuel-server.com"' >> ~/.bashrc
source ~/.bashrc

# Verificar configuración
echo "API Token configurado: $([ -n "$CLOUDFLARE_API_TOKEN" ] && echo 'Sí ✅' || echo 'No ❌')"
echo "Zone ID configurado: $([ -n "$CLOUDFLARE_ZONE_ID" ] && echo 'Sí ✅' || echo 'No ❌')"
```

## Paso 2: Crear Proyecto con DNS Automático

```bash
# Sintaxis: saas-factory <nombre> [db] --dns
saas-factory crm-acme acme_crm_db --dns
```

**Output esperado:**
```
╔═══════════════════════════════════════════════════════╗
║        🏭 SaaS Factory - Full Stack Generator        ║
║   Next.js 14 + PostgreSQL + NextAuth + TypeScript    ║
╚═══════════════════════════════════════════════════════╝

📦 Creando proyecto: crm-acme
🗄️  Base de datos: acme_crm_db
🌐 DNS: crm-acme.emanuel-server.com

[1/8] Inicializando Next.js con TypeScript...
[2/8] Instalando PostgreSQL client y NextAuth.js...
[3/8] Instalando dependencias UI/UX...
[4/8] Creando estructura de carpetas...
[5/8] Generando archivos de configuración...
[6/8] Creando script de setup de base de datos...
[7/8] Generando documentación...
[8/8] Finalizando configuración...

[Bonus] Configurando DNS en Cloudflare...
Creando registro DNS...
Subdominio: crm-acme.emanuel-server.com
IP: 192.168.1.100
✅ Registro DNS creado exitosamente
URL: http://crm-acme.emanuel-server.com

╔═══════════════════════════════════════════════════════╗
║          ✅ ¡Proyecto creado exitosamente!            ║
╚═══════════════════════════════════════════════════════╝

📁 Ubicación: /home/epardo/crm-acme
🗄️  Base de datos: acme_crm_db
🌐 DNS: https://crm-acme.emanuel-server.com

🏭 Happy coding!
```

## Paso 3: Configurar Base de Datos

```bash
cd crm-acme

# Crear base de datos PostgreSQL
createdb acme_crm_db

# Ejecutar migraciones
npx prisma migrate dev --name init

# Verificar en Prisma Studio
npx prisma studio
# → http://localhost:5555
```

## Paso 4: Configurar Variables de Entorno

```bash
# Editar .env.local con los valores correctos
nano .env.local
```

**Contenido de `.env.local`:**
```env
# PostgreSQL
DATABASE_URL="postgresql://localhost:5432/acme_crm_db"

# NextAuth
NEXTAUTH_URL=https://crm-acme.emanuel-server.com
NEXTAUTH_SECRET=tu_secret_generado_automaticamente

# App
NEXT_PUBLIC_APP_NAME=Acme CRM
NEXT_PUBLIC_APP_URL=https://crm-acme.emanuel-server.com
```

## Paso 5: Desarrollo y Testing

```bash
# Iniciar servidor de desarrollo
npm run dev
# → http://localhost:3000

# Probar que funciona
curl http://localhost:3000
```

## Paso 6: Configurar Proxy Reverso (Nginx o Caddy)

### Opción A: Nginx

```bash
# Crear configuración de Nginx
sudo nano /etc/nginx/sites-available/crm-acme.emanuel-server.com
```

```nginx
server {
    listen 80;
    server_name crm-acme.emanuel-server.com;

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
sudo ln -s /etc/nginx/sites-available/crm-acme.emanuel-server.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Instalar SSL con Certbot
sudo certbot --nginx -d crm-acme.emanuel-server.com
```

### Opción B: Caddy (Más fácil, SSL automático)

```bash
# Editar Caddyfile
sudo nano /etc/caddy/Caddyfile
```

```caddyfile
crm-acme.emanuel-server.com {
    reverse_proxy localhost:3000
    encode gzip
}
```

```bash
# Recargar Caddy
sudo systemctl reload caddy

# ¡Listo! SSL automático con Let's Encrypt
```

## Paso 7: Configurar PM2 para Producción

```bash
# Build de producción
npm run build

# Instalar PM2
npm install -g pm2

# Iniciar con PM2
pm2 start npm --name "crm-acme" -- start

# Guardar configuración
pm2 save

# Configurar auto-start en boot
pm2 startup
```

## Paso 8: Verificar Todo Funciona

```bash
# 1. Verificar DNS
dig crm-acme.emanuel-server.com

# 2. Verificar en navegador
curl https://crm-acme.emanuel-server.com

# 3. Verificar proceso
pm2 status

# 4. Verificar logs
pm2 logs crm-acme
```

## Resultado Final

🎉 **Ya tienes un CRM completo en producción:**

- ✅ **URL**: https://crm-acme.emanuel-server.com
- ✅ **Base de datos**: PostgreSQL (acme_crm_db)
- ✅ **Autenticación**: NextAuth.js
- ✅ **SSL**: Let's Encrypt (Caddy automático)
- ✅ **Proceso**: PM2 con auto-restart
- ✅ **DNS**: Cloudflare

## Gestión del Subdominio

### Ver información del DNS

```bash
./scripts/cloudflare-dns.sh verify crm-acme
```

### Cambiar IP del subdominio

```bash
# Si cambias de servidor
./scripts/cloudflare-dns.sh create crm-acme nueva_ip
```

### Eliminar subdominio

```bash
./scripts/cloudflare-dns.sh delete crm-acme
```

### Listar todos los subdominios

```bash
./scripts/cloudflare-dns.sh list
```

## Crear Múltiples Proyectos

```bash
# Proyecto para desarrollo
saas-factory crm-acme-dev acme_crm_dev_db --dns
# → crm-acme-dev.emanuel-server.com

# Proyecto para staging
saas-factory crm-acme-staging acme_crm_staging_db --dns
# → crm-acme-staging.emanuel-server.com

# Proyecto para producción
saas-factory crm-acme-prod acme_crm_prod_db --dns
# → crm-acme-prod.emanuel-server.com
```

## Script de Automatización Completo

Crear un script para automatizar todo el proceso:

```bash
# crear-proyecto-cliente.sh
#!/bin/bash

CLIENTE=$1
PUERTO=$2

if [ -z "$CLIENTE" ] || [ -z "$PUERTO" ]; then
    echo "Uso: $0 <cliente> <puerto>"
    echo "Ejemplo: $0 acme 3001"
    exit 1
fi

PROYECTO="crm-${CLIENTE}"
DB_NAME="${CLIENTE}_crm_db"

echo "🏭 Creando proyecto para ${CLIENTE}..."

# 1. Crear proyecto con DNS
saas-factory "$PROYECTO" "$DB_NAME" --dns

# 2. Entrar al proyecto
cd "$PROYECTO"

# 3. Setup base de datos
createdb "$DB_NAME"
npx prisma migrate dev --name init

# 4. Actualizar puerto en package.json
sed -i "s/3000/$PUERTO/g" package.json

# 5. Build y start con PM2
npm run build
pm2 start npm --name "$PROYECTO" -- start
pm2 save

# 6. Crear configuración de Caddy
cat > "/tmp/${PROYECTO}.caddy" <<EOF
${PROYECTO}.emanuel-server.com {
    reverse_proxy localhost:${PUERTO}
    encode gzip
}
EOF

echo ""
echo "✅ Proyecto creado exitosamente!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Agregar configuración de Caddy: sudo cat /tmp/${PROYECTO}.caddy >> /etc/caddy/Caddyfile"
echo "2. Recargar Caddy: sudo systemctl reload caddy"
echo "3. Visitar: https://${PROYECTO}.emanuel-server.com"
echo ""
```

Usar el script:

```bash
chmod +x crear-proyecto-cliente.sh

# Crear proyecto para Acme
./crear-proyecto-cliente.sh acme 3001

# Crear proyecto para Beta Corp
./crear-proyecto-cliente.sh beta 3002

# Crear proyecto para Gamma Inc
./crear-proyecto-cliente.sh gamma 3003
```

## Monitoreo y Mantenimiento

### Ver todos los proyectos activos

```bash
pm2 list
```

### Ver logs de un proyecto

```bash
pm2 logs crm-acme
```

### Restart de un proyecto

```bash
pm2 restart crm-acme
```

### Ver métricas

```bash
pm2 monit
```

### Backup de base de datos

```bash
# Crear backup
pg_dump acme_crm_db > backups/acme_crm_db_$(date +%Y%m%d).sql

# Restaurar backup
psql acme_crm_db < backups/acme_crm_db_20260115.sql
```

## Tips Pro

### 1. Usar subdominios con wildcards

Si configuras un wildcard DNS (`*.emanuel-server.com`), puedes crear subdominios sin llamar a la API:

```bash
# Solo necesitas configurar el proxy reverso
# El DNS ya resuelve automáticamente
```

### 2. Base de datos remota

Para ambientes de staging/producción, usar base de datos remota:

```env
# .env.local
DATABASE_URL="postgresql://user:pass@db.emanuel-server.com:5432/acme_crm_db"
```

### 3. CI/CD con GitHub Actions

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

      - name: Deploy via SSH
        uses: appleboy/ssh-action@master
        with:
          host: emanuel-server.com
          username: epardo
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /home/epardo/crm-acme
            git pull
            npm install
            npm run build
            pm2 restart crm-acme
```

---

**🌐 Tu infraestructura completa de SaaS en minutos**

**Stack generado:**
- Next.js 14 + PostgreSQL + NextAuth
- Subdominio personalizado en emanuel-server.com
- SSL automático
- PM2 con auto-restart
- Listo para clientes en producción
