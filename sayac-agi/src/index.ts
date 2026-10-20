import { registerPlugin } from '@capacitor/core';

import type { SayacAgiPlugin } from './definitions';

const SayacAgi = registerPlugin<SayacAgiPlugin>('SayacAgi', {
  web: () => import('./web').then((m) => new m.SayacAgiWeb()),
});

export * from './definitions';
export { SayacAgi };
