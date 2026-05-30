/* -------------------------------------------------------------------------
   LAYER 1 — EXTRACT DATA PUBLIKASI
   Database : DW_penelitianPublikasi_layer1Extract
   Tabel    : publikasi_2020_2025 (raw table)
   Tujuan   : Menyimpan data mentah publikasi tahun 2020-2025
   Catatan  :
     - Seluruh kolom disimpan sebagai TEXT (raw).
     - Transformasi dilakukan nanti di Layer 2.
--------------------------------------------------------------------------- */

USE DW_penelitianPublikasi_layer1Extract;

-- ======================================================================
-- 1. DROP TABLE jika sudah ada (agar load ulang tidak error)
-- ======================================================================
DROP TABLE IF EXISTS raw_publikasi_2020_2025;

-- ======================================================================
-- 2. CREATE TABLE (DDL)
-- ======================================================================
CREATE TABLE raw_publikasi_2020_2025 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    source_file VARCHAR(255),

    no INT,
    judul_artikel TEXT,
    tahun_terbit INT,
    penulis TEXT,
    penulis_internal TEXT,
    nama_jurnal TEXT,
    jenis_publikasi TEXT,

    sitasi_ts3 INT,
    sitasi_ts2 INT,
    sitasi_ts1 INT,
    sitasi_ts INT,

    link_artikel TEXT,
    kolaborator TEXT,
    jenis_kolaborator TEXT,
    skala_publikasi TEXT,
    sistem_indeksasi TEXT
);

-- ======================================================================
-- 3. LOAD DATA (EXTRACT)
--    Catatan:
--    - Gunakan LOCAL agar membaca file dari laptop.
--    - FIELDS TERMINATED BY ';' menyesuaikan file sumber.
--    - OPTIONALLY ENCLOSED BY '"' mencegah error bila ada tanda kutip.
--    - LINES TERMINATED BY diuji ke '\n' (macOS), fallback '\r\n'.
-- ======================================================================

LOAD DATA LOCAL INFILE '/Users/SEMESTER5/Data DWH/publikasi2020-2025_final.csv'
INTO TABLE raw_publikasi_2020_2025
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @no,
    judul_artikel,
    tahun_terbit,
    penulis,
    penulis_internal,
    nama_jurnal,
    jenis_publikasi,
    sitasi_ts3,
    sitasi_ts2,
    sitasi_ts1,
    sitasi_ts,
    link_artikel,
    kolaborator,
    jenis_kolaborator,
    skala_publikasi,
    sistem_indeksasi
)
SET
    no = CAST(REGEXP_REPLACE(TRIM(@no), '[^0-9]', '') AS UNSIGNED),
    source_file = 'publikasi.csv';

-- CEK JUDUL_ARTIKEL DAN JUDUL_PENELITIAN YANG SAMA (TIDAK ADA)
-- SELECT 
--     p.no,
--     p.judul_penelitian,
--     pub.judul_artikel
-- FROM raw_penelitian2025 p
-- JOIN raw_publikasi_2020_2025 pub
--     ON LOWER(TRIM(p.judul_penelitian)) = LOWER(TRIM(pub.judul_artikel));