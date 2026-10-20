import { WebPlugin } from '@capacitor/core';

import type { SayacAgiPlugin } from './definitions';

export class SayacAgiWeb extends WebPlugin implements SayacAgiPlugin {
  async gonderAl(): Promise<{ cevaplar: { ip: string; veri: string }[] }> {
    throw this.unavailable('Sayaç okuma yalnızca telefon uygulamasında çalışır.');
  }
  async agBilgisi(): Promise<{ wifi: boolean }> {
    return { wifi: false };
  }
}
