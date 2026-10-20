# Star Print telefon uygulaması (Android + iOS)

Uygulama starprint.tr'yi açar; telefona özgü işler yerel eklentilerle yapılır.

- `uygulama/` – Capacitor uygulaması (Android ve iOS projeleri)
- `sayac-agi/` – yerel ağdaki yazıcılardan sayaç okumak için UDP eklentisi (Java + Swift)
- `.github/workflows/` – GitHub'ın bulut bilgisayarlarında derleme

## Derleme (GitHub)

1. github.com'da **özel (private)** bir depo açın, bu klasörün içeriğini yükleyin.
2. **Actions** sekmesinde iki iş çalışır:
   - **Android**: bitince "StarPrint-android" dosyasını indirin, içindeki `app-debug.apk` doğrudan Android telefona kurulur.
   - **iOS**: kodun iPhone için hatasız derlendiğini doğrular. App Store / TestFlight gönderimi Apple hesabı anahtarları eklenince açılır.

## Kimlik
- Uygulama kimliği: `tr.starprint.app`
- Ad: Star Print
