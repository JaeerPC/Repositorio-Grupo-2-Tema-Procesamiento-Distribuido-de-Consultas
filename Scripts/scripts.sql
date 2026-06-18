CREATE DATABASE quito; 
CREATE DATABASE manta; 
CREATE DATABASE guayaquil; 

CREATE TABLE ventas_medicamentos ( id SERIAL PRIMARY KEY, 
medicamento TEXT, 
cantidad INT, 
precio NUMERIC, 
ciudad TEXT 
); 

INSERT INTO ventas_medicamentos VALUES
(DEFAULT, 'Paracetamol 500mg', 15, 0.10, 'Manta'), 
(DEFAULT, 'Ibuprofeno 400mg', 22, 0.25, 'Manta'); 

CREATE TABLE ventas_medicamentos (
id SERIAL PRIMARY KEY, 
medicamento TEXT, 
cantidad INT, 
precio NUMERIC, 
ciudad TEXT 
); 

INSERT INTO ventas_medicamentos VALUES 
(DEFAULT, 'Amoxicilina 500mg', 8, 0.60, 'Guayaquil'), 
(DEFAULT, 'Loratadina 10mg', 40, 0.15, 'Guayaquil'); 

CREATE TABLE ventas_medicamentos ( 
id SERIAL PRIMARY KEY, 
medicamento TEXT, 
cantidad INT, 
precio NUMERIC, 
ciudad TEXT 
); 

INSERT INTO ventas_medicamentos VALUES 
(DEFAULT, 'Omeprazol 20mg', 30, 0.30, 'Quito'), 
(DEFAULT, 'Vitamina C 1g', 12, 0.80, 'Quito'); 

CREATE EXTENSION postgres_fdw; 

CREATE SERVER servidor_manta FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname 'manta', host 'localhost', port '5432');
CREATE SERVER servidor_guayaquil FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname 'guayaquil', host 'localhost', port '5432');

CREATE USER MAPPING FOR postgres SERVER servidor_manta OPTIONS (user 'postgres', password '1234');
CREATE USER MAPPING FOR postgres SERVER servidor_guayaquil OPTIONS (user 'postgres', password '1234');

CREATE SCHEMA node_manta; IMPORT FOREIGN SCHEMA public FROM SERVER servidor_manta INTO node_manta;
CREATE SCHEMA node_guayaquil; IMPORT FOREIGN SCHEMA public FROM SERVER servidor_guayaquil INTO node_guayaquil;

CREATE TABLE laboratorios_medicos (
medicamento TEXT PRIMARY KEY, 
laboratorio TEXT, requiere_receta TEXT
); 

INSERT INTO laboratorios_medicos VALUES 
('Paracetamol 500mg', 'Bayer', 'NO'),
('Ibuprofeno 400mg', 'Genfar', 'NO'),
('Amoxicilina 500mg', 'Bago', 'SI'),
('Loratadina 10mg', 'Mk', 'NO'),
('Omeprazol 20mg', 'Genfar', 'NO'), 
('Vitamina C 1g', 'Bayer', 'NO'); 

SELECT * FROM ventas_medicamentos; 


SELECT * FROM ventas_medicamentos 
UNION ALL 
SELECT * FROM node_manta.ventas_medicamentos 
UNION ALL 
SELECT * FROM node_guayaquil.ventas_medicamentos; 

SELECT * FROM ventas_medicamentos WHERE ciudad = 'Quito' 
UNION ALL 
SELECT * FROM node_manta.ventas_medicamentos WHERE ciudad = 'Manta' 
UNION ALL 
SELECT * FROM node_guayaquil.ventas_medicamentos WHERE ciudad = 'Guayaquil'; 

SELECT l.laboratorio, SUM(v.cantidad) AS cajas_vendidas
FROM ( 
SELECT * FROM ventas_medicamentos 
UNION ALL 
SELECT * FROM node_manta.ventas_medicamentos 
UNION ALL 
SELECT * FROM node_guayaquil.ventas_medicamentos 
)v

JOIN laboratorios_medicos l ON v.medicamento = l.medicamento 
GROUP BY l.laboratorio;