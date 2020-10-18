//
//  MeldingDetaljKontroller.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 28/07/2020.
//

import UIKit

class MeldingDetaljKontroller: UIViewController {

    @IBOutlet var textView: UITextView!
    
    var melding: Melding
    
    var stil: Cellstyle = lastInnCellestyle()
    
    @IBOutlet var lukkKnapp: UIButton!
    @IBOutlet var detaljLabel: UILabel!
    @IBOutlet var separator: UIProgressView!
    
    init(melding: Melding) {
        self.melding = melding
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "\(melding.timestamp) (\(melding.id))"
        textView.text = melding.melding
        
        lukkKnapp.addTarget(self, action: #selector(lukk), for: .touchUpInside)
        
        forfriskStil()
    }
    
    func forfriskStil() {
        self.stil = lastInnCellestyle()
        let stiil = CellstyleManager.manager(forStyle: self.stil)
        
        stiil.style(label: detaljLabel)
        
        textView.textColor = detaljLabel.textColor
        textView.font = detaljLabel.font
        
        detaljLabel.font = detaljLabel.font.withSize(22)
        lukkKnapp.tintColor = stiil.temafarge
        separator.trackTintColor = stiil.temafarge
        
        detaljLabel.text = "\(melding.timestamp) (\(melding.id))"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(YES, animated: NO)
    }
    
    @objc func lukk() {
        self.navigationController?.popViewController(animated: YES)
    }


}
