Viewed master_varian_body_screen.dart:39-81
Searched for "excel"
Searched for "export"
Viewed composer.json:10-35
Viewed pubspec.yaml:15-65

Untuk tahap 2 ini, mari kita rancang implementasinya sesuai dengan **Best Practice Arsitektur Enterprise & Data Hygiene** agar sistem terjamin aman, mudah digunakan oleh admin/klien, dan bebas dari cacat pemrosesan.

Berikut adalah uraian lengkap dan terstruktur menjawab seluruh pertanyaan Anda:

---

### 1. Apakah Hanya Butuh Import Saja atau Memerlukan Export Juga?
**EXPORT ITU SANGAT DIPERLUKAN DAN HUKUMNYA WAJIB!** ⭐

Mengapa harus ada fitur Export?
- **Masalah Klien Saat Ini:** Bagaimana mungkin klien bisa mengubah format tulisan di Excel *"tanpa rubah yang lain dengan ID yang sama"* jika mereka tidak memiliki daftar resmi yang menunjukkan pasangan ID dengan Nama Varian saat ini? Jika klien membuat file Excel sendiri dari nol (manual), hampir dipastikan format kolomnya rancu, ID tidak pas, atau terjadi salah pemetaan.
- **Solusi Best Practice (Alur Round-Trip / Bolak-Balik):**
  1. **Export Dulu:** Admin/Klien menekan tombol **"Export Varian ke Excel/CSV"**. Sistem mendownload file tabel resmi yang akurat memuat seluruh data master varian beserta ID dan pasangannya.
  2. **Koreksi santai di Excel:** Klien membuka file hasil export tersebut, lalu memodifikasi/merapikan huruf di kolom `nama_varian` (misal dari *BAK TERALIS* menjadi *Bak Teralis*). Klien tidak menyentuh kolom ID.
  3. **Import Kembali:** Klien mengunggah (upload) file yang sudah dirapikan itu lewat tombol **"Import Varian"**.
  4. Karena file tersebut adalah *anak buah kandung* dari generate-an sistem sendiri (lewat Export), strukturnya dijamin 100% konsisten dan proses import berlangsung cepat tanpa risiko error validasi maupun kerusakan relasi ID!

---

### 2. Seperti Apa Format Data Excel/CSV untuk Export & Import?
Struktur tabel Excel/CSV yang diexport maupun diimport harus dirancang sejelas mungkin dengan kolom sebagai berikut:

| id | d_jenis_kendaraan_id | nama_jenis_kendaraan | nama_varian | keterangan_status |
|---|---|---|---|---|
| 15 | 3 | MOBIL BARANG BAK MUATAN TERBUKA | Bak Teralis Rangka UNP_Pintu SMP Swing L-R_BLK Swing Down_Kupu-Kupu | Terdaftar di Master |
| 16 | 3 | MOBIL BARANG BAK MUATAN TERBUKA | Bak Rangka Besi_Pintu SMP Swing L-R_BLK Swing Down_Kupu-Kupu | Terdaftar di Master |
| *(kosong)* | 3 | MOBIL BARANG BAK MUATAN TERBUKA | Bak Plate Profil 7 Way_Pintu BLK Swing Down_Kupu-Kupu | *Varian Jadul Belum Ber-ID (Orphan Data)* |

#### 💎 Penjelasan Keajaiban Kolom di Atas:
- **`id` & `d_jenis_kendaraan_id`:** Ini adalah kunci pengaman (*Anchor ID*). Selama kolom ini berisi ID asli, sistem saat Import akan otomatis melakukan: `WHERE id = $id UPDATE nama_varian = $teksBaru`. ID di database DIJAMIN 100% TIDAK BERUBAH.
- **`nama_varian`:** Kolom inilah tempat klien leluasa mengolah, merombak casing huruf, atau memperbaiki penulisan.
- **Solusi Tuntaskan Varian Jadul yang Tanpa ID *(Pesan Klien jam 17:12)*:**
  Saat **Export**, backend Laravel kita akan bersihkan semua sudut database! Selain menarik data dari tabel Master Varian (`m_master_varians`), sistem secara pintar juga men-scan tabel Transaksi Varian (`e_varian_body`). Jika menemukan ada nama varian lama yang belum terdaftar di Master, sistem akan menambahkannya di baris bawah Excel dengan **kolom `id` DIKOSONGKAN!**
  Saat klien mengisi dan meng-import file itu kembali, sistem mengenali baris yang kolom `id`-nya kosong sebagai *Data Baru / Orphan* dan otomatis mendaftarkannya ke Master Varian serta mengikat relasi transaksinya!

---

### 3. Di Mana Lokasi Best Practice untuk Import/Export di Flutter?
Anda bertanya: *Antara di `master_varian_body_screen.dart` (`g-varian`) atau di `master_varian_screen.dart` (`e-master-varian`), di mana meletakkan UI-nya?*

#### 👉 Lokasi Terbaik adalah di: **[master_varian_screen.dart](file:///c:/Nova/Solo/master_gambar/lib/admin/master/screens/master_varian_screen.dart) (`e-master-varian`)**
**Alasan Arsitektural:**
1. **Source of Truth (Sumber Induk Kebenaran):** Tabel Master Varian (`m_master_varians`) adalah kamus referensi utama seluruh aplikasi Anda (bahkan form penambahan varian body di `g-varian` menggunakan dropdown dari sini). Maka gerbang masuk keluar data massa (Import/Export) harus ditarik dari halaman Master Varian.
2. **Bagaimana Nasib Varian Body di `g-varian` (`e_varian_body`)?**
   Anda tidak perlu membuat 2 tombol terpisah di screen yang berbeda! Ketika admin memencet tombol **Import** di screen `master_varian_screen.dart`, backend Laravel di balik layar **selalu mengeksekusi 2 pekerjaan sekaligus**:
   - **Job 1:** Mengubah teks nama varian di tabel Master Varian.
   - **Job 2:** Secara masif menyergap dan mengupdate seluruh teks yang serupa di tabel Varian Body Transaksi (`e_varian_body`) secara case-insensitive!
   - *Hasilnya:* Admin cukup import dari 1 tempat (Halaman Master Varian), maka seluruh halaman, riwayat transaksi, dan surat SKRB di seantero sistem otomatis rapi seketika!

