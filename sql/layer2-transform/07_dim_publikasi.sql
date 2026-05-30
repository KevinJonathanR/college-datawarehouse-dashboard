USE DW_penelitianPublikasi_layer2Transform;

DROP TABLE IF EXISTS transform_publikasi;

CREATE TABLE transform_publikasi (
    id_publikasi INT AUTO_INCREMENT PRIMARY KEY,

    judul_publikasi TEXT,
    jenis_publikasi TEXT,
    prosiding_jurnal TEXT,
    tahun_terbit INT,
    sistem_indeksasi TEXT,

    penulis_internal_all TEXT,
    penulis_1 TEXT,
    penulis_2 TEXT,
    penulis_3 TEXT,
    penulis_4 TEXT,
    penulis_5 TEXT,
    penulis_6 TEXT,
    penulis_7 TEXT,

    nama_kolaborator TEXT,
    tipe_kolaborator TEXT,  

    sitasi_ts3 INT,
    sitasi_ts2 INT,
    sitasi_ts1 INT,
    sitasi_ts INT,

    source_file VARCHAR(255),

    tanggal_input_system TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tanggal_update_system TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO transform_publikasi (
    judul_publikasi,
    jenis_publikasi,
    prosiding_jurnal,
    tahun_terbit,
    sistem_indeksasi,

    penulis_internal_all,
    penulis_1,
    penulis_2,
    penulis_3,
    penulis_4,
    penulis_5,
    penulis_6,
    penulis_7,

    nama_kolaborator,
    tipe_kolaborator,

    sitasi_ts3,
    sitasi_ts2,
    sitasi_ts1,
    sitasi_ts,
    source_file
)
SELECT
    judul_artikel,
    skala_publikasi,
    nama_jurnal,
    tahun_terbit,
    sistem_indeksasi,

    penulis_internal,

    -- PENULIS INTERNAL PARSED
    TRIM(SUBSTRING_INDEX(penulis_internal, ',', 1)),
    CASE WHEN COUNT_COMMA >= 1 THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(penulis_internal, ',', 2), ',', -1)) END,
    CASE WHEN COUNT_COMMA >= 2 THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(penulis_internal, ',', 3), ',', -1)) END,
    CASE WHEN COUNT_COMMA >= 3 THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(penulis_internal, ',', 4), ',', -1)) END,
    CASE WHEN COUNT_COMMA >= 4 THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(penulis_internal, ',', 5), ',', -1)) END,
    CASE WHEN COUNT_COMMA >= 5 THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(penulis_internal, ',', 6), ',', -1)) END,
    CASE WHEN COUNT_COMMA >= 6 THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(penulis_internal, ',', 7), ',', -1)) END,

    NULLIF(TRIM(SUBSTRING_INDEX(kolaborator, ',', 1)), '') AS nama_kolaborator,

    NULLIF(TRIM(jenis_kolaborator), '') AS tipe_kolaborator,

    sitasi_ts3,
    sitasi_ts2,
    sitasi_ts1,
    sitasi_ts,
    'publikasi_2020_2025'
FROM (
    SELECT *,
        (LENGTH(penulis_internal) - LENGTH(REPLACE(penulis_internal, ',', ''))) AS COUNT_COMMA
    FROM DW_penelitianPublikasi_layer1Extract.raw_publikasi_2020_2025
) AS x;