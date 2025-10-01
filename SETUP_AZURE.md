# 🚀 Configuración de Azure PostgreSQL - Paso a Paso

## 📋 Paso 1: Configurar Firewall en Azure

1. Ve a [Azure Portal](https://portal.azure.com)
2. Busca tu servidor PostgreSQL: `condominio-flutter`
3. En el menú izquierdo, click en **"Redes"** o **"Networking"**
4. En la sección **"Reglas de firewall"**:
   - Click en **"+ Agregar regla de firewall"**
   - Nombre: `AllowAll`
   - IP inicial: `0.0.0.0`
   - IP final: `255.255.255.255`
   - Click en **"Guardar"**

⚠️ **IMPORTANTE:** Esto permite conexiones desde cualquier IP (solo para desarrollo). En producción, usa tu IP específica.

---

## 📋 Paso 2: Ejecutar Script SQL

### Opción A: Usar Query Editor en Azure Portal

1. En tu servidor PostgreSQL, busca **"Query editor (preview)"** en el menú izquierdo
2. Si no aparece, ve a **"Configuración"** → Habilita **"Query editor"**
3. Conéctate usando:
   - Usuario: `jeadmin`
   - Contraseña: `ByuSix176488`
   - Base de datos: `Condominio`
4. Copia **TODO** el contenido del archivo `database_azure.sql`
5. Pégalo en el editor
6. Click en **"Ejecutar"** o **"Run"**
7. Espera a que termine (puede tardar 1-2 minutos)

### Opción B: Usar pgAdmin (si lo tienes instalado)

1. Abre pgAdmin
2. Click derecho en **"Servers"** → **"Register"** → **"Server"**
3. En la pestaña **"General"**:
   - Name: `Azure Condominio`
4. En la pestaña **"Connection"**:
   - Host: `condominio-flutter.postgres.database.azure.com`
   - Port: `5432`
   - Database: `Condominio`
   - Username: `jeadmin`
   - Password: `ByuSix176488`
   - SSL mode: `require`
5. Click en **"Save"**
6. Expande el servidor → `Condominio` → Click derecho → **"Query Tool"**
7. Abre el archivo `database_azure.sql` y ejecútalo

### Opción C: Usar línea de comandos (si tienes psql)

```bash
# Windows
psql "host=condominio-flutter.postgres.database.azure.com port=5432 dbname=Condominio user=jeadmin password=ByuSix176488 sslmode=require" -f database_azure.sql

# Linux/Mac
PGPASSWORD=ByuSix176488 psql -h condominio-flutter.postgres.database.azure.com -p 5432 -U jeadmin -d Condominio -f database_azure.sql
```

---

## ✅ Paso 3: Verificar que todo funciona

Ejecuta estas consultas en Query Editor para verificar:

```sql
-- Ver todas las tablas creadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Ver áreas comunes
SELECT id, nombre, requiere_pago, tarifa 
FROM areas_comunes 
WHERE activo = true;

-- Ver usuarios con roles
SELECT u.nombre_completo, u.email, r.nombre as rol
FROM usuarios u
JOIN usuario_roles ur ON u.id = ur.usuario_id
JOIN roles r ON ur.rol_id = r.id;

-- Ver reservas
SELECT r.codigo, ac.nombre, r.fecha_reserva, r.estado
FROM reservas r
JOIN areas_comunes ac ON r.area_comun_id = ac.id;
```

**Resultados esperados:**
- ✅ 10 tablas creadas
- ✅ 7 áreas comunes
- ✅ 5 usuarios con roles
- ✅ 3 reservas de prueba

---

## 📱 Paso 4: Ejecutar la App Flutter

### A. Desde tu terminal actual (donde está corriendo):

```bash
# Si la app está corriendo, presiona:
# Shift + R (Hot Restart completo)
```

### B. Desde una nueva terminal:

```bash
cd "C:\Users\eduardo\Documents\Nueva carpeta\condominio_roles"

# Hot restart
..\flutter_sdk\bin\flutter.bat run -d emulator-5554
```

---

## 🔍 Paso 5: Ver los Logs

En la terminal donde está corriendo Flutter, deberías ver:

```
🔌 Conectando a PostgreSQL Azure...
   Host: condominio-flutter.postgres.database.azure.com
   Database: Condominio
   User: jeadmin
✅ Conexión exitosa a PostgreSQL Azure!

📍 [AREAS] Intentando obtener áreas comunes...
📍 [AREAS] Conexión obtenida, ejecutando query...
📍 [AREAS] Query ejecutado exitosamente. Filas: 7
📍 [AREAS] Áreas procesadas: 7
   - Área de BBQ (ID: 5)
   - Cancha de Tenis (ID: 4)
   - Gimnasio (ID: 2)
   - Parque Infantil (ID: 6)
   - Piscina (ID: 1)
   - Sala de Cine (ID: 7)
   - Salón de Eventos (ID: 3)

📅 [RESERVAS] Intentando obtener reservas...
📅 [RESERVAS] Conexión obtenida, ejecutando query...
📅 [RESERVAS] Query ejecutado exitosamente. Filas: 3
📅 [RESERVAS] Reservas procesadas: 3
   - R-2025010002: Salón de Eventos - PENDIENTE
   - R-2025010001: Piscina - CONFIRMADA
   - R-2025010003: Área de BBQ - CONFIRMADA
```

---

## 🐛 Solución de Problemas

### Error: "Connection refused"
- ✅ Verifica el firewall en Azure (Paso 1)
- ✅ Verifica que el servidor esté en estado "Ready"

### Error: "Authentication failed"
- ✅ Verifica la contraseña en `.env`: `ByuSix176488`
- ✅ Verifica el usuario: `jeadmin`

### Error: "SSL connection error"
- ✅ Azure requiere SSL (ya configurado en el código)
- ✅ No cambies `SslMode.require`

### Error: "Table does not exist"
- ✅ Ejecuta el SQL del Paso 2
- ✅ Verifica con las consultas del Paso 3

### No veo logs en la terminal
```bash
# Abre una nueva terminal y ejecuta:
cd "C:\Users\eduardo\Documents\Nueva carpeta\condominio_roles"
..\flutter_sdk\bin\flutter.bat logs
```

---

## 🎯 Próximos Pasos

Una vez que veas los logs exitosos:

1. ✅ **Crear una reserva** desde la app
2. ✅ Ver que aparezca en la lista inmediatamente
3. ✅ Verificar en Azure Query Editor:
   ```sql
   SELECT * FROM reservas ORDER BY id DESC LIMIT 5;
   ```

---

## 📝 Credenciales de Prueba

Para probar la app, usa estos usuarios:

| Usuario | Contraseña | Rol |
|---------|------------|-----|
| juanperez | adminJUAN | ADMIN |
| anaperez | adminANA | GUARDIA |
| mariolopez | adminMARIO | RESIDENTE |
| pedroquispe | adminPEDRO | ADMIN |

---

## 🆘 Si sigues sin ver conexión

Envíame una captura de pantalla de:
1. ✅ La terminal donde está corriendo Flutter
2. ✅ Los resultados de las consultas de verificación en Azure
3. ✅ La pantalla de la app (para ver si carga datos)

**¡Con esto debería funcionar todo!** 🚀

