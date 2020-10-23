//
//  Tjenar.swift
//  Tjenar
//
//  Created by Eskil Sviggum on 27/09/2020.
//

import Foundation

enum SpessChar: UInt8 {
    case newline = 10
    case carriageReturn = 13
    case null = 0
}

public struct TjenarResponsHandler {
    public var completion: ((String?)->Void)? = nil
    public var svar: ((String?)->String)? = nil
    public var status: String?=nil
    public var headers: [String:String]? = nil
    
    public init(completion: @escaping ((String?)->Void)) {
        self.completion = completion
    }
    
    public init(svar: @escaping ((String?)->String)) {
        self.svar = svar
    }
    
    public init(completion: @escaping ((String?)->Void), svar: @escaping ((String?)->String)) {
        self.completion = completion
        self.svar = svar
    }
    
    internal mutating func setStatus(_ status: String?) {
        self.status = status
    }
    
    internal mutating func setHeaders(_ headers: [String:String]?) {
        self.headers = headers
    }
}

public enum Tjenarfeil: Error {
    case kjøyrerAllereie
    case ukjend
}

public class Tjenar {
    
    private static let transportMetode = SOCK_STREAM
    private static let internetProtocoll = AF_INET
    //(label: "com.skillbreak.Tjenar", qos: .default)
    private static let kø = DispatchQueue(label: "com.skillbreak.Tjenar", qos: .default, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    public var responsHandler: TjenarResponsHandler?
    public var isRunning: Bool = false
    public var error: Tjenarfeil?
    public var url: URL? {
        
        if !isRunning { return nil }
        
        var grensesnitt: UnsafeMutablePointer<ifaddrs>? = nil
        getifaddrs(&grensesnitt)
        var addresse: String? = nil
        for ptr in sequence(first: grensesnitt!, next: { $0.pointee.ifa_next }) {
            let addr = ptr.pointee.ifa_addr.pointee
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
            //let addr = addrb.flatMap { Character(Unicode.Scalar(Int($0.pointee))!) }
            let addrStr = String(cString: hostname)
            
            //Tungvinnt måte å sjekke for IPv4 && interfaceName [0] == "e"(101), [2] == "0"(48)
            if addr.sa_family == UInt8(AF_INET) && ptr.pointee.ifa_name.pointee == 101 && ptr.pointee.ifa_name.successor().successor().pointee == 48 { addresse = addrStr; break}
        }
        
        return URL(string: "http://\(addresse ?? "localhost"):\(socketPort ?? 8080)")!
    }
    
    private var sock: Int32? = nil
    private var socketPort: UInt16? = nil
    
    
    public init() {}
    
    //DEKODING AV SOCKET
    
    private func dekodSokk(client: Int32) -> [String:String] {
        var headerDict: [String:String] = [:]
        
        let status = lesLinjeISokk(client: client)
        headerDict["__stat__"] = status
        
        let headers = lesSokk(client: client)
        let splittar = headers.split(separator: "\n")
        for splitt in splittar {
            let kutt = splitt.split(separator: ":")
            let key = String(kutt[0])
            var val = String(kutt[1])
            if val.first == " " { val.removeFirst() }
            headerDict[key] = val
        }
        
        if let len = headerDict["Content-Length"] {
            let data = lesBytesISokk(client: client, antal: Int(len) ?? 0)
            headerDict["__data__"] = data
        }
        
        return headerDict
    }
    
    private func lesBytesISokk(client: Int32, antal: Int) -> String {
        var offset: Int = 0
        let antalMaks = 1024
        let maksAntalTilLesing = offset + antalMaks < antal ? antalMaks : antal
        var bytes : [UInt8] = Array<UInt8>(repeating: 0, count: maksAntalTilLesing)
        var res: String = ""
        
        while offset < antal {
            
            let antalTilLesing = offset + antalMaks < antal ? antalMaks : antal - offset
            let antalLest = read(client, &bytes, antalTilLesing)
            for byte in bytes {
                if byte == 0 { break }
                res.append(Character(Unicode.Scalar(byte)))
            }
            offset += antalLest
        }
        return res
    }
    
    private func lesLinjeISokk(client: Int32) -> String {
        var res:String = ""
        
        var idx:UInt8 = 0
        
        repeat {
            var byte : UInt8 = 0
            read(client, &byte, 1)
            idx = byte
            if idx > SpessChar.carriageReturn.rawValue { res.append(Character(Unicode.Scalar(idx))) }
        } while idx != SpessChar.newline.rawValue
        
        return res
    }
    
    private func lesSokk(client: Int32) -> String {
        var res: String = ""
        while case let lin = lesLinjeISokk(client: client), !lin.isEmpty {
            res += lin + "\n"
        }
        return res
    }

    ///Starts the server on specified port. When the server is up and running, the handler is called with a bool as a parameter to indicate whether the setup was successful — which for the case if not, the error will be set to the instance-property `error`.
    public func start(port: UInt16? = nil, handler: @escaping (Bool)->Void) {
        self.error = nil
        if sock != nil { print("Kunne ikkje starte tjenar grunna med at ein socket allereie lyttar."); self.error = .kjøyrerAllereie; return }
        self.sock = socket(Tjenar.internetProtocoll, Tjenar.transportMetode, 0)
        let port = port ?? 80
        self.socketPort = port
        
        let socklen = UInt8(socklen_t(MemoryLayout<sockaddr_in>.size))
        var address = sockaddr_in()
        address.sin_family = sa_family_t(Tjenar.internetProtocoll)
        address.sin_port = in_port_t(((port << 8) + (port >> 8)))
        address.sin_addr = in_addr(s_addr: in_addr_t(0))
        address.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        
        var pntr2: Int32 = 1
        setsockopt(self.sock!, SOL_SOCKET, SO_REUSEADDR, &pntr2, socklen_t(MemoryLayout<Int>.size))
        
        let res = withUnsafePointer(to: &address) { (pointAddress) -> Bool in
            let pntr = UnsafeRawPointer(pointAddress).assumingMemoryBound(to: sockaddr.self)
            let bindres = bind(sock!, pntr, socklen_t(socklen))
            
            if bindres == -1 {
                print("Kunne ikkje binde adresse, feil: ", String(cString: strerror(errno)), errno)
                if errno == 48 {
                    self.error = .kjøyrerAllereie
                } else {
                    self.error = .ukjend
                }
                self.isRunning = false
                return false
            }
            
            return true
        }
        
        if !res {
            handler(false)
            return
        }
        
        Tjenar.kø.async { [self] in
            listen(sock!, 5)
            self.isRunning = true
            
            handler(true)
            
            print("Tjenar lyttar på port \(port)")
            
            repeat {
                let client = accept(sock!, nil, nil)
                if client == -1 { break }
                let req = self.dekodSokk(client: client)
                var data: String? = nil
                data = req["__data__"]
                self.responsHandler?.setStatus(req["__stat__"])
                self.responsHandler?.setHeaders(req)
                let resp = (self.responsHandler?.svar?(data)) ?? ":’)"
                let httpResponse: String = """
    HTTP/1.1 200 OK
    server: PlaygroundKonsoll
    content-length: \(resp.count)

    \(resp)
    """
                httpResponse.withCString { bytes in
                    send(client, bytes, Int(strlen(bytes)), 0)
                    close(client)
                    self.responsHandler?.completion?(data)
                }
            } while sock != nil && sock! > -1
            self.isRunning = false
        }
    }
    
    public func stop() {
        self.isRunning = false
        guard let sock = sock else { return }
        close(sock)
        self.sock = nil
    }
}
