//
//  PickerCelle.swift
//  Vekeplan1_5
//
//  Created by Eskil Sviggum on 11/03/2020.
//  Copyright © 2020 SIGABRT. All rights reserved.
//

import UIKit

class PickerCelle: UITableViewCell {
    
    
    @IBOutlet var cellemembran: UIView!
    @IBOutlet var label: UILabel!
    @IBOutlet var bildeView: UIImageView!
    
    var data: String!
    
    var stil: CellstyleType = TraditionalCellstyle() {
        didSet {
            konfig()
        }
    }
    
    var valgt: Bool = NO
    var valdBilde = UIImage(systemName: "checkmark")
    final let animTid: Double = 0.25
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.cellemembran.layer.cornerRadius = 8
        
        konfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        konfig()
    }
    
    func konfig() {
        self.label.text = data
        stil.style(label: self.label)
        //bildeView.tintColor = .white
        
        if valgt {
            velg()
        }
    }
    
    func velg() {
        self.valgt = YES
        let tint = UIColor(named: "Cell")!
        bildeView.tintColor = tint
        UIView.transition(with: self.label, duration: animTid, options: .transitionCrossDissolve, animations: {
            self.label.textColor = tint
        }, completion: nil)
        UIView.animate(withDuration: animTid) {
            self.cellemembran.backgroundColor = self.stil.temafarge
            self.bildeView.image = self.valdBilde
        }
    }
    
    func avvelg() {
        self.valgt = NO
        UIView.transition(with: self.label, duration: animTid, options: .transitionCrossDissolve, animations: {
            self.label.textColor = self.stil.temafarge
        }, completion: nil)
        UIView.animate(withDuration: animTid) {
            self.cellemembran.backgroundColor = UIColor(named: "Cell")!
            self.label.textColor = self.stil.temafarge
            self.bildeView.image = nil
        }
    }
    
}
