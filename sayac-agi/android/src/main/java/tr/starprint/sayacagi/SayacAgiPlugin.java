package tr.starprint.sayacagi;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.LinkAddress;
import android.net.LinkProperties;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.util.Base64;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import org.json.JSONObject;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.SocketTimeoutException;
import java.util.List;

/**
 * Yerel ağdaki yazıcılarla SNMP konuşmak için ham UDP gönder/al.
 * SNMP paketleri JavaScript tarafında hazırlanır ve çözülür; burada yalnızca ağ işi yapılır.
 */
@CapacitorPlugin(name = "SayacAgi")
public class SayacAgiPlugin extends Plugin {

    private Network wifiAgi() {
        ConnectivityManager cm = (ConnectivityManager) getContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        if (cm == null) return null;
        for (Network n : cm.getAllNetworks()) {
            NetworkCapabilities nc = cm.getNetworkCapabilities(n);
            if (nc != null && (nc.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) || nc.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET))) {
                return n;
            }
        }
        return null;
    }

    @PluginMethod
    public void agBilgisi(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("wifi", false);
        try {
            ConnectivityManager cm = (ConnectivityManager) getContext().getSystemService(Context.CONNECTIVITY_SERVICE);
            Network n = wifiAgi();
            if (cm != null && n != null) {
                LinkProperties lp = cm.getLinkProperties(n);
                if (lp != null) {
                    for (LinkAddress la : lp.getLinkAddresses()) {
                        InetAddress a = la.getAddress();
                        if (a instanceof Inet4Address && !a.isLoopbackAddress()) {
                            ret.put("wifi", true);
                            ret.put("ip", a.getHostAddress());
                            ret.put("onEk", la.getPrefixLength());
                            break;
                        }
                    }
                }
            }
        } catch (Exception e) {
            // bilgi alınamazsa wifi=false döner
        }
        call.resolve(ret);
    }

    @PluginMethod
    public void gonderAl(final PluginCall call) {
        final JSArray paketler = call.getArray("paketler");
        final int port = call.getInt("port", 161);
        final int sure = Math.max(200, Math.min(15000, call.getInt("sureMs", 2500)));
        if (paketler == null) {
            call.reject("paketler gerekli");
            return;
        }
        new Thread(() -> {
            DatagramSocket soket = null;
            try {
                soket = new DatagramSocket();
                Network wifi = wifiAgi();
                if (wifi != null) {
                    // Wi-Fi'ın interneti yoksa Android trafiği mobil veriye yönlendirebilir: soketi Wi-Fi'a bağla
                    try {
                        wifi.bindSocket(soket);
                    } catch (Exception ignored) {
                    }
                }
                soket.setSoTimeout(100);
                List<JSONObject> liste = paketler.toList();
                int gonderilen = 0;
                for (JSONObject p : liste) {
                    try {
                        byte[] veri = Base64.decode(p.getString("veri"), Base64.NO_WRAP);
                        InetAddress adres = InetAddress.getByName(p.getString("ip"));
                        soket.send(new DatagramPacket(veri, veri.length, adres, port));
                    } catch (Exception ignored) {
                        // ulaşılamayan tek adres taramayı durdurmasın
                    }
                    if (++gonderilen % 32 == 0) Thread.sleep(4);
                }
                long bitis = System.currentTimeMillis() + sure;
                JSArray cevaplar = new JSArray();
                byte[] tampon = new byte[65535];
                while (System.currentTimeMillis() < bitis && cevaplar.length() < liste.size()) {
                    DatagramPacket dp = new DatagramPacket(tampon, tampon.length);
                    try {
                        soket.receive(dp);
                    } catch (SocketTimeoutException e) {
                        continue;
                    }
                    JSObject o = new JSObject();
                    o.put("ip", dp.getAddress().getHostAddress());
                    o.put("veri", Base64.encodeToString(dp.getData(), dp.getOffset(), dp.getLength(), Base64.NO_WRAP));
                    cevaplar.put(o);
                }
                JSObject ret = new JSObject();
                ret.put("cevaplar", cevaplar);
                call.resolve(ret);
            } catch (Exception e) {
                call.reject("Ağ hatası: " + e.getMessage());
            } finally {
                if (soket != null) soket.close();
            }
        }).start();
    }
}
