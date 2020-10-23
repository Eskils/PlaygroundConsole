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
    
    var prefix: PrefixView?
    
    var stil : CellstyleType! {
        didSet {
            self.oppdaterStiil()
        }
    }
    
    var erGrå: Bool = NO
    
    var labelLeadingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: cellemembran.leadingAnchor, constant: 4)
        labelLeadingConstraint.isActive = YES
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        konfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        //konfig()
    }
    
    func konfig() {
        self.label.text = melding.melding
        
        stil.style(label: self.label)
        stil.style(backg: cellemembran)
        
        if erGrå {
            self.grå()
        }
        
        label.translatesAutoresizingMaskIntoConstraints = NO
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: cellemembran.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: cellemembran.trailingAnchor, constant: -4)
        ])
        DispatchQueue.main.async {
            self.addPrefixview()
        }
    }
    
    func addPrefixview() {
        let p = stil.prefix()
            if self.prefix != nil {
                //if self.prefix?.view.superview != nil {
                    self.prefix?.view.removeFromSuperview();
                //}
                self.prefix = nil;
                
            }//self.prefix?.view.isHidden = YES }
            self.prefix = p
        guard let pView = prefix?.view else { labelLeadingConstraint.isActive = YES; return }
            self.cellemembran.addSubview(pView)
        
        labelLeadingConstraint.isActive = NO
            
            pView.translatesAutoresizingMaskIntoConstraints = NO
            NSLayoutConstraint.activate([
                pView.leadingAnchor.constraint(equalTo: cellemembran.leadingAnchor, constant: 4),
                pView.widthAnchor.constraint(lessThanOrEqualToConstant: 20),
                pView.topAnchor.constraint(equalTo: cellemembran.topAnchor),
                pView.bottomAnchor.constraint(equalTo: cellemembran.bottomAnchor),
                pView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -4)
            ])
    }
    
    func oppdaterStiil() {
        stil.style(label: self.label)
        stil.style(backg: cellemembran)
        addPrefixview()
        
        if erGrå {
            self.grå()
        }
    }
    
    func grå() {
        let farge = UIColor.systemGray2
        self.label.textColor = farge
        self.prefix?.endreFarge(farge)
        self.erGrå = YES
    }
    
    func avgrå() {
        self.erGrå = NO
        konfig()
    }
    
}
