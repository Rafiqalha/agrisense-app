# AgriSense Mobile

Dashboard Flutter untuk memantau kondisi kebun melalui ponsel. Antarmuka
dirancang dengan pendekatan visual ala Notion: tenang, terstruktur, mudah
dipindai, dan menggunakan bahasa Indonesia yang mudah dipahami.

## Ruang lingkup saat ini

- Ringkasan kebun, tanaman aktif, hasil panen, dan aktivitas terbaru.
- Daftar kebun dengan pencarian dan detail tanaman.
- Riwayat aktivitas dengan filter jenis kegiatan.
- Profil, status sesi, dan ketersediaan setiap kelompok data.
- Tata letak responsif untuk ponsel dan tablet.

## Integrasi produksi

Aplikasi menggunakan BFF AgriSense pada
`https://agrisense-web-iota.vercel.app` dan tidak menyimpan token internal
Railway, Brain, atau Farm. Alurnya:

1. Pengguna mengirim `LOGIN` ke WhatsApp AgriSense.
2. Kode satu kali dimasukkan ke aplikasi.
3. Sesi 15 menit disimpan melalui `flutter_secure_storage`.
4. Dashboard membaca kebun, tanaman, panen, dan aktivitas milik akun tersebut.

Origin API dapat diganti saat build tanpa mengubah source:

```shell
flutter build apk --release \
  --dart-define=AGRISENSE_API_BASE_URL=https://domain-anda.example
```

Nilai harus berupa origin HTTPS tanpa path, query, atau kredensial. Data sensor
belum ditampilkan karena backend AgriSense saat ini belum mengekspos API sensor.
Aplikasi tidak membuat angka sensor sintetis.

## Menjalankan

```shell
flutter pub get
flutter run
```

## Validasi

```shell
flutter analyze
flutter test
flutter build web
flutter build apk --release
```
