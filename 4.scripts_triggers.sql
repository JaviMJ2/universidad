DELIMITER //

-- R.N.01: Limitación de Invitaciones (Insert)
DROP TRIGGER IF EXISTS rn01_limitacionInvitaciones_insert;
CREATE TRIGGER rn01_limitacionInvitaciones_insert
BEFORE INSERT ON tiempoInvitados
FOR EACH ROW
BEGIN
    DECLARE invitacionesMes INT;

    SELECT COUNT(*) INTO invitacionesMes
    FROM tiempoInvitados
    WHERE socioId = NEW.socioId 
      AND MONTH(fechaEntrada) = MONTH(NEW.fechaEntrada) 
      AND YEAR(fechaEntrada) = YEAR(NEW.fechaEntrada);

    IF invitacionesMes > 12 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El socio ha alcanzado el límite de 12 invitaciones este mes.';
    END IF;
END //

-- R.N.01: Limitación de Invitaciones (Update)
DROP TRIGGER IF EXISTS rn01_limitacionInvitaciones_update;
CREATE TRIGGER rn01_limitacionInvitaciones_update
BEFORE UPDATE ON tiempoInvitados
FOR EACH ROW
BEGIN
    DECLARE invitacionesMes INT;

    SELECT COUNT(*) INTO invitacionesMes
    FROM tiempoInvitados
    WHERE socioId = NEW.socioId 
      AND MONTH(fechaEntrada) = MONTH(NEW.fechaEntrada) 
      AND YEAR(fechaEntrada) = YEAR(NEW.fechaEntrada);

    IF invitacionesMes > 12 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El socio ha alcanzado el límite de 12 invitaciones este mes.';
    END IF;
END //

-- R.N.02: Validar Pago de Inscripción
DROP TRIGGER IF EXISTS rn02_validarPagoInscripcion;
CREATE TRIGGER rn02_validarPagoInscripcion
BEFORE INSERT ON socios
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pagosSuscripcion
        WHERE usuarioId = NEW.usuarioId
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe realizar un pago de inscripción antes de registrarse.';
    END IF;
END //

-- R.N.03: Validar pago Mensual
DROP TRIGGER IF EXISTS rn03_verificarPagoMensual;
CREATE TRIGGER rn03_verificarPagoMensual
BEFORE INSERT ON pagosSuscripcion
FOR EACH ROW
BEGIN
    DECLARE fechaUltimoPago DATE DEFAULT NULL;
    DECLARE fechaLimite DATE DEFAULT NULL;

    -- Comprobar si el usuario tiene algún pago previo
    SELECT pagosSuscripcion.fechaRealizacion
    INTO fechaUltimoPago
    FROM pagosSuscripcion
    WHERE usuarioId = NEW.usuarioId
    ORDER BY fechaRealizacion DESC
    LIMIT 1;

    -- Si el usuario tiene un pago previo, validamos la fecha
    IF fechaUltimoPago IS NOT NULL THEN
        -- Establecer la fecha límite del próximo mes
        SET fechaLimite = DATE_ADD(fechaUltimoPago, INTERVAL 1 MONTH);
        
        -- Ajustar la fecha límite si el día no existe en el próximo mes
        IF DAY(fechaUltimoPago) > DAY(LAST_DAY(fechaLimite)) THEN
            SET fechaLimite = LAST_DAY(fechaLimite);
        END IF;

        -- Si el nuevo pago no está en la fecha límite, lanzar un error
        IF NEW.fechaRealizacion <> fechaLimite THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe realizar el pago de la cuota mensual dentro del período de un mes desde el último pago.';
        END IF;
    END IF;
END//

-- R.N.04: Ofertas de Cuotas
DROP TRIGGER IF EXISTS rn04_ofertasCuotas;
CREATE TRIGGER rn04_ofertasCuotas
BEFORE INSERT ON pagosSuscripcion
FOR EACH ROW
BEGIN
    DECLARE edad INT;

    SELECT TIMESTAMPDIFF(YEAR, fechaNacimiento, CURDATE()) INTO edad
    FROM usuarios
    WHERE id = NEW.usuarioId;

    IF edad < 3 THEN
        SET NEW.importePagado = 0;
    ELSEIF edad < 14 OR edad > 65 THEN
        SET NEW.importePagado = NEW.importePagado * 0.8;
    END IF;
END //

-- R.N.05: Comprobar Socio o Administrador
DROP TRIGGER IF EXISTS rn05_reservaSocioAdministrador;
CREATE TRIGGER rn05_reservaSocioAdministrador
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM socios
        WHERE id = NEW.socioId
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No puede realizar la reserva debido a que no es ni socio ni administrador.';
    END IF;
END //

-- R.N.06: Número de Reservas Simultáneas
DROP TRIGGER IF EXISTS rn06_simultaneidadReservas;
CREATE TRIGGER rn06_simultaneidadReservas
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    DECLARE numReservasSimultaneas INT;

    SELECT COUNT(*) INTO numReservasSimultaneas
    FROM reservas
    WHERE socioId = NEW.socioId 
      AND ((NEW.fechaInicio BETWEEN fechaInicio AND fechaFin) 
        OR (NEW.fechaFin BETWEEN fechaInicio AND fechaFin));

    IF numReservasSimultaneas >= 2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No puede realizar más de dos reservas simultáneas.';
    END IF;
END //

-- R.N.07: Diferencia Máxima de Días
DROP TRIGGER IF EXISTS rn07_maxDiferenciaDias;
CREATE TRIGGER rn07_maxDiferenciaDias
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    IF DATEDIFF(NEW.fechaInicio, CURDATE()) > 15 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La reserva debe hacerse con un máximo de 15 días de antelación.';
    END IF;
END //

-- R.N.08: Solape de Reservas
DROP TRIGGER IF EXISTS rn08_solapeReservas;
CREATE TRIGGER rn08_solapeReservas
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM reservas
        WHERE pistaId = NEW.pistaId 
          AND ((NEW.fechaInicio BETWEEN fechaInicio AND fechaFin)
            OR (NEW.fechaFin BETWEEN fechaInicio AND fechaFin) 
            OR (fechaInicio BETWEEN NEW.fechaInicio AND NEW.fechaFin))
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede realizar la reserva debido a que otro socio ha hecho otra reserva en el mismo tramo horario en dicha pista.';
    END IF;
END //

DELIMITER ;
