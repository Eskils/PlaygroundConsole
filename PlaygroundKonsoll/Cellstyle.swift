//
//  Cellstyle.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 05/10/2020.
//

import UIKit

@objc protocol CellstyleType {
    func style(label: UILabel)
    func style(backg: UIView)
    func prefix() -> UIView?
    func height() -> CGFloat
    
    var temafarge: UIColor {get}
    var temafont: UIFont {get}
    var tittel: String {get}
    
    init()
}

fileprivate func consoledisplayStyle(forLabel label: UILabel, color: UIColor, backcolor: UIColor) {
    label.layer.shadowColor = color.cgColor
    label.layer.shadowRadius = 2
    label.layer.shadowOpacity = 0.4
}

//Traditional
class TraditionalCellstyle: CellstyleType {
    
    let tittel: String = "Traditional"
    let temafarge = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    let temafont = UIFont.monospacedSystemFont(ofSize: 17, weight: .regular)
    
    func prefix() -> UIView? {
        let labb = UILabel()
        labb.text = ">"
        labb.textColor = temafarge
        labb.font = temafont
        return labb
    }
    
    func style(label: UILabel) {
        label.textColor = temafarge
        label.font = temafont
        consoledisplayStyle(forLabel: label, color: temafarge, backcolor: UIColor(named: "ConsoleBack")!)
    }
    
    func style(backg: UIView) {
        backg.backgroundColor = .clear
    }
    
    func height() -> CGFloat {
        return 30
    }
    
    required init() {}
}

//Clean
class CleanCellstyle: CellstyleType {
    
    let tittel: String = "Clean"
    let temafarge = UIColor.white
    let temafont = UIFont.systemFont(ofSize: 17, weight: .regular)
    
    func prefix() -> UIView? {
        return nil
    }
    
    func style(label: UILabel) {
        label.textColor = temafarge
        label.font = temafont
    }
    
    func style(backg: UIView) {
        backg.backgroundColor = .systemFill
        backg.layer.cornerRadius = 8
    }
    
    func height() -> CGFloat {
        return 40
    }
    
    required init() {}
}

//Futuristic
class FuturisticCellstyle: CellstyleType {
    
    let tittel: String = "Futuristic"
    let temafarge = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    let temafont = UIFont(name: "Futura", size: 17)!
    
    func prefix() -> UIView? {
        let view = UIView()
        view.backgroundColor = temafarge
        view.layer.cornerRadius = 1.25
        view.widthAnchor.constraint(equalToConstant: 4).isActive = YES
        return view
    }
    
    func style(label: UILabel) {
        label.textColor = temafarge
        label.font = temafont
    }
    
    func style(backg: UIView) {
        backg.backgroundColor = .clear
    }
    
    func height() -> CGFloat {
        return 30
    }
    
    required init() {}
}

//Hacker
class HackerCellstyle: CellstyleType {
    
    let tittel: String = "H4CK3R"
    let temafarge = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    let temafont = UIFont.monospacedSystemFont(ofSize: 17, weight: .regular)
    
    func prefix() -> UIView? {
        let labb = UILabel()
        labb.text = "_"
        labb.textColor = temafarge
        labb.font = temafont
        return labb
    }
    
    func style(label: UILabel) {
        label.textColor = temafarge
        label.font = temafont
        consoledisplayStyle(forLabel: label, color: temafarge, backcolor: UIColor(named: "ConsoleBack")!)
    }
    
    func style(backg: UIView) {
        backg.backgroundColor = .clear
    }
    
    func height() -> CGFloat {
        return 30
    }
    
    required init() {}
}

enum Cellstyle: Int, CaseIterable {
    case futuristic
    case traditional
    case clean
    case hacker
}

func lastInnCellestyle() -> Cellstyle {
    let typ = ud?.string(forKey: "style") ?? "0"
    return Cellstyle(rawValue: Int(typ)!) ?? .traditional
}

var CellstyleClasses: [CellstyleType.Type] = [TraditionalCellstyle.self, FuturisticCellstyle.self, CleanCellstyle.self, HackerCellstyle.self]



class CellstyleManager {
    
    static func manager(forStyle style: Cellstyle) -> CellstyleType {
        return CellstyleClasses[style.rawValue].init()
    }
    
}
