/*CREATE TABLE EMPLEADO(
 legajo int,
 nombre varchar(100),
 edad int,
 sueldo int,
 primary key (legajo)
 );
 
 -- Los amigos de windows no nos dieron los permisos para abrir el archivo entonces lo pasamos a un pendrive
 COPY EMPLEADO
 FROM
 'E:\empleados.csv' WITH CSV HEADER DELIMITER ',';
 
 CREATE TABLE EMPLEADO_TT AS
 SELECT
 *
 FROM
 EMPLEADO
 ALTER TABLE
 EMPLEADO_TT
 ADD
 COLUMN tt_izq timestamp,
 ADD
 COLUMN tt_der timestamp;
 
 UPDATE
 EMPLEADO_TT
 SET
 tt_izq = CURRENT_TIMESTAMP,
 tt_der = 'infinity' :: timestamp;
 
 ALTER TABLE
 EMPLEADO_TT
 ALTER COLUMN
 tt_izq
 SET
 NOT NULL,
 ALTER COLUMN
 tt_der
 SET
 NOT NULL,
 ALTER COLUMN
 legajo
 SET
 NOT NULL,
 ALTER COLUMN
 nombre
 SET
 NOT NULL,
 ALTER COLUMN
 sueldo
 SET
 NOT NULL,
 ALTER COLUMN
 edad
 SET
 NOT NULL;
 
 ALTER TABLE
 EMPLEADO
 ALTER COLUMN
 legajo
 SET
 NOT NULL,
 ALTER COLUMN
 nombre
 SET
 NOT NULL,
 ALTER COLUMN
 sueldo
 SET
 NOT NULL,
 ALTER COLUMN
 edad
 SET
 NOT NULL;
 
 ALTER TABLE
 EMPLEADO_TT
 add
 primary key (legajo, tt_izq);
 */
-- valida los extremos
CREATE
OR REPLACE FUNCTION valid_timestamp() RETURNS trigger AS $ valid_timestamp $ BEGIN IF (new.tt_der <= new.tt_izq) THEN RAISE EXCEPTION 'El extremo derecho debe ser mas grande que el izquierdo';

END IF;

RETURN NEW;

END;

$ valid_timestamp $ LANGUAGE plpgsql;

CREATE TRIGGER valid_timestamp BEFORE
INSERT
	OR
UPDATE
	ON EMPLEADO_TT FOR EACH ROW EXECUTE PROCEDURE valid_timestamp();

-- executa una accion dependiendo del tipo de comando
CREATE
OR REPLACE FUNCTION call_action() RETURNS trigger AS $ $ BEGIN IF (TG_OP = 'DELETE') THEN
UPDATE
	EMPLEADO_TT
SET
	tt_der = CURRENT_TIMESTAMP
WHERE
	tt_der = 'infinity' :: timestamp
	AND legajo = old.legajo;

ELSIF (TG_OP = 'UPDATE') THEN
UPDATE
	EMPLEADO_TT
SET
	tt_der = CURRENT_TIMESTAMP
WHERE
	tt_der = 'infinity' :: timestamp
	AND legajo = new.legajo;

INSERT INTO
	EMPLEADO_TT
VALUES
	(
		new.legajo,
		(
			SELECT
				nombre
			FROM
				EMPLEADO
			WHERE
				LEGAJO = new.legajo
		),
		(
			SELECT
				sueldo
			FROM
				EMPLEADO
			WHERE
				LEGAJO = new.legajo
		),
		(
			SELECT
				edad
			FROM
				EMPLEADO
			WHERE
				LEGAJO = new.legajo
		),
		CURRENT_TIMESTAMP,
		'infinity' :: timestamp
	);

ELSE
INSERT INTO
	EMPLEADO_TT
VALUES
	(
		new.legajo,
		new.nombre,
		new.sueldo,
		new.edad,
		CURRENT_TIMESTAMP,
		'infinity' :: timestamp
	);

END IF;

RETURN NEW;

END;

$ $ LANGUAGE plpgsql;

DROP TRIGGER call_action ON EMPLEADO;

CREATE TRIGGER call_action
AFTER
INSERT
	OR
UPDATE
	OR DELETE ON EMPLEADO FOR EACH ROW EXECUTE PROCEDURE call_action();

-- testeos
INSERT INTO
	EMPLEADO
VALUES
	(18000, 'Hola theo', 16, 21);

SELECT
	*
FROM
	EMPLEADO_TT
WHERE
	legajo = 18000;

UPDATE
	EMPLEADO
SET
	sueldo = 20
WHERE
	legajo = 18000;

delete from
	EMPLEADO
WHERE
	legajo = 18000 -- Historial empleados (timestamp) y retorna todos los empleados dsp d ese timestamp
	CREATE
	OR REPLACE FUNCTION historial_empleado(datetime IN EMPLEADO_TT.tt_izq % type) RETURNS VARCHAR AS $ $ DECLARE ret text;

nombre_empleado EMPLEADO_TT.tt_izq % type;

-- Declara una variable del tipo de la columna
BEGIN ret := '----------HISTORIAL DE EMPLEADOS -------------------
            ESTADO--------------LEGAJO---SUELDO---EDAD---NRO MOV
            ----------------------------------------------------';

FOR nombre_empleado IN
SELECT
	nombre
FROM
	EMPLEADO_TT LOOP ret := ret || E '\n' || '                          ' || nombre_empleado;

END LOOP;

RETURN ret;

END;

$ $ LANGUAGE plpgsql;

DO $ $ DECLARE resultado text;

BEGIN resultado := historial_empleado(CURRENT_TIMESTAMP :: timestamp without time zone);

RAISE NOTICE '%',
resultado;

END;

$ $ LANGUAGE plpgsql;

/*
 select
 *
 from
 EMPLEADO
 select
 *
 from
 EMPLEADO_TT
 */