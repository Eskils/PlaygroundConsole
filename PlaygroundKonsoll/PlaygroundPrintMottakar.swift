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
            guard let data = data else { return "Ingen data." }
            if let melding = self.dekodMelding(data: data, type: Melding.self) {
                self.abbonentar.forEach { $0.mottokMelding(melding: melding) }
                return "Mtk: \(melding.id)"
            }else if let kommando = self.dekodMelding(data: data, type: KonsollKomando.self) {
                self.abbonentar.forEach { $0.mottokKommando(kommando: kommando) }   
                return "MtkCmd: \(kommando.rawValue)"
            }
            return "Kunne ikkje dekode melding. Du må lage ein POST-request med meldingen som data i http-bodyen enkoda med UTF-8."
        })
    }
    
    
    public func startAvlytting() -> URL? {
        if webTjenar.isRunning { return webTjenar.url }
        webTjenar.start()
        //webTjenar.start(withPort: 8080, bonjourName: "PlaygroundKonsoll")
        
        return webTjenar.url
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
