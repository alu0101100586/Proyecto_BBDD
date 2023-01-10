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

SET default_tablespace = '';

SET default_table_access_method = heap;

--------------------------------------------
-------- TABLAS DE LA BASE DE DATOS --------
--------------------------------------------

-- ALTER TABLE public.security OWNER TO postgres;

-- Tablas car_park

CREATE TABLE public.car_park (
  id_car_park integer NOT NULL,
  park_name varchar(20),
  location varchar(20),
  total_spaces integer NOT NULL,
  hour_operation integer NOT NULL,
  fees float NOT NULL,

  PRIMARY KEY(id_car_park)
);

-- Tabla employee y sus tipos manager, cashier y security

CREATE TABLE public.employee (
  id_employee integer NOT NULL,
  id_car_park integer,
  first_name varchar(20),
  last_name varchar(20),
  role_name varchar(20),

  PRIMARY KEY(id_employee),
  CONSTRAINT fk_id_car_park
  FOREIGN KEY(id_car_park)
  REFERENCES car_park(id_car_park)
  ON DELETE CASCADE
);

CREATE TABLE public.manager (
  id_employee integer NOT NULL,
  n_parking_owned integer,

  PRIMARY KEY(id_employee),
  CONSTRAINT fk_id_employee
  FOREIGN KEY(id_employee)
  REFERENCES employee(id_employee)
  ON DELETE CASCADE
);

CREATE TABLE public.cashier (
  id_employee integer NOT NULL,
  n_asigned_machines integer,

  PRIMARY KEY(id_employee),
  CONSTRAINT fk_id_employee
  FOREIGN KEY(id_employee)
  REFERENCES employee(id_employee)
  ON DELETE CASCADE
);

CREATE TABLE public.security (
  id_employee integer NOT NULL,
  certificate varchar(50),

  PRIMARY KEY(id_employee),
  CONSTRAINT fk_id_employee
  FOREIGN KEY(id_employee)
  REFERENCES employee(id_employee)
  ON DELETE CASCADE
);

-- Tabla parking_space y los tipos de 

CREATE TABLE public.parking_space (
  id_parking_space integer NOT NULL,
  id_car_park integer NOT NULL,
  availability BIT, -- como bool
  space_length integer NOT NULL,
  space_width integer NOT NULL,
  accesibility varchar(20),

  PRIMARY KEY(id_parking_space),
  CONSTRAINT fk_id_car_park
  FOREIGN KEY(id_car_park)
  REFERENCES car_park(id_car_park)
  ON DELETE CASCADE
);

CREATE TABLE public.ordinary (
  id_parking_space integer NOT NULL,
  type varchar(20),

  PRIMARY KEY(id_parking_space),
  CONSTRAINT fk_id_parking_space
  FOREIGN KEY(id_parking_space)
  REFERENCES parking_space(id_parking_space)
  ON DELETE CASCADE
);

CREATE TABLE public.disabled (
  id_parking_space integer NOT NULL,
  condition varchar(50),
  validation_date date,

  PRIMARY KEY(id_parking_space),
  CONSTRAINT fk_id_parking_space
  FOREIGN KEY(id_parking_space)
  REFERENCES parking_space(id_parking_space)
  ON DELETE CASCADE
);


-- Tabla customer

CREATE TABLE public.customer (
  id_customer integer NOT NULL,
  id_car_park integer,
  first_name varchar(20),
  last_name varchar(20),
  email varchar(30),
  phone_number integer,
  membership_status varchar(30),

  PRIMARY KEY(id_customer),
  CONSTRAINT fk_id_car_park
  FOREIGN KEY(id_car_park)
  REFERENCES car_park(id_car_park)
  ON DELETE CASCADE
);


-- Tabla car

CREATE TABLE public.car (
  id_car integer NOT NULL,
  id_customer integer,
  brand varchar(20),
  model varchar(20),

  PRIMARY KEY(id_car),
  CONSTRAINT fk_id_customer
  FOREIGN KEY(id_customer)
  REFERENCES customer(id_customer)
  ON DELETE CASCADE
);

-- Tablas reservation

CREATE TABLE public.reservation (
  id_reservation integer NOT NULL,
  id_customer integer,
  start_time timestamp,
  end_time timestamp,

  PRIMARY KEY(id_reservation),
  CONSTRAINT fk_id_customer
  FOREIGN KEY(id_customer)
  REFERENCES customer(id_customer)
  ON DELETE CASCADE,
);

-- Tabla Relacion triple

CREATE TABLE public.have (
  id_reservation integer NOT NULL,
  id_car integer NOT NULL,
  id_parking_space integer NOT NULL,

  PRIMARY KEY (id_reservation, id_car, id_parking_space),
  CONSTRAINT fk_id_reservation
  FOREIGN KEY (id_reservation)
  REFERENCES reservation(id_reservation)
  ON DELETE CASCADE,

  CONSTRAINT fk_id_car
  FOREIGN KEY (id_car)
  REFERENCES car(id_car)
  ON DELETE CASCADE,
	
  CONSTRAINT fk_id_parking_space
  FOREIGN KEY (id_parking_space)
  REFERENCES parking_space(id_parking_space)
  ON DELETE CASCADE,
);

