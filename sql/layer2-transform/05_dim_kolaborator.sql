USE DW_penelitianPublikasi_layer2Transform;

DROP TABLE IF EXISTS transform_kolaborator;

CREATE TABLE transform_kolaborator (
    id_kolaborator INT AUTO_INCREMENT PRIMARY KEY,
    nama_kolaborator VARCHAR(255),
    tipe_kolaborator VARCHAR(50),
    negara_kolaborator VARCHAR(100),
    tanggal_input_system TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tanggal_update_system TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
       ON UPDATE CURRENT_TIMESTAMP
);

LOAD DATA LOCAL INFILE '/Users/SEMESTER5/Data DWH/df_kolaborator.csv'
INTO TABLE transform_kolaborator
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    tipe_kolaborator,
    negara_kolaborator,
    id_kolaborator,
    tanggal_input_system,
    tanggal_update_system,
    nama_kolaborator
);