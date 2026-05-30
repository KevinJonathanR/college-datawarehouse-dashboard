USE DW_penelitianPublikasi_layer2Transform;

DROP TABLE IF EXISTS transform_waktu;

CREATE TABLE transform_waktu (
    id_waktu INT PRIMARY KEY,    
    tahun INT,
    triwulan INT,
    semester VARCHAR(10)
);

INSERT INTO transform_waktu (id_waktu, tahun, triwulan, semester)
SELECT 
    y.tahun * 10 + q.triwulan AS id_waktu,
    y.tahun,
    q.triwulan,
    CASE 
        WHEN q.triwulan IN (1,2) THEN 'GANJIL'
        WHEN q.triwulan IN (3,4) THEN 'GENAP'
    END AS semester
FROM (
    SELECT 2020 AS tahun UNION SELECT 2021 UNION SELECT 2022 UNION
    SELECT 2023 UNION SELECT 2024 UNION SELECT 2025
) y
CROSS JOIN (
    SELECT 1 AS triwulan UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
) q
ORDER BY y.tahun, q.triwulan;