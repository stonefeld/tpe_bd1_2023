-- Creado de la tabla empleado
CREATE TABLE EMPLEADO(
	legajo int,
	nombre varchar(100),
	edad int,
	sueldo int,
	primary key (legajo)
);

-- Importación del archivo .csv
COPY EMPLEADO
FROM
	'C:\empleados.csv' WITH CSV HEADER DELIMITER ',';

	-- Para Linux
	-- '/empleados.csv' WITH CSV HEADER DELIMITER ',';

-- Creado de la tabla empleado_tt en base a la tabla empleado
CREATE TABLE EMPLEADO_TT AS
SELECT
	*
FROM
	EMPLEADO;

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

-- Validación de los extremos timestamp
CREATE
OR REPLACE FUNCTION valid_timestamp() RETURNS trigger AS $ valid_timestamp $ BEGIN IF (new.tt_der <= new.tt_izq) THEN RAISE EXCEPTION 'El extremo derecho debe ser mas grande que el izquierdo';

END IF;

RETURN NEW;

END;

$ valid_timestamp $ LANGUAGE plpgsql;

-- Creado del trigger para validar extremos timestamp
CREATE TRIGGER valid_timestamp BEFORE
INSERT
	OR
UPDATE
	ON EMPLEADO_TT FOR EACH ROW EXECUTE PROCEDURE valid_timestamp();

-- Función para insertar o modificar tuplas en empleado_tt
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
				edad
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

-- Creado de trigger para insertar o modificar la tabla empleado_tt
CREATE TRIGGER call_action
AFTER
INSERT
	OR
UPDATE
	OR DELETE ON EMPLEADO FOR EACH ROW EXECUTE PROCEDURE call_action();

-- Función para crear el historial de empleados a partir de la tabla empleado_tt
CREATE
OR REPLACE FUNCTION historial_empleado(datetime IN timestamp without time zone) RETURNS VARCHAR AS $ $ DECLARE ret text;

var_aux record;

BEGIN IF(
	EXTRACT(
		YEAR
		FROM
			datetime
	) <> EXTRACT(
		YEAR
		FROM
			CURRENT_TIMESTAMP
	)
) THEN RAISE EXCEPTION 'El año debe ser actual';

END IF;

ret := E '\n' || '-------------HISTORIAL DE EMPLEADOS -------------------
ESTADO---------------LEGAJO-----SUELDO---EDAD---NRO MOV
-------------------------------------------------------';

FOR var_aux IN
SELECT
	CASE
		WHEN tt_izq >= datetime
		and tt_der = 'infinity' :: timestamp THEN 'VIGENTE          '
		WHEN tt_izq < datetime
		and tt_der = 'infinity' :: timestamp THEN 'VIGENTE ANTERIOR '
		ELSE 'NO VIGENTE       '
	END estado,
	legajo,
	sueldo,
	edad,
	tt_izq,
	(
		SELECT
			COUNT(*)
		FROM
			EMPLEADO_TT as tt
		WHERE
			tt.tt_izq <= my_t.tt_izq
			and tt.legajo = my_t.legajo
	) as nro_mov
FROM
	EMPLEADO_TT as my_t
GROUP BY
	legajo,
	tt_izq
ORDER BY
	legajo LOOP ret := ret || E '\n' || var_aux.estado || '   ' || var_aux.legajo || '     ' || var_aux.sueldo || '     ' || var_aux.edad || '       ' || var_aux.nro_mov;

END LOOP;

RETURN ret;

END;

$ $ LANGUAGE plpgsql;

--Llamado a función historial empleado e impresión por salida estándar

DO $ $ DECLARE resultado text;

BEGIN resultado := historial_empleado('2023-11-01 00:00:00');

RAISE NOTICE '%',
resultado;

END;

$ $ LANGUAGE plpgsql;