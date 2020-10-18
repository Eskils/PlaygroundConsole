//
//  PrintCelle.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 26/07/2020.
//

import UIKit

class PrintCelle: UITableViewCell {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var cellemembran: UIView!
    
    var melding: Melding!
    var farge: UIColor = .label
    
    var prefix: UIView?
    
    var stil : CellstyleType!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        konfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        konfig()
    }
    
    func konfig() {
        self.label.textColor = farge
        self.label.text = melding.melding
        
        stil.style(label: self.label)
        stil.style(backg: cellemembran)
        
        label.translatesAutoresizingMaskIntoConstraints = NO
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: cellemembran.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: cellemembran.trailingAnchor, constant: -4)
        ])
        DispatchQueue.main.async { [self] in
            //self.prefix?.removeFromSuperview()
            if let p = stil.prefix() {
                if self.prefix != nil { self.prefix?.isHidden = YES }
                    self.prefix = p
                    self.addSubview(self.prefix!)
                
                self.prefix?.translatesAutoresizingMaskIntoConstraints = NO
                NSLayoutConstraint.activate([
                    self.prefix!.leadingAnchor.constraint(equalTo: cellemembran.leadingAnchor, constant: 4),
                    self.prefix!.widthAnchor.constraint(lessThanOrEqualToConstant: 30),
                    self.prefix!.topAnchor.constraint(equalTo: cellemembran.topAnchor),
                    self.prefix!.bottomAnchor.constraint(equalTo: cellemembran.bottomAnchor),
                    label.leadingAnchor.constraint(equalTo: self.prefix!.trailingAnchor, constant: 4)
                ])
            } else {
                label.leadingAnchor.constraint(equalTo: cellemembran.leadingAnchor, constant: 4).isActive = YES
            }
        }
    }
    
}
