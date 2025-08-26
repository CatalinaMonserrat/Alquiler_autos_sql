CREATE DATABASE rentacar
    DEFAULT CHARACTER SET = 'utf8mb4';

USE rentacar;

CREATE TABLE Clientes (
  id_cliente   INT PRIMARY KEY,
  nombre       VARCHAR(100) NOT NULL,
  telefono     VARCHAR(20),
  email        VARCHAR(100) UNIQUE,
  direccion    VARCHAR(150)
);

CREATE TABLE Vehiculos (
  id_vehiculo  INT PRIMARY KEY,
  marca        VARCHAR(50)  NOT NULL,
  modelo       VARCHAR(50)  NOT NULL,
  anio         INT,
  precio_dia   DECIMAL(10,2) NOT NULL
);

CREATE TABLE Alquileres (
  id_alquiler  INT PRIMARY KEY,
  id_cliente   INT NOT NULL,
  id_vehiculo  INT NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin    DATE NOT NULL,
  CONSTRAINT fk_alq_cliente  FOREIGN KEY (id_cliente)  REFERENCES Clientes(id_cliente),
  CONSTRAINT fk_alq_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES Vehiculos(id_vehiculo),
  CONSTRAINT chk_fechas CHECK (fecha_fin >= fecha_inicio)
);

CREATE TABLE Pagos (
  id_pago      INT PRIMARY KEY,
  id_alquiler  INT NOT NULL,
  monto        DECIMAL(10,2) NOT NULL,
  fecha_pago   DATE NOT NULL,
  CONSTRAINT fk_pago_alquiler FOREIGN KEY (id_alquiler) REFERENCES Alquileres(id_alquiler)
);

-- === CLIENTES ===
INSERT INTO Clientes (id_cliente, nombre, telefono, email, direccion) VALUES
(1, 'Juan Pérez',  '555-1234', 'juan@mail.com',  'Calle 123'),
(2, 'Laura Gómez', '555-5678', 'laura@mail.com', 'Calle 456'),
(3, 'Carlos Sánchez', '555-9101', 'carlos@mail.com', 'Calle 789');

-- === VEHICULOS ===
INSERT INTO Vehiculos (id_vehiculo, marca, modelo, anio, precio_dia) VALUES
(1, 'Toyota', 'Corolla', 2020, 30.00),
(2, 'Honda',  'Civic',   2019, 28.00),
(3, 'Ford',   'Focus',   2021, 35.00);

-- === ALQUILERES ===
INSERT INTO Alquileres (id_alquiler, id_cliente, id_vehiculo, fecha_inicio, fecha_fin) VALUES
(1, 1, 2, '2025-03-10', '2025-03-15'),
(2, 2, 1, '2025-03-12', '2025-03-16'),
(3, 3, 3, '2025-03-20', '2025-03-22');

-- === PAGOS ===
INSERT INTO Pagos (id_pago, id_alquiler, monto, fecha_pago) VALUES
(1, 1, 150.00, '2025-03-12'),
(2, 2, 112.00, '2025-03-13'),
(3, 3,  70.00, '2025-03-20');

/* 
Consulta 1: Mostrar el nombre, telefono y email de todos los clientes que tienen un alquiler activo 
(es decir, cuya fecha actual esté dentro del rango entre fecha_inicio y fecha_fin)
*/
SELECT c.nombre, c.telefono, c.email
FROM Clientes AS c
JOIN Alquileres AS a ON c.id_cliente = a.id_cliente
WHERE CURDATE() BETWEEN a.fecha_inicio AND a.fecha_fin;

/* 
Consulta 2: Mostrar los vehículos que se alquilaron en el mes de marzo de 2025. 
Debe mostrar el modelo, marca, y precio_dia de esos vehículos.
*/
SELECT v.modelo, v.marca, v.precio_dia
FROM Vehiculos AS v
JOIN Alquileres AS a ON v.id_vehiculo = a.id_vehiculo
WHERE a.fecha_inicio BETWEEN '2025-03-01' 
    AND '2025-03-31';

