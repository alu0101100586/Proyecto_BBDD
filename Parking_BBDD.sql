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
  schedule varchar(100),

  PRIMARY KEY(id_car_park)
);

-- Tablas payment

CREATE TABLE public.payment (
  id_payment integer NOT NULL,
  method varchar(20),
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
  entity_name varchar(20),
  expiration_date date,
  
  PRIMARY KEY(id_payment),
  CONSTRAINT fk_id_payment
		FOREIGN KEY(id_payment)
			REFERENCES payment(id_payment)
				ON DELETE CASCADE
);

CREATE TABLE public.employee (
  id_employee integer NOT NULL,
  first_name varchar(20),
  last_name varchar(20),
  role_name varchar(20),
  id_car_park integer,

  PRIMARY KEY(id_employee),
  CONSTRAINT fk_id_car_park
		FOREIGN KEY(id_car_park)
			REFERENCES car_park(id_car_park)
				ON DELETE CASCADE
);

CREATE TABLE public.manager (
  id_employee integer NOT NULL,
  opinion varchar(50),

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

-- Tabla parking_space

CREATE TABLE public.parking_space (
  id_parking_space integer NOT NULL,
  availability BIT, -- como bool
  space_length integer,
  space_width integer,
  accesibility varchar(20),
  --id_owner integer,
  id_car_park integer,

  PRIMARY KEY(id_parking_space),
  CONSTRAINT fk_id_car_park
		FOREIGN KEY(id_car_park)
			REFERENCES car_park(id_car_park)
				ON DELETE CASCADE
);

CREATE TABLE public.ordinary (
  id_parking_space integer NOT NULL,
  columns_near integer,

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

CREATE TABLE public.car (
  id_car integer NOT NULL,
  brand varchar(20),
  model varchar(20),
  -- id_owner integer,
  id_parking_space integer,

  PRIMARY KEY(id_car),
  CONSTRAINT fk_id_parking_space
		FOREIGN KEY(id_parking_space)
			REFERENCES parking_space(id_parking_space)
				ON DELETE CASCADE
);

-- Tabla customer

CREATE TABLE public.customer (
  id_customer integer NOT NULL,
  first_name varchar(20),
  last_name varchar(20),
  email varchar(30),
  phone_number integer,
  membership_status varchar(30),
  id_car integer,

  PRIMARY KEY(id_customer),
  CONSTRAINT fk_id_car
		FOREIGN KEY(id_car)
			REFERENCES car(id_car)
				ON DELETE CASCADE
);

-- Tablas reservation

CREATE TABLE public.reservation (
  id_reservation integer NOT NULL,
  start_time timestamp,
  end_time timestamp,
  id_payment integer,
  id_customer integer,
  id_parking_space integer,

  PRIMARY KEY(id_reservation),
  CONSTRAINT fk_id_payment
		FOREIGN KEY(id_payment)
			REFERENCES payment(id_payment)
				ON DELETE CASCADE,
  CONSTRAINT fk_id_customer
		FOREIGN KEY(id_customer)
			REFERENCES customer(id_customer)
				ON DELETE CASCADE,
  CONSTRAINT fk_id_parking_space
		FOREIGN KEY(id_parking_space)
			REFERENCES parking_space(id_parking_space)
				ON DELETE CASCADE
);

-- Tabla complaint

CREATE TABLE public.complaint (
  id_complaint integer NOT NULL,
  id_reservation integer,
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
  eligibility_criteria varchar(20),
  amount integer,

  PRIMARY KEY(id_discount)
);

CREATE TABLE public.applied_discounts (
  id_discount integer NOT NULL,
  id_reservation integer NOT NULL,

  PRIMARY KEY(id_discount, id_reservation),
  CONSTRAINT fk_id_discount
		FOREIGN KEY(id_discount)
			REFERENCES discount(id_discount)
				ON DELETE CASCADE,
  CONSTRAINT fk_id_reservation
		FOREIGN KEY(id_reservation)
			REFERENCES reservation(id_reservation)
				ON DELETE CASCADE
);



--
-- Creación de Disparadores
--

--
-- Insercion de datos en la tabla X
-- 
-- INSERT INTO public.X VALUES ();
--
-- Creacion de las Aserciones
--

--
-- Creacion de los Checks
--
