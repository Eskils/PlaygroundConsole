//
//  InstructionsKontroller.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 07/10/2020.
//

import UIKit

class InstructionsKontroller: UIViewController {

    @IBOutlet var lukkKnapp: UIButton!
    @IBOutlet var separator: UIProgressView!
    @IBOutlet var instructsLabel: UILabel!
    
    @IBOutlet var instructCelleCopyCode: InstructCelle!
    @IBOutlet var instructCelleAddModule: InstructCelle!
    @IBOutlet var instructCelleImportAndPprint: InstructCelle!
    
    var stil = lastInnCellestyle()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        forfriskStil()
        
        instructCelleCopyCode.link = copyCode
        lukkKnapp.addTarget(self, action: #selector(self.lukk), for: .touchUpInside)
        
    }
    
    func forfriskStil() {
        self.stil = lastInnCellestyle()
        let stiil = CellstyleManager.manager(forStyle: self.stil)
        stiil.style(label: instructsLabel)
        instructsLabel.font = instructsLabel.font.withSize(22)
        //instructsLabel.font = instructsLabel.font
        lukkKnapp.tintColor = stiil.temafarge
        separator.trackTintColor = stiil.temafarge
        
        let instructsCeller = [instructCelleCopyCode, instructCelleAddModule, instructCelleImportAndPprint]
        
        instructsCeller.forEach {
            $0?.stilmanager = stiil
        }
        
        instructsLabel.text = "Instructions".localized
    }
    
    func copyCode() {
        guard let codeUrl = Bundle.main.url(forResource: "pprint", withExtension: "txt"),
              let codeData = try? Data(contentsOf: codeUrl),
              let code = String(data: codeData, encoding: .utf8)
        else { return }
        UIPasteboard.general.string = code
        
        let alert = UIAlertController(title: "Copied!".localized, message: nil, preferredStyle: .alert)
        self.present(alert, animated: YES) {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: NO) { (_) in
                alert.dismiss(animated: YES, completion: nil)
            }
        }
    }
    
    @objc func lukk() {
        self.dismiss(animated: YES, completion: nil)
    }

}
