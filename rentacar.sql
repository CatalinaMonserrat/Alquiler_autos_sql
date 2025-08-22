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

-- === Consulta 1 ===
SELECT c.nombre, c.telefono, c.email
FROM Clientes c
JOIN Alquileres a ON a.id_cliente = c.id_cliente
WHERE CURRENT_DATE BETWEEN a.fecha_inicio AND a.fecha_fin;

-- === Consulta 2 ===
SELECT v.modelo, v.marca, v.precio_dia
FROM Vehiculos v
JOIN Alquileres a ON a.id_vehiculo = v.id_vehiculo
WHERE a.fecha_fin >= '2025-03-01'
  AND a.fecha_inicio <  '2025-04-01'
GROUP BY v.id_vehiculo, v.modelo, v.marca, v.precio_dia;

-- === Consulta 3 ===
SELECT c.nombre,
       SUM( (DATEDIFF(a.fecha_fin, a.fecha_inicio) + 1) * v.precio_dia ) AS total_a_pagar
FROM Clientes c
JOIN Alquileres a  ON a.id_cliente  = c.id_cliente
JOIN Vehiculos  v  ON v.id_vehiculo = a.id_vehiculo
GROUP BY c.id_cliente, c.nombre;

-- === Consulta 4 ===
SELECT DISTINCT c.nombre, c.email
FROM Clientes c
JOIN Alquileres a ON a.id_cliente = c.id_cliente
LEFT JOIN Pagos p ON p.id_alquiler = a.id_alquiler
WHERE p.id_pago IS NULL;