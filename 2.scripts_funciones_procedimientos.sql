DELIMITER //

-- CREAR USUARIO
CREATE OR REPLACE PROCEDURE crearUsuario(nombre VARCHAR(255), apellido1 VARCHAR(255), apellido2 VARCHAR(255),correo VARCHAR(255), contrasena VARCHAR(255), fechaNacimiento DATE)
    BEGIN
        INSERT INTO usuarios(nombre, apellido1, apellido2, correo, contrasena, fechaNacimiento)
        VALUES(nombre, apellido1, apellido2, correo, contrasena, fechaNacimiento);
    END //
    
-- MODIFICAR USUARIOS
CREATE OR REPLACE PROCEDURE modificarUsuario(nombre VARCHAR(255), apellido1 VARCHAR(255), apellido2 VARCHAR(255), correoAntiguo VARCHAR(255), correoNuevo VARCHAR(255), contrasena VARCHAR(255), fechaNacimiento DATE)
    BEGIN 
        UPDATE usuarios AS u
        SET 
            u.nombre = nombre, 
            u.apellido1 = apellido1, 
            u.apellido2 = apellido2, 
            u.correo = correoNuevo, 
            u.contrasena = contrasena,
            u.fechaNacimiento = fechaNacimiento
        WHERE u.correo = correoAntiguo;
    END //

-- LISTAR USUARIO
CREATE OR REPLACE PROCEDURE listarUsuario()
    BEGIN
        SELECT * FROM usuarios;
    END //

-- ELIMINAR USUARIO
CREATE OR REPLACE PROCEDURE eliminarUsuario(correo VARCHAR(255))
    BEGIN    
        DELETE FROM usuarios
        WHERE usuarios.correo = correo;
    END // 





-- CREAR SOCIO
CREATE OR REPLACE PROCEDURE crearSocio(correo VARCHAR(255),dni VARCHAR(9), telefono VARCHAR(255))
    BEGIN 
        DECLARE usuarioId INT;
        
        -- Obtener el id del usuario a partir del correo
        SELECT id INTO usuarioId FROM usuarios u WHERE u.correo = correo;
        
        -- Insertar el nuevo socio
        INSERT INTO socios (dni, telefono, usuarioId)
        VALUES (dni, telefono, usuarioId);
    END //

-- MODIFICAR SOCIO
CREATE OR REPLACE PROCEDURE modificarSocio(correo VARCHAR(255),dni VARCHAR(9), telefono VARCHAR(255))
    BEGIN
        UPDATE socios s JOIN usuarios AS u ON(s.usuarioId = u.id) 
        SET 
            s.dni = dni, 
            s.telefono = telefono
        WHERE u.correo = correo;
    END //

-- LISTAR SOCIOS
CREATE OR REPLACE PROCEDURE listarSocio()
	BEGIN 
        SELECT * FROM socios;
    END //

-- ELIMINAR SOCIO
CREATE OR REPLACE PROCEDURE eliminarSocio(correo VARCHAR(255))
    BEGIN 
        DECLARE socioId INT;
        
        SELECT socios.id INTO socioId 
        FROM socios 
        JOIN usuarios ON usuarios.id = socios.usuarioId 
        WHERE usuarios.correo = correo;
        
        DELETE FROM socios
        WHERE socios.id = socioId;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Socio eliminado con exito';
    END //





-- CREAR NO SOCIO
CREATE OR REPLACE PROCEDURE crearNoSocio(correo VARCHAR(255), dni VARCHAR(9), telefono VARCHAR(255))
BEGIN 
    DECLARE usuarioId INT;

    SELECT id INTO usuarioId FROM usuarios u WHERE u.correo = correo;

    INSERT INTO nosocios(dni, telefono, usuarioId)
    VALUES(dni, telefono, usuarioId);
END //

-- MODIFICAR NO SOCIO
CREATE OR REPLACE PROCEDURE modificarNoSocio(correo VARCHAR(255), dni VARCHAR(9), telefono VARCHAR(255))
	BEGIN 
		UPDATE socios s JOIN usuarios AS u ON (s.usuarioId = u.id)
		SET 
			s.dni = dni,
			s.telefono = telefono
		WHERE u.correo = correo;
	END //

