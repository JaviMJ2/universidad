-- CREAR USUARIOS
CALL crearUsuario("Pablo", "Morón", "García", "moronpablo05@gmail.com", "pablomoron12345", "2005-03-15");
CALL crearUsuario ("Álvaro", "Guerrero", "López", "alvaroguerr2014@gmail.com", "contraseñaClub_", "2004-12-20");
CALL crearUsuario ("Juan Manuel", "Vargas", "Bellido", "juanmanuelvargas2005@gmail.com", "juanmaDeporte05", "2005-08-25");
CALL crearUsuario ("Javier", "Morales", "Jiménez", "moralesjavier2005@hotmail.com", "BombardinoMairena123", "2005-07-14");
CALL crearUsuario ("Miguel", "Romero", "García", "lupinrg@outlook.es", "mirogar2004_", "2004-10-09");
CALL crearUsuario ("Laura", "Martínez", "Hernández", "martinezlaura23@gmail.com", "lauraMartinez2023", "2003-11-18");
CALL crearUsuario ("Carlos", "González", "Pérez", "carlosgonzalez98@gmail.com", "carlitos2020!", "1998-05-22");
CALL crearUsuario ("Sara", "López", "Ramírez", "sara_lopez2021@hotmail.com", "saraLopez_21", "2001-06-30");
CALL crearUsuario ("Alejandro", "Ríos", "Martín", "alejandro.rios@outlook.com", "alejandroRios01", "2000-02-17");
CALL crearUsuario ("Patricia", "Torres", "Ortiz", "patriciatorres@gmail.com", "patyTorres2022", "2002-09-11");

-- CREAR SUSCRIPCION
CALL crearSuscripcion(30, 'moronpablo05@gmail.com', 1);
CALL crearSuscripcion(30, 'alvaroguerr2014@gmail.com', 1);
CALL crearSuscripcion(30, 'juanmanuelvargas2005@gmail.com', 1);
CALL crearSuscripcion(30, 'moralesjavier2005@hotmail.com', 1);

-- CREAR PAGOS SUSCRIPCION
CALL crearPagoSuscripcion('alvaroguerr2014@gmail.com', '2024-07-14', 'TARJETA');
CALL crearPagoSuscripcion('moronpablo05@gmail.com', '2024-08-01', 'EFECTIVO');
CALL crearPagoSuscripcion('moralesjavier2005@hotmail.com', '2024-08-15', 'TRANSFERENCIA');
CALL crearPagoSuscripcion('juanmanuelvargas2005@gmail.com', '2024-09-10', 'EFECTIVO');

-- CREAR SOCIO
CALL crearSocio('moronpablo05@gmail.com', "53962040S", 677890427);
CALL crearSocio('alvaroguerr2014@gmail.com',"67890437A", 669356874);
CALL crearSocio('juanmanuelvargas2005@gmail.com',"45612300K", 667854123);
CALL crearSocio('moralesjavier2005@hotmail.com', "12345678A", 612345678);

-- CREAR NO SOCIO
CALL crearNoSocio('lupinrg@outlook.es','98765432M','678912345');
CALL crearNoSocio('martinezlaura23@gmail.com','11223344L','612345678');
CALL crearNoSocio('carlosgonzalez98@gmail.com','22334455M','623456789');
CALL crearNoSocio('sara_lopez2021@hotmail.com','33445566N','634567890');
CALL crearNoSocio('alejandro.rios@outlook.com','44556677P','645678901');
CALL crearNoSocio('patriciatorres@gmail.com','55667788Q','656789012');

-- CREAR INVITADO
CALL crearInvitado('moronpablo05@gmail.com', 'Miguel', 'Romero', 'García');
CALL crearInvitado('moronpablo05@gmail.com', 'Laura', 'Martínez', 'Hernández');
CALL crearInvitado('alvaroguerr2014@gmail.com', 'Carlos', 'González', 'Pérez');
CALL crearInvitado('juanmanuelvargas2005@gmail.com', 'Sara', 'López', 'Ramírez');

-- CREAR TIEMPO INVITADO
CALL crearTiempoInvitado('moronpablo05@gmail.com', '2024-12-01 10:00:00', '2024-12-01 20:00', 'Miguel', 'Romero', 'García');
CALL crearTiempoInvitado('moronpablo05@gmail.com', '2024-12-02 14:00:00', '2024-12-02 18:00', 'Laura', 'Martínez', 'Hernández');
CALL crearTiempoInvitado('alvaroguerr2014@gmail.com', '2024-12-03 09:00:00', '2024-12-03 21:00', 'Carlos', 'González', 'Pérez');
CALL crearTiempoInvitado('juanmanuelvargas2005@gmail.com', '2024-12-04 17:00:00', '2024-12-04 19:00', 'Sara', 'López', 'Ramírez');

-- RESERVAS
CALL crearReserva('moralesjavier2005@hotmail.com', '2024-11-27 18:00', '2024-11-27 19:30', 'Tenis');
CALL crearReserva('moronpablo05@gmail.com', '2024-11-28 10:00', '2024-11-28 11:00', 'Pádel');
CALL crearReserva('alvaroguerr2014@gmail.com', '2024-11-29 15:30', '2024-11-29 17:00', 'Fútbol Sala');
CALL crearReserva('juanmanuelvargas2005@gmail.com', '2024-12-01 12:00', '2024-12-01 21:30', 'Baloncesto');
CALL crearReserva('moronpablo05@gmail.com', '2024-12-02 09:00', '2024-12-02 10:30', 'Voleibol');

-- CREAR CURSO
CALL crearCurso("Escuela de tenis", 50, '2023-09-05 17:00', '2024-05-05 19:00');
CALL crearCurso("Escuela de futbol", 120, '2023-08-15 19:00', '2024-06-05 21:00');

-- CREAR PAGO CURSO
CALL crearPagoCurso('moronpablo05@gmail.com', "Escuela de tenis", 'TARJETA');
CALL crearPagoCurso('moralesjavier2005@hotmail.com', "Escuela de futbol", 'EFECTIVO');

-- CREAR PERIODICIDAD
CALL crearPeriodicidad("Lunes", '16:00:00', '18:00:00', 'Escuela de futbol');
CALL crearPeriodicidad("Martes", '19:00:00', '21:00:00', 'Escuela de tenis');
CALL crearPeriodicidad("Miércoles", '18:00:00', '20:00:00', 'Escuela de futbol');
CALL crearPeriodicidad("Viernes", '20:00:00', '22:00:00', 'Escuela de tenis');
CALL crearPeriodicidad("Sábado", '14:00:00', '16:00:00', 'Escuela de futbol');