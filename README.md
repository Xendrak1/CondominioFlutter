# 📱 Condominio KE - App Flutter

> **App Flutter con UI condicional por rol**: ADMIN, RESIDENTE, GUARDIA

[![Flutter](https://img.shields.io/badge/Flutter-3.5+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 Características Principales

### 🏠 **RESIDENTE**
- ✅ Dashboard con estadísticas en tiempo real
- ✅ **Expensas**: Ver lista, detalle completo, opciones de pago (QR, comprobante, online)
- ✅ **Reservas**: Ver áreas disponibles, crear reservas, generar QR, cancelar
- ✅ **Comunicados**: Leer comunicados, marcar como leído/no leído
- ✅ **Visitantes**: Generar QR temporal, compartir por WhatsApp/Email/SMS

### 🛡️ **GUARDIA**
- ✅ Scanner QR en tiempo real con cámara
- ✅ Validación automática de QR (reservas y visitantes)
- ✅ Feedback visual inmediato (AUTORIZADO/DENEGADO)
- ✅ Entrada manual para casos especiales
- ✅ Base preparada para IA de reconocimiento de placas

### ⚙️ **ADMIN**
- ✅ Dashboard con estadísticas del condominio
- ✅ Gestión de residentes
- ✅ Visualización de expensas (por cobrar/cobradas)
- ✅ Control de reservas activas
- ✅ Módulo de reportes y análisis

## 🎨 Diseño

- **Paleta de colores**: Tonos morados elegantes (#6A1B9A)
- **Material Design 3**: Componentes modernos
- **Tema claro/oscuro**: Soporte completo
- **Responsive**: Adaptable a diferentes tamaños
- **Animaciones**: Transiciones suaves y feedback visual
- **Accesibilidad**: Alto contraste y tamaños legibles

## 🔐 Autenticación

| Usuario | Password | Rol |
|---------|----------|-----|
| **juanperez** | adminJUAN | ADMIN |
| **anaperez** | adminANA | GUARDIA |
| **pedroquispe** | adminPEDRO | ADMIN |
| **mariolopez** | adminMARIO | RESIDENTE |

## 🚀 Inicio Rápido

### Prerequisitos
- Flutter SDK 3.5+
- Android SDK o emulador Android
- PostgreSQL 17 (opcional, usa datos mock por defecto)

### Instalación

```bash
# 1. Clonar o navegar a la carpeta
cd condominio_roles

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en emulador Android
flutter run -d emulator-5554

# O en dispositivo Android conectado
flutter run -d android

# O en Windows (requiere Modo Desarrollador habilitado)
flutter run -d windows
```

## 🔥 Hot Reload

La app soporta **Hot Reload** para desarrollo rápido:

- **`r`** - Hot Reload (cambios instantáneos, mantiene estado)
- **`R`** - Hot Restart (reinicia completamente)
- **`q`** - Quit (cerrar app)
- **`h`** - Help (ver todos los comandos)

### Flujo de trabajo recomendado:
1. Ejecuta `flutter run -d emulator-5554`
2. Edita archivos `.dart`
3. Guarda (Ctrl+S) o presiona `r` en terminal
4. ¡Ves cambios instantáneamente!

## 📂 Arquitectura

```
lib/
├── main.dart                 # Entry point
├── app/
│   ├── router.dart          # Navegación con go_router
│   └── theme.dart           # Paleta de colores y temas
├── core/
│   ├── database/            # Conexión a PostgreSQL
│   ├── storage/             # Almacenamiento seguro (tokens)
│   ├── env/                 # Variables de entorno
│   └── constants/           # Constantes de la app
├── features/
│   ├── auth/                # Login y autenticación
│   │   ├── data/           # Repository
│   │   └── presentation/   # UI y providers
│   ├── dashboard/           # Dashboards por rol
│   ├── expenses/            # Módulo de expensas
│   ├── reservations/        # Módulo de reservas
│   ├── announcements/       # Módulo de comunicados
│   ├── visitors/            # Módulo de visitantes
│   ├── guard/               # Scanner de guardia
│   └── admin/               # Panel de administración
└── common/
    ├── widgets/             # Widgets reutilizables
    └── providers.dart       # Providers globales
```

**Patrón de arquitectura:**
- ✅ Clean Architecture (separación de capas)
- ✅ Riverpod para gestión de estado
- ✅ Repository pattern
- ✅ Widgets reutilizables
- ✅ Inyección de dependencias con Providers

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter_riverpod: ^2.5.1      # Estado reactivo
  go_router: ^14.2.0            # Navegación declarativa
  flutter_secure_storage: ^9.2.2 # Almacenamiento seguro
  mobile_scanner: ^5.2.3        # Scanner QR
  qr_flutter: ^4.1.0            # Generador QR
  image_picker: ^1.1.2          # Captura de imágenes
  share_plus: ^10.1.2           # Compartir contenido
  url_launcher: ^6.3.0          # Abrir URLs
  postgres: ^3.0.0              # Conexión PostgreSQL (opcional)
  flutter_dotenv: ^5.1.0        # Variables de entorno
  intl: ^0.19.0                 # Internacionalización
```

## 🗄️ Base de Datos

La app puede funcionar con:

### Opción 1: Datos Mock (por defecto)
- No requiere configuración
- Datos de ejemplo precargados
- Ideal para desarrollo y pruebas

### Opción 2: PostgreSQL
```env
# .env
DB_HOST=10.0.2.2       # localhost desde emulador
DB_PORT=5432
DB_NAME=Condominio
DB_USER=postgres
DB_PASSWORD=1788
```

**Tablas requeridas:**
- `usuarios`, `roles`, `usuario_roles`
- `expensas`, `reservas`, `comunicados`
- `visitantes`, `areas_comunes`, `viviendas`

## 🎯 Funcionalidades Implementadas

### ✅ Autenticación
- Login con validación de credenciales
- Almacenamiento seguro de tokens
- Refresh automático de sesión
- Logout con limpieza de datos
- Redirección automática por rol

### ✅ Navegación
- Router con guards por rol
- Deep linking habilitado
- Transiciones suaves entre pantallas
- Botón back nativo de Android
- Prevención de navegación no autorizada

### ✅ Expensas (Residente)
- Lista con filtros (pendientes/pagadas)
- Detalle completo de cada expensa
- Pago con QR bancario
- Subir comprobante (foto)
- Pago en línea (link externo)

### ✅ Reservas (Residente)
- Ver áreas comunes disponibles
- Crear nueva reserva con fecha
- Generar QR de reserva
- Cancelar reserva
- Visualización de estado

### ✅ Comunicados (Residente)
- Lista ordenada por fecha
- Expandir para ver detalle
- Marcar como leído
- Badge de no leídos
- Diferenciación visual

### ✅ Visitantes (Residente)
- Generar QR de visitante
- Compartir por múltiples canales
- Ver historial de visitantes
- QR con información completa

### ✅ Scanner (Guardia)
- Escaneo QR en tiempo real
- Validación automática
- Feedback visual (verde/rojo)
- Animaciones de resultado
- Registro de accesos
- Modo manual
- Preparado para IA de placas

### ✅ Panel Admin
- Estadísticas generales
- Lista de residentes
- Control de expensas
- Gestión de reservas
- Módulo de reportes

## 🤖 IA de Reconocimiento de Placas

La app tiene la base preparada para integrar reconocimiento de placas con IA:

### Datasets Recomendados:
- **OpenALPR**: Dataset público multi-país
- **UFPR-ALPR**: Dataset latinoamericano (Brasil)
- **LPRNet**: Específico para reconocimiento
- **CCPD**: 500k+ imágenes

### Stack Tecnológico Sugerido:
- **TensorFlow Lite** para Flutter
- **YOLO** para detección + **CRNN** para OCR
- **OpenCV** para preprocesamiento
- **Tesseract** como fallback

### Integración:
```dart
// Botón "Placas IA" ya implementado en GuardScannerPage
// Archivo: lib/features/guard/presentation/guard_scanner_page.dart
// Método: _showPlateScanner()
```

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Tests específicos
flutter test test/features/auth/
flutter test test/features/guard/
```

Tests incluidos:
- ✅ AuthProvider (login, logout, refresh)
- ✅ GuardRepository (validación QR)
- ✅ Mocks con Mockito

## 📱 Capturas de Pantalla

### Login
- Gradient morado de fondo
- Card elevado con sombra
- Usuarios de prueba visibles
- Validación de campos

### Dashboard Residente
- Estadísticas en cards
- Badges de notificaciones
- Navegación rápida
- Diseño moderno

### Expensas
- Lista con estados
- Detalle completo
- Múltiples formas de pago
- QR de pago

### Scanner Guardia
- Vista de cámara full screen
- Marco de escaneo
- Feedback inmediato
- Botones de acceso rápido

## 🔧 Configuración Avanzada

### Variables de Entorno (.env)
```env
# Base de datos (opcional)
DB_HOST=10.0.2.2
DB_PORT=5432
DB_NAME=Condominio
DB_USER=postgres
DB_PASSWORD=1788
```

### Permisos Android
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Build para Producción
```bash
# Android APK
flutter build apk --release

# Android App Bundle (recomendado para Play Store)
flutter build appbundle --release

# iOS (requiere Mac)
flutter build ios --release
```

## 🐛 Troubleshooting

### Error: "No devices found"
```bash
# Ver dispositivos disponibles
flutter devices

# Listar emuladores
flutter emulators

# Crear emulador
flutter emulators --create --name pixel_7
```

### Error: "Building with plugins requires symlink support"
- **Solución**: Habilitar Modo Desarrollador en Windows
- Ejecutar: `start ms-settings:developers`
- Activar "Modo de desarrollador"

### Error de conexión a PostgreSQL
- Verificar que PostgreSQL esté corriendo
- Usar IP `10.0.2.2` desde emulador (no `localhost`)
- Verificar firewall y `pg_hba.conf`

## 📝 Próximas Características

- [ ] Pago de expensas integrado
- [ ] Notificaciones push
- [ ] Chat entre residentes
- [ ] Gestión de mascotas
- [ ] Control de parqueos
- [ ] IA para reconocimiento de placas
- [ ] Reportes PDF exportables
- [ ] Modo offline completo
- [ ] Biométrica (huella/Face ID)
- [ ] Mapa interactivo del condominio

## 👨‍💻 Desarrollo

### Convenciones de Código
- Usar `const` siempre que sea posible
- Nombres descriptivos en español
- Comentarios en código complejo
- Widgets privados con `_` prefix
- Providers con sufijo `Provider`

### Agregar Nueva Feature
1. Crear carpeta en `lib/features/nueva_feature/`
2. Estructura: `data/`, `presentation/`
3. Crear repository en `data/`
4. Crear providers y UI en `presentation/`
5. Agregar ruta en `lib/app/router.dart`

## 📄 Licencia

MIT License - Ver archivo LICENSE

## 👤 Autor

**Eduardo**  
Proyecto Final - Gestión de Condominios  
Fecha: 30 de septiembre de 2025

---

## 🙌 Agradecimientos

- Flutter Team por el excelente framework
- Riverpod por la gestión de estado reactiva
- La comunidad de Flutter en Bolivia

---

**¿Preguntas?** Abre un issue o contacta al desarrollador.

**⭐ Si te gusta este proyecto, dale una estrella!**