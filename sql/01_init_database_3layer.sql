-- ============================================
-- Data Warehouse Initialization Script (MySQL)
-- Penelitian & Publikasi – 3-Layer Architecture
-- Layer 1: Extract -> data mentah dari source
-- Layer 2: Transform -> data transform/clean
-- Layer 3: Load -> tabel fakta dan dimensi
-- ============================================

DROP DATABASE IF EXISTS DW_penelitianPublikasi_layer1Extract;
DROP DATABASE IF EXISTS DW_penelitianPublikasi_layer2Transform;
DROP DATABASE IF EXISTS DW_penelitianPublikasi_layer3Load;

-- Cek dan buat database Layer 1 (Extract)
CREATE DATABASE IF NOT EXISTS DW_penelitianPublikasi_layer1Extract;

-- Cek dan buat database Layer 2 (Transform)
CREATE DATABASE IF NOT EXISTS DW_penelitianPublikasi_layer2Transform;

-- Cek dan buat database Layer 3 (Load)
CREATE DATABASE IF NOT EXISTS DW_penelitianPublikasi_layer3Load;

-- Opsional: tampilkan daftar database untuk verifikasi
SHOW DATABASES;
