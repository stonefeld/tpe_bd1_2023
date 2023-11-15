/*CREATE TABLE EMPLEADO(
	legajo int,
	nombre varchar(100),
	edad int,
	sueldo int,

	primary key (legajo)	
);


-- Los amigos de windows no nos dieron los permisos para abrir el archivo entonces lo pasamos a un pendrive
COPY EMPLEADO FROM 'E:\empleados.csv' WITH CSV HEADER DELIMITER ',';

CREATE TABLE EMPLEADO_TT AS SELECT * FROM EMPLEADO


ALTER TABLE EMPLEADO_TT
	ADD COLUMN tt_izq timestamp,
	ADD COLUMN tt_der timestamp;
	
UPDATE EMPLEADO_TT SET tt_izq = CURRENT_TIMESTAMP, tt_der = 'infinity'::timestamp;

ALTER TABLE EMPLEADO_TT
ALTER COLUMN tt_izq SET NOT NULL,
ALTER COLUMN tt_der SET NOT NULL,
ALTER COLUMN legajo SET NOT NULL,
ALTER COLUMN nombre SET NOT NULL,
ALTER COLUMN sueldo SET NOT NULL,
ALTER COLUMN edad SET NOT NULL;

ALTER TABLE EMPLEADO
ALTER COLUMN legajo SET NOT NULL,
ALTER COLUMN nombre SET NOT NULL,
ALTER COLUMN sueldo SET NOT NULL,
ALTER COLUMN edad SET NOT NULL;

*/


--select * from EMPLEADO

--select * from EMPLEADO_TT

