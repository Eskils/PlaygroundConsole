//
//  InstructCelle.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 07/10/2020.
//

import UIKit

class InstructCelle: UIView {

    var label: UILabel!
    var image: UIImageView!
    
    @IBInspectable var link: (()->Void)?
    @IBInspectable var ikon: UIImage? = UIImage(systemName: "chevron.left.slash.chevron.right")! {
        didSet {
            image.image = ikon
        }
    }
    @IBInspectable var text: String? = "" {
        didSet {
            label.text = text
        }
    }
    @IBInspectable var stilmanager: CellstyleType? {
        didSet {
            stilmanager?.style(label: label)
            image.tintColor = stilmanager?.temafarge ?? .blue
        }
    }
    
    init(stil: CellstyleType, link: (()->Void)?) {
        self.link = link
        self.stilmanager = stil
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.layer.cornerRadius = 12
        self.backgroundColor = .clear//UIColor(named: "Cell")!
        
        label = UILabel()
        label.text = text
        label.textAlignment = .left
        stilmanager?.style(label: label)
        
        image = UIImageView()
        image.image = ikon
        image.contentMode = .scaleAspectFit
        image.tintColor = stilmanager?.temafarge ?? .blue
        
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = NO
        
        self.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = NO
        
        //Image constarints
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            image.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            image.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            image.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
        
        image.clipsToBounds = YES
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 12
        
        //Label constarints
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            label.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Om tid, sjekk at touchen blei avslutta inni viewen.
        link?()
    }


}
