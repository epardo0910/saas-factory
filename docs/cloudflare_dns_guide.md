# 🌐 Cloudflare DNS - Guía Completa

**SaaS Factory** puede crear automáticamente subdominios en tu dominio usando la API de Cloudflare.

---

## ⚡ Quick Start (Ya Configurado)

Tu sistema ya está configurado y listo para usar:

```bash
# Crear proyecto con DNS automático
saas-factory mi-app mi_db --dns

# Resultado:
# ✅ Proyecto: mi-app/
# ✅ DNS: mi-app.emanuel-server.com → 192.168.1.135
```

### Configuración Actual

```bash
API Token: XLZjWhP76OYrfhdN7n_E4ItLgmtmiyJW8DxgbiK3
Zone ID:   f34695ae8b9f6efe0f3eb4eebf34496a
Dominio:   emanuel-server.com
Estado:    ✅ Funcionando
```

---

## 📚 Tabla de Contenidos

1. [Uso Básico](#uso-básico)
2. [Obtener Credenciales](#obtener-credenciales)
3. [Configuración Inicial](#configuración-inicial)
4. [Comandos Disponibles](#comandos-disponibles)
5. [Ejemplos Completos](#ejemplos-completos)
6. [Troubleshooting](#troubleshooting)

---

## 🚀 Uso Básico

### Crear Proyecto con DNS

```bash
saas-factory mi-proyecto mi_proyecto_db --dns
```

Esto automáticamente:
- ✅ Crea el proyecto Next.js
- ✅ Crea el registro DNS en Cloudflare
- ✅ Apunta a tu servidor (192.168.1.135)

### Gestión Manual de DNS

```bash
# Listar subdominios
./scripts/cloudflare-dns.sh list

# Crear subdominio
./scripts/cloudflare-dns.sh create mi-app 192.168.1.100

# Verificar subdominio
./scripts/cloudflare-dns.sh verify mi-app

# Eliminar subdominio
./scripts/cloudflare-dns.sh delete mi-app

# Ver información de configuración
./scripts/cloudflare-dns.sh info
```

---

## 🔑 Obtener Credenciales (Si No las Tienes)

### Paso 1: Crear API Token

**1. Acceder a Cloudflare:**
- URL: https://dash.cloudflare.com/profile/api-tokens
- Login con tu cuenta

**2. Crear Token:**
- Click en **"Create Token"**
- Selecciona el template **"Edit zone DNS"**

**3. Configurar Permisos:**

```
Permissions:
  ✅ Zone · DNS · Edit
  ✅ Zone · Zone · Read

Zone Resources:
  ✅ Include · Specific zone · emanuel-server.com
```

**IMPORTANTE:** Selecciona "Specific zone" y luego "emanuel-server.com", no "All zones".

**4. Opcional - Seguridad Adicional:**

```
IP Address Filtering:
  - Agregar IP de tu servidor (opcional)

TTL (Time to Live):
  - Configurar fecha de expiración (opcional)
```

**5. Crear y Copiar:**
- Click **"Continue to summary"**
- Click **"Create Token"**
- **COPIA EL TOKEN** (solo se muestra una vez)
- Ejemplo: `xY4kL9mN2pQ8sT6vU...` (40+ caracteres)

### Paso 2: Obtener Zone ID

**Método 1: Dashboard de Cloudflare**

1. Ve a: https://dash.cloudflare.com
2. Click en **emanuel-server.com**
3. En la barra lateral derecha, busca la sección **"API"**
4. Copia el **Zone ID**

```
Ubicación exacta:
Dashboard → emanuel-server.com → Overview → Barra lateral derecha → API → Zone ID
```

**Método 2: Desde la URL**

Al abrir tu dominio, la URL tendrá este formato:
```
https://dash.cloudflare.com/<ACCOUNT_ID>/emanuel-server.com
```

Nota: El ACCOUNT_ID en la URL NO es el Zone ID. Debes buscarlo en la sección API.

---

## ⚙️ Configuración Inicial

### Setup Interactivo (Recomendado)

```bash
cd /home/epardo/projects/saas-factory
./scripts/setup-cloudflare.sh
```

El script te pedirá:
1. Zone ID
2. API Token
3. Dominio (emanuel-server.com)

Automáticamente:
- ✅ Guarda las variables en ~/.bashrc
- ✅ Verifica la conexión
- ✅ Prueba creando un subdominio de test

### Setup Manual

```bash
# Agregar al final de ~/.bashrc
echo 'export CLOUDFLARE_API_TOKEN="tu_token"' >> ~/.bashrc
echo 'export CLOUDFLARE_ZONE_ID="tu_zone_id"' >> ~/.bashrc
echo 'export CLOUDFLARE_DOMAIN="emanuel-server.com"' >> ~/.bashrc

# Recargar
source ~/.bashrc

# Verificar
echo $CLOUDFLARE_API_TOKEN
echo $CLOUDFLARE_ZONE_ID
echo $CLOUDFLARE_DOMAIN
```

### Verificar Configuración

```bash
# Probar listando subdominios
./scripts/cloudflare-dns.sh list

# Si funciona, verás una lista de tus subdominios existentes
```

---

## 🛠️ Comandos Disponibles

### Script cloudflare-dns.sh

#### CREATE - Crear Subdominio

```bash
./scripts/cloudflare-dns.sh create <subdominio> <ip>
```

**Ejemplo:**
```bash
./scripts/cloudflare-dns.sh create mi-app 192.168.1.135
```

**Salida:**
```
🗄️  Creando registro DNS...
Subdominio: mi-app.emanuel-server.com
IP: 192.168.1.135
✅ Registro DNS creado/actualizado exitosamente
URL: http://mi-app.emanuel-server.com
```

#### LIST - Listar Subdominios

```bash
./scripts/cloudflare-dns.sh list
```

**Salida:**
```
📊 Listando registros DNS para emanuel-server.com...

antigravity.emanuel-server.com (CNAME) → 5eceb54a...cfargotunnel.com
easy-n8n.emanuel-server.com (CNAME) → 5eceb54a...cfargotunnel.com
mi-app.emanuel-server.com (A) → 192.168.1.135
```

#### VERIFY - Verificar Subdominio

```bash
./scripts/cloudflare-dns.sh verify <subdominio>
```

**Ejemplo:**
```bash
./scripts/cloudflare-dns.sh verify mi-app
```

**Salida:**
```
✅ El subdominio existe
Apunta a: 192.168.1.135
```

#### DELETE - Eliminar Subdominio

```bash
./scripts/cloudflare-dns.sh delete <subdominio>
```

**Ejemplo:**
```bash
./scripts/cloudflare-dns.sh delete mi-app
```

**Salida:**
```
⚠️  Eliminando registro DNS: mi-app.emanuel-server.com
✅ Registro DNS eliminado exitosamente
```

---

## 📝 Ejemplos Completos

### Ejemplo 1: Crear CRM Completo

```bash
# 1. Crear proyecto con DNS automático
saas-factory crm-acme acme_crm_db --dns --create-db

# Resultado:
# ✅ Proyecto: crm-acme/
# ✅ DNS: crm-acme.emanuel-server.com → 192.168.1.135
# ✅ DB: acme_crm_db creada

# 2. Configurar proyecto
cd crm-acme
npx prisma migrate dev --name init

# 3. Desarrollo
npm run dev

# 4. Producción
npm run build
pm2 start npm --name "crm-acme" -- start

# 5. Nginx
sudo nano /etc/nginx/sites-available/crm-acme
# Configurar reverse proxy a localhost:3000

sudo ln -s /etc/nginx/sites-available/crm-acme /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 6. SSL
sudo certbot --nginx -d crm-acme.emanuel-server.com

# ✅ Listo! https://crm-acme.emanuel-server.com
```

### Ejemplo 2: Múltiples Ambientes

```bash
# Desarrollo
saas-factory app-dev dev_db --dns --create-db
# → app-dev.emanuel-server.com

# Staging
saas-factory app-staging staging_db --dns --create-db
# → app-staging.emanuel-server.com

# Producción
saas-factory app-prod prod_db --dns --create-db
# → app-prod.emanuel-server.com

# Verificar todos
./scripts/cloudflare-dns.sh list | grep app-
```

### Ejemplo 3: Crear DNS para App Existente

Si ya tienes una app corriendo y solo necesitas crear el DNS:

```bash
# Crear DNS para app existente en puerto 3005
./scripts/cloudflare-dns.sh create mi-app-existente 192.168.1.135

# Configurar Nginx para esa app
sudo nano /etc/nginx/sites-available/mi-app-existente
# proxy_pass http://localhost:3005

# Habilitar y SSL
sudo ln -s /etc/nginx/sites-available/mi-app-existente /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
sudo certbot --nginx -d mi-app-existente.emanuel-server.com
```

### Ejemplo 4: Cambiar IP de un Subdominio

```bash
# Ver IP actual
./scripts/cloudflare-dns.sh verify mi-app

# Cambiar a nueva IP (actualiza automáticamente si existe)
./scripts/cloudflare-dns.sh create mi-app 192.168.1.200

# Verificar cambio
./scripts/cloudflare-dns.sh verify mi-app
```

---

## 🔍 Troubleshooting

### Error: "No route for that URI"

**Causa:** El token no tiene los permisos correctos.

**Solución:**
1. Crear un nuevo token con el template "Edit zone DNS"
2. Asegurarse de incluir permisos:
   - Zone → DNS → Edit
   - Zone → Zone → Read
3. Scope: Specific zone → emanuel-server.com

**Actualizar token:**
```bash
nano ~/.bashrc
# Cambiar CLOUDFLARE_API_TOKEN por el nuevo
source ~/.bashrc
```

### Error: Variables no configuradas

```
❌ Error: Variables de Cloudflare no configuradas
```

**Solución:**
```bash
# Verificar si existen
echo $CLOUDFLARE_API_TOKEN
echo $CLOUDFLARE_ZONE_ID

# Si están vacías, agregar a ~/.bashrc
echo 'export CLOUDFLARE_API_TOKEN="tu_token"' >> ~/.bashrc
echo 'export CLOUDFLARE_ZONE_ID="tu_zone_id"' >> ~/.bashrc
echo 'export CLOUDFLARE_DOMAIN="emanuel-server.com"' >> ~/.bashrc

# Recargar sesión actual
source ~/.bashrc
```

### Error: "El registro ya existe"

```
⚠️  El registro ya existe. Actualizando...
```

**Esto es normal.** El script detecta que el subdominio existe y lo actualiza en lugar de crear uno duplicado.

### Error: Token expirado

**Síntomas:** Funcionaba antes pero ahora da errores de autenticación.

**Solución:**
1. Ve a https://dash.cloudflare.com/profile/api-tokens
2. Revoca el token viejo
3. Crea uno nuevo
4. Actualiza en ~/.bashrc

### DNS no resuelve

**Verificar propagación:**
```bash
# Verificar en Cloudflare
./scripts/cloudflare-dns.sh verify mi-app

# Verificar DNS local
dig mi-app.emanuel-server.com +short

# Verificar desde otro servidor
nslookup mi-app.emanuel-server.com 8.8.8.8
```

**Nota:** La propagación DNS puede tardar hasta 5 minutos, pero generalmente es instantáneo con Cloudflare.

### Permisos insuficientes

```
❌ Error: Insufficient permissions
```

**Causa:** El token no tiene acceso a emanuel-server.com

**Solución:**
1. Verificar que el token incluya: Zone Resources → Specific zone → emanuel-server.com
2. No usar "All zones" sino "Specific zone"

---

## 🔒 Seguridad

### Mejores Prácticas

1. **Usar API Token** (no API Key global)
   - Token tiene permisos específicos
   - Puede ser revocado sin afectar otros servicios

2. **Scope mínimo necesario**
   - Solo "Edit zone DNS" y "Zone Read"
   - Solo para emanuel-server.com

3. **No compartir el token**
   - Mantenerlo en ~/.bashrc (no en repos Git)
   - No incluirlo en archivos públicos

4. **Revisar tokens periódicamente**
   - https://dash.cloudflare.com/profile/api-tokens
   - Revocar tokens no usados

5. **Considerar expiración**
   - Configurar TTL en tokens para ambientes temporales
   - Tokens permanentes solo para producción

### Revocar Token

Si el token se compromete:

1. Ve a: https://dash.cloudflare.com/profile/api-tokens
2. Encuentra el token
3. Click en "Revoke"
4. Crea uno nuevo
5. Actualiza ~/.bashrc

---

## 📊 Subdominios Actuales

Ya tienes **40+ subdominios** configurados en emanuel-server.com:

### Algunos ejemplos:
- antigravity.emanuel-server.com
- easy-n8n.emanuel-server.com
- easypanel.emanuel-server.com
- files.emanuel-server.com
- grafana.emanuel-server.com
- pgadmin.emanuel-server.com
- ssh.emanuel-server.com

Ver todos:
```bash
./scripts/cloudflare-dns.sh list
```

---

## 🎯 Workflows Recomendados

### Workflow 1: Desarrollo → Producción

```bash
# 1. Crear proyecto dev
saas-factory mi-app-dev dev_db --dns --create-db

# 2. Desarrollar
cd mi-app-dev
npm run dev

# 3. Cuando esté listo, crear producción
cd ..
saas-factory mi-app mi_app_db --dns --create-db

# 4. Copiar código
cp -r mi-app-dev/* mi-app/
cd mi-app

# 5. Deploy
npm run build
pm2 start npm --name "mi-app" -- start

# 6. Nginx + SSL
# ... configurar nginx ...
```

### Workflow 2: Testing con Subdominios Temporales

```bash
# Crear test
./scripts/cloudflare-dns.sh create test-feature-x 192.168.1.135

# Usar para testing
pm2 start npm --name "test-feature-x" -- start

# Cuando termine, eliminar
pm2 delete test-feature-x
./scripts/cloudflare-dns.sh delete test-feature-x
```

---

## 📚 Referencias

- [Script cloudflare-dns.sh](../scripts/cloudflare-dns.sh)
- [Documentación Cloudflare API](https://developers.cloudflare.com/api/)
- [QUICKSTART.md](../QUICKSTART.md) - Guía rápida de deployment
- [deployment_servidor_propio.md](deployment_servidor_propio.md) - Deployment completo

---

## ✅ Resumen

**Estado actual:** ✅ Cloudflare DNS completamente configurado y funcional

**Configuración:**
```
API Token: XLZjWhP76OYrfhdN7n_E4ItLgmtmiyJW8DxgbiK3
Zone ID:   f34695ae8b9f6efe0f3eb4eebf34496a
Dominio:   emanuel-server.com
```

**Uso:**
```bash
# Crear proyecto con DNS
saas-factory mi-app mi_db --dns

# Gestión manual
./scripts/cloudflare-dns.sh create|list|verify|delete
```

**Todo funcionando perfectamente.** 🚀

---

**Última actualización:** 2026-01-15
**Estado:** ✅ OPERATIVO
