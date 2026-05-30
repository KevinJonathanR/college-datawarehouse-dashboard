USE DW_penelitianPublikasi_layer2Transform;

DROP TABLE IF EXISTS transform_penelitian;

CREATE TABLE transform_penelitian (
    id_penelitian INT AUTO_INCREMENT PRIMARY KEY,

    -- Atribut utama penelitian
    judul_penelitian TEXT,
    skema_penelitian TEXT,

    -- Mahasiswa terlibat
    mahasiswa_1 TEXT,
    mahasiswa_2 TEXT,
    mahasiswa_3 TEXT,
    mahasiswa_4 TEXT,
    mahasiswa_5 TEXT,
    mahasiswa_6 TEXT,
    mahasiswa_7 TEXT,
    mahasiswa_8 TEXT,
    mahasiswa_9 TEXT,
    mahasiswa_10 TEXT,

    -- Informasi pendanaan & status
    sumber_dana TEXT,
    status_penelitian TEXT,

    -- Waktu pelaksanaan
    tahun_pelaksanaan INT,
    triwulan INT,

    -- Luaran & kolaborasi
    luaran_penelitian TEXT,
    negara_mitra TEXT,

    industri TEXT,
    universitas TEXT,

    -- Ketua & referensi dosen
    ketua_peneliti TEXT,
    id_dosen INT,

    -- Metadata sistem
    tanggal_input_system TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tanggal_update_system TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
        ON UPDATE CURRENT_TIMESTAMP,

    source_data VARCHAR(50)
);

INSERT INTO transform_penelitian (
    judul_penelitian,
    skema_penelitian,

    mahasiswa_1, mahasiswa_2, mahasiswa_3, mahasiswa_4,
    mahasiswa_5, mahasiswa_6, mahasiswa_7, mahasiswa_8,
    mahasiswa_9, mahasiswa_10,

    sumber_dana,
    status_penelitian,

    tahun_pelaksanaan,
    triwulan,

    luaran_penelitian,
    negara_mitra,

    industri,
    universitas,

    ketua_peneliti,

    source_data
)
SELECT
    s.judul_penelitian,
    s.jenis_skema_penelitian AS skema_penelitian,

    s.mahasiswa_1,
    s.mahasiswa_2,
    s.mahasiswa_3,
    s.mahasiswa_4,
    s.mahasiswa_5,
    s.mahasiswa_6,
    s.mahasiswa_7,
    s.mahasiswa_8,
    s.mahasiswa_9,
    s.mahasiswa_10,

    s.jenis_pendanaan AS sumber_dana,
    s.status_pelaksanaan_on_going_selesai AS status_penelitian,

    s.tahun_pelaksanaan,
    s.triwulan,

    s.luaran_tambahan_kemendikbudristek AS luaran_penelitian,
    s.negara AS negara_mitra,

    s.industri,
    s.universitas,

    s.nama_ketua_tim AS ketua_peneliti,

    'raw_penelitian2021_2025'
FROM DW_penelitianPublikasi_layer1Extract.raw_penelitian2021_2025 s;

-- ============================================================================
-- 7. BASIC CLEANING
-- ============================================================================

UPDATE transform_penelitian
SET
    judul_penelitian = NULLIF(TRIM(judul_penelitian), ''),
    skema_penelitian = NULLIF(TRIM(skema_penelitian), ''),

    mahasiswa_1 = NULLIF(TRIM(mahasiswa_1), 'NULL'),
    mahasiswa_2 = NULLIF(TRIM(mahasiswa_2), 'NULL'),
    mahasiswa_3 = NULLIF(TRIM(mahasiswa_3), 'NULL'),
    mahasiswa_4 = NULLIF(TRIM(mahasiswa_4), 'NULL'),
    mahasiswa_5 = NULLIF(TRIM(mahasiswa_5), 'NULL'),
    mahasiswa_6 = NULLIF(TRIM(mahasiswa_6), 'NULL'),
    mahasiswa_7 = NULLIF(TRIM(mahasiswa_7), 'NULL'),
    mahasiswa_8 = NULLIF(TRIM(mahasiswa_8), 'NULL'),
    mahasiswa_9 = NULLIF(TRIM(mahasiswa_9), 'NULL'),
    mahasiswa_10 = NULLIF(TRIM(mahasiswa_10), 'NULL'),

    sumber_dana = NULLIF(TRIM(sumber_dana), ''),
    status_penelitian = NULLIF(TRIM(status_penelitian), ''),
    tahun_pelaksanaan = NULLIF(TRIM(tahun_pelaksanaan), ''),
    luaran_penelitian = NULLIF(TRIM(luaran_penelitian), ''),
    negara_mitra = NULLIF(TRIM(negara_mitra), '');

-- ============================================================================
-- 7.2 NORMALISASI SUMBER DANA
-- ============================================================================

UPDATE transform_penelitian
SET sumber_dana = 
    CASE
        WHEN UPPER(sumber_dana) LIKE '%INTERNAL%' 
         AND UPPER(sumber_dana) LIKE '%EKSTERNAL%'
            THEN 'INTERNAL DAN EKSTERNAL'
        WHEN UPPER(sumber_dana) LIKE '%INTERNAL%'
            THEN 'INTERNAL'
        WHEN UPPER(sumber_dana) LIKE '%EKSTERNAL%'
            THEN 'EKSTERNAL'
        ELSE NULL
    END;

-- ============================================================================
-- 7.3 CLEANING NAMA MAHASISWA
-- ============================================================================

UPDATE transform_penelitian
SET
    mahasiswa_1 = CASE WHEN mahasiswa_1 REGEXP '^[A-Za-z0-9 ()''.-]+$' THEN mahasiswa_1 ELSE NULL END,
    mahasiswa_2 = CASE WHEN mahasiswa_2 REGEXP '^[A-Za-z0-9 ()''.-]+$' THEN mahasiswa_2 ELSE NULL END,
    mahasiswa_3 = CASE WHEN mahasiswa_3 REGEXP '^[A-Za-z0-9 ()''.-]+$' THEN mahasiswa_3 ELSE NULL END,
    mahasiswa_4 = CASE WHEN mahasiswa_4 REGEXP '^[A-Za-z0-9 ()''.-]+$' THEN mahasiswa_4 ELSE NULL END,
    mahasiswa_5 = CASE WHEN mahasiswa_5 REGEXP '^[A-Za-z0-9 ()''.-]+$' THEN mahasiswa_5 ELSE NULL END,
    mahasiswa_6 = CASE WHEN mahasiswa_6 REGEXP '^[A-Za-z0-9 ()''.-]+$' THEN mahasiswa_6 ELSE NULL END,
    mahasiswa_7 = CASE WHEN mahasiswa_7 REGEXP '^[A-Za-z0-9 ()''.-]+$' THEN mahasiswa_7 ELSE NULL END,
    mahasiswa_8 = CASE WHEN mahasiswa_8 REGEXP '^[A-Za-z0-9 ()''.-]+$' THEN mahasiswa_8 ELSE NULL END,
    mahasiswa_9 = CASE WHEN mahasiswa_9 REGEXP '^[A-Za-z0-9 ()''.-]+$' THEN mahasiswa_9 ELSE NULL END,
    mahasiswa_10 = CASE WHEN mahasiswa_10 REGEXP '^[A-Za-z0-9 ()''.-]+$' THEN mahasiswa_10 ELSE NULL END;