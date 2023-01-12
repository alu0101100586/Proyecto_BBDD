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
\c postgres
DROP DATABASE parking_db;
CREATE DATABASE parking_db WITH TEMPLATE = template0 ENCODING = 'UTF8';
ALTER DATABASE parking_db OWNER TO adminpark;

--
-- Realizamos la conexión a la base de datos
-- 
-- \connect parking_db user adminpark identified BY parksswd;
\connect parking_db
SET default_tablespace = '';

SET default_table_access_method = heap;

--------------------------------------------
-------- TABLAS DE LA BASE DE DATOS --------
--------------------------------------------

GRANT ALL PRIVILEGES ON DATABASE parking_db TO adminpark;

-- Tabla Car_park
CREATE TABLE public.car_park (
  id_car_park SERIAL NOT NULL,
  park_name varchar(50),
  location varchar(50),
  total_spaces integer NOT NULL,
  hour_operation integer NOT NULL,
  fees float NOT NULL,

  PRIMARY KEY(id_car_park)
);

-- Tabla employee y sus tipos manager, cashier y security
CREATE TABLE public.employee (
  id_employee SERIAL NOT NULL,
  id_car_park integer,
  first_name varchar(50),
  last_name varchar(50),
  role_name varchar(50),

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

-- Tabla parking_space y los tipos de plazas
CREATE TABLE public.parking_space (
  id_parking_space SERIAL NOT NULL,
  id_car_park integer NOT NULL,
  name varchar(2),
  availability boolean,
  space_length integer NOT NULL,
  space_width integer NOT NULL,
  accesibility varchar(50),

  PRIMARY KEY(id_parking_space),
  CONSTRAINT fk_id_car_park
  FOREIGN KEY(id_car_park)
  REFERENCES car_park(id_car_park)
  ON DELETE CASCADE
);

CREATE TABLE public.ordinary (
  id_parking_space integer NOT NULL,
  parking_type varchar(50),

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
  id_customer varchar(9),
  id_car_park integer,
  first_name varchar(50),
  last_name varchar(50),
  email varchar(50),
  phone_number integer,
  membership_status varchar(50),

  PRIMARY KEY(id_customer),
  CONSTRAINT fk_id_car_park
  FOREIGN KEY(id_car_park)
  REFERENCES car_park(id_car_park)
  ON DELETE CASCADE
);

-- Tabla car
CREATE TABLE public.car (
  id_car SERIAL NOT NULL,
  id_customer varchar(9),
  plate varchar(10) NOT NULL,
  brand varchar(50),
  model varchar(50),

  PRIMARY KEY(id_car),
  CONSTRAINT fk_id_customer
  FOREIGN KEY(id_customer)
  REFERENCES customer(id_customer)
  ON DELETE CASCADE
);

-- Tablas reservation
CREATE TABLE public.reservation (
  id_reservation SERIAL NOT NULL,
  id_customer varchar(9),
  start_time timestamp,
  end_time timestamp,

  PRIMARY KEY(id_reservation),
  CONSTRAINT fk_id_customer
  FOREIGN KEY(id_customer)
  REFERENCES customer(id_customer)
  ON DELETE CASCADE
);

-- Tabla Relacion triple (Car - Parking_Space - Reservation)
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
  ON DELETE CASCADE
);

-- Tabla complaint
CREATE TABLE public.complaint (
  id_complaint SERIAL NOT NULL,
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
  id_discount SERIAL NOT NULL,
  id_reservation integer,
  name varchar(50),
  percentage integer,

  PRIMARY KEY(id_discount),
  CONSTRAINT fk_id_reservation
  FOREIGN KEY(id_reservation)
  REFERENCES reservation(id_reservation)
  ON DELETE CASCADE
);

-- Tablas payment y sus tipos
CREATE TABLE public.payment (
  id_reservation integer NOT NULL,
  type varchar(50),
  amount float,

  PRIMARY KEY(id_reservation),
  CONSTRAINT fk_id_reservation
  FOREIGN KEY(id_reservation)
  REFERENCES reservation(id_reservation)
  ON DELETE CASCADE
);

