-- ============================================
-- SCRIPT COMPLETO PARA AZURE POSTGRESQL 17.5
-- Base de datos: Condominio
-- ============================================

-- Eliminar tablas si existen (solo para desarrollo)
DROP TABLE IF EXISTS accesos CASCADE;
DROP TABLE IF EXISTS visitantes CASCADE;
DROP TABLE IF EXISTS reservas CASCADE;
DROP TABLE IF EXISTS areas_comunes CASCADE;
DROP TABLE IF EXISTS expensas CASCADE;
DROP TABLE IF EXISTS comunicados CASCADE;
DROP TABLE IF EXISTS usuario_roles CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS viviendas CASCADE;

-- ============================================
-- TABLA: viviendas
-- ============================================
CREATE TABLE viviendas (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    direccion VARCHAR(200),
    metros_cuadrados DECIMAL(10,2),
    habitaciones INTEGER,
    banos INTEGER,
    ocupada BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: usuarios
-- ============================================
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(200) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    telefono VARCHAR(20),
    vivienda_id INTEGER REFERENCES viviendas(id),
    fecha_nacimiento DATE,
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: roles
-- ============================================
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT
);

-- ============================================
-- TABLA: usuario_roles
-- ============================================
CREATE TABLE usuario_roles (
    usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    rol_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    asignado_el TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, rol_id)
);

-- ============================================
-- TABLA: areas_comunes
-- ============================================
CREATE TABLE areas_comunes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    capacidad INTEGER,
    requiere_pago BOOLEAN DEFAULT FALSE,
    tarifa DECIMAL(10,2) DEFAULT 0,
    horario_apertura TIME,
    horario_cierre TIME,
    activo BOOLEAN DEFAULT TRUE,
    imagen_url VARCHAR(500)
);

