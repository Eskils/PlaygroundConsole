//
//  PickerView.swift
//  Vekeplan1_5
//
//  Created by Eskil Sviggum on 11/03/2020.
//  Copyright © 2020 SIGABRT. All rights reserved.
//

import UIKit

class PickerView: UIView, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet var contentView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var celler: [String] = []
    var delegat: PickerViewDelegat?
    var valdCelle: PickerCelle?
    
    let impactor = UISelectionFeedbackGenerator()
    let radhøgd : CGFloat = 50
    
    var identifier: Int = 0
    
    var stil: CellstyleType! = TraditionalCellstyle() {
        didSet {
            tableView.visibleCells.forEach {
                ($0 as? PickerCelle)?.stil = self.stil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialiser()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialiser()
    }
    
    func initialiser() {
        Bundle.main.loadNibNamed("PickerView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = NO
        
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = YES
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = YES
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = YES
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = YES
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        let PickerCelleNib = UINib(nibName: "PickerCelle", bundle: nil)
        tableView.register(PickerCelleNib, forCellReuseIdentifier: "celle")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}
