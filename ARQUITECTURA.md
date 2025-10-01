# 🏗️ Arquitectura del Sistema

## Arquitectura Actual (Desarrollo/Prototipo)

```
┌─────────────────────────────────────┐
│                                     │
│      Flutter App (Cliente)          │
│     - Android / iOS                 │
│     - UI por rol                    │
│     - Conecta directamente a BD     │
│                                     │
└───────────────┬─────────────────────┘
                │
                │ TCP/IP + SSL
                │ Port 5432
                │
┌───────────────▼─────────────────────┐
│                                     │
│  PostgreSQL 17.5 en Azure           │
│  - Host: condominio-flutter...     │
│  - Usuario: jeadmin                │
│  - SSL requerido                   │
│  - 2 GiB RAM, 32 GB Storage        │
│                                     │
└─────────────────────────────────────┘
```

### ✅ Ventajas de esta arquitectura:
1. **Rápido desarrollo** - No necesitas backend
2. **Menos código** - Conexión directa
3. **Bueno para prototipos** - Ideal para demos
4. **Menos infraestructura** - Solo BD + App

### ❌ Desventajas de esta arquitectura:
1. **Credenciales expuestas** - Cualquiera puede descompilar el APK
2. **Sin lógica de negocio** - Todo está en el cliente
3. **Sin validación centralizada** - Fácil de hackear
4. **No escalable** - Conexiones directas limitadas
5. **Sin caché** - Cada consulta va a la BD
6. **Sin rate limiting** - Vulnerable a ataques
7. **Difícil mantenimiento** - Cambios requieren actualizar la app

---

## Arquitectura Profesional (Producción Recomendada)

```
┌─────────────────────────────────────┐
│      Flutter App (Cliente)          │
│     - Solo UI y lógica de vista     │
│     - NO tiene credenciales         │
│     - Llama a API REST              │
└───────────────┬─────────────────────┘
                │
                │ HTTPS + JWT
                │ Port 443
                │
┌───────────────▼─────────────────────┐
│   Django REST API (Azure App)       │
│   ┌─────────────────────────────┐   │
│   │ • Autenticación JWT         │   │
│   │ • Permisos por rol          │   │
│   │ • Validación de datos       │   │
│   │ • Lógica de negocio         │   │
│   │ • Rate limiting             │   │
│   │ • Caché (Redis)             │   │
│   │ • Logs y auditoría          │   │
│   └─────────────────────────────┘   │
└───────────────┬─────────────────────┘
                │
                │ TCP/IP + SSL
                │ Port 5432
                │
┌───────────────▼─────────────────────┐
│  PostgreSQL 17.5 en Azure           │
│  - Solo el backend se conecta       │
│  - Credenciales nunca salen         │
│  - Firewall restrictivo             │
└─────────────────────────────────────┘
```

### ✅ Ventajas de esta arquitectura:
1. **Seguridad total** - Credenciales solo en backend
2. **Lógica centralizada** - Fácil de mantener
3. **Escalabilidad** - Backend puede crecer
4. **Caché inteligente** - Reduce carga en BD
5. **Rate limiting** - Protege contra ataques
6. **Versionado de API** - /api/v1, /api/v2
7. **Múltiples clientes** - Web, móvil, IoT

### 📊 Comparación

| Aspecto | Directa (Actual) | Con Backend (Recomendado) |
|---------|------------------|---------------------------|
| Seguridad | ⚠️ Baja | ✅ Alta |
| Escalabilidad | ⚠️ Limitada | ✅ Excelente |
| Mantenimiento | ⚠️ Difícil | ✅ Fácil |
| Costo inicial | ✅ Bajo | ⚠️ Medio |
| Velocidad dev | ✅ Rápida | ⚠️ Media |
| Producción | ❌ No | ✅ Sí |

---

## 🔄 Migración a Arquitectura Profesional

### Paso 1: Configurar Django en Azure

```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'Condominio',
        'USER': 'jeadmin',
        'PASSWORD': os.environ.get('DB_PASSWORD'),
        'HOST': 'condominio-flutter.postgres.database.azure.com',
        'PORT': '5432',
        'OPTIONS': {'sslmode': 'require'},
    }
}

INSTALLED_APPS = [
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    # ... tus apps
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}
```

