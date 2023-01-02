-- Administración y Diseño de Bases de Datos
--
-- Proyecto de Parking
--
-- Realizado por:
-- Paula Regalado de León      (alu0101330174)
-- Álvaro Rodríguez Gómez      (alu0101362953)
-- Jonay Estévez Díaz          (alu0101100586)
-- 

--
-- Creación de la base de datos
--
DROP DATABASE IF EXISTS parking_db;
CREATE DATABASE parking_db WITH TEMPLATE = template0 ENCODING = 'UTF8';
ALTER DATABASE parking_db OWNER TO postgres;

--
-- Realizamos la conexión a la base de datos
-- 
\connect parking_db

--
-- Creación del schema publico
--
CREATE SCHEMA public;
AlTER SCHEMA public OWNER TO postgres;
COMMENT On SCHEMA public IS 'standard public schema';

--
-- Creacion de la tabla X
--

--
-- Creación de Disparadores
--

--
-- Insercion de datos en la tabla X
-- 

--
-- Creacion de las Aserciones
--

--
-- Creacion de los Checks
--
