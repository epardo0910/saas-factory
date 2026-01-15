# 🔑 Crear API Token de Cloudflare con Permisos Correctos

## ⚠️ Problema Actual

El token actual (`6sfb00L5dHmYV-ozgr1Nqut9g58q3xDMpCKNzku8`) **no tiene los permisos necesarios** para gestionar DNS.

Error recibido: `"No route for that URI"` - Esto significa que el token no puede acceder a las rutas de la API de DNS.

## ✅ Solución: Crear Nuevo Token

### Paso 1: Ve a la Página de API Tokens

🔗 **https://dash.cloudflare.com/profile/api-tokens**

### Paso 2: Crear Nuevo Token

1. Click en el botón azul **"Create Token"**

2. Busca el template **"Edit zone DNS"** y haz click en **"Use template"**

### Paso 3: Configurar Permisos

Ya viene preconfigurado, pero verifica que tenga:

```
Permissions:
  ✅ Zone · DNS · Edit
  ✅ Zone · Zone · Read

Zone Resources:
  ✅ Include · Specific zone · emanuel-server.com
```

**IMPORTANTE**: En "Zone Resources", selecciona:
- **Include** (no "All zones")
- **Specific zone**
- **emanuel-server.com**

### Paso 4: Opcional - Restricciones Adicionales

Para mayor seguridad, puedes agregar:

```
IP Address Filtering:
  Tu IP del servidor (opcional)

TTL (Time to Live):
  Configurar fecha de expiración (opcional)
```

### Paso 5: Crear y Copiar el Token

1. Click en **"Continue to summary"**
2. Revisa que todo esté correcto
3. Click en **"Create Token"**
4. **IMPORTANTE**: El token se muestra **solo una vez**
5. **Cópialo inmediatamente** - Algo como: `xY4kL9m...` (40+ caracteres)

### Paso 6: Configurar en el Servidor

Una vez que tengas el nuevo token:

```bash
# Opción A: Configuración automática (Recomendada)
cd /home/epardo/projects/saas-factory
./scripts/setup-cloudflare.sh

# El script te pedirá:
# 1. Zone ID: f34695ae8b9f6efe0f3eb4eebf34496a
# 2. API Token: [tu_nuevo_token_aquí]
```

```bash
# Opción B: Configuración manual
echo 'export CLOUDFLARE_API_TOKEN="tu_nuevo_token"' >> ~/.bashrc
echo 'export CLOUDFLARE_ZONE_ID="f34695ae8b9f6efe0f3eb4eebf34496a"' >> ~/.bashrc
echo 'export CLOUDFLARE_DOMAIN="emanuel-server.com"' >> ~/.bashrc
source ~/.bashrc

# Probar
cd /home/epardo/projects/saas-factory
./scripts/cloudflare-dns.sh list
```

## 🧪 Verificar que Funciona

```bash
# Listar registros DNS
./scripts/cloudflare-dns.sh list

# Si ves una lista de dominios, ¡funciona! ✅
# Si ves un error, revisa los permisos del token
```

## 📸 Ayuda Visual

### Ubicación del Botón "Create Token"

```
Cloudflare Dashboard
  └── Profile (icono de usuario arriba a la derecha)
       └── API Tokens
            └── [Create Token] ← Click aquí
```

### Seleccionar Template

```
Create API Token
  └── API token templates
       └── Edit zone DNS [Use template] ← Click aquí
```

### Configurar Zona Específica

```
Zone Resources
  [ Include ▼ ] [ Specific zone ▼ ] [ emanuel-server.com ▼ ]
       ↑                ↑                    ↑
    Asegúrate      Seleccionar        Tu dominio
    que diga       "Specific zone"
    "Include"
```

## ❓ FAQs

### ¿Por qué el token actual no funciona?

El token fue creado sin los permisos de **"Zone DNS Edit"**. Cloudflare requiere permisos específicos para cada tipo de operación.

### ¿Puedo usar el mismo token para múltiples dominios?

Sí, pero por seguridad es mejor crear un token específico para cada dominio.

### ¿Qué pasa si pierdo el token?

No hay problema, solo creas uno nuevo y actualizas la configuración. El anterior dejará de funcionar.

### ¿El token expira?

Depende de cómo lo configures. Por defecto, no expira, pero puedes configurar una fecha de expiración por seguridad.

## 🎯 Después de Configurar

Una vez que tengas el token configurado correctamente:

```bash
# Crear proyecto con DNS automático
saas-factory mi-crm crm_db --dns

# Resultado:
# ✅ Proyecto creado
# ✅ Base de datos configurada
# ✅ DNS creado: mi-crm.emanuel-server.com → Tu IP
```

---

## 📝 Resumen de Datos

```
Zone ID:     f34695ae8b9f6efe0f3eb4eebf34496a
Domain:      emanuel-server.com
Token Viejo: 6sfb00L5dHmYV-ozgr1Nqut9g58q3xDMpCKNzku8 (sin permisos)
Token Nuevo: [Créalo siguiendo los pasos de arriba]
```

**🔗 Link directo para crear token:**
https://dash.cloudflare.com/profile/api-tokens/create

Selecciona el template **"Edit zone DNS"** y sigue los pasos.

---

**¿Necesitas más ayuda?** Puedo guiarte paso a paso por el proceso.
