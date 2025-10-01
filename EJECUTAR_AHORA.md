# ⚡ EJECUTA ESTOS PASOS AHORA MISMO

## ✅ Paso 1: Configurar Firewall en Azure (2 minutos)

1. Abre [Azure Portal](https://portal.azure.com) en tu navegador
2. Busca `condominio-flutter` en la barra de búsqueda
3. Click en tu servidor PostgreSQL
4. En el menú izquierdo, busca **"Redes"** o **"Networking"**
5. Verás una sección **"Reglas de firewall"**
6. Click en **"+ Agregar regla de firewall"** o **"+ Add firewall rule"**
7. Completa:
   ```
   Nombre: AllowAll
   IP inicial: 0.0.0.0
   IP final: 255.255.255.255
   ```
8. Click en **"Guardar"** y espera 30 segundos

---

## ✅ Paso 2: Ejecutar SQL en Azure (3 minutos)

### Opción A: Desde Azure Portal (MÁS FÁCIL)

1. En tu servidor PostgreSQL, busca **"Query editor"** en el menú izquierdo
2. Si no lo ves, ve a **"Configuración"** y habilita **"Query editor"**
3. Click en **"Query editor"**
4. Te pedirá conectarte:
   - Base de datos: `Condominio`
   - Usuario: `jeadmin`
   - Contraseña: `ByuSix176488`
5. Abre el archivo `database_azure.sql` de este proyecto
6. **Copia TODO el contenido** (Ctrl+A, Ctrl+C)
7. **Pega** en el Query editor (Ctrl+V)
8. Click en **"Ejecutar"** o **"Run"**
9. Espera 1-2 minutos hasta que termine

### Opción B: Desde tu computadora (si tienes psql)

```bash
psql "host=condominio-flutter.postgres.database.azure.com port=5432 dbname=Condominio user=jeadmin password=ByuSix176488 sslmode=require" -f database_azure.sql
```

---

## ✅ Paso 3: Verificar que funcionó

En el Query editor de Azure, ejecuta:

```sql
SELECT COUNT(*) FROM areas_comunes;
SELECT COUNT(*) FROM reservas;
SELECT COUNT(*) FROM usuarios;
```

**Debes ver:**
- áreas_comunes: 7
- reservas: 3
- usuarios: 5

Si ves esos números, **¡está listo!** ✅

---

## ✅ Paso 4: Ejecutar la App

Abre una terminal y ejecuta:

```bash
cd "C:\Users\eduardo\Documents\Nueva carpeta\condominio_roles"
..\flutter_sdk\bin\flutter.bat run -d emulator-5554
```

**MANTÉN LA TERMINAL ABIERTA** para ver los logs.

---

## 🔍 Qué deberías ver en los logs:

```
🔌 Conectando a PostgreSQL Azure...
   Host: condominio-flutter.postgres.database.azure.com
   Database: Condominio
   User: jeadmin
✅ Conexión exitosa a PostgreSQL Azure!

📍 [AREAS] Query ejecutado exitosamente. Filas: 7
   - Piscina (ID: 1)
   - Gimnasio (ID: 2)
   - Salón de Eventos (ID: 3)
   - Cancha de Tenis (ID: 4)
   - Área de BBQ (ID: 5)
   - Parque Infantil (ID: 6)
   - Sala de Cine (ID: 7)

📅 [RESERVAS] Reservas procesadas: 3
   - R-2025010001: Piscina - CONFIRMADA
   - R-2025010002: Salón de Eventos - PENDIENTE
   - R-2025010003: Área de BBQ - CONFIRMADA
```

---

## 🎯 Ahora SÍ podrás:

1. **Entrar** con `mariolopez` / `adminMARIO`
2. **Ver las 3 reservas** existentes
3. **Crear una nueva reserva** → Se guardará en Azure PostgreSQL
4. **Ver la nueva reserva** aparecer inmediatamente en la lista

---

## ❌ Si ves errores:

### Error: "Connection refused" o "timeout"
→ **Problema:** Firewall no configurado
→ **Solución:** Repite el Paso 1

### Error: "Table does not exist"
→ **Problema:** SQL no ejecutado
→ **Solución:** Repite el Paso 2

### Error: "Authentication failed"
→ **Problema:** Contraseña incorrecta
→ **Solución:** Verifica que sea `ByuSix176488` (con mayúsculas)

---

## 📱 Usuarios para probar:

| Usuario | Contraseña | Rol | Ver |
|---------|------------|-----|-----|
| mariolopez | adminMARIO | RESIDENTE | Reservas, expensas |
| juanperez | adminJUAN | ADMIN | Panel completo |
| anaperez | adminANA | GUARDIA | Scanner QR |

---

## ⏱️ Tiempo total: 5-7 minutos

**¿Listo? Empieza por el Paso 1 (configurar firewall)** 🚀