-- LISTAR NO SOCIO
CREATE OR REPLACE PROCEDURE listarNoSocio()
    BEGIN
        SELECT * FROM nosocios;
    END //

-- BORRAR NO SOCIO
CREATE OR REPLACE PROCEDURE borrarNoSocio(correo VARCHAR(255))
    BEGIN 
        DECLARE noSocioId INT;
        
        SELECT nosocios.id INTO noSocioId 
        FROM nosocios 
        JOIN usuarios ON usuarios.id = nosocios.usuarioId 
        WHERE usuarios.correo = correo;
        
        DELETE FROM nosocios 
        WHERE nosocios.id = noSocioId;
    END //









-- CREAR INVITADO
CREATE OR REPLACE PROCEDURE crearInvitado(correo VARCHAR(255),nombre VARCHAR(255),apellido1 VARCHAR(255),apellido2 VARCHAR(255)) 
	BEGIN	
		DECLARE socioid INT;
		
		SELECT s.id INTO socioid FROM socios s JOIN usuarios u ON(s.usuarioId = u.id) WHERE correo = u.correo;
		
		INSERT INTO invitados(nombre,apellido1,apellido2,socioId)
		VALUES (nombre,apellido1,apellido2,socioId);
	END //
	
-- MODIFICAR INVITADO
CREATE OR REPLACE PROCEDURE modificarInvitado(correo VARCHAR(255),nombre VARCHAR(255),apellido1 VARCHAR(255),apellido2 VARCHAR(255)) 
    BEGIN	
        DECLARE socioid INT;
        
        SELECT s.id INTO socioid FROM socios s JOIN usuarios u ON(s.usuarioId = u.id) WHERE correo = u.correo;
        
        UPDATE invitados i JOIN socios s ON(i.socioId = s.id) JOIN usuarios u ON(s.usuarioId = u.id)
        SET i.nombre = nombre, i.apellido1 = apellido1, i.apellido2 = apellido2
        WHERE u.correo = correo;
    END //

-- LISTAR INVITADOS
CREATE OR REPLACE PROCEDURE listarInvitado()
	BEGIN
		SELECT * FROM invitados;
	END //

-- BORRAR INVITADO	
CREATE OR REPLACE PROCEDURE eliminarInvitado(correo VARCHAR(255), nombre VARCHAR(255), apellido1 VARCHAR(255), apellido2 VARCHAR(255))
	BEGIN	
        DECLARE socioId INT;
        
        SELECT s.id INTO socioId FROM socios s JOIN usuarios u ON(s.usuarioId = u.id) WHERE correo = u.correo;
        
        DELETE FROM invitados 
        WHERE nombre = nombre AND apellido1 = apellido1 
                AND apellido2 = apellido2 AND socioId = socioId;
	END // 









-- CREAR TIEMPOINVITADO
CREATE OR REPLACE PROCEDURE crearTiempoInvitado(correo VARCHAR(255), fechaEntrada DATETIME,fechaSalida DATETIME,nombre VARCHAR(255),apellido1 VARCHAR(255),apellido2 VARCHAR(255)
)
BEGIN
    DECLARE invitadoId INT;
    DECLARE socioId INT;
    
    -- Seleccionar el ID del invitado, asegurando que solo se devuelva una fila
    SELECT i.id INTO invitadoId
    FROM invitados i
    JOIN socios s ON i.socioId = s.id
    JOIN usuarios u ON s.usuarioId = u.id
    WHERE u.correo = correo 
      AND i.nombre = nombre 
      AND i.apellido1 = apellido1 
      AND i.apellido2 = apellido2
    LIMIT 1;  -- Asegurar que solo se devuelve una fila
    
    -- Seleccionar el ID del socio
    SELECT s.id INTO socioId
    FROM socios s
    JOIN usuarios u ON s.usuarioId = u.id
    WHERE u.correo = correo
    LIMIT 1;  -- Asegurar que solo se devuelve una fila
    
    -- Insertar en la tabla tiempoinvitados
    INSERT INTO tiempoinvitados(fechaEntrada, fechaSalida, invitadoId, socioId)
    VALUES(fechaEntrada, fechaSalida, invitadoId, socioId);
