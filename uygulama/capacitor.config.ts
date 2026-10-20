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
  appendUserAgent: "StarPrintUygulama/1.0",
  android: {
    allowMixedContent: false,
  },
  ios: {
    contentInset: "automatic",
    limitsNavigationsToAppBoundDomains: false,
  },
};

export default config;