/* 
Consulta 3: Calcular el precio total del alquiler para cada cliente, considerando el número de días que alquiló el vehículo 
(el precio por día de cada vehículo multiplicado por la cantidad de días de alquiler).
*/
SELECT c.nombre,
       SUM(DATEDIFF(a.fecha_fin, a.fecha_inicio) * v.precio_dia) AS total_alquiler
FROM Clientes AS c
JOIN Alquileres AS a ON c.id_cliente = a.id_cliente
JOIN Vehiculos AS v ON a.id_vehiculo = v.id_vehiculo
GROUP BY c.nombre;

/* 
Consulta 4: Encontrar los clientes que no han realizado ningún pago (no tienen registros en la tabla Pagos). Muestra su nombre y email.
*/
SELECT c.nombre, c.email
FROM Clientes AS c
LEFT JOIN Alquileres AS a ON c.id_cliente = a.id_cliente
LEFT JOIN Pagos AS p ON a.id_alquiler = p.id_alquiler
WHERE p.id_pago IS NULL;
/* 
Consulta 5: Calcular el promedio de los pagos realizados por cada cliente. Muestra el nombre del cliente y el promedio de pago.
*/
SELECT c.nombre,
       AVG(p.monto) AS promedio_pago
FROM Clientes AS c
JOIN Alquileres AS a ON c.id_cliente = a.id_cliente
JOIN Pagos AS p ON a.id_alquiler = p.id_alquiler
GROUP BY c.nombre;
/* 
Consulta 6: Mostrar los vehículos que están disponibles para alquilar en una fecha específica (por ejemplo, 2025-03-18). Debe mostrar el modelo, marca y precio_dia. 
Si el vehículo está ocupado, no se debe incluir.
*/
SELECT v.modelo, v.marca, v.precio_dia
FROM Vehiculos AS v
LEFT JOIN Alquileres AS a
  ON v.id_vehiculo = a.id_vehiculo
  AND '2025-03-18' BETWEEN a.fecha_inicio AND a.fecha_fin
WHERE a.id_alquiler IS NULL;
/* 
Consulta 7: Encontrar la marca y el modelo de los vehículos que se alquilaron más de una vez en el mes de marzo de 2025.
*/
SELECT v.marca, v.modelo, COUNT(*) AS veces_alquilado
FROM Vehiculos AS v
JOIN Alquileres AS a ON v.id_vehiculo = a.id_vehiculo
WHERE YEAR(a.fecha_inicio) = 2025
  AND MONTH(a.fecha_inicio) = 3
GROUP BY v.marca, v.modelo
HAVING COUNT(*) > 1;
/* 
Consulta 8: Mostrar el total de monto pagado por cada cliente. 
Debe mostrar el nombre del cliente y la cantidad total de pagos realizados (suma del monto de los pagos).
*/
SELECT c.nombre,
       SUM(p.monto) AS total_pagado
FROM Clientes AS c
JOIN Alquileres AS a ON c.id_cliente = a.id_cliente
JOIN Pagos AS p ON a.id_alquiler = p.id_alquiler
GROUP BY c.nombre;
/* 
Consulta 9: Mostrar los clientes que alquilaron el vehículo Ford Focus (con id_vehiculo = 3). 
Debe mostrar el nombre del cliente y la fecha del alquiler.
*/
SELECT c.nombre, a.fecha_inicio, a.fecha_fin
FROM Clientes AS c
JOIN Alquileres AS a ON c.id_cliente = a.id_cliente
WHERE a.id_vehiculo = 3;
/* 
Consulta 10: Realizar una consulta que muestre el nombre del cliente y el total de días alquilados de cada cliente, ordenado de mayor a menor total de días. 
El total de días es calculado como la diferencia entre fecha_inicio y fecha_fin.
*/
SELECT c.nombre,
       SUM(DATEDIFF(a.fecha_fin, a.fecha_inicio)) AS total_dias
FROM Clientes AS c
JOIN Alquileres AS a ON c.id_cliente = a.id_cliente
GROUP BY c.nombre
ORDER BY total_dias DESC;