END //

-- LISTAR TIEMPOINVITADO
CREATE OR REPLACE PROCEDURE listarTiempoInvitado()
    BEGIN
        SELECT * FROM tiemposinvitados;
    END //

-- BORRAR TIEMPOINVITADO
CREATE OR REPLACE PROCEDURE borrarTiempoInvitado(correo VARCHAR(255), fechaInicio DATETIME, fechaFin DATETIME,
                                                nombre VARCHAR(255), apellido1 VARCHAR(255), apellido2 VARCHAR(255))
    BEGIN
        DECLARE invitadoId INT;
        DECLARE socioId INT;
        
        SELECT i.id INTO invitadoId
        FROM invitados i
        JOIN socios s ON i.socioId = s.id
        JOIN usuarios u ON s.usuarioId = u.id
        WHERE u.correo = correo AND i.nombre = nombre AND i.apellido1 = apellido1 AND i.apellido2 = apellido2;
        
        SELECT s.id INTO socioId
        FROM socios s
        JOIN usuarios u ON s.usuarioId = u.id
        WHERE u.correo = correo;
        
        DELETE FROM tiemposinvitados
        WHERE fechaInicio = fechaInicio AND fechaFin = fechaFin AND invitadoId = invitadoId AND socioId = socioId
        AND nombre = nombre AND apellido1 = apellido1 AND apellido2 = apellido2;
    END //









-- CREAR ADMINISTRADOR
CREATE OR REPLACE PROCEDURE crearAdministrador(correo VARCHAR(255))
	BEGIN 
		DECLARE usuarioId INT;
		SELECT u.id INTO usuarioId FROM usuarios u WHERE correo = u.correo;
		
		INSERT INTO administradores(usuarioId)
		VALUES (usuarioId);
	END //

/*NO SE HA CREADO UN MODIFICAR UN ADMINISTRADOR YA QUE NO HAY DATOS QUE ACTUALIZAR*/

-- LISTAR ADMINISTRADOR
CREATE OR REPLACE PROCEDURE listarAdministrador()
    BEGIN 
        SELECT * FROM administradores;
    END //

-- BORRAR ADMINISTRADOR
CREATE OR REPLACE PROCEDURE eliminarAdministrador(correo VARCHAR(255))
	BEGIN	
		DECLARE usuarioId INT;
		SELECT u.id INTO usuarioId FROM usuarios u WHERE correo = u.correo;
		
		DELETE FROM administradores 
		WHERE usuarioId = usuarioId;
	END //









-- CREAR RESERVAS (tanto si eres administrador como socio)
CREATE OR REPLACE PROCEDURE crearReserva(correo VARCHAR(255), fechaInicio DATETIME, fechaFin DATETIME, nombrePista VARCHAR(255))
    BEGIN
        DECLARE pistaId INT;
        DECLARE socioId INT;
        
        SET pistaId = NULL;

        SELECT socios.id INTO socioId 
        FROM socios 
        JOIN usuarios ON socios.usuarioId = usuarios.id
        WHERE usuarios.correo = correo
        LIMIT 1;

        IF (nombrePista IS NOT NULL) THEN
            SELECT pistas.id INTO pistaId 
            FROM pistas 
            WHERE pistas.nombre = nombrePista
            LIMIT 1;
        END IF ;

        INSERT INTO reservas(fechaInicio, fechaFin, socioId, pistaId)
        VALUES(fechaInicio, fechaFin, socioId, pistaId);
    END //


-- MODIFICAR RESERVAS
CREATE OR REPLACE PROCEDURE modificarReserva(correo VARCHAR(255), fechaInicio DATETIME, fechaFin DATETIME, nombrePista VARCHAR(255))
    BEGIN 
        UPDATE reservas r 
        JOIN socios s ON s.id = r.socioId 
        JOIN usuarios u ON s.usuarioId = u.id 
        JOIN pistas p ON r.pistaId = p.id
        SET 
            r.fechaInicio = fechaInicio,
            r.fechaFin = fechaFin,
            r.pistaId = p.id
            WHERE u.correo = correo AND p.nombre = nombrePista;
    END //

-- LISTAR RESERVA
CREATE OR REPLACE PROCEDURE listarReserva()
    BEGIN
        SELECT * FROM reservas;
    END //

-- BORRAR RESERVA (tanto si eres administrador como si eres socio)
CREATE OR REPLACE PROCEDURE borrarReserva(correo VARCHAR(255), fechaInicio DATETIME, fechaFin DATETIME, nombrePista VARCHAR(255))
    BEGIN
        DECLARE idReserva INT;

        SELECT reservas.id INTO idReserva
        FROM reservas
        JOIN socios ON socios.id = reservas.socioId
        JOIN usuarios ON usuarios.id = socios.usuarioId
        JOIN pistas ON reservas.pistaId = pistas.id
        WHERE usuarios.correo = correo;

        DELETE FROM reservas
        WHERE id = idReserva;
    END //









-- CREAR PISTAS
CREATE OR REPLACE PROCEDURE crearPistas(nombrePista VARCHAR(255), tipoPista VARCHAR(255), capacidadMaxima INT)
    BEGIN
        INSERT INTO pistas(nombre,tipo,capacidadMax)
        VALUES(nombrePista,tipoPista,capacidadMaxima);
    END //

-- LISTAR PISTAS
CREATE OR REPLACE PROCEDURE listarPistas()
    BEGIN
        SELECT * FROM pistas;
    END //

-- MODIFICAR PISTAS
CREATE OR REPLACE PROCEDURE modificarPista(viejoNombre VARCHAR(255), nuevoNombre VARCHAR(255), nuevoTipo VARCHAR(255), nuevaCapacidad INT)
    BEGIN
        UPDATE pistas AS p
        SET 
            p.nombre = nuevoNombre,
            p.tipo = nuevoTipo,
            p.capacidadMax = nuevaCapacidad
        WHERE nombre = viejoNombre;
    END //

-- BORRAR PISTAS
CREATE OR REPLACE PROCEDURE eliminarPista(nombre VARCHAR(255))
    BEGIN
        DELETE FROM pistas
        WHERE pistas.nombre = nombre;
    END //
    
CREATE OR REPLACE PROCEDURE listarPistas()
BEGIN
    SELECT * FROM pistas;
END //









-- CREAR SUSCRIPCIONES
CREATE OR REPLACE PROCEDURE crearSuscripcion(precio INT, correo VARCHAR(255), tipoSuscripcion INT) 
    BEGIN
        DECLARE usuarioId INT;
        
        SELECT usuarios.id INTO usuarioId
        FROM usuarios
		WHERE usuarios.correo = correo; 
        
        INSERT INTO suscripciones(precio, usuarioId, tipoSuscripcion)
        VALUES(precio, usuarioId, tipoSuscripcion);
    END //

-- LISTAR SUSCRIPCIONES
CREATE OR REPLACE PROCEDURE listarSuscripcion()
    BEGIN
        SELECT * FROM suscripciones;
    END //

-- MODIFICAR SUSCRIPCIONES
CREATE OR REPLACE PROCEDURE modificarSuscripcion(correo VARCHAR(255), precio DECIMAL(10, 2), tipoSuscripcion INT)
    BEGIN
        DECLARE socioId INT;
        SELECT socios.id INTO socioId FROM socios JOIN usuarios ON usuarios.id = socios.usuarioId WHERE usuarios.correo = correo;

        UPDATE suscripciones AS s 
        SET 
            s.precio = precio,
            s.tipoSuscripcion = tipoSuscripcion
        WHERE s.socioId = socioId;
    END //

