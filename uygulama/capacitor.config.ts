import type { CapacitorConfig } from "@capacitor/cli";

// Uygulama starprint.tr'yi açar: siteye eklenen her özellik uygulamaya da gelir.
// Telefona özgü işler (yerel ağdan sayaç okuma vb.) yerel eklentilerle yapılır.
const config: CapacitorConfig = {
  appId: "tr.starprint.app",
  appName: "Star Print",
  webDir: "www",
  server: {
    url: "https://starprint.tr/giris",
    allowNavigation: ["starprint.tr", "www.starprint.tr"],
    errorPath: "cevrimdisi.html",
  },
  backgroundColor: "#f3f5f8",
  // Site uygulamayı tanısın (uzun oturum vb.)
  appendUserAgent: "StarPrintUygulama/1.0 SistemBandi",
  android: {
    allowMixedContent: false,
  },
  ios: {
    contentInset: "automatic",
    limitsNavigationsToAppBoundDomains: false,
  },
  // iOS SwiftPM: Firebase paketinin kimlik çakışmasını önler (eklenti belgesine göre)
  experimental: {
    ios: {
      spm: {
        packageOptions: {
          "@capacitor-firebase/messaging": { symlink: true },
        },
      },
    },
  },
  plugins: {
    // Telefon bildirimleri (Firebase Cloud Messaging). iOS'ta uygulama açıkken de sistem bildirimi düşer
    // (site bunu "SistemBandi" etiketinden anlar ve kendi şeridini göstermez). Android'de açıkken site şeridi çıkar.
    FirebaseMessaging: {
      presentationOptions: ["alert", "badge", "sound"],
    },
  },
};

export default config;
