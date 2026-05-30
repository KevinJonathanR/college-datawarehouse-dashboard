USE DW_penelitianPublikasi_layer1Extract;

/* PROSES DDL DAN EXTRACT DATA PENELITIAN */

-- ============================================================
-- 1. DROP TABLE (jika sudah ada)
-- ============================================================
DROP TABLE IF EXISTS raw_penelitian2021_2025;

-- ============================================================
-- 2. CREATE TABLE RAW
-- ============================================================

CREATE TABLE raw_penelitian2021_2025 (

    no INT,
    fakultas TEXT,
    prodi TEXT,
    judul_penelitian TEXT,
    kelompok_keahlian TEXT,

    nama_ketua_tim TEXT,
    nama_anggota_1 TEXT, fakultas_1 TEXT, prodi_1 TEXT,
    nama_anggota_2 TEXT, fakultas_2 TEXT, prodi_2 TEXT,
    nama_anggota_3 TEXT, fakultas_3 TEXT, prodi_3 TEXT,
    nama_anggota_4 TEXT, fakultas_4 TEXT, prodi_4 TEXT,
    nama_anggota_5 TEXT, fakultas_5 TEXT, prodi_5 TEXT,
    nama_anggota_6 TEXT, fakultas_6 TEXT, prodi_6 TEXT,
    nama_anggota_7 TEXT, fakultas_7 TEXT, prodi_7 TEXT,
    nama_anggota_8 TEXT, fakultas_8 TEXT, prodi_8 TEXT,
    nama_anggota_9 TEXT, fakultas_9 TEXT, prodi_9 TEXT,
    nama_anggota_10 TEXT, fakultas_10 TEXT, prodi_10 TEXT,

    nama_ketua_mitra TEXT,
    nama_anggota_mitra_1 TEXT,
    nama_anggota_mitra_2 TEXT,

    mahasiswa_1 TEXT,
    mahasiswa_2 TEXT,
    mahasiswa_3 TEXT,
    mahasiswa_4 TEXT,
    mahasiswa_5 TEXT,
    mahasiswa_6 TEXT,
    mahasiswa_7 TEXT,
    mahasiswa_8 TEXT,

    kelompok_masyarakat_lembaga TEXT,
    pemerintah_kemendikbudristek TEXT,
    luaran_tambahan_kemendikbudristek TEXT,
    pemerintah_non_kemendikbudristek TEXT,
    industri TEXT,
    universitas TEXT,
    keterangan_pendanaan_mitra_inkind_incash TEXT,

    jenis_skema_penelitian TEXT,
    tahun_pelaksanaan INT,
    triwulan INT,
    jenis_pendanaan TEXT,
    tingkat_kesiapan_teknologi_trl TEXT,

    negara TEXT,
    tipe_kolaborator TEXT,

    kelompok_keahlian_1 TEXT,
    kelompok_keahlian_2 TEXT,
    kelompok_keahlian_3 TEXT,
    kelompok_keahlian_4 TEXT,
    kelompok_keahlian_5 TEXT,
    kelompok_keahlian_6 TEXT,
    kelompok_keahlian_7 TEXT,
    kelompok_keahlian_8 TEXT,
    kelompok_keahlian_9 TEXT,
    kelompok_keahlian_10 TEXT,

    nama_anggota_mitra_3 TEXT,
    nama_anggota_mitra_4 TEXT,
    judul_ta_mahasiswa TEXT,
    keterkaitan_dengan_mata_kuliah TEXT,
    sdgs TEXT,
    bidang_fokus_1 TEXT,
    bidang_fokus_2 TEXT,

    kode_dosen_ketua TEXT,
    coe TEXT,
    nidn TEXT,

    kode_dosen_anggota_1 TEXT, nidn_1 TEXT, coe_1 TEXT,
    kode_dosen_anggota_2 TEXT, nidn_2 TEXT, coe_2 TEXT,
    kode_dosen_anggota_3 TEXT, nidn_3 TEXT, coe_3 TEXT,
    kode_dosen_anggota_4 TEXT, nidn_4 TEXT, coe_4 TEXT,
    kode_dosen_anggota_5 TEXT, nidn_5 TEXT, coe_5 TEXT,
    kode_dosen_anggota_6 TEXT, nidn_6 TEXT, coe_6 TEXT,
    kode_dosen_anggota_7 TEXT, nidn_7 TEXT, coe_7 TEXT,
    kode_dosen_anggota_8 TEXT, nidn_8 TEXT, coe_8 TEXT,
    kode_dosen_anggota_9 TEXT, nidn_9 TEXT, coe_9 TEXT,
    kode_dosen_anggota_10 TEXT, nidn_10 TEXT, coe_10 TEXT,

    -- KOLOM YANG TADI HILANG (INI BIANG GESER)
    nama_anggota_11 TEXT,
    kode_dosen_anggota_11 TEXT,
    nidn_11 TEXT,
    fakultas_11 TEXT,
    prodi_11 TEXT,
    kelompok_keahlian_11 TEXT,
    coe_11 TEXT,

    nama_anggota_mitra_5 TEXT,
    nama_anggota_mitra_6 TEXT,
    nama_anggota_mitra_7 TEXT,
    nama_anggota_mitra_8 TEXT,

    mahasiswa_9 TEXT,
    mahasiswa_10 TEXT,

    status_pelaksanaan_on_going_selesai TEXT,
    anggota_all TEXT,
    proposal TEXT,
    laporan_akhir TEXT,
    sk_pks TEXT
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/SEMESTER5/Data DWH/penelitianAll_final.csv'
INTO TABLE raw_penelitian2021_2025
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;