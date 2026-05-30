USE DW_penelitianPublikasi_layer2Transform;

DROP TABLE IF EXISTS transform_dosen;

CREATE TABLE IF NOT EXISTS transform_dosen (
    id_dosen INT AUTO_INCREMENT PRIMARY KEY,
    nama_dosen VARCHAR(255),
    nidn VARCHAR(50),
    kode_dosen VARCHAR(50),
    prodi VARCHAR(255),
    fakultas VARCHAR(255),
    kelompok_keahlian VARCHAR(255),
    tanggal_input_system TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tanggal_update_system TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
        ON UPDATE CURRENT_TIMESTAMP,
    source_data VARCHAR(50)
);

INSERT IGNORE INTO transform_dosen (nama_dosen, nidn, kode_dosen, prodi, fakultas, kelompok_keahlian, source_data)
SELECT DISTINCT nama_ketua_tim, nidn, kode_dosen_ketua, prodi, fakultas, kelompok_keahlian, 'raw_penelitian2021_2025'
FROM DW_penelitianPublikasi_layer1Extract.raw_penelitian2021_2025 WHERE nama_ketua_tim IS NOT NULL;

INSERT IGNORE INTO transform_dosen (nama_dosen, source_data)
SELECT DISTINCT penulis_1, 'transform_publikasi'
FROM DW_penelitianPublikasi_layer2Transform.transform_publikasi WHERE penulis_1 IS NOT NULL;

-- cleaning

UPDATE transform_dosen
SET 
    nama_dosen = NULLIF(TRIM(nama_dosen), ''),
    nidn = NULLIF(TRIM(nidn), ''),
    kode_dosen = NULLIF(TRIM(kode_dosen), ''),
    prodi = NULLIF(TRIM(prodi), ''),
    fakultas = NULLIF(TRIM(fakultas), ''),
    kelompok_keahlian = NULLIF(TRIM(kelompok_keahlian), '');
    
ALTER TABLE transform_dosen
ADD skor_kualitas INT;

UPDATE transform_dosen
SET skor_kualitas =
      (CASE WHEN nidn IS NOT NULL THEN 2 ELSE 0 END)
    + (CASE WHEN kode_dosen IS NOT NULL THEN 1 ELSE 0 END);
    
DROP TABLE IF EXISTS transform_dosen_final;

CREATE TABLE transform_dosen_final AS
SELECT t.*
FROM transform_dosen t
JOIN (
    SELECT
        nama_dosen,
        MAX(skor_kualitas) AS max_skor
    FROM transform_dosen
    GROUP BY nama_dosen
) best
  ON t.nama_dosen = best.nama_dosen
 AND t.skor_kualitas = best.max_skor
 AND t.id_dosen = (
      SELECT MIN(x.id_dosen)
      FROM transform_dosen x
      WHERE x.nama_dosen = t.nama_dosen
        AND x.skor_kualitas = best.max_skor
 );

DROP TABLE IF EXISTS transform_dosen;

RENAME TABLE transform_dosen_final TO transform_dosen;
    
select * from transform_dosen;