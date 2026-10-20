export interface Paket {
  ip: string;
  /** base64 */
  veri: string;
}

export interface SayacAgiPlugin {
  /** Paketleri UDP ile gönderir, süre dolana (ya da her pakete bir cevap gelene) kadar cevapları toplar */
  gonderAl(secenek: { paketler: Paket[]; port: number; sureMs: number }): Promise<{ cevaplar: Paket[] }>;
  /** Telefonun Wi-Fi IPv4 adresi ve ağ ön eki */
  agBilgisi(): Promise<{ wifi: boolean; ip?: string; onEk?: number }>;
}
