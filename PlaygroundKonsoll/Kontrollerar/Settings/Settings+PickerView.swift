//
//  Settings+PickerView.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 17/10/2020.
//

import UIKit

extension SettingsKontroller: PickerViewDelegat {
    
    func pickerView(_ pickerView: Int, valdeCelle celle: String, indeks: Int) {
        guard let sel = pickerhandlers[pickerView] else { return }
        sel(indeks)
    }
    
    func pickerViewCelleVald(_ pickerView: Int, erCelleVald index: Int) -> ObjCBool {
        let valdidx = pickerdefaults[pickerView]
        return ObjCBool(index == valdidx)
    }
    
}
