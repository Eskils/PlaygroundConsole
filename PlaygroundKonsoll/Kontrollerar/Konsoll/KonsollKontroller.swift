//
//  KonsollKontroller.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 26/07/2020.
//

import UIKit

enum Konsollstatus: String {
    case Inaktiv, Aktiv
    
    var knapptittel: String {
        get {
            switch self {
                case .Aktiv:
                    return "Stopp Konsoll"
                case .Inaktiv:
                    return "Start Konsoll"
            }
        }
    }
    
    var shortcutState: UIMenuElement.State {
        switch self {
            case .Aktiv:
                return .on
            case .Inaktiv:
                return .off
        }
    }
    
    var isOn : Bool {
        switch self {
            case .Aktiv:
                return YES
            case .Inaktiv:
                return NO
        }
    }
}

class KonsollKontroller: UIViewController, PPMotakarDelegat {
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "Kopier adresse".localized, image: UIImage(systemName: "doc.on.doc"), action: #selector(kopierAdresse), input: "c", modifierFlags: [.command, .shift],state: status.shortcutState),
            UIKeyCommand(title: "Rensk konsoll".localized, image: UIImage(systemName: "trash"), action: #selector(rensk), input: "e", modifierFlags: [.command]),
            UIKeyCommand(title: "Skru av/på sanntidsscrolling".localized, image: UIImage(systemName: "arrow.down.right"), action: #selector(toggleSanntidsscroll), input: "s", modifierFlags: [.alternate])
        ]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func mottokMelding(melding: Melding) {
        DispatchQueue.main.async { [self] in
            if meldingar.isEmpty { self.meldingar.append(melding); return }
            if meldingar.contains(where: { $0 == melding }) { return }
            let id = melding.timestamp
            for (i,mld) in meldingar.enumerated() {
                if mld.timestamp < id {
                    meldingar.insert(melding, at: meldingar.count-i)
                    break
                    
                }
            }
        }
    }
    
    func mottokKommando(kommando: KonsollKomando) {
        DispatchQueue.main.async {
            kommando.utfør(konsoll: self)
        }
    }
    
    
    var meldingar: [Melding] = [] {
        didSet {
            if !meldingar.isEmpty { taVekkInstructs() }
            oppdaterCeller(medSøkefrase: self.søkefrase)
        }
    }
    
    var celler: [Melding] = [] {
        didSet {
            tableView.reloadData()
            if skalScrolle {
                scrollTilBotn()
            }
        }
    }
    
    var stil : Cellstyle = lastInnCellestyle() {
        didSet {
            stilmanager = CellstyleManager.manager(forStyle: stil)
        }
    }
    var stilmanager: CellstyleType!
    
    ///Kva den skal filtrere meldingane på. Skal alltid vere med små bokstavar. Om tom vert alle meldingar passert gjennom.
    var søkefrase: String = "" {
        didSet {
            oppdaterCeller(medSøkefrase: søkefrase)
        }
    }
    
    func oppdaterCeller(medSøkefrase søkefrase: String) {
        if søkefrase == "" { celler = meldingar; return }
        celler = meldingar.filter { $0.melding.lowercased().contains(søkefrase) }
        
        if celler.isEmpty && !meldingar.isEmpty {
            let ingenResultatCelle = Melding(melding: "\("Fann ingen celler med".localized) „\(søkefrase)”")
            celler.append(ingenResultatCelle)
        }
    }
    
    var mottakar: PPMotakar!
    var avsendar: PPAvsendar?
    
    var skalScrolle: Bool = NO {
        didSet {
            if skalScrolle {
                scrollTilBotn()
            }
            sanntidsscrollToggle.isOn = skalScrolle
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var startKonsollKnapp: IkonifisertToggleKnapp!
    @IBOutlet var sanntidsscrollToggle: ToggleKnapp!
    
    @IBOutlet var bottomSeparator: UIProgressView!
    @IBOutlet var topSeparator: UIProgressView!
    
    @IBOutlet var søkefelt: KollapsbartTekstfelt!
    
    @IBOutlet var instructionsView: InstructionsCelle!
    
    @IBOutlet var intructionsKnapp: UIButton!
    
    @IBOutlet var tømKnapp: UIButton!
    
    @IBOutlet var settingsKnapp: UIButton!
    
    var status: Konsollstatus = .Inaktiv {
        didSet {
            DispatchQueue.main.async { [self] in
                statusLabel.text = self.status.rawValue.localized
                startKonsollKnapp.isOn = self.status.isOn
            }
        }
    }
    
    override func validate(_ command: UICommand) {
        if let fontStyleDict = command.propertyList as? [String: String] {
            // Check if the command comes from the Styles menu.
            if let fontStyle = fontStyleDict[keyCommands![1].title] {
                // Update the "Style" menu command state (checked or unchecked).
                command.state = status.shortcutState
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mottakar = PPMotakar.nyMottakar()
        
        let celle = UINib(nibName: "PrintCelle", bundle: nil)
        tableView.register(celle, forCellReuseIdentifier: "celle")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        søkefelt.felt.addTarget(self, action: #selector(søkEtterMelding(felt:)), for: .editingChanged)
        startKonsollKnapp.addTarget(self, action: #selector(startKonsoll), for: .touchUpInside)
        sanntidsscrollToggle.addTarget(self, action: #selector(toggleSanntidsscroll), for: .touchUpInside)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        for menuElement in keyCommands! {
            addKeyCommand(menuElement)
        }
        
        tableView.layer.cornerRadius = 12
        
        sanntidsscrollToggle.layer.cornerRadius = 25 / 2
        status = .Inaktiv
        skalScrolle = YES
        
        self.stil = lastInnCellestyle()
        
        oppdaterStil()
        
        startKonsoll()
        
        intructionsKnapp.addTarget(self, action: #selector(self.opneInstruksar), for: .touchUpInside)
        intructionsKnapp.isHidden = YES
        
        tømKnapp.addTarget(self, action: #selector(self.rensk), for: .touchUpInside)
        
        settingsKnapp.addTarget(self, action: #selector(opneSettings), for: .touchUpInside)
        
        #if targetEnvironment(macCatalyst)
        let recog = UILongPressGestureRecognizer(target: self, action: #selector(opneMeny))
        self.view.addGestureRecognizer(recog)
        self.tableView.addGestureRecognizer(recog)
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(YES, animated: NO)
        
        mottakar.abboner(self)
        
        instructionsView.alpha = 0
        instructionsView.link = opneInstruksar
        UIView.animate(withDuration: 0.3) {
            self.instructionsView.alpha = 1
        }
        
    }
    
    var harInterlacelinjer: Bool = NO
    
    func oppdaterStil() {
        guard let stiil = stilmanager else { return }
        stiil.style(label: startKonsollKnapp.titleLabel!)
        stiil.style(label: statusLabel)
        
        instructionsView.stilmanager = stiil
        
        søkefelt.felt.textColor = stiil.temafarge
        topSeparator.trackTintColor = stiil.temafarge
        bottomSeparator.trackTintColor = stiil.temafarge
        
        søkefelt.tint = stiil.temafarge
        søkefelt.felt.font = stiil.temafont
        
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        
        let knappar = [startKonsollKnapp, tømKnapp, sanntidsscrollToggle, søkefelt.knapp, intructionsKnapp, settingsKnapp]
        knappar.forEach {
            $0?.tintAdjustmentMode = .normal
            $0?.tintColor = stiil.temafarge
        }
        
        startKonsollKnapp.tint = stiil.temafarge
        intructionsKnapp.tintColor = stiil.temafarge
        tømKnapp.tintColor = stiil.temafarge
        sanntidsscrollToggle.tint = stiil.temafarge
        
        instructsKontroller?.forfriskStil()
        settingsKontroller?.forfriskStil()
        
        //removeInterlace()
        t1: if stil == .hacker || stil == .futuristic {
            //if harInterlacelinjer { break t1 }
            //interlacestyle()
        }
    }
    
    func interlacestyle() {
        let antal = 100
        let stripestep = (self.view.frame.height) / CGFloat(antal)
         for i in 0..<antal {
            let stripe = UIView()
            stripe.backgroundColor = UIColor(named: "ConsoleBack")!.withAlphaComponent(0.3)
            stripe.tag = 200
            self.view.addSubview(stripe)
            stripe.translatesAutoresizingMaskIntoConstraints = NO
            NSLayoutConstraint.activate([
                stripe.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                stripe.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stripe.heightAnchor.constraint(equalToConstant: 2),
                stripe.topAnchor.constraint(equalTo: view.topAnchor, constant: CGFloat(i) * stripestep)
            ])
         }
        harInterlacelinjer = YES
    }
    
    func removeInterlace() {
        for sub in self.view.subviews {
            if sub.tag == 200 { sub.removeFromSuperview() }
        }
    }
    
    func taVekkInstructs() {
        if instructionsView.isHidden { return }
        
        intructionsKnapp.alpha = 0
        intructionsKnapp.isHidden = NO
        
        UIView.animate(withDuration: 0.3) {
            self.instructionsView.alpha = 0
            self.intructionsKnapp.alpha = 1
        } completion: { (_) in
            self.instructionsView.isHidden = YES
        }
        
        instructsKontroller?.dismiss(animated: YES, completion: nil)
        
    }
    
    func disableTable() {
        tableView.visibleCells.forEach {
            ($0 as? PrintCelle)?.grå()
        }
        tableView.isMultipleTouchEnabled = NO
    }
    
    func activateTable() {
        rensk()
        tableView.isMultipleTouchEnabled = NO
    }
    
    @objc func startKonsoll() {
        switch status {
            case .Aktiv:
                //STOPP
                mottakar.avsluttAvlytting()
                status = .Inaktiv
                avsendar = nil
                disableTable()
            case .Inaktiv:
                //START
                status = .Aktiv
                activateTable()
                mottakar.startAvlytting { [self] (u) in
                    DispatchQueue.main.async {
                        guard let url = u else { statusLabel.text = "Kunne ikkje starte. Kanskje ein tjenar allereie kjøyrer?".localized; return }
                        avsendar = PPAvsendar(url: url)
                        statusLabel.text = "\("Konsoll aktiv på".localized) \(url.absoluteString)"
                    }
                }
        }
    }
    
    var instructsKontroller: InstructionsKontroller?
    @objc func opneInstruksar() {
        if (instructsKontroller == nil) { instructsKontroller = InstructionsKontroller() }
        instructsKontroller?.modalPresentationStyle = .formSheet
        self.present(instructsKontroller!, animated: YES, completion: nil)
    }
    
    var settingsKontroller: SettingsKontroller?
    @objc func opneSettings() {
        if (settingsKontroller == nil) { settingsKontroller = SettingsKontroller() }
        settingsKontroller?.modalPresentationStyle = .formSheet
        settingsKontroller?.sender = self
        self.present(settingsKontroller!, animated: YES, completion: nil)
    }
    
    @objc func søkEtterMelding(felt: UITextField) {
        let tekst = felt.text ?? ""
        
        søkefrase = tekst.lowercased()
    }
    
    @objc func kopierAdresse() {
        UIPasteboard.general.string = "\(mottakar.webTjenar.url ?? URL(string: "example.com")!)"
    }
    
    @objc func rensk() {
        self.meldingar = []
    }
    
    @objc func toggleSanntidsscroll() {
        skalScrolle = !skalScrolle
    }
    
    @objc func opneMeny() {
        let alert = UIAlertController(title: "Vel ein handling".localized, message: nil, preferredStyle: .alert)
        for meny in keyCommands! {
            let act = UIAlertAction(title: meny.title, style: .default, handler: { (action) in
                self.perform(meny.action)
            })
                
            if let image = meny.image {
                act.setValue(image, forKey: "image")
            }
            
            alert.addAction(act)
        }
        
        alert.addAction(UIAlertAction(title: "Avbryt".localized, style: .cancel, handler: nil))
        
        self.present(alert, animated: YES, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        søkefelt.felt.endEditing(YES)
    }


}
