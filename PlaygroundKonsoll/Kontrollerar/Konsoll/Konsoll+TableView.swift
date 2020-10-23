//
//  Konsoll+TableView.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 26/07/2020.
//

import UIKit


extension KonsollKontroller: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return celler.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let celle = tableView.dequeueReusableCell(withIdentifier: "celle") as? PrintCelle else { fatalError() }
        
        celle.melding = celler[indexPath.row]
        celle.erGrå = self.status == .Inaktiv
        celle.stil = CellstyleManager.manager(forStyle: stil)
        
        return celle
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return stilmanager.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let celle = tableView.cellForRow(at: indexPath) as? PrintCelle else { return }
        let melding = celle.melding!
        
        let detalj = MeldingDetaljKontroller(melding: melding)
        self.navigationController?.pushViewController(detalj, animated: YES)
    }
    
    func scrollTilBotn() {
        if celler.isEmpty { return }
        tableView.scrollToRow(at: IndexPath(row: celler.count-1, section: 0), at: .bottom, animated: NO)
    }
 
    /*func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y < scrollView.contentOffset.y {
            skalScrolle = NO
        }
    }*/
    
}