CREATE TABLE public.cash (
  id_payment integer NOT NULL,
  currency varchar(50),
  
  PRIMARY KEY(id_payment),
  CONSTRAINT fk_id_payment
  FOREIGN KEY(id_payment)
  REFERENCES payment(id_reservation)
  ON DELETE CASCADE
);

CREATE TABLE public.credit_card (
  id_payment integer NOT NULL,
  holder varchar(50),
  account_number integer,
  
  PRIMARY KEY(id_payment),
  CONSTRAINT fk_id_payment
  FOREIGN KEY(id_payment)
  REFERENCES payment(id_reservation)
  ON DELETE CASCADE
);

CREATE TABLE public.debit_card (
  id_payment integer NOT NULL,
  account_number integer,
  expiration_date date,
  
  PRIMARY KEY(id_payment),
  CONSTRAINT fk_id_payment
  FOREIGN KEY(id_payment)
  REFERENCES payment(id_reservation)
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

ALTER TABLE payment
ADD CONSTRAINT Check_payment_type
CHECK (type IN ('cash', 'credit card', 'debit card'));

ALTER TABLE car
ADD CONSTRAINT Check_car_plate
UNIQUE (plate);

ALTER TABLE car_park
ADD CONSTRAINT Check_park_name
UNIQUE (park_name);

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
ADD CONSTRAINT Check_accesibility_park
CHECK (accesibility IN ('ordinary', 'disabled'));

ALTER TABLE ordinary
ADD CONSTRAINT Check_type_park
CHECK (parking_type IN ('touring car', 'boxcar'));

ALTER TABLE customer
ADD CONSTRAINT Check_customer_membership
CHECK (membership_status IN ('none', 'vip'));

ALTER TABLE discount
ADD CONSTRAINT check_discount_percentage
CHECK (percentage < 90);

--
-- Creación de Disparadores
--
-- Comprobar al ingresar una tarjeda de debito si no ha expirado
CREATE OR REPLACE FUNCTION check_expiration_date()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.expiration_date < NOW() THEN
     RAISE EXCEPTION 'The debit card has been expired';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_debit_expiration_date
BEFORE INSERT OR UPDATE ON debit_card
FOR EACH ROW
EXECUTE FUNCTION check_expiration_date();

-- Comprobar que al insertar una reserva el tiempo de inicio no sea menor que el de salida
CREATE OR REPLACE FUNCTION check_reservation_start_end_time()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.end_time IS NOT NULL THEN
    IF NEW.start_time >= NEW.end_time THEN
      RAISE EXCEPTION 'start_time must be less than end_time.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_reservation_time
BEFORE INSERT ON reservation
EXECUTE FUNCTION check_reservation_start_end_time();


-- Comprobar que antes de ingresar una tarjeta de debito o de credito que el numero de cuenta no exista ya en la base de datos
CREATE OR REPLACE FUNCTION check_unique_account_number()
RETURNS TRIGGER AS $$
DECLARE
  duplicate INT;
BEGIN
  SELECT 1 INTO duplicate
  FROM credit_card
  WHERE account_number = NEW.account_number
  AND id_payment != NEW.id_payment
  UNION
  SELECT 1 FROM debit_card
  WHERE account_number = NEW.account_number
  AND id_payment != NEW.id_payment;
  IF duplicate = 1 THEN
    RAISE EXCEPTION 'account_number must be unique.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_unique_credit_account_number
BEFORE INSERT OR UPDATE ON credit_card
FOR EACH ROW
EXECUTE FUNCTION check_unique_account_number();

CREATE TRIGGER check_unique_debit_account_number
BEFORE INSERT OR UPDATE ON debit_card
FOR EACH ROW
EXECUTE FUNCTION check_unique_account_number();

-- Diaparador que cada vez que se ingrese una fila de reservation, ponga como inicio la fecha y hora actual
CREATE OR REPLACE FUNCTION update_start_time_to_current() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.start_time IS NULL THEN
    NEW.start_time = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_reservation_start_time
BEFORE INSERT ON public.reservation
EXECUTE FUNCTION update_start_time_to_current();

-- Disparador actualiza el campo avaibility de la tabla payment cuando se ingresa una nueva entreda en la tabla have
CREATE OR REPLACE FUNCTION update_parking_availability() RETURNS TRIGGER AS $$
BEGIN
  UPDATE parking_space 
  SET availability = 'false' 
  WHERE id_parking_space = NEW.id_parking_space;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_parking_avaibility_from_have
AFTER INSERT ON public.have
FOR EACH ROW
EXECUTE FUNCTION update_parking_availability();

--
-- Insercion tabla car_park
--
INSERT INTO public.car_park (id_car_park, park_name, location, total_spaces, hour_operation, fees)
VALUES (1, 'Parking La Laguna', 'La Laguna', 40, 12, 0.99),
       (2, 'Parking Santa Cruz', 'Santa Cruz de Tenerife', 35, 24, 1.50),
       (3, 'Parking Concepcion', 'La Laguna', 26, 20, 1.05),
       (4, 'Parking Los Realejos', 'Los Realejos', 50, 12, 1.69);

--
-- Insercion tabla employee
--
INSERT INTO public.employee (id_employee, id_car_park, first_name, last_name, role_name)
VALUES (1, 1, 'Manuel', 'Hernandez Díaz', 'Manager'),
       (2, 1, 'Antonio', 'Guijarro Rodríguez', 'Cashier'),
       (3, 1, 'Juliana', 'Pérez Laya', 'Security'),
       (4, 2, 'Bruno', 'Estévez Estévez', 'Manager'),
       (5, 2, 'María', 'Hernández Bello', 'Cashier'),
       (6, 3, 'Nadia', 'Esquivel Cruz', 'Cashier'),
       (7, 3, 'Lazaro', 'Martin Esquivel', 'Security'),
       (8, 4, 'Manolo', 'Díaz Díaz', 'Manager'),
       (9, 4, 'Cristian', 'Redondo Rojas', 'Cashier');

--
-- Insercion tabla manager
--
INSERT INTO public.manager (id_employee, n_parking_owned)
VALUES (1, 2),
       (4, 1),
       (8, 1);

--
-- Insercion tabla cashier
--
INSERT INTO public.cashier (id_employee, n_asigned_machines)
VALUES (2, 1),
       (5, 1),
       (6, 1),
       (9, 1);

--
-- Insercion tabla security
--
INSERT INTO public.security (id_employee, certificate)
VALUES (3, 'Certificado en Seguridad Privada'),
       (7, 'Certificado de Segurita de Prosegur');

--
-- Insercion tabla parking_space
--
INSERT INTO public.parking_space (id_car_park, name, availability, space_length, space_width, accesibility)
VALUES (1, 'A1', true, 5, 3, 'ordinary'),
       (1, 'A2', false, 5, 3, 'ordinary'),
       (1, 'A3', false, 5, 3, 'ordinary'),
       (1, 'A1', true , 5, 3, 'ordinary'),
       (1, 'A2', false , 7, 5, 'disabled'),
       (1, 'A3', true , 7, 5, 'disabled'),
       (2, 'C4', false , 6, 3, 'ordinary'),
       (2, 'C5', false , 6, 3, 'ordinary'),
       (2, 'C6', true , 6, 3, 'ordinary'),
       (2, 'C7', false , 6, 3, 'ordinary'),
       (2, 'C8', true , 6, 3, 'ordinary'),
       (2, 'C9', true , 6, 3, 'ordinary'),
       (3, 'AA', true , 7, 4, 'ordinary'),
       (3, 'AB', false , 7, 4, 'ordinary'),
       (3, 'AC', false , 7, 4, 'ordinary'),
       (3, 'AD', false , 7, 4, 'ordinary'),
       (3, 'AE', true , 7, 4, 'disabled'),
       (3, 'AF', true , 7, 4, 'ordinary'),
       (4, 'B1', false , 7, 4, 'ordinary'),
       (4, 'B2', true , 7, 4, 'ordinary'),
       (4, 'B3', true , 7, 4, 'ordinary'),
       (4, 'B4', false , 7, 5, 'disabled'),
       (4, 'B5', false , 7, 5, 'disabled'),
       (4, 'B6', true , 7, 5, 'disabled');

-- Insert tabla ordinary
--
INSERT INTO public.ordinary (id_parking_space, parking_type)
VALUES (1, 'touring car'),
       (2, 'touring car'),
       (3, 'boxcar'),
       (4, 'boxcar'),
       (7, 'boxcar'),
       (8, 'touring car'),
       (9, 'touring car'),
       (10, 'boxcar'),
       (11, 'touring car'),
       (12, 'boxcar'),
       (13, 'touring car'),
       (14, 'touring car'),
       (15, 'boxcar'),
       (16, 'boxcar'),
       (18, 'boxcar'),
       (19, 'touring car'),
       (20, 'boxcar'),
       (21, 'touring car');

--
-- Insert tabla disabled
--
INSERT INTO public.disabled (id_parking_space, condition, validation_date)
VALUES (5, 'disabled', '2023-01-12'),
       (6, 'pregnant', '2022-11-23'),
       (17, 'disabled', '2022-10-20'),
       (22, 'pregnant', '2021-09-23'),
       (23, 'disabled', '2021-09-22'),
       (24, 'disabled', '2021-09-24');

--
-- Insercion tabla customer
--
INSERT INTO public.customer (id_customer, id_car_park, first_name, last_name, email, phone_number, membership_status)
VALUES ('00000001A',  1, 'Pablo',   'Gómez Gómez',         'pabgomez@email.com',   '665786534',  'vip'),
       ('00000002B',  1, 'Maria',   'Perez Gutierrez',     'marperez@email.com',   '647653894',  'none'),
       ('00000003C',  1, 'Marcos',  'Reyes Contreras',     'marcreyes@email.com',  '678906565',  'vip'),
       ('00000004D',  2, 'Violeta', 'Rodriguez Hernández', 'viorguez@email.com',   '637452893',  'vip'),
       ('00000005E',  2, 'Amanda',  'Garcia González',     'amandagar@email.com',  '665545780',  'none'),
       ('00000006F',  2, 'Jonay',   'Estévez Díaz',        'jonayest@gmail.com',   '678456345',  'vip'),
       ('00000007G',  3, 'Álvaro',  'Rodríguez Gómez',     'alvaroguez@gmail.com', '723567765',   'vip'),
       ('00000008H',  3, 'Paula',   'Regalado de León',    'paularegal@gmail.com', '668554338',  'vip'),
       ('00000009I',  3, 'Maria',   'Díaz Díaz',           'mauxidiaz@gmail.com',  '654546654',  'none'),
       ('00000010J', 4, 'Pedro',   'García Martin',       'pedrogar@gmail.com',   '788543342',  'none'),
       ('00000011L', 4, 'Juan',    'Laya, Hernández',     'juanlaya@gmail.com',   '778112345',  'none'),
       ('00000012M', 4, 'Cristo',  'Socas Gutierrez',     'crissocas@gmail.com',  '657345678',  'none');

--
-- Insercion tabla car
--
INSERT INTO public.car (id_customer, plate, brand, model)
VALUES ('00000001A',  '0331BCD', 'Seat',     'Panda'),
       ('00000002B',  '0768DFG', 'Opel',     'Astra'),
       ('00000003C',  '0030HTH', 'Opel',     'Corsa'),
       ('00000004D',  '0404LMN', 'Ford',     'Focus'),
       ('00000005E',  '1205CHJ', 'Ford',     'Fiesta'),
       ('00000006F',  '9843FYR', 'Porshe',   'Panamera'),
       ('00000007G',  '5619DRT', 'Seat',     'Ibiza'),
       ('00000008H',  '4897DQR', 'Dacia',    'Dokker'),
       ('00000009I',  '7865JJL', 'Citroen',  'Van'),
       ('00000010J', '7653HTL', 'Fiat',     'Ducato'),
       ('00000011L', '3827GYR', 'Ford',     'Transit'),
       ('00000012M', '7878DDV', 'Mercedes', 'Marco Polo');

--
--Insercion tabla reservation
--
INSERT INTO public.reservation (id_customer, start_time, end_time)
VALUES ('00000001A', '2022-12-31 10:20:00', '2022-12-31 15:28:49'),
       ('00000002B', '2022-12-30 19:10:00', '2022-12-30 21:45:50'),
       ('00000003C', '2023-01-01 18:30:00', '2023-01-02 20:30:00'),
       ('00000004D', '2023-01-02 09:00:00', '2023-01-02 09:30:00'),
       ('00000001A', '2023-01-03 11:15:00', '2023-01-02 14:15:00'),
       ('00000006F', '2023-01-04 15:30:00', '2023-01-02 16:00:00'),
       ('00000007G', '2023-01-05 20:00:00', '2023-01-02 23:59:00'),
       ('00000008H', '2023-01-06 17:45:00', NULL),
       ('00000003C', '2023-01-07 13:00:00', NULL),
       ('00000009I', '2023-01-08 08:10:00', NULL),
       ('00000010J', '2023-01-09 10:05:00', NULL),
       ('00000005E', '2023-01-10 07:35:00', NULL),
       ('00000011L', '2023-01-10 12:20:00', NULL),
       ('00000012M', '2023-01-10 06:55:00', NULL);
--
-- Inserción tabla have
--
INSERT INTO public.have (id_reservation, id_car, id_parking_space)
VALUES (1, 1, 2),
       (2, 2, 13),
       (3, 3, 5),
       (4, 4, 20),
       (5, 1, 14),
       (6, 6, 8),
       (7, 7, 13),
       (8, 8 , 2),
       (9, 3, 3),
       (10, 9, 10),
       (11, 10, 15),
       (12, 5, 16),
       (13, 11, 19),
       (14, 12, 23);

--
-- Insercion tabla complaint
--
INSERT INTO public.complaint (id_complaint, id_reservation, description, resolution)
VALUES (1, 3, 'Me otorgaron una plaza para minusválidos por error', 'Al cliente se le asignó una nueva plaza'),
       (2, 5, 'El segurita rayó mi coche', 'Se pagó al cliente por los daños causados y se le pidieron explicaciones al segurita'),
       (3, 6, 'El aparcamiento asignado a mi reserva estaba muy sucio', 'Se realió una limpieza entera del parking');

--
-- Insercion tabla Discount
--
INSERT INTO public.discount (id_discount, id_reservation, name, percentage)
VALUES (1, 6, 'Descuento del 25%', 25),
       (2, 10, 'Descuento del 50%', 50),
       (3, 12, 'Descuento del 75%', 75),
       (4, 13, 'Descuento VIP', 80);

--
-- Inserción tabla payment
--
INSERT INTO public.payment (id_reservation, type, amount)
VALUES (1, 'cash', 4.1),
       (2, 'cash', 2.36),
       (3, 'credit card', 1.22),
       (4, 'credit card',  2.58),
       (5, 'debit card',  7.19),
       (6, 'cash', 1.13),
       (7, 'debit card', 3.28),
       (8, 'debit card', 6.68),
       (9, 'cash', 8.37),
       (10, 'credit card', 8.61),
       (11, 'debit card', 8.32),
       (12, 'cash', 5.33),
       (13, 'credit card', 9.24),
       (14, 'debit card', 5.79);
--
-- Inserción Tabla cash
--
INSERT INTO public.cash (id_payment, currency)
VALUES (1, 'euro'),
       (2,'euro'),
       (6, 'euro'),
       (9, 'euro'),
       (12, 'euro');
--
-- Inserción Tabla credit_card
--
INSERT INTO public.credit_card (id_payment, holder, account_number)
VALUES (3, 'Marcos Reyes Contreras', 10001),
       (4, 'Violeta Rodriguez Hernández', 10002),
       (10, 'Maria Díaz Díaz', 10003),
       (13, 'Juan Laya, Hernández', 10004);

--
-- Inserción Tabla debit_card
--
INSERT INTO public.debit_card (id_payment, account_number, expiration_date)
VALUES (5, 10005, '2024-05-29'),
       (7, 10006, '2023-09-10'),
       (8, 10007, '2025-03-30'),
       (11, 10008, '2024-08-14'),
       (14, 10009, '2023-12-18');