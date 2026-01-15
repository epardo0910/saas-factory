# 🔑 Cómo Obtener tu Zone ID de Cloudflare

## Método Rápido (2 minutos)

### Paso 1: Accede a tu Dashboard de Cloudflare

Ve a: **https://dash.cloudflare.com**

### Paso 2: Selecciona tu Dominio

Haz clic en **emanuel-server.com** en la lista de dominios

### Paso 3: Encuentra el Zone ID

En el dashboard de tu dominio:

1. **Scroll down** en la página de Overview
2. En la **barra lateral derecha**, busca la sección **"API"**
3. Verás dos valores:
   - **Zone ID** ← Este es el que necesitas
   - **Account ID**

El **Zone ID** tiene este formato: `abc123def456789...` (32 caracteres)

### Ubicación Exacta

```
Dashboard de Cloudflare
  └── emanuel-server.com (hacer clic aquí)
       └── Overview (pestaña por defecto)
            └── Barra lateral derecha
                 └── Sección "API"
                      └── Zone ID ← ¡AQUÍ!
```

---

## Método Alternativo: Desde la URL

1. Ve a: **https://dash.cloudflare.com**
2. Haz clic en **emanuel-server.com**
3. Observa la URL del navegador:
   ```
   https://dash.cloudflare.com/<ESTE_ES_EL_ACCOUNT_ID>/emanuel-server.com
   ```
4. **NO es el Account ID**, sigue buscando el Zone ID en la sección API

---

## Una Vez que Tengas el Zone ID

Ejecuta el script de configuración interactivo:

```bash
cd /home/epardo/projects/saas-factory
./scripts/setup-cloudflare.sh
```

El script te pedirá:
1. ✅ Zone ID (cópialo del dashboard)
2. ✅ API Token (ya lo tienes: 6sfb00L5dHmYV-ozgr1Nqut9g58q3xDMpCKNzku8)

---

## Configuración Manual (Alternativa)

Si prefieres configurarlo manualmente:

```bash
# Una vez que tengas el Zone ID, reemplaza ZONE_ID_AQUI:
echo 'export CLOUDFLARE_API_TOKEN="6sfb00L5dHmYV-ozgr1Nqut9g58q3xDMpCKNzku8"' >> ~/.bashrc
echo 'export CLOUDFLARE_ZONE_ID="ZONE_ID_AQUI"' >> ~/.bashrc
echo 'export CLOUDFLARE_DOMAIN="emanuel-server.com"' >> ~/.bashrc
source ~/.bashrc

# Probar configuración
cd /home/epardo/projects/saas-factory
./scripts/cloudflare-dns.sh list
```

---

## Troubleshooting

### "No encuentro la sección API"

La sección API está en la barra lateral **derecha** del dashboard, no en el menú principal.

### "El token dice 'No route for that URI'"

El token actual puede necesitar permisos adicionales. Sigue estos pasos:

1. Ve a: https://dash.cloudflare.com/profile/api-tokens
2. Crea un nuevo token:
   - Template: **"Edit zone DNS"**
   - Permissions:
     - ✅ Zone → DNS → Edit
     - ✅ Zone → Zone → Read
   - Zone Resources:
     - ✅ Specific zone → emanuel-server.com
3. Usa el nuevo token en lugar del actual

---

## Próximos Pasos

Una vez configurado:

```bash
# Crear proyecto con DNS automático
saas-factory mi-app mi_app_db --dns

# Resultado: mi-app.emanuel-server.com
```

🌐 ¡Listo para subdominios automáticos!