-- BORRAR SUSCRIPCIONES
CREATE OR REPLACE PROCEDURE eliminarSuscripcion(correo VARCHAR(255))
    BEGIN
        DECLARE socioId INT;
        SELECT socios.id INTO socioId 
        FROM socios JOIN usuarios ON usuarios.id = socios.usuarioId 
        WHERE usuarios.correo = correo
        LIMIT 1;

        DELETE FROM suscripciones
        WHERE suscripciones.socioId = socioId;
    END //









-- CREAR PAGO SUSCRIPCION
CREATE OR REPLACE PROCEDURE crearPagoSuscripcion(correo VARCHAR(255), fechaRealizacion DATE, metodoPago VARCHAR(50))
BEGIN
    DECLARE usuarioId INT;
    DECLARE suscripcionId INT;
    DECLARE importePagado DECIMAL(10, 2);
 
    -- Obtener el ID del usuario basado en el correo
    SELECT id INTO usuarioId
    FROM usuarios u
    WHERE u.correo = correo
    LIMIT 1;

    -- Obtener el ID de la suscripcion basado en el correo
    SELECT suscripciones.id INTO suscripcionId
    FROM suscripciones
    JOIN usuarios ON(suscripciones.usuarioId = usuarios.id)
    WHERE usuarios.correo = correo
    LIMIT 1;

    SELECT suscripciones.precio INTO importePagado
    FROM suscripciones
    JOIN usuarios ON(suscripciones.usuarioId = usuarios.id)
    WHERE usuarios.correo = correo
    LIMIT 1;


    -- Insertar el pago
    INSERT INTO pagosSuscripcion(fechaRealizacion, importePagado, usuarioId, metodoPago, suscripcionId)
    VALUES(fechaRealizacion, importePagado, usuarioId, metodoPago, suscripcionId);

END //


-- LISTAR PAGOS
CREATE OR REPLACE PROCEDURE listarPagos()
BEGIN
    SELECT * FROM pagosSuscripcion;
END //

-- MODIFICAR PAGOSUSCRIPCION
CREATE OR REPLACE PROCEDURE modificarPago(
    correo VARCHAR(255), 
    nuevoMetodoPago VARCHAR(50), 
    nuevaFecha DATE, 
    nuevaSuscripcionId INT,
    nuevoImporte DECIMAL(10, 2)
)
BEGIN
    DECLARE usuarioId INT;

    -- Obtener el ID del usuario basado en el correo
    SELECT id INTO usuarioId
    FROM usuarios
    WHERE usuarios.correo = correo;

    -- Actualizar los datos del pago
    UPDATE pagosSuscripcion
    SET 
        pagosSuscripcion.metodoPago = nuevoMetodoPago,
        pagosSuscripcion.fechaRealizacion = nuevaFecha,
        pagosSuscripcion.suscripcionId = nuevaSuscripcionId,
        pagosSuscripcion.importePagado = nuevoImporte
    WHERE pagosSuscripcion.usuarioId = usuarioId;
END //


-- ELIMINAR PAGOSUSCRIPCION
CREATE OR REPLACE PROCEDURE eliminarPago(correo VARCHAR(255))
BEGIN
    DECLARE usuarioId INT;

    -- Obtener el ID del usuario basado en el correo
    SELECT id INTO usuarioId
    FROM usuarios
    WHERE usuarios.correo = correo;

    -- Eliminar pagos asociados al usuario
    DELETE FROM pagosSuscripcion
    WHERE pagosSuscripcion.usuarioId = usuarioId;
END //









-- CREAR EVENTO 
CREATE OR REPLACE PROCEDURE crearEvento(nombreEvento VARCHAR(255), fechaEvento DATE, descripcionEvento VARCHAR(255), correo VARCHAR(255))
    BEGIN
        DECLARE reservaId INT;

        SELECT reservas.id INTO reservaId
        FROM reservas
        JOIN socios ON socios.id = reservas.socioId
        JOIN usuarios ON usuarios.id = socios.usuarioId
        WHERE usuarios.correo = correo;

        INSERT INTO eventos(nombre, fecha, descripcion, reservaId)
        VALUES (nombreEvento, fechaEvento, descripcionEvento, reservaId);
    END //

