# 🔧 Setup de Cloudflare DNS - Guía Paso a Paso

## Paso 1: Obtener Zone ID

### Opción A: Desde el Dashboard (Más fácil)

1. Ve a: https://dash.cloudflare.com
2. Haz clic en tu dominio **emanuel-server.com**
3. En la barra lateral derecha, busca la sección **"API"**
4. Verás **"Zone ID"** - Cópialo

**Ubicación exacta:**
```
Dashboard → emanuel-server.com → Overview (abajo a la derecha)
```

### Opción B: Usando el navegador

1. Ve a: https://dash.cloudflare.com
2. Abre las herramientas de desarrollador (F12)
3. Ve a la pestaña **Network**
4. Recarga la página
5. Busca una petición que contenga `/zones/`
6. El Zone ID aparecerá en la URL

## Paso 2: Crear API Token con Permisos Correctos

El token actual necesita permisos adicionales. Vamos a crear uno nuevo:

1. Ve a: https://dash.cloudflare.com/profile/api-tokens
2. Haz clic en **"Create Token"**
3. Selecciona el template **"Edit zone DNS"**
4. Configura los permisos:

```
Permissions:
  ✅ Zone → DNS → Edit
  ✅ Zone → Zone → Read

Zone Resources:
  ✅ Include → Specific zone → emanuel-server.com
```

5. **Continue to summary**
6. **Create Token**
7. **Copia el token** (se muestra solo una vez)

## Paso 3: Configurar Variables de Entorno

Una vez que tengas ambos valores:

```bash
# Configurar permanentemente
echo 'export CLOUDFLARE_API_TOKEN="tu_nuevo_token"' >> ~/.bashrc
echo 'export CLOUDFLARE_ZONE_ID="tu_zone_id"' >> ~/.bashrc
echo 'export CLOUDFLARE_DOMAIN="emanuel-server.com"' >> ~/.bashrc
source ~/.bashrc

# Verificar configuración
echo "API Token: $CLOUDFLARE_API_TOKEN"
echo "Zone ID: $CLOUDFLARE_ZONE_ID"
echo "Domain: $CLOUDFLARE_DOMAIN"
```

## Paso 4: Probar la Configuración

```bash
# Test 1: Listar registros DNS existentes
cd /home/epardo/projects/saas-factory
./scripts/cloudflare-dns.sh list

# Test 2: Verificar un subdominio
./scripts/cloudflare-dns.sh verify test

# Test 3: Crear un subdominio de prueba
./scripts/cloudflare-dns.sh create test-saas 192.168.1.100

# Test 4: Eliminar el subdominio de prueba
./scripts/cloudflare-dns.sh delete test-saas
```

## Troubleshooting

### Error: "No route for that URI"

**Causa**: El token no tiene los permisos correctos.

**Solución**: Crear un nuevo token con los permisos indicados en el Paso 2.

### Error: "Zone ID inválido"

**Causa**: El Zone ID no corresponde a emanuel-server.com.

**Solución**: Verificar el Zone ID en el dashboard de Cloudflare.

### Error: "API token not found"

**Causa**: El token ha expirado o fue eliminado.

**Solución**: Crear un nuevo token siguiendo el Paso 2.

## Estructura de Permisos del Token

Para máxima seguridad, el token debe tener:

```
Tipo: API Token (no API Key)

Permisos:
  ✅ Zone.DNS.Edit    - Para crear/editar/eliminar registros DNS
  ✅ Zone.Zone.Read   - Para leer información de la zona

Restricciones:
  ✅ Solo emanuel-server.com
  ✅ No acceso a otros dominios
  ✅ Sin permisos de administración
```

## Obtener Zone ID mediante Script

Si prefieres usar un script, una vez que tengas el token correcto:

```bash
# Script para obtener Zone ID
curl -X GET "https://api.cloudflare.com/v4/zones" \
  -H "Authorization: Bearer TU_NUEVO_TOKEN" \
  -H "Content-Type: application/json" | \
  python3 -c "import sys, json; zones = json.load(sys.stdin)['result']; print(next((z['id'] for z in zones if z['name'] == 'emanuel-server.com'), 'No encontrado'))"
```

## Una Vez Configurado

Ya podrás usar SaaS Factory con DNS automático:

```bash
# Crear proyecto con subdominio
saas-factory mi-app mi_app_db --dns

# Resultado: mi-app.emanuel-server.com → IP de tu servidor
```

---

**¿Necesitas ayuda?**
- Contacto: https://github.com/epardo0910/saas-factory/issues