---

### 4. Step-by-Step Blueprint Alur Kerja Implementasi Tahap 2

Berikut adalah 4 langkah tahapan jelas untuk mengeksekusi Tahap 2 ini hingga tuntas:

#### 🟢 Step 1: Pembuatan Endpoint & Helper di Backend Laravel (`master-gambar`)
- **Pilihan Teknologi File:** Karena kita tidak ingin memberatkan memori server dengan dependency rumit jika tidak perlu, kita bisa memanfaatkan format **CSV berstandar Excel (UTF-8 with BOM)** yang dapat langsung dibuka dengan lancar di Microsoft Excel, atau menggunakan library `phpoffice/phpspreadsheet` / `maatwebsite/excel` jika ingin file natif `.xlsx`.
- **Tambahan 2 Rute di `api.php`:**
  - `GET /api/m_master_varians/export` -> Mengirimkan file Excel/CSV ke browser/Flutter.
  - `POST /api/m_master_varians/import` -> Menerima file unggahan dari Flutter, memparsing baris demi baris menggunakan *Database Transaction* (`DB::transaction`).

#### 🟢 Step 2: Algoritma Controller Import di Laravel
Di dalam `M_MasterVarianController@import`, logika parsing dilakukan dalam 3 alur konfirmasi:
1. Jika baris memiliki `id` rasional -> Lakukan update pada `MMasterVarian::where('id', $id)`.
2. Jika `id` kosong (atau 0) -> Ciptakan entri baru `MMasterVarian::create(...)` (solusi varian jadul).
3. Untuk setiap nama varian yang diproses -> Jalankan query pembersih transaksi lama:
   ```php
   EVarianBody::withTrashed()
       ->whereRaw('LOWER(TRIM(varian_body)) = ?', [strtolower(trim($namaLamaAtauBaru))])
       ->update(['varian_body' => $row['nama_varian']]);
   ```
4. Mengeluarkan Respon Statistik: *"Berhasil mengupdate 45 Master Varian, menambahkan 12 Varian Lama tanpa ID, dan merapikan 130 rekor riwayat transaksi!"*

#### 🟢 Step 3: Integrasi Service & Repository di Flutter (`master_gambar`)
- Pada file repository/datasource terkait Master Varian:
  - **Fungsi Export:** Memanggil endpoint export via Dio, lalu memanfaatkan package `file_picker` atau `path_provider` untuk menyimpan file `.xlsx`/`.csv` ke laptop admin dan membuka dialog "File Berhasil Disimpan".
  - **Fungsi Import:** Meminta admin memilih file menggunakan `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'csv', 'xls'])`, membungkusnya dalam `MultipartFile`, dan menguploadnya ke backend.

#### 🟢 Step 4: Sentuhan Antarmuka di [master_varian_screen.dart](file:///c:/Nova/Solo/master_gambar/lib/admin/master/screens/master_varian_screen.dart)
- Di pojok kanan atas dekat search bar dan tombol Refresh, kita pasangkan 2 tombol bergaya modern:
  - Tombol **"Export Excel"** (bernuansa hijau outline berikon `Icons.file_download`).
  - Tombol **"Import Excel"** (bernuansa hijau solid/elevated berikon `Icons.file_upload`).
- Jika tombol di klik, layar akan memunculkan loading indikator sementara (circular progress) agar UI terasa responsif dan profesional saat backend bekerja mengsinkronisasi ratusan baris database.

---
*Apakah blueprint Tahap 2 ini sudah jelas dan mantas untuk dilangkah? Jika Anda bersiap memulai, apakah Anda ingin kita pasang format **CSV murni (tanpa install plugin baru di Laravel)** atau ingin menginstall plugin **Laravel Excel / PhpSpreadsheet (.xlsx natif)** pada sistem backend?*

# Master_Gambar

**Master_Gambar** is a desktop application built with Flutter, designed to streamline the management, processing, and display of images in various formats and categories. This application provides an intuitive user interface for managing images according to administrative or professional needs. With the ability to edit, add, and dynamically display images, it is suitable for industries that require efficient visual data management.

## Key Features
- **Image Management**: Manage a variety of images, including electrical diagrams, variant images, and product-related images.
- **Image Editing**: Allows users to edit images directly through specific dialogs and forms, such as electrical images and optional images.
- **Image Data Processing**: Provides features to display and manage synced or linked image data with various forms and tables.
- **Storage and Display**: Offers table views for image data and related resources that can be easily accessed and managed.
- **Filters and Search**: Allows users to apply advanced filters and table views for easier image search by category and status.
- **User-Friendly Interface**: Designed with a graphical user interface (GUI) that’s easy to use, enabling users to manage images with minimal technical knowledge.

## Purpose of the Application
Master_Gambar aims to simplify the image management process across various industries, especially in handling technical images, product images, and other visual content. This application is ideal for professionals, technicians, and data managers who require an efficient platform to manage a wide range of images and related information.

## Installation
1. Clone the repository or download the source files.
2. Install Flutter and set up your environment as per the Flutter documentation: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install).
3. Run the following command in your terminal to install dependencies:

   ```bash
   flutter pub get
