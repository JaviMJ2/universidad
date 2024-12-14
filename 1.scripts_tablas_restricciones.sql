/*CREACIÓN DE TABLAS DE LA BASE DE DATOS*/
/*DROP DE TABLAS EN EL CASO DE QUE EXISTIERAN*/
DROP TABLE IF EXISTS periodicidades;
DROP TABLE IF EXISTS pagosCursos;
DROP TABLE IF EXISTS cursos;

DROP TABLE IF EXISTS eventos;
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS pistas;

DROP TABLE IF EXISTS pagos;
DROP TABLE IF EXISTS suscripciones;

DROP VIEW  if EXISTS numinvitacionesestemes;
DROP TABLE IF EXISTS tiempoInvitados;
DROP TABLE IF EXISTS invitados;
DROP TABLE IF EXISTS administradores;
DROP TABLE IF EXISTS noSocios;
DROP TABLE IF EXISTS socios;
DROP TABLE IF EXISTS usuarios;

/* USUARIOS Y TIPOS DE USUARIOS */
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    correo VARCHAR(255) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    apellido1 VARCHAR(255) NOT NULL,
    apellido2 VARCHAR(255) NOT NULL,
    fechaNacimiento DATE NOT NULL
);

CREATE TABLE socios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dni VARCHAR(9) NOT NULL,
    telefono VARCHAR(255) UNIQUE NOT NULL,
    usuarioId INT NOT NULL,
    FOREIGN KEY (usuarioId) REFERENCES usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE noSocios ( 
    id INT PRIMARY KEY AUTO_INCREMENT,  
    dni VARCHAR(9) NOT NULL,
    telefono VARCHAR(255) UNIQUE NOT NULL,
    usuarioId INT NOT NULL,
    FOREIGN KEY (usuarioId) REFERENCES usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE administradores ( 
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuarioId INT NOT NULL,
    FOREIGN KEY (usuarioId) REFERENCES usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

/* INVITADOS DE "SOCIOS" */
CREATE TABLE invitados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    apellido1 VARCHAR(255) NOT NULL,
    apellido2 VARCHAR(255) NOT NULL,
    socioId INT NOT NULL,
    FOREIGN KEY (socioId) REFERENCES socios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE tiempoInvitados (
	id INT PRIMARY KEY AUTO_INCREMENT,
	fechaEntrada DATETIME NOT NULL,
	fechaSalida DATETIME NOT NULL,
	socioId INT NOT NULL,
	invitadoId INT NOT NULL,
	FOREIGN KEY (socioId) REFERENCES socios(id)
		ON DELETE CASCADE 
		ON UPDATE CASCADE, 
	FOREIGN KEY (invitadoId) REFERENCES invitados(id)
		ON DELETE CASCADE 
		ON UPDATE CASCADE 
);

/* PAGO Y SUSCRIPCIÓN "SOCIO" */
CREATE TABLE suscripciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    precio DECIMAL(10, 2) NOT NULL CHECK(precio > 0),
    usuarioId INT NOT NULL, 
    tipoSuscripcion ENUM('NORMAL', 'REDUCIDA', 'OFERTA') NOT NULL DEFAULT 'NORMAL',
    FOREIGN KEY (usuarioId) REFERENCES usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE pagosSuscripcion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    suscripcionId INT NOT NULL,
    fechaRealizacion DATE DEFAULT CURDATE(),
    importePagado INT NOT NULL,
    usuarioId INT NOT NULL,
    metodoPago ENUM('TARJETA', 'EFECTIVO', 'TRANSFERENCIA') NOT NULL DEFAULT 'TARJETA',
    FOREIGN KEY (usuarioId) REFERENCES usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (suscripcionId) REFERENCES suscripciones(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE (suscripcionId, usuarioId, fechaRealizacion)
);

/* RESERVAS, PISTAS Y EVENTOS */
CREATE TABLE pistas (
    id INT PRIMARY KEY AUTO_INCREMENT, 
    nombre VARCHAR(255) NOT NULL,
    tipo VARCHAR(255) NOT NULL,
    capacidadMax INT NOT NULL check(capacidadMax > 0)
);

CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fechaInicio DATETIME NOT NULL,
    fechaFin DATETIME NOT NULL,
    socioId INT NOT NULL,
    pistaId INT,
    FOREIGN KEY (socioId) REFERENCES socios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (pistaId) REFERENCES pistas(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE eventos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    fecha DATE NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    reservaId INT NOT NULL,
    FOREIGN KEY (reservaId) REFERENCES reservas(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

/* CURSOS, PERIODICIDAD Y PAGO_CURSO */
CREATE TABLE cursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL check(precio > 0),
    inicioCurso DATETIME NOT NULL, 
    finCurso DATETIME NOT NULL
);

CREATE TABLE pagosCursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fechaRealizacion DATETIME DEFAULT CURDATE(),
    socioId INT,
    noSocioId INT,
    cursoId INT NOT NULL,
    metodoPago ENUM('TARJETA', 'EFECTIVO', 'TRANSFERENCIA') NOT NULL DEFAULT 'TARJETA',
    FOREIGN KEY (socioId) REFERENCES socios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (noSocioId) REFERENCES noSocios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (cursoId) REFERENCES cursos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE periodicidades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dia VARCHAR(255) NOT NULL,
    horaInicio TIME NOT NULL,
    horaFin TIME NOT NULL,
    cursoId INT NOT NULL,
    FOREIGN KEY (cursoId) REFERENCES cursos(id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
);

CREATE VIEW numInvitacionesEsteMes AS
SELECT COUNT(*) AS numInvitaciones
FROM tiempoInvitados 
WHERE MONTH(fechaEntrada) = MONTH(CURDATE()) AND YEAR(fechaSalida) = YEAR(CURDATE())
GROUP BY socioId;