### Paso 2: Crear Endpoints

```python
# urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register('expensas', ExpensasViewSet)
router.register('reservas', ReservasViewSet)
router.register('visitantes', VisitantesViewSet)
router.register('comunicados', ComunicadosViewSet)

urlpatterns = [
    path('api/auth/login/', TokenObtainPairView.as_view()),
    path('api/auth/refresh/', TokenRefreshView.as_view()),
    path('api/', include(router.urls)),
]
```

### Paso 3: Actualizar Flutter para usar API

```dart
// lib/core/network/api_client.dart
class ApiClient {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://tu-backend.azurewebsites.net/api',
    connectTimeout: Duration(seconds: 10),
  ))
  ..interceptors.add(JwtInterceptor());
}

// lib/features/expenses/data/expenses_repository.dart
class ExpensesRepository {
  Future<List<Expense>> getExpenses() async {
    final response = await ApiClient.dio.get('/expensas/');
    return (response.data as List)
        .map((json) => Expense.fromJson(json))
        .toList();
  }
}
```

### Paso 4: Actualizar .env

```env
# Cambiar de conexión directa a API
BASE_URL=https://tu-backend-django.azurewebsites.net

# Eliminar credenciales de BD (ya no se usan en Flutter)
# DB_HOST=...
# DB_USER=...
# DB_PASSWORD=...
```

---

## 🛡️ Mejoras de Seguridad Adicionales

### 1. Autenticación Multi-Factor (MFA)
```python
# Django
INSTALLED_APPS += ['django_otp', 'django_otp.plugins.otp_totp']
```

### 2. Rate Limiting por IP
```python
# Django
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle'
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '10/hour',
        'user': '100/hour'
    }
}
```

### 3. Auditoría de Accesos
```python
# models.py
class AuditLog(models.Model):
    user = models.ForeignKey(User)
    action = models.CharField(max_length=100)
    ip_address = models.GenericIPAddressField()
    timestamp = models.DateTimeField(auto_now_add=True)
```

### 4. Firewall de Azure
```bash
# Permitir solo tu backend
az postgres flexible-server firewall-rule create \
  --resource-group Condominio \
  --name condominio-flutter \
  --rule-name AllowBackend \
  --start-ip-address <TU_BACKEND_IP> \
  --end-ip-address <TU_BACKEND_IP>
```

---

## 💰 Costos Estimados (Azure)

### Configuración Actual (Solo BD)
- PostgreSQL B1ms: ~$12/mes
- **Total: $12/mes**

### Configuración Profesional
- PostgreSQL B1ms: ~$12/mes
- App Service B1: ~$13/mes
- Redis Basic: ~$16/mes (opcional)
- **Total: $25-41/mes**

---

## 📈 Roadmap Recomendado

### Fase 1: Prototipo ✅ (Actual)
- [x] Conexión directa Flutter → PostgreSQL
- [x] UI funcional para 3 roles
- [x] CRUD básico

### Fase 2: MVP (Siguiente)
- [ ] Implementar Django REST API
- [ ] Migrar Flutter a usar API
- [ ] JWT para autenticación
- [ ] Deploy en Azure App Service

### Fase 3: Producción
- [ ] Rate limiting
- [ ] Caché con Redis
- [ ] Monitoreo (Azure Monitor)
- [ ] CI/CD con GitHub Actions
- [ ] Tests automatizados

### Fase 4: Escalamiento
- [ ] Microservicios
- [ ] Load balancer
- [ ] CDN para assets
- [ ] Backups automáticos
- [ ] Disaster recovery

---

## 🎯 Recomendación Final

**Para tu proyecto académico**: La arquitectura actual está **PERFECTA**. Es rápida, funciona bien y demuestra tus habilidades.

**Para producción real**: Necesitas migrar a la arquitectura con backend **ANTES** de lanzar al público.

**Plazo sugerido**: Termina tu materia con la arquitectura actual, luego refactoriza en 2-3 semanas para producción.

---

**Pregunta clave**: ¿Este proyecto es solo para la materia o planeas lanzarlo como producto real?

- **Solo materia** → Mantén la arquitectura actual ✅
- **Producto real** → Migra a backend profesional 🚀

