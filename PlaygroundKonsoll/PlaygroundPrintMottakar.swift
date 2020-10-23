//
//  PlaygroundPrintMottakar.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 26/07/2020.
//

import Foundation
import WebKit
import Tjenar

extension KonsollKomando {
    func utfør(konsoll: KonsollKontroller) {
        switch self {
            case .tøm:
                konsoll.rensk()
            case .skrollingPå:
                konsoll.skalScrolle = YES
            case .skrollingAv:
                konsoll.skalScrolle = NO
            case .forfriskTema:
                konsoll.stil = lastInnCellestyle()
                konsoll.oppdaterStil()
        }
    }
}

public protocol PPMotakarDelegat {
    func mottokMelding(melding: Melding)
    func mottokKommando(kommando: KonsollKomando)
}

public class PPMotakar {
    
    fileprivate init() {
        lagWebtjenar()
    }
    private var abbonentar: [PPMotakarDelegat] = []
    
    var henteHash: Int = 0
    var webTjenar: Tjenar!
    
    public var meldingar: [String] = []
    
    private func dekodMelding<T:Sendable>(data: String, type: T.Type) -> T? {
        do {
            let dekoda = try JSONDecoder().decode(type, from: data.data(using: .utf8)!)
            return dekoda
        } catch {
            print(error)
            return nil
        }
    }
    
    func lagWebtjenar() {
        webTjenar = Tjenar()
        webTjenar.responsHandler = TjenarResponsHandler(svar: { (data) -> String in
            guard let data = data else { return "No data." }
            if let melding = self.dekodMelding(data: data, type: Melding.self) {
                self.abbonentar.forEach { $0.mottokMelding(melding: melding) }
                return "Mtk: \(melding.id)"
            }else if let kommando = self.dekodMelding(data: data, type: KonsollKomando.self) {
                self.abbonentar.forEach { $0.mottokKommando(kommando: kommando) }   
                return "MtkCmd: \(kommando.rawValue)"
            }
            return "Could not decode message. The data needs to be encoded using UTF-8, and sent in the body of a POST-request."
        })
    }
    
    
    public func startAvlytting(fullføring: @escaping (URL?)->Void) {
        if webTjenar.isRunning { fullføring(webTjenar.url) ;return }
        webTjenar.start() { (success) in
            if !success {
                print("Error med start webTjenar, ", self.webTjenar.error)
            }
            fullføring(self.webTjenar.url)
        }
    }
    
    public func avsluttAvlytting() {
        if webTjenar.isRunning {
            webTjenar.stop()
        }
    }
    
}


extension PPMotakar {
    public class func nyMottakar() -> PPMotakar {
        return PPMotakar()
    }
    
    public func abboner(_ delegat: PPMotakarDelegat) {
        abbonentar.append(delegat)
    }
}
