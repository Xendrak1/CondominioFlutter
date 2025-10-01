# Condominio Roles - Flutter App

Aplicación Flutter multi-rol para gestión de condominios con PostgreSQL en Azure.

## 🏗️ Arquitectura

```
Flutter App (Android/iOS)
       ↓
PostgreSQL en Azure ← DIRECTAMENTE
(condominio-flutter.postgres.database.azure.com)
```

## 🔐 Configuración de Conexión

### Paso 1: Configurar credenciales de Azure PostgreSQL

Edita el archivo `.env` y coloca tu contraseña real:

```env
DB_HOST=condominio-flutter.postgres.database.azure.com
DB_PORT=5432
DB_NAME=Condominio
DB_USER=jeadmin
DB_PASSWORD=TU_PASSWORD_REAL_AQUI
```

### Paso 2: Verificar la conexión

La app se conecta automáticamente a Azure PostgreSQL con SSL habilitado.

**Detalles de tu servidor Azure:**
- **Host**: `condominio-flutter.postgres.database.azure.com`
- **Usuario**: `jeadmin`
- **Base de datos**: `Condominio`
- **Versión PostgreSQL**: 17.5
- **Ubicación**: Brazil South
- **SSL**: Requerido ✅

## ⚠️ Importante sobre Seguridad

### ¿Por qué Flutter se conecta directamente a PostgreSQL?

**Ventajas:**
- ✅ Más rápido (sin intermediario)
- ✅ Menos código
- ✅ Ideal para desarrollo/prototipos

**Desventajas:**
- ❌ Las credenciales están en el cliente (riesgo de seguridad)
- ❌ No hay capa de lógica de negocio
- ❌ No hay validación centralizada
- ❌ Difícil de escalar

### 🎯 Arquitectura Recomendada para Producción

```
Flutter App
    ↓
Django REST API (en Azure App Service)
    ↓
PostgreSQL en Azure
```

**Esta es la arquitectura profesional:**
1. Flutter solo se comunica con la API REST
2. Django maneja toda la lógica de negocio
3. Django se conecta a PostgreSQL con permisos adecuados
4. Las credenciales nunca llegan al cliente

## 👥 Usuarios de Prueba

| Usuario | Contraseña | Rol |
|---------|------------|-----|
| juanperez | adminJUAN | ADMIN |
| anaperez | adminANA | GUARDIA |
| pedroquispe | adminPEDRO | ADMIN |
| mariolopez | adminMARIO | RESIDENTE |

## 🚀 Ejecutar la Aplicación

### Prerrequisitos
- Flutter SDK
- Android Studio con emulador
- Conexión a Internet (para Azure)

### Comandos

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en emulador Android
flutter run -d emulator-5554

# Ejecutar en dispositivo físico
flutter run

# Hot Reload (mientras la app está corriendo)
# Presiona 'r' en la terminal

# Hot Restart (reinicio completo)
# Presiona 'R' en la terminal
```

## 📦 Generar APK para Compartir

```bash
# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Construir APK de release
flutter build apk --release
```

El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

## 🌐 Subir a GitHub

```bash
git init
git add .
git commit -m "feat: App Flutter con conexión a Azure PostgreSQL"
git branch -M main
git remote add origin https://github.com/Xendrak1/CondominioFlutter.git
git push -u origin main
```

## 📱 Funcionalidades por Rol

### 👤 RESIDENTE
- ✅ Ver expensas y detalles de pago
- ✅ Ver y crear reservas de áreas comunes
- ✅ Ver código QR de reservas
- ✅ Cancelar reservas
- ✅ Ver comunicados del condominio
- ✅ Generar QR para visitantes
- ✅ Ver historial de visitantes

### 👨‍💼 ADMIN
- ✅ Dashboard con estadísticas en tiempo real
- ✅ Gestión completa de expensas
- ✅ Gestión completa de reservas
- ✅ Gestión de comunicados
- ✅ Ver lista de residentes
- ✅ Análisis y reportes

### 🛡️ GUARDIA
- ✅ Escanear códigos QR
- ✅ Validar reservas y visitantes
- ✅ Registrar entradas y salidas
- ✅ Ver historial de accesos

## 🎨 Diseño

- Paleta de colores morada consistente
- Material Design 3
- Animaciones fluidas
- Estados de carga, vacío y error
- Responsive design

## 🗄️ Estructura del Proyecto

```
lib/
├── app/                    # Configuración global
│   ├── router.dart        # Rutas y navegación
│   └── theme.dart         # Tema y colores
├── core/                   # Servicios base
│   ├── database/          # PostgreSQL service
│   ├── network/           # API client
│   ├── env/              # Variables de entorno
│   └── storage/          # Secure storage
├── common/                # Widgets reutilizables
│   ├── providers.dart    # Riverpod providers
│   └── widgets/         # Componentes compartidos
└── features/             # Módulos por feature
    ├── auth/            # Autenticación
    ├── admin/           # Panel de administración
    ├── expenses/        # Gestión de expensas
    ├── reservations/    # Gestión de reservas
    ├── announcements/   # Comunicados
    ├── visitors/        # Control de visitantes
    └── guard/          # Panel de guardia
```

## 🔧 Tecnologías

- **Flutter 3.x** - Framework UI
- **Riverpod** - State management
- **GoRouter** - Navegación declarativa
- **Dio** - Cliente HTTP
- **PostgreSQL** - Base de datos en Azure
- **flutter_secure_storage** - Almacenamiento seguro
- **qr_flutter** - Generación de códigos QR
- **mobile_scanner** - Escaneo de códigos QR
- **image_picker** - Selección de imágenes

## 📊 Base de Datos

La aplicación se conecta directamente a tu base de datos PostgreSQL en Azure:

### Tablas Principales
- `usuarios` - Datos de usuarios
- `usuario_roles` - Asignación de roles
- `viviendas` - Información de viviendas
- `expensas` - Expensas mensuales
- `reservas` - Reservas de áreas comunes
- `areas_comunes` - Áreas disponibles
- `visitantes` - Control de visitantes
- `comunicados` - Anuncios y noticias
- `accesos` - Log de entradas/salidas

## 🆘 Solución de Problemas

### Error: "Failed host lookup"
- Verifica que tengas conexión a Internet
- Confirma que el host de Azure es correcto
- Verifica el firewall de tu red

### Error: "Authentication failed"
- Verifica la contraseña en `.env`
- Confirma el usuario `jeadmin`
- Revisa las reglas de firewall en Azure

### Error: "SSL connection error"
- Azure PostgreSQL requiere SSL
- La app ya está configurada con `SslMode.require`

### Las reservas no aparecen
- Verifica que la tabla `reservas` exista
- Confirma que hay datos en `areas_comunes`
- Revisa los logs en la consola de Flutter

## 📝 Notas

- La app está configurada para **desarrollo/pruebas**
- Para **producción**, implementa el backend Django
- Usa **Firebase** o **Azure AD** para autenticación real
- Implementa **rate limiting** en la base de datos
- Configura **backups automáticos** en Azure

## 🔗 Enlaces Útiles

- [Flutter Documentation](https://docs.flutter.dev/)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/azure/postgresql/)
- [Riverpod](https://riverpod.dev/)
- [GoRouter](https://pub.dev/packages/go_router)

## 📄 Licencia

Este proyecto es de código abierto para fines educativos.

---

**Desarrollado con ❤️ usando Flutter**