-- LISTAR EVENTOS
CREATE OR REPLACE PROCEDURE listarEvento()
    BEGIN
        SELECT * FROM eventos;
    END //

-- MODIFICAR EVENTOS
CREATE OR REPLACE PROCEDURE modificarEvento(antiguoNombre VARCHAR(255), nuevoNombre VARCHAR(255), antiguaFecha DATE, nuevaFecha DATE, nuevaDescripcion VARCHAR(255))
    BEGIN
        DECLARE reservaId INT;

        SELECT reservas.id INTO reservaId
        FROM reservas
        JOIN socios ON socios.id = reservas.socioId
        JOIN usuarios ON usuarios.id = socios.usuarioId
        WHERE usuarios.correo = correo AND reservas;
        
        UPDATE eventos AS e
        SET 
            e.nombre = nuevoNombre,
            e.fecha = nuevaFecha,
            e.descripcion = nuevaDescripcion,
            e.reservaId = nuevaReservaId
        WHERE e.nombre = antiguoNombre AND e.fecha = antiguaFecha;
    END //

-- ELIMINAR EVENTO
CREATE OR REPLACE PROCEDURE eliminarEvento(nombre VARCHAR(255), fecha DATE)
    BEGIN
        DELETE FROM eventos 
        WHERE eventos.nombre = nombre AND eventos.fecha = fecha;
    END //









-- CREAR CURSO
CREATE OR REPLACE PROCEDURE crearCurso(nombre VARCHAR(255), precio DECIMAL(10, 2), inicioCurso DATETIME, finCurso DATETIME)
BEGIN
    INSERT INTO cursos (nombre, precio, inicioCurso, finCurso)
    VALUES (nombre, precio, inicioCurso, finCurso);
END //

-- LISTAR CURSO
CREATE OR REPLACE PROCEDURE listarCurso()
BEGIN
    SELECT * FROM cursos;
END //

-- MODIFICAR CURSO
CREATE OR REPLACE PROCEDURE modificarCurso(nombreAntiguo VARCHAR(255), nombreNuevo VARCHAR(255), precio DECIMAL(10, 2), inicioCurso DATETIME, finCurso DATETIME)
BEGIN
    UPDATE cursos AS c
    SET 
        c.nombre = nombreNuevo,
        c.precio = precio,
        c.inicioCurso = inicioCurso,
        c.finCurso = finCurso
    WHERE c.nombre = nombreAntiguo;
END //

-- BORRAR CURSO
CREATE OR REPLACE PROCEDURE borrarCurso(nombre VARCHAR(255))
BEGIN
    DELETE FROM cursos
    WHERE cursos.nombre = nombre;
END //









-- CREAR PERIODICIDAD
CREATE OR REPLACE PROCEDURE crearPeriodicidad(dia VARCHAR(255), horaInicio TIME, horaFin TIME, cursoNombre VARCHAR(255))
    BEGIN
        DECLARE cursoId INT;

        SELECT cursos.id INTO cursoId FROM cursos WHERE cursos.nombre = cursoNombre;

        INSERT INTO periodicidades(dia, horaInicio, horaFin, cursoId)
        VALUES (dia, horaInicio, horaFin, cursoId);
    END //

-- LISTAR PERIODICIDAD
CREATE OR REPLACE PROCEDURE listarPeriodicidad()
    BEGIN
        SELECT * FROM periodicidades;
    END //

-- MODIFICAR PERIODICIDAD
CREATE OR REPLACE PROCEDURE modificarPeriodicidad(diaAnterior VARCHAR(255), diaNuevo VARCHAR(255), antiguaHoraInicio TIME, horaInicio TIME, horaFin TIME, cursoNombre VARCHAR(255))
BEGIN
    DECLARE cursoId INT;

    SELECT cursos.id INTO cursoId FROM cursos WHERE cursos.nombre = cursoNombre;

    UPDATE periodicidades AS p
    SET
        p.dia = diaNuevo,
        p.horaInicio = horaInicio,
        p.horaFin = horaFin,
        p.cursoId = cursoId
    WHERE p.cursoId = cursoId AND p.dia = diaAnterior AND p.horaInicio = antiguaHoraInicio;
END //

-- BORRAR PERIODICIDAD
CREATE OR REPLACE PROCEDURE borrarPeriodicidad(diaAnterior VARCHAR(255), cursoNombre VARCHAR(255), antiguaHoraInicio TIME)
    BEGIN
        DECLARE cursoId INT;

        SELECT cursos.id INTO cursoId FROM cursos WHERE cursos.nombre = cursoNombre;

        DELETE FROM periodicidades
        WHERE p.cursoId = cursoId AND p.dia = diaAnterior AND p.horaInicio = antiguaHoraInicio;
    END //









-- CREAR PAGOCURSO
CREATE OR REPLACE PROCEDURE crearPagoCurso(correo VARCHAR(255), cursoNombre VARCHAR(255), metodoPago VARCHAR(50))
    BEGIN
        DECLARE socioId INT;
        DECLARE cursoId INT;

        SELECT socios.id INTO socioId
        FROM socios
        JOIN usuarios ON usuarios.id = socios.usuarioId
        WHERE usuarios.correo = correo;

        SELECT cursos.id INTO cursoId
        FROM cursos
        WHERE cursos.nombre = cursoNombre;

        INSERT INTO pagosCursos(fechaRealizacion, socioId, cursoId, metodoPago)
        VALUES (CURDATE(), socioId, cursoId, metodoPago);
    END //

-- LISTAR
CREATE OR REPLACE PROCEDURE listarPagoCurso()
BEGIN
    SELECT * FROM pagosCursos;
END //




-- funcion para devolver la fecha de ultimo pago de un socio
CREATE OR REPLACE FUNCTION ultimoPagoSocio(correo VARCHAR(255))
RETURNS DATE
BEGIN

    DECLARE fechaUltimoPago DATE;
    SELECT MAX(pagosSuscripcion.fechaRealizacion) INTO fechaUltimoPago
    FROM pagosSuscripcion
    JOIN usuarios ON usuarios.id = pagosSuscripcion.usuarioId
    WHERE usuarios.correo = correo;

    return fechaUltimoPago;
END //

-- Funcion (no procedimiento) para averiguar el proximo pago de un socio.
CREATE OR REPLACE FUNCTION proximoPagoSocio(correo VARCHAR(255)) RETURNS DATE
BEGIN
    DECLARE fechaUltimoPago DATE;
    DECLARE fechaProximoPago DATE;
    
    CALL verUltimoPagoSocio(correo, fechaUltimoPago);
    
    SELECT DATE_ADD(fechaUltimoPago, INTERVAL 1 MONTH) INTO fechaProximoPago;
    
    RETURN fechaProximoPago;
END //

-- funcion para calcular el pago total de un socio en el club

CREATE OR REPLACE FUNCTION pagoTotalSocio(correo VARCHAR(255))
RETURNS DOUBLE
BEGIN 

    DECLARE sumaPagosSuscripcion DOUBLE;
    DECLARE sumaPagosCursos DOUBLE;

    SELECT SUM(cursos.precio) INTO sumaPagosCursos 
    FROM pagosCursos 
    JOIN cursos ON(pagosCursos.cursoId = cursos.id) 
    JOIN socios ON(pagoscursos.socioId = socios.id)
    JOIN usuarios ON(socios.usuarioId = usuarios.id) 
    WHERE usuarios.correo = correo;
    
    SELECT SUM(suscripciones.precio) INTO sumaPagosSuscripcion 
    FROM pagosSuscripcion 
    JOIN usuarios ON (pagossuscripcion.usuarioId = usuarios.id)
    JOIN suscripciones ON (pagossuscripcion.suscripcionId = suscripciones.id)
    WHERE usuarios.correo = correo;
    
    return sumaPagosSuscripcion + sumaPagosCursos;
END //



