USE DW_penelitianPublikasi_layer3Load;

-- -----------------------------
-- 1) Drop existing (safe restart)
-- -----------------------------
DROP TABLE IF EXISTS Fact_PenelitianPublikasi;
DROP TABLE IF EXISTS dim_dosen;
DROP TABLE IF EXISTS dim_penelitian;
DROP TABLE IF EXISTS dim_publikasi;
DROP TABLE IF EXISTS dim_kolaborator;
DROP TABLE IF EXISTS dim_waktu;

-- -----------------------------
-- 2) Create dims from layer2
-- -----------------------------
CREATE TABLE dim_dosen AS
SELECT * 
FROM DW_penelitianPublikasi_layer2Transform.transform_dosen;
ALTER TABLE dim_dosen
ADD PRIMARY KEY (id_dosen);

CREATE TABLE dim_penelitian AS
SELECT * 
FROM DW_penelitianPublikasi_layer2Transform.transform_penelitian;
ALTER TABLE dim_penelitian
ADD PRIMARY KEY (id_penelitian);

CREATE TABLE dim_publikasi AS
SELECT 
    id_publikasi,
    judul_publikasi,
    jenis_publikasi,
    prosiding_jurnal,
    tahun_terbit,
    sistem_indeksasi,
    penulis_1, penulis_2, penulis_3,
    penulis_4, penulis_5, penulis_6, penulis_7,
    nama_kolaborator,
    tipe_kolaborator,
    sitasi_ts3, sitasi_ts2, sitasi_ts1, sitasi_ts,
    source_file,
    tanggal_input_system,
    tanggal_update_system
FROM DW_penelitianPublikasi_layer2Transform.transform_publikasi;
ALTER TABLE dim_publikasi ADD PRIMARY KEY(id_publikasi);

CREATE TABLE dim_kolaborator AS
SELECT *
FROM DW_penelitianPublikasi_layer2Transform.transform_kolaborator;
ALTER TABLE dim_kolaborator
ADD PRIMARY KEY (id_kolaborator);

CREATE TABLE dim_waktu AS
SELECT *
FROM DW_penelitianPublikasi_layer2Transform.transform_waktu;
ALTER TABLE dim_waktu
ADD PRIMARY KEY (id_waktu);

-- ----------------------------------------------------
-- 3) STAGING KOALBORATOR PENELITIAN (INDUSTRI/UNIV)
-- ----------------------------------------------------
DROP TABLE IF EXISTS staging_kolaborator_penelitian;

CREATE TABLE staging_kolaborator_penelitian AS
SELECT 
    p.id_penelitian,
    MIN(k.id_kolaborator) AS id_kolaborator
FROM dim_penelitian p
LEFT JOIN dim_kolaborator k
    ON (

        REPLACE(REPLACE(UPPER(TRIM(k.nama_kolaborator)),'.',''),',','')
        = REPLACE(REPLACE(UPPER(TRIM(COALESCE(p.industri,''))),'.',''),',','')

        OR
        
        REPLACE(REPLACE(UPPER(TRIM(k.nama_kolaborator)),'.',''),',','')
        = REPLACE(REPLACE(UPPER(TRIM(COALESCE(p.universitas,''))),'.',''),',','')
    )
GROUP BY p.id_penelitian;
ALTER TABLE staging_kolaborator_penelitian
ADD PRIMARY KEY (id_penelitian);

-- ----------------------------------------------------
-- 4) STAGING KOALBORATOR PUBLIKASI
-- ----------------------------------------------------
DROP TABLE IF EXISTS staging_kolaborator_publikasi;

CREATE TABLE staging_kolaborator_publikasi AS
SELECT 
    pub.id_publikasi,
    k.id_kolaborator
FROM dim_publikasi pub
LEFT JOIN dim_kolaborator k
    ON REPLACE(REPLACE(UPPER(TRIM(k.nama_kolaborator)),'.',''),',','')
       =
       REPLACE(REPLACE(UPPER(TRIM(SUBSTRING_INDEX(COALESCE(pub.nama_kolaborator,''), ',', 1))),'.',''),',','');  
ALTER TABLE staging_kolaborator_publikasi
ADD PRIMARY KEY (id_publikasi);

-- ----------------------------------------------------
-- 5) STAGING DOSEN PENELITIAN
-- ----------------------------------------------------
DROP TABLE IF EXISTS staging_dosen_penelitian;

CREATE TABLE staging_dosen_penelitian AS
SELECT
    p.id_penelitian,
    MIN(d.id_dosen) AS id_dosen
FROM dim_penelitian p
LEFT JOIN dim_dosen d
    ON UPPER(TRIM(d.nama_dosen)) = UPPER(TRIM(COALESCE(p.ketua_peneliti,'')))
GROUP BY p.id_penelitian;

ALTER TABLE staging_dosen_penelitian
ADD PRIMARY KEY (id_penelitian);

-- ----------------------------------------------------
-- 6) STAGING DOSEN PUBLIKASI
-- ----------------------------------------------------
DROP TABLE IF EXISTS staging_dosen_publikasi;

CREATE TABLE staging_dosen_publikasi AS
SELECT
    pub.id_publikasi,
    MIN(d.id_dosen) AS id_dosen
FROM dim_publikasi pub
LEFT JOIN dim_dosen d
    ON (
        UPPER(TRIM(d.nama_dosen)) = UPPER(TRIM(pub.penulis_1)) OR
        UPPER(TRIM(d.nama_dosen)) = UPPER(TRIM(pub.penulis_2)) OR
        UPPER(TRIM(d.nama_dosen)) = UPPER(TRIM(pub.penulis_3)) OR
        UPPER(TRIM(d.nama_dosen)) = UPPER(TRIM(pub.penulis_4)) OR
        UPPER(TRIM(d.nama_dosen)) = UPPER(TRIM(pub.penulis_5)) OR
        UPPER(TRIM(d.nama_dosen)) = UPPER(TRIM(pub.penulis_6)) OR
        UPPER(TRIM(d.nama_dosen)) = UPPER(TRIM(pub.penulis_7))
       )
GROUP BY pub.id_publikasi;

ALTER TABLE staging_dosen_publikasi
ADD PRIMARY KEY (id_publikasi);

-- ----------------------------------------------------
-- 7) FACT TABLE
-- ----------------------------------------------------
CREATE TABLE Fact_PenelitianPublikasi (
    id_fact INT AUTO_INCREMENT PRIMARY KEY,
    id_dosen INT,
    id_penelitian INT,
    id_publikasi INT,
    id_kolaborator INT,
    id_waktu INT,
    jumlah_sitasi INT,
    jumlah_hibah BIGINT,
    dana_terpakai BIGINT,
    FOREIGN KEY (id_dosen) REFERENCES dim_dosen(id_dosen),
    FOREIGN KEY (id_penelitian) REFERENCES dim_penelitian(id_penelitian),
    FOREIGN KEY (id_publikasi) REFERENCES dim_publikasi(id_publikasi),
    FOREIGN KEY (id_kolaborator) REFERENCES dim_kolaborator(id_kolaborator),
    FOREIGN KEY (id_waktu) REFERENCES dim_waktu(id_waktu)
);

-- ----------------------------------------------------
-- 8) INSERT FACT — PENELITIAN
-- ----------------------------------------------------
INSERT INTO Fact_PenelitianPublikasi (
    id_dosen, id_penelitian, id_publikasi, id_kolaborator,
    id_waktu, jumlah_sitasi, jumlah_hibah, dana_terpakai
)
SELECT
    sd.id_dosen,
    p.id_penelitian,
    NULL AS id_publikasi,
    sk.id_kolaborator,
    (COALESCE(p.tahun_pelaksanaan,0) * 10 + COALESCE(CAST(p.triwulan AS SIGNED),1)),
    0 AS jumlah_sitasi,
    
    CASE
        WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%LPDP%' 
             OR UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%RISPRO%'
            THEN FLOOR(500000000 + RAND()*500000000)
        WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%MATCHING FUND%'
            THEN FLOOR(500000000 + RAND()*1500000000)
        WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%INTERNASIONAL%'
            THEN FLOOR(300000000 + RAND()*500000000)
        WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%MANDIRI%' THEN 0  
        ELSE FLOOR(100000000 + RAND()*200000000)
    END AS jumlah_hibah,

    CASE 
        WHEN (
            CASE
                WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%LPDP%' 
                     OR UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%RISPRO%'
                    THEN FLOOR(500000000 + RAND()*500000000)
                WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%MATCHING FUND%'
                    THEN FLOOR(500000000 + RAND()*1500000000)
                WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%INTERNASIONAL%'
                    THEN FLOOR(300000000 + RAND()*500000000)
                WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%MANDIRI%' THEN 0  
                ELSE FLOOR(100000000 + RAND()*200000000)
            END
        ) = 0 THEN 0
        ELSE FLOOR(
            (
                CASE
                    WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%LPDP%' 
                         OR UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%RISPRO%'
                        THEN FLOOR(500000000 + RAND()*500000000)
                    WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%MATCHING FUND%'
                        THEN FLOOR(500000000 + RAND()*1500000000)
                    WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%INTERNASIONAL%'
                        THEN FLOOR(300000000 + RAND()*500000000)
                    WHEN UPPER(COALESCE(p.skema_penelitian,'')) LIKE '%MANDIRI%' THEN 0  
                    ELSE FLOOR(100000000 + RAND()*200000000)
                END
            ) * (0.5 + RAND()*0.5)
        )
    END AS dana_terpakai

FROM dim_penelitian p
LEFT JOIN staging_dosen_penelitian sd ON sd.id_penelitian = p.id_penelitian
LEFT JOIN staging_kolaborator_penelitian sk ON sk.id_penelitian = p.id_penelitian;

-- ----------------------------------------------------
-- 9) INSERT FACT — PUBLIKASI
-- ----------------------------------------------------
INSERT INTO Fact_PenelitianPublikasi (
    id_dosen, id_penelitian, id_publikasi, id_kolaborator,
    id_waktu, jumlah_sitasi, jumlah_hibah, dana_terpakai
)
SELECT
    sp.id_dosen,
    NULL,
    pub.id_publikasi,
    sk.id_kolaborator,
    (COALESCE(pub.tahun_terbit, 0) * 10 + 1) AS id_waktu,

    COALESCE(pub.sitasi_ts,0)
        + COALESCE(pub.sitasi_ts1,0)
        + COALESCE(pub.sitasi_ts2,0)
        + COALESCE(pub.sitasi_ts3,0) AS jumlah_sitasi,

    0 AS jumlah_hibah,
    0 AS dana_terpakai

FROM dim_publikasi pub
LEFT JOIN staging_dosen_publikasi sp ON sp.id_publikasi = pub.id_publikasi
LEFT JOIN staging_kolaborator_publikasi sk ON sk.id_publikasi = pub.id_publikasi;