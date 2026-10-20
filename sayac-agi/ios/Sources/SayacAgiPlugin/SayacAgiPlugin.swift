import Foundation
import Capacitor
import Darwin

/// Yerel ağdaki yazıcılarla SNMP konuşmak için ham UDP gönder/al.
/// SNMP paketleri JavaScript tarafında hazırlanır ve çözülür; burada yalnızca ağ işi yapılır.
@objc(SayacAgiPlugin)
public class SayacAgiPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SayacAgiPlugin"
    public let jsName = "SayacAgi"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "gonderAl", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "agBilgisi", returnType: CAPPluginReturnPromise)
    ]

    @objc func agBilgisi(_ call: CAPPluginCall) {
        var sonuc: [String: Any] = ["wifi": false]
        var ilk: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ilk) == 0, let ilk = ilk {
            var p: UnsafeMutablePointer<ifaddrs>? = ilk
            while let a = p {
                let arayuz = a.pointee
                let ad = String(cString: arayuz.ifa_name)
                if ad == "en0", let adr = arayuz.ifa_addr, adr.pointee.sa_family == UInt8(AF_INET) {
                    var ipMetni = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                    var sin = adr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
                    inet_ntop(AF_INET, &sin.sin_addr, &ipMetni, socklen_t(INET_ADDRSTRLEN))
                    sonuc["wifi"] = true
                    sonuc["ip"] = String(cString: ipMetni)
                    if let maske = arayuz.ifa_netmask {
                        let m = maske.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
                        sonuc["onEk"] = UInt32(bigEndian: m.sin_addr.s_addr).nonzeroBitCount
                    }
                    break
                }
                p = arayuz.ifa_next
            }
            freeifaddrs(ilk)
        }
        call.resolve(sonuc)
    }

    @objc func gonderAl(_ call: CAPPluginCall) {
        guard let paketler = call.getArray("paketler", JSObject.self) else {
            call.reject("paketler gerekli")
            return
        }
        let port = UInt16(call.getInt("port") ?? 161)
        let sure = max(200, min(15000, call.getInt("sureMs") ?? 2500))

        DispatchQueue.global(qos: .userInitiated).async {
            let fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
            if fd < 0 {
                call.reject("Soket açılamadı")
                return
            }
            defer { close(fd) }
            var tv = timeval(tv_sec: 0, tv_usec: 100_000)
            setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))

            var gonderilen = 0
            for p in paketler {
                guard let ip = p["ip"] as? String, let b64 = p["veri"] as? String, let veri = Data(base64Encoded: b64) else { continue }
                var hedef = sockaddr_in()
                hedef.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
                hedef.sin_family = sa_family_t(AF_INET)
                hedef.sin_port = port.bigEndian
                guard inet_pton(AF_INET, ip, &hedef.sin_addr) == 1 else { continue }
                _ = veri.withUnsafeBytes { tampon in
                    withUnsafePointer(to: &hedef) { ptr in
                        ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sa in
                            sendto(fd, tampon.baseAddress, veri.count, 0, sa, socklen_t(MemoryLayout<sockaddr_in>.size))
                        }
                    }
                }
                gonderilen += 1
                if gonderilen % 32 == 0 { usleep(4000) }
            }

            var cevaplar: [[String: Any]] = []
            let bitis = Date().addingTimeInterval(Double(sure) / 1000.0)
            var tampon = [UInt8](repeating: 0, count: 65535)
            while Date() < bitis && cevaplar.count < paketler.count {
                var kaynak = sockaddr_in()
                var uzunluk = socklen_t(MemoryLayout<sockaddr_in>.size)
                let n = withUnsafeMutablePointer(to: &kaynak) { ptr in
                    ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sa in
                        recvfrom(fd, &tampon, tampon.count, 0, sa, &uzunluk)
                    }
                }
                if n <= 0 { continue }
                var ipMetni = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                inet_ntop(AF_INET, &kaynak.sin_addr, &ipMetni, socklen_t(INET_ADDRSTRLEN))
                cevaplar.append([
                    "ip": String(cString: ipMetni),
                    "veri": Data(tampon[0..<n]).base64EncodedString()
                ])
            }
            call.resolve(["cevaplar": cevaplar])
        }
    }
}