-- Tabla complaint

CREATE TABLE public.complaint (
  id_complaint integer NOT NULL,
  id_reservation integer NOT NULL,
  description varchar(100),
  resolution varchar(100),
  
  PRIMARY KEY(id_complaint),
  CONSTRAINT fk_id_reservation
  FOREIGN KEY(id_reservation)
  REFERENCES reservation(id_reservation)
  ON DELETE CASCADE
);

-- Tablas discount

CREATE TABLE public.discount (
  id_discount integer NOT NULL,
  id_reservation interger,
  name varchar(20),
  eligibility_criteria varchar(20),
  amount integer,

  PRIMARY KEY(id_discount),
  CONSTRAINT fk_id_reservation
  FOREIGN KEY(id_reservation)
  REFERENCES reservation(id_reservation)
  ON DELETE CASCADE
);

--CREATE TABLE public.applied_discounts (
--  id_discount integer NOT NULL,
--  id_reservation integer NOT NULL,
--
--  PRIMARY KEY(id_discount, id_reservation),
--  CONSTRAINT fk_id_discount
--		FOREIGN KEY(id_discount)
--			REFERENCES discount(id_discount)
--				ON DELETE CASCADE,
--  CONSTRAINT fk_id_reservation
--		FOREIGN KEY(id_reservation)
--			REFERENCES reservation(id_reservation)
--				ON DELETE CASCADE
--);

-- Tablas payment

CREATE TABLE public.payment (
  id_payment integer NOT NULL,
  id_reservation integer,
  type varchar(20),
  amount integer,

  PRIMARY KEY(id_payment)
);


CREATE TABLE public.cash (
  id_payment integer NOT NULL,
  currency varchar(20),
  
  PRIMARY KEY(id_payment),
  CONSTRAINT fk_id_payment
  FOREIGN KEY(id_payment)
  REFERENCES payment(id_payment)
  ON DELETE CASCADE
);

CREATE TABLE public.credit_card (
  id_payment integer NOT NULL,
  holder varchar(20),
  account_number integer,
  
  PRIMARY KEY(id_payment),
  CONSTRAINT fk_id_payment
  FOREIGN KEY(id_payment)
  REFERENCES payment(id_payment)
  ON DELETE CASCADE
);

CREATE TABLE public.debit_card (
  id_payment integer NOT NULL,
  account_number integer,
  expiration_date date,
  
  PRIMARY KEY(id_payment),
  CONSTRAINT fk_id_payment
  FOREIGN KEY(id_payment)
  REFERENCES payment(id_payment)
  ON DELETE CASCADE
);

--
-- Creacion de los Checks
--
ALTER TABLE customer
ADD CONSTRAINT Check_phone_number
UNIQUE (phone_number);

ALTER TABLE payment
ADD CONSTRAINT Check_amount_price
CHECK (amount > 0);

ALTER TABLE car_park
ADD CONSTRAINT Check_park_name
UNIQUE (park_name);

ALTER TABLE car_park
ADD CONSTRAINT Check_localization_car_park
UNIQUE (localization);

ALTER TABLE car_park
ADD CONSTRAINT Check_total_spaces
CHECK (total_spaces >= 10);

ALTER TABLE car_park
ADD CONSTRAINT Check_hour_operation
CHECK (hour_operation >= 8);

ALTER TABLE manager
ADD CONSTRAINT Check_manager_parking
CHECK (n_parking_owned >= 1);

ALTER TABLE cashier
ADD CONSTRAINT Check_cashier_machines
CHECK (n_asigned_machines >= 1);

ALTER TABLE parking_space
ADD CONSTRAINT Check_paking_space_type
CHECK (condition IN ("ordinary", "disabled"));

ALTER TABLE ordinary
ADD CONSTRAINT Check_type_park
CHECK (condition IN ("vehicle", "motorcycle"));

ALTER TABLE disabled
ADD CONSTRAINT Check_condition_park
CHECK (condition IN ("pregnant", "disabled"));

ALTER TABLE customer
ADD CONSTRAINT Check_customer_membership
CHECK (condition IN ("none", "prime"));

ALTER TABLE discount
ADD CONSTRAINT check_discount_amount
CHECK (amount < 100);

ALTER TABLE complaint
ADD CONSTRAINT check_description
CHECK description IS NOT NULL;

--
-- Insercion de datos
-- 


--
-- Creación de Funcion
--

--
-- Creación de Disparadores
--
-- Idea de disparadores
-- Comprobar al ingresar una tarjeda de debito si no ha expirado
-- Comprobar que al insertar una reserva el tiempo de inicio no sea menor que el de salida
-- Comprobar que antes de ingresar una tarjeta de debito o de credito que el numero de cuenta no exista ya en la base de datos
--
CREATE TRIGGER insert_new_row_debit_card
AFTER INSERT on public.debit_card
FOR EACH row
DECLARE
  exp_date date;
BEGIN
  --
END;
