--
-- Consultas sobre la base de datos
--
-- 1) Matricula y nombre del cliente aparcado en plazas para embarazadas
SELECT car.plate AS Matricula, car.brand AS Marca, car.model AS Modelo, 
       customer.first_name as Nombre_Cliente, customer.last_name AS Apellido_Cliente
FROM car
JOIN customer ON car.id_customer = customer.id_customer
JOIN have ON car.id_car = have.id_car
JOIN parking_space ON have.id_parking_space = parking_space.id_parking_space
JOIN disabled ON parking_space.id_parking_space = disabled.id_parking_space
WHERE disabled.condition = 'disabled';


-- 2) Numero de plazas disponibles para cada Parking
SELECT car_park.park_name AS Nombre_Aparcamiento, 
       COUNT(parking_space.id_parking_space) as Plazas_disponibles_para_reserva
FROM car_park
INNER JOIN parking_space ON car_park.id_car_park = parking_space.id_car_park
WHERE parking_space.availability = 'true'
GROUP BY car_park.park_name;


-- 3) Todos los parking y para cada uno los trabajadores del mismo
SELECT car_park.park_name AS Nombre_Aparcamiento, employee.first_name AS Nombre_Empleado, 
       employee.last_name AS Apellido_Empleado, employee.role_name AS Ocupacion,
       manager.n_parking_owned AS Aparcamientos_en_Propiedad, 
       cashier.n_asigned_machines AS Maquinas_asignadas, 
       security.certificate AS Certificado_Seguridad
FROM car_park
LEFT JOIN employee ON car_park.id_car_park = employee.id_car_park
LEFT JOIN manager ON employee.id_employee = manager.id_employee
LEFT JOIN cashier ON employee.id_employee = cashier.id_employee
LEFT JOIN security ON employee.id_employee = security.id_employee;

-- 4) Todos los clientes que han reservado en enero del 2023 y el numero de reserva
SELECT customer.first_name AS Nombre_Cliente, customer.last_name AS Apellidos_Cliente, 
       reservation.id_reservation AS Numero_reserva
FROM customer
INNER JOIN reservation ON customer.id_customer = reservation.id_customer
WHERE EXTRACT(YEAR FROM reservation.start_time) = 2023 AND 
      EXTRACT(MONTH FROM reservation.start_time) = 1;


-- 5) Consultar el nombre, matricula, fecha de inicio, fecha de salida, 
--    nombre de la plaza y el nombre del parking
SELECT customer.first_name AS Nombre_cliente, customer.last_name AS Apellido_Cliente, 
       car.plate AS Matricula, reservation.start_time AS Fecha_inicio, 
       reservation.end_time AS Fecha_salida, parking_space.name AS Nombre_Plaza, 
       car_park.park_name AS Aparcamiento
FROM customer
INNER JOIN car ON customer.id_customer = car.id_customer
INNER JOIN have ON car.id_car = have.id_car
INNER JOIN reservation ON have.id_reservation = reservation.id_reservation
INNER JOIN parking_space ON have.id_parking_space = parking_space.id_parking_space
INNER JOIN car_park ON parking_space.id_car_park = car_park.id_car_park;


--F 6) Clientes a los que se les ha aplicado descuento y el porcentaje de descuento
SELECT customer.first_name AS Nombre_Cliente, customer.last_name AS Apellido_Cliente, 
       reservation.id_reservation AS Numero_reserva, discount.percentage AS Porcentaje_descuento
FROM customer
INNER JOIN reservation ON customer.id_customer = reservation.id_customer
INNER JOIN discount ON reservation.id_reservation = discount.id_reservation;

-- 7) Clientes que han reservado más de una vez y donde
SELECT customer.first_name AS Nombre_Cliente, customer.last_name AS Apellido_Cliente, 
       car_park.park_name AS Aparcamiento
FROM customer
INNER JOIN reservation ON customer.id_customer = reservation.id_customer
INNER JOIN have ON reservation.id_reservation = have.id_reservation
INNER JOIN parking_space ON have.id_parking_space = parking_space.id_parking_space
INNER JOIN car_park ON parking_space.id_car_park = car_park.id_car_park
GROUP BY customer.id_customer, car_park.id_car_park
HAVING COUNT(reservation.id_reservation) > 1;


-- 8) Parking que ha tenido más reservas
SELECT car_park.park_name AS Aparcamiento, car_park.fees AS Tarifa, 
       COUNT(reservation.id_reservation) as Numero_Total_Reservas
FROM car_park
LEFT JOIN parking_space ON car_park.id_car_park = parking_space.id_car_park
LEFT JOIN have ON parking_space.id_parking_space = have.id_parking_space
LEFT JOIN reservation ON have.id_reservation = reservation.id_reservation
GROUP BY car_park.id_car_park
ORDER BY COUNT(reservation.id_reservation) DESC
LIMIT 1;