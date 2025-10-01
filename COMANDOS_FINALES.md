# 🚀 COMANDOS FINALES

## 📦 1. Subir a GitHub

```bash
cd "C:\Users\eduardo\Documents\Nueva carpeta\condominio_roles"

# Inicializar git (si no está inicializado)
git init

# Agregar todos los archivos
git add .

# Commit
git commit -m "feat: App Flutter completa con conexión a Azure PostgreSQL - Gestión de Condominio con 3 roles (ADMIN, RESIDENTE, GUARDIA)"

# Cambiar a rama main
git branch -M main

# Conectar con tu repositorio
git remote add origin https://github.com/Xendrak1/CondominioFlutter.git

# Subir (te pedirá usuario y contraseña de GitHub)
git push -u origin main
```

### Si ya tienes git inicializado:

```bash
cd "C:\Users\eduardo\Documents\Nueva carpeta\condominio_roles"

git add .
git commit -m "feat: Conexión completa a Azure PostgreSQL con estructura adaptada"
git push origin main
```

---

## 📱 2. Generar APK para compartir

```bash
cd "C:\Users\eduardo\Documents\Nueva carpeta\condominio_roles"

# Limpiar build anterior
..\flutter_sdk\bin\flutter.bat clean

# Obtener dependencias
..\flutter_sdk\bin\flutter.bat pub get

# Construir APK de RELEASE (optimizado, sin logs)
..\flutter_sdk\bin\flutter.bat build apk --release
```

**El APK estará en:**
```
build\app\outputs\flutter-apk\app-release.apk
```

Tamaño aproximado: **25-35 MB**

---

## 📤 3. Compartir el APK

### Opción A: Por WhatsApp/Telegram

1. Navega a `build\app\outputs\flutter-apk\`
2. Encuentra `app-release.apk`
3. Comparte el archivo directamente

### Opción B: Subirlo a Drive/Dropbox

```bash
# Copiar a una ubicación accesible
copy build\app\outputs\flutter-apk\app-release.apk C:\Users\eduardo\Desktop\CondominioApp.apk
```

Luego súbelo a Google Drive/Dropbox y comparte el link.

---

## 🔐 4. Firmar el APK (Opcional - Para producción)

Si quieres subirlo a Google Play Store, necesitas firmar el APK:

```bash
# Generar keystore
keytool -genkey -v -keystore C:\Users\eduardo\condominio-key.jks -alias condominio -keyalg RSA -keysize 2048 -validity 10000

# Luego configurar en android\app\build.gradle
```

(No es necesario para compartir con amigos)

---

## 📊 5. Verificar que todo funciona antes de compartir

### Checklist antes de generar el APK:

- [ ] ✅ La app se conecta a Azure PostgreSQL
- [ ] ✅ Se ven las 10 áreas comunes
- [ ] ✅ Se ven las 2 reservas existentes
- [ ] ✅ Puedes crear una nueva reserva
- [ ] ✅ La nueva reserva aparece en la lista
- [ ] ✅ Puedes cancelar reservas
- [ ] ✅ Login funciona con los 3 roles
- [ ] ✅ Panel de Admin muestra estadísticas
- [ ] ✅ Guardia puede escanear QR

---

## 🎨 6. Información de la App

**Nombre de la app:** Condominio Roles
**Package name:** `com.eduardo.condominio_roles`
**Versión:** 1.0.0+1
**Tamaño APK:** ~30 MB
**Requisitos:** Android 5.0+ (API 21)
**Conexión:** Requiere Internet (para Azure PostgreSQL)

---

## 📝 7. Instrucciones para tu amigo

Cuando le pases el APK, dile:

1. **Descargar el APK** desde el link que le envíes
2. **Instalar** (puede pedir "Permitir instalación de fuentes desconocidas")
3. **Abrir la app**
4. **Usar estos usuarios de prueba:**
   - RESIDENTE: `mariolopez` / `adminMARIO`
   - ADMIN: `juanperez` / `adminJUAN`
   - GUARDIA: `anaperez` / `adminANA`

---

## ⚠️ IMPORTANTE ANTES DE COMPARTIR

### Seguridad:

Tu APK tiene las credenciales de Azure PostgreSQL **hardcoded** en el archivo `.env`, que se incluye en el APK.

**Esto significa que:**
- ❌ Cualquiera puede descompilar el APK
- ❌ Pueden extraer las credenciales
- ❌ Pueden conectarse directamente a tu BD
- ❌ Pueden modificar/borrar datos

### Soluciones:

#### Para desarrollo/demo/materia: ✅ **Está bien así**
- Es temporal
- Solo para pruebas
- Puedes cambiar la contraseña después

#### Para producción: ⚠️ **Debes usar backend**
```
Flutter → Django REST API → Azure PostgreSQL
```
De esta forma, las credenciales NUNCA salen del servidor.

---

## 🎯 RESUMEN DE COMANDOS

```bash
# 1. Subir a GitHub
cd condominio_roles
git init
git add .
git commit -m "feat: App completa con Azure PostgreSQL"
git remote add origin https://github.com/Xendrak1/CondominioFlutter.git
git push -u origin main

# 2. Generar APK
flutter clean
flutter pub get
flutter build apk --release

# 3. Encontrar el APK
explorer build\app\outputs\flutter-apk\
```

---

## ✅ LISTO PARA COMPARTIR

Una vez que verifiques que TODO funciona:

1. ✅ Sube el código a GitHub
2. ✅ Genera el APK
3. ✅ Compártelo con tu amigo
4. ✅ Dale las credenciales de prueba

**¡Tu proyecto está completo!** 🎉

