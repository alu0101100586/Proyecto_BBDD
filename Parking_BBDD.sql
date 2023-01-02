-- Administración y Diseño de Bases de Datos
--
-- Proyecto de Parking
--
-- Realizado por:
-- Paula Regalado de León      (alu0101330174)
-- Álvaro Rodríguez Gómez      (alu0101362953)
-- Jonay Estévez Díaz          (alu0101100586)
-- 

DROP DATABASE IF EXISTS parking_db;

CREATE DATABASE parking_db WITH TEMPLATE = template0 ENCODING = 'UTF8';

ALTER DATABASE parking_db OWNER TO postgres;

\connect parking_db
