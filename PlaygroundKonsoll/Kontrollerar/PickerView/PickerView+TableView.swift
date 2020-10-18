
//
//  PickerView+TableView.swift
//  Vekeplan1_5
//
//  Created by Eskil Sviggum on 11/03/2020.
//  Copyright © 2020 SIGABRT. All rights reserved.
//

import UIKit

@objc protocol PickerViewDelegat {
    func pickerView(_ pickerView: Int, valdeCelle celle: String, indeks: Int)
    @objc optional func pickerView(_ pickerView: Int, bildeForCelle index: Int) -> UIImage?
    
    @objc optional func pickerViewCelleVald(_ pickerView: Int, erCelleVald index: Int) -> ObjCBool
}

extension PickerView {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let antal = celler.count
        let tableHøgd = (radhøgd * CGFloat(celler.count)) + 8
        
        tableView.fjernConstraints(.height)
        tableView.heightAnchor.constraint(equalToConstant: tableHøgd).isActive = YES
        
        return antal
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celle = tableView.dequeueReusableCell(withIdentifier: "celle") as! PickerCelle
        
        celle.data = celler[indexPath.row].localized
        if let bilde = delegat?.pickerView?(self.identifier, bildeForCelle: indexPath.row) {
            celle.bildeView.image = bilde
            celle.bildeView.isHidden = NO
            celle.bildeView.tintColor = self.stil.temafarge
        }
        
        celle.stil = self.stil
        
        if let vald = delegat?.pickerViewCelleVald?(self.identifier, erCelleVald: indexPath.row) {
            if vald.boolValue {
                celle.valgt = YES
                self.valdCelle = celle
            }
        }
        
        return celle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let celle = tableView.cellForRow(at: indexPath) as! PickerCelle
        if valdCelle == celle { return }
        let data = celle.data
        
        celle.velg()
        valdCelle?.avvelg()
        
        self.valdCelle = celle
        self.delegat?.pickerView(self.identifier, valdeCelle: data!, indeks: indexPath.row)
        impactor.selectionChanged()
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let celle = tableView.cellForRow(at: indexPath) as! PickerCelle
        if celle.valgt { return }
        celle.cellemembran.backgroundColor = UIColor(named: "SelectedCell")!
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let celle = tableView.cellForRow(at: indexPath) as! PickerCelle
        if celle.valgt { return }
        celle.cellemembran.backgroundColor = UIColor(named: "Cell")!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return radhøgd
    }
    
}
