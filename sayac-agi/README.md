# sayac-agi

Yerel ag UDP/SNMP

## Install

To use npm

```bash
npm install sayac-agi
````

To use yarn

```bash
yarn add sayac-agi
```

Sync native files

```bash
npx cap sync
```

## API

<docgen-index>

* [`gonderAl(...)`](#gonderal)
* [`agBilgisi()`](#agbilgisi)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### gonderAl(...)

```typescript
gonderAl(secenek: { paketler: Paket[]; port: number; sureMs: number; }) => Promise<{ cevaplar: Paket[]; }>
```

Paketleri UDP ile gönderir, süre dolana (ya da her pakete bir cevap gelene) kadar cevapları toplar

| Param         | Type                                                              |
| ------------- | ----------------------------------------------------------------- |
| **`secenek`** | <code>{ paketler: Paket[]; port: number; sureMs: number; }</code> |

**Returns:** <code>Promise&lt;{ cevaplar: Paket[]; }&gt;</code>

--------------------


### agBilgisi()

```typescript
agBilgisi() => Promise<{ wifi: boolean; ip?: string; onEk?: number; }>
```

Telefonun Wi-Fi IPv4 adresi ve ağ ön eki

**Returns:** <code>Promise&lt;{ wifi: boolean; ip?: string; onEk?: number; }&gt;</code>

--------------------


### Interfaces


#### Paket

| Prop       | Type                | Description |
| ---------- | ------------------- | ----------- |
| **`ip`**   | <code>string</code> |             |
| **`veri`** | <code>string</code> | base64      |

</docgen-api>
