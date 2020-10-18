//
//  SettingsKontroller.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 17/10/2020.
//

import UIKit

class SettingsKontroller: UIViewController {
    
    
    @IBOutlet var settingsLabel: UILabel!
    @IBOutlet var separator: UIProgressView!
    @IBOutlet var lukkKnapp: UIButton!
    
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var languagePicker: PickerView!
    
    @IBOutlet var styleLabel: UILabel!
    @IBOutlet var stylePicker: PickerView!
    
    var sender: KonsollKontroller?
    
    
    var stil = lastInnCellestyle()
    
    var pickerhandlers:[Int:(Int)->Void] = [:]
    var pickerdefaults:[Int:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        forfriskStil()
        
        lukkKnapp.addTarget(self, action: #selector(self.lukk), for: .touchUpInside)
        
        konfig()
        
        pickerhandlers = [0:languagePickerHandler(index:),
                          1:stylePickerHandler(index:)]
        
    }
    
    func konfig() {
        languagePicker.delegat = self
        languagePicker.identifier = 0
        
        stylePicker.delegat = self
        stylePicker.identifier = 1
        
        languagePicker.backgroundColor = .clear
        stylePicker.backgroundColor = .clear
        
        let stiil = CellstyleManager.manager(forStyle: self.stil)
        languagePicker.stil = stiil
        stylePicker.stil = stiil
        
        languagePicker.celler = LanguageManager.languageStrings() as! [String]
        stylePicker.celler = Cellstyle.allCases.compactMap { CellstyleManager.manager(forStyle: $0).tittel }
        
        pickerdefaults = [0: LanguageManager.currentLanguageIndex(),
                          1: lastInnCellestyle().rawValue]
        
        settingsLabel.text = "Settings".localized
        languageLabel.text = "Language".localized
        styleLabel.text = "Style".localized
    }
    
    @objc func languagePickerHandler(index: Int) {
        LanguageManager.saveLanguage(by: index)
        LanguageManager.setupCurrentLanguage()
        konfig()
        
        let langstr = LanguageManager.languageStrings()[index] as! String
        
        let alert = UIAlertController(title: langstr, message: "Start appen på nytt for endringane til å tre i kraft".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: nil))
        self.present(alert, animated: NO, completion: nil)
    }
    
    @objc func stylePickerHandler(index: Int) {
        ud?.setValue(index, forKey: "style")
        sender?.stil = lastInnCellestyle()
        sender?.oppdaterStil()
    }
    
    func forfriskStil() {
        self.stil = lastInnCellestyle()
        let stiil = CellstyleManager.manager(forStyle: self.stil)
        stiil.style(label: settingsLabel)
        stiil.style(label: languageLabel)
        stiil.style(label: styleLabel)
        settingsLabel.font = settingsLabel.font.withSize(22)
        //instructsLabel.font = instructsLabel.font
        lukkKnapp.tintColor = stiil.temafarge
        separator.trackTintColor = stiil.temafarge
        
        languagePicker.stil = stiil
        stylePicker.stil = stiil
    }
    
    @objc func lukk() {
        self.dismiss(animated: YES, completion: nil)
    }

}