-- ============================================
-- TABLA: reservas
-- ============================================
CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    usuario_id INTEGER REFERENCES usuarios(id),
    area_comun_id INTEGER REFERENCES areas_comunes(id),
    vivienda_id INTEGER REFERENCES viviendas(id),
    fecha_reserva DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    estado VARCHAR(20) DEFAULT 'PENDIENTE',
    qr_generado TEXT,
    monto_pagado DECIMAL(10,2),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_estado_reserva CHECK (estado IN ('PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'EN_CURSO', 'FINALIZADA'))
);

-- ============================================
-- TABLA: expensas
-- ============================================
CREATE TABLE expensas (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    vivienda_id INTEGER REFERENCES viviendas(id),
    periodo VARCHAR(7) NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado VARCHAR(20) DEFAULT 'PENDIENTE',
    fecha_pago TIMESTAMP,
    metodo_pago VARCHAR(50),
    comprobante_url VARCHAR(500),
    CONSTRAINT chk_estado_expensa CHECK (estado IN ('PENDIENTE', 'PAGADA', 'VENCIDA', 'PARCIAL'))
);

-- ============================================
-- TABLA: comunicados
-- ============================================
CREATE TABLE comunicados (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT NOT NULL,
    prioridad VARCHAR(20) DEFAULT 'MEDIA',
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    autor_id INTEGER REFERENCES usuarios(id),
    CONSTRAINT chk_prioridad CHECK (prioridad IN ('ALTA', 'MEDIA', 'BAJA'))
);

-- ============================================
-- TABLA: visitantes
-- ============================================
CREATE TABLE visitantes (
    id SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(200) NOT NULL,
    documento VARCHAR(50) NOT NULL,
    vivienda_id INTEGER REFERENCES viviendas(id),
    fecha_visita DATE NOT NULL,
    hora_entrada TIME,
    hora_salida TIME,
    qr_generado TEXT,
    estado VARCHAR(20) DEFAULT 'PENDIENTE',
    observaciones TEXT,
    CONSTRAINT chk_estado_visitante CHECK (estado IN ('PENDIENTE', 'EN_PROPIEDAD', 'SALIO', 'CANCELADO'))
);

-- ============================================
-- TABLA: accesos
-- ============================================
CREATE TABLE accesos (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(20) NOT NULL,
    referencia_id INTEGER NOT NULL,
    qr_escaneado TEXT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    guardia_id INTEGER REFERENCES usuarios(id),
    CONSTRAINT chk_tipo_acceso CHECK (tipo IN ('RESERVA', 'VISITANTE'))
);

-- ============================================
-- DATOS DE PRUEBA
-- ============================================

-- Insertar viviendas
INSERT INTO viviendas (codigo, direccion, metros_cuadrados, habitaciones, banos, ocupada) VALUES
('CN-001', 'Condominio Norte - Casa 1', 120.50, 3, 2, TRUE),
('CN-002', 'Condominio Norte - Casa 2', 110.00, 3, 2, TRUE),
('CS-001', 'Condominio Sur - Casa 1', 95.00, 2, 1, TRUE),
('CS-002', 'Condominio Sur - Casa 2', 130.00, 4, 3, TRUE),
('CE-001', 'Condominio Este - Casa 1', 100.00, 2, 2, FALSE),
('CE-002', 'Condominio Este - Casa 2', 115.00, 3, 2, TRUE);

-- Insertar roles
INSERT INTO roles (nombre, descripcion) VALUES
('ADMIN', 'Administrador del condominio con acceso total'),
('RESIDENTE', 'Residente del condominio'),
('GUARDIA', 'Personal de seguridad');

-- Insertar usuarios (password: SHA256 hash de las contraseñas)
INSERT INTO usuarios (nombre_completo, email, password_hash, telefono, vivienda_id, activo) VALUES
('Juan Pérez', 'juanperez', '8b5e6e8c8e1c8f0a9e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f', '77012345', 1, TRUE),
('Ana Pérez', 'anaperez', '7a4d5c6b7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a', '77012346', NULL, TRUE),
('Pedro Quispe', 'pedroquispe', '6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f', '77012347', 2, TRUE),
('Mario Lopez', 'mariolopez', '5e4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e', '77012348', 4, TRUE),
('Diego Torres', 'diegotorres', '4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d', '77012349', 6, TRUE);

-- Asignar roles
INSERT INTO usuario_roles (usuario_id, rol_id) VALUES
(1, 1), -- Juan = ADMIN
(2, 3), -- Ana = GUARDIA
(3, 1), -- Pedro = ADMIN
(4, 2), -- Mario = RESIDENTE
(5, 2); -- Diego = RESIDENTE

-- Insertar áreas comunes
INSERT INTO areas_comunes (nombre, descripcion, capacidad, requiere_pago, tarifa, horario_apertura, horario_cierre, activo) VALUES
('Piscina', 'Piscina climatizada para adultos y niños', 20, TRUE, 50.00, '08:00', '20:00', TRUE),
('Gimnasio', 'Gimnasio equipado con máquinas modernas', 10, FALSE, 0.00, '06:00', '22:00', TRUE),
('Salón de Eventos', 'Salón para fiestas y reuniones', 50, TRUE, 150.00, '10:00', '00:00', TRUE),
('Cancha de Tenis', 'Cancha de tenis profesional', 4, TRUE, 30.00, '07:00', '21:00', TRUE),
('Área de BBQ', 'Parrillas y mesas para asados', 30, TRUE, 80.00, '10:00', '22:00', TRUE),
('Parque Infantil', 'Juegos para niños', 25, FALSE, 0.00, '08:00', '18:00', TRUE),
('Sala de Cine', 'Sala con proyector y sonido surround', 15, FALSE, 0.00, '14:00', '23:00', TRUE);

-- Insertar reservas de ejemplo
INSERT INTO reservas (codigo, usuario_id, area_comun_id, vivienda_id, fecha_reserva, hora_inicio, hora_fin, estado, qr_generado) VALUES
('R-2025010001', 4, 1, 4, '2025-10-15', '14:00', '18:00', 'CONFIRMADA', 'RESERVA-R-2025010001'),
('R-2025010002', 5, 3, 6, '2025-10-20', '19:00', '23:00', 'PENDIENTE', 'RESERVA-R-2025010002'),
('R-2025010003', 4, 5, 4, '2025-10-12', '12:00', '16:00', 'CONFIRMADA', 'RESERVA-R-2025010003');

-- Insertar expensas
INSERT INTO expensas (codigo, vivienda_id, periodo, monto_total, fecha_vencimiento, estado) VALUES
('EXP-2025-09-001', 1, '2025-09', 500.00, '2025-09-30', 'PAGADA'),
('EXP-2025-09-002', 2, '2025-09', 500.00, '2025-09-30', 'PAGADA'),
('EXP-2025-09-003', 4, '2025-09', 550.00, '2025-09-30', 'PAGADA'),
('EXP-2025-10-001', 1, '2025-10', 500.00, '2025-10-31', 'PENDIENTE'),
('EXP-2025-10-002', 2, '2025-10', 500.00, '2025-10-31', 'PENDIENTE'),
('EXP-2025-10-003', 4, '2025-10', 550.00, '2025-10-31', 'PENDIENTE'),
('EXP-2025-10-004', 6, '2025-10', 520.00, '2025-10-31', 'PENDIENTE');

-- Insertar comunicados
INSERT INTO comunicados (titulo, contenido, prioridad, autor_id, activo) VALUES
('Mantenimiento de Piscina', 'La piscina estará cerrada el próximo sábado por mantenimiento preventivo. Disculpen las molestias.', 'ALTA', 1, TRUE),
('Nuevo Horario de Gimnasio', 'A partir del 1 de octubre, el gimnasio abrirá desde las 6:00 AM hasta las 22:00 PM.', 'MEDIA', 1, TRUE),
('Recordatorio de Pago', 'Recordamos a todos los residentes que el vencimiento de la expensa es el día 31 de cada mes.', 'MEDIA', 1, TRUE),
('Fiesta de Halloween', 'Los invitamos a la fiesta de Halloween el 31 de octubre en el salón de eventos. Entrada gratuita.', 'BAJA', 1, TRUE);

-- Insertar visitantes
INSERT INTO visitantes (nombre_completo, documento, vivienda_id, fecha_visita, qr_generado, estado) VALUES
('Carlos Mamani', '12345678', 4, CURRENT_DATE, 'VISIT-1727891234567', 'PENDIENTE'),
('Laura Flores', '87654321', 1, CURRENT_DATE + INTERVAL '1 day', 'VISIT-1727891234568', 'PENDIENTE');

-- ============================================
-- VERIFICACIÓN
-- ============================================
SELECT 'Viviendas insertadas: ' || COUNT(*) FROM viviendas;
SELECT 'Usuarios insertados: ' || COUNT(*) FROM usuarios;
SELECT 'Áreas comunes insertadas: ' || COUNT(*) FROM areas_comunes;
SELECT 'Reservas insertadas: ' || COUNT(*) FROM reservas;
SELECT 'Expensas insertadas: ' || COUNT(*) FROM expensas;
SELECT 'Comunicados insertados: ' || COUNT(*) FROM comunicados;
SELECT 'Visitantes insertados: ' || COUNT(*) FROM visitantes;

-- ============================================
-- CONSULTAS DE PRUEBA
-- ============================================

-- Ver usuarios con sus roles
SELECT u.nombre_completo, u.email, r.nombre as rol
FROM usuarios u
JOIN usuario_roles ur ON u.id = ur.usuario_id
JOIN roles r ON ur.rol_id = r.id;

-- Ver reservas con detalles
SELECT r.codigo, u.nombre_completo, a.nombre as area, r.fecha_reserva, r.estado
FROM reservas r
JOIN usuarios u ON r.usuario_id = u.id
JOIN areas_comunes a ON r.area_comun_id = a.id;

-- Ver expensas por vivienda
SELECT v.codigo, e.periodo, e.monto_total, e.estado
FROM expensas e
JOIN viviendas v ON e.vivienda_id = v.id
ORDER BY e.periodo DESC;

