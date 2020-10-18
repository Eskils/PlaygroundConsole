//
//  Designables.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 28/07/2020.
//

import UIKit

extension UIView {
    
    func constraints(affectingLayoutFor attribute: NSLayoutConstraint.Attribute) -> [NSLayoutConstraint] {
        var res: [NSLayoutConstraint] = []
        for constraint in self.constraints {
            if constraint.firstAttribute == attribute {
                res.append(constraint)
            }
        }
        return res
    }
    
        func fjernConstraints(_ attributt: NSLayoutConstraint.Attribute) {
            var tilFjerning: [NSLayoutConstraint] = []
            for constraint in self.constraints {
                if constraint.firstAttribute == attributt || constraint.secondAttribute == attributt {
                    tilFjerning.append(constraint)
                }
            }
            self.removeConstraints(tilFjerning)
        }
    
}

extension String {
    var localized : String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UIColor {
    func whiter(level: CGFloat = 1) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var l: CGFloat = 0
        
        self.getHue(&h, saturation: &s, brightness: &l, alpha: nil)
        
        return UIColor(hue: h, saturation: s - (0.05 * level), brightness: l + (0.1 * level), alpha: 1.0)
    }
    
    func blacker(level: CGFloat = 1) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var l: CGFloat = 0
        
        self.getHue(&h, saturation: &s, brightness: &l, alpha: nil)
        
        return UIColor(hue: h, saturation: s + (0.15 * level), brightness: l - (0.1 * level), alpha: 1.0)
    }
    
    func darker(level: CGFloat = 1) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var l: CGFloat = 0
        
        self.getHue(&h, saturation: &s, brightness: &l, alpha: nil)
        
        return UIColor(hue: h, saturation: s + (0.1 * level), brightness: l - (0.2 * level), alpha: 1.0)
    }
}

@IBDesignable class ToggleKnapp: UIButton {
    @IBInspectable var isOn: Bool = NO {
        didSet {
            konfig()
        }
    }
    @IBInspectable var tint: UIColor = .blue {
        didSet {
            konfig()
        }
    }
    @IBInspectable var background: UIColor = .clear
    @IBInspectable var backgroundIsOpaque: Bool = YES
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        konfig()
    }
    
    func konfig() {
        switch isOn {
            case true:
                self.backgroundColor = tint
                self.tintColor = background.withAlphaComponent(1)
            case false:
                self.backgroundColor = backgroundIsOpaque ? background : background.withAlphaComponent(0)
                self.tintColor = tint
        }
    }
}

@IBDesignable class IkonifisertToggleKnapp: UIButton {
    @IBInspectable var isOn: Bool = NO {
        didSet {
            konfig()
        }
    }
    @IBInspectable var tint: UIColor = .blue {
        didSet {
            konfig()
        }
    }
    @IBInspectable var background: UIColor = .clear
    @IBInspectable var backgroundIsOpaque: Bool = YES
    @IBInspectable var offImage: UIImage?
    @IBInspectable var onImage: UIImage?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        konfig()
    }
    
    func konfig() {
        switch isOn {
            case true:
                //self.backgroundColor = tint
                self.tintColor = tint
                self.setImage(onImage, for: .normal)
            case false:
                //self.backgroundColor = backgroundIsOpaque ? background : background.withAlphaComponent(0)
                self.tintColor = tint
                self.setImage(offImage, for: .normal)
        }
    }
}

@IBDesignable class IconifisertTextField: UITextField {
    
    @IBInspectable var ikon: UIImage = UIImage() {
        didSet {
            iconView.image = ikon
        }
    }
    
    private var iconView: UIImageView!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        iconView = UIImageView()
        iconView.tag = 128
        self.viewWithTag(128)?.removeFromSuperview()
        self.addSubview(iconView)
        
        iconView.translatesAutoresizingMaskIntoConstraints = NO
        
        iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4).isActive = YES
        iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = YES
        iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = YES
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = YES
        
        iconView.image = ikon
        iconView.tintColor = .lightGray
    }
    
    private var textInsets: UIEdgeInsets {
        let leadingAnchor = 4 + self.frame.height - 8
        return UIEdgeInsets(top: 2, left: leadingAnchor, bottom: 2, right: 4)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func drawPlaceholder(in rect: CGRect) {
        super.drawPlaceholder(in: rect)
        for sub in self.subviews {
            if NSClassFromString("UITextFieldLabel") == sub.classForCoder {
                (sub as? UILabel)?.textColor = .lightGray
            }
        }
        
    }
}

@IBDesignable class Tekstfelt: UITextField {
    
    @IBInspectable var placeholderColor: UIColor? = .placeholderText
    @IBInspectable var leadingInset: CGFloat = 4
    @IBInspectable var trailingInset: CGFloat = 4
    
    private var textInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: leadingInset, bottom: 2, right: trailingInset)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func drawPlaceholder(in rect: CGRect) {
        super.drawPlaceholder(in: rect)
        for sub in self.subviews {
            if NSClassFromString("UITextFieldLabel") == sub.classForCoder {
                (sub as? UILabel)?.textColor = placeholderColor
            }
        }
        
    }
    
}

@IBDesignable class KollapsbartTekstfelt: UIView, CAAnimationDelegate {
    @IBInspectable var tint: UIColor = .blue {
        didSet {
            konfig()
        }
    }
    @IBInspectable var background: UIColor = .clear
    @IBInspectable var isExpanded: Bool = YES
    @IBInspectable var icon: UIImage? {
        didSet {
            konfig()
        }
    }
    @IBInspectable var closeIcon: UIImage? {
        didSet {
            konfig()
        }
    }
    
    @IBInspectable var placeholder: String? {
        didSet {
            konfig()
        }
    }
    
    @IBInspectable var expandableWidth: CGFloat = 200 {
        didSet {
            konfig()
        }
    }
    
    public var knapp: UIButton!
    public var felt: Tekstfelt!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        knapp = UIButton()
        felt = Tekstfelt()
        
        self.addSubview(felt)
        self.addSubview(knapp)
        
        //Constraints for knapp
        knapp.translatesAutoresizingMaskIntoConstraints = NO
        NSLayoutConstraint.activate([
            knapp.widthAnchor.constraint(equalTo: knapp.heightAnchor),
            knapp.heightAnchor.constraint(equalTo: knapp.heightAnchor),
            knapp.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            knapp.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        //Constraints for felt
        felt.translatesAutoresizingMaskIntoConstraints = NO
        NSLayoutConstraint.activate([
            felt.heightAnchor.constraint(equalTo: self.heightAnchor),
            felt.widthAnchor.constraint(equalToConstant: expandableWidth),
            felt.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
        
        //Felless constraints
        felt.trailingAnchor.constraint(equalTo: knapp.trailingAnchor, constant: 4).isActive = YES
        //felt.centerYAnchor.constraint(equalTo: knapp.centerYAnchor).isActive = YES
        
        knapp.addTarget(self, action: #selector(knappTrykkt), for: .touchUpInside)
        
        konfig()
        
    }
    
    func konfig() {
        
        self.backgroundColor = .clear
        
        self.translatesAutoresizingMaskIntoConstraints = NO
        self.widthAnchor.constraint(equalToConstant: self.expandableWidth).isActive = YES
        
        knapp.setImage(icon, for: .normal)
        
        knapp.backgroundColor = .clear
        //knapp.layer.borderColor = tint.cgColor
        //knapp.layer.borderWidth = 2
        knapp.tintColor = tint
        knapp.layer.cornerRadius = self.frame.height / 2
        
        
        felt.placeholderColor = tint.darker(level: 1)
        felt.leadingInset = 8
        felt.trailingInset = self.frame.height
        felt.placeholder = placeholder
        
        felt.backgroundColor = .clear
        felt.layer.borderColor = tint.cgColor
        felt.layer.borderWidth = 2
        felt.layer.cornerRadius = self.frame.height / 2
        //felt.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        
        orgainserLayout()
    }
    
    @objc func knappTrykkt() {
        isExpanded = !isExpanded
        orgainserLayout()
    }
    
    func orgainserLayout() {
        let transitionDuration: Double = 0.2
        
        switch isExpanded {
            case true:
                //Skal lukke
                felt.alpha = 1
                felt.transform = CGAffineTransform(scaleX: 1, y: 1)
                UIView.animate(withDuration: transitionDuration) {
                    self.felt.alpha = 0
                } completion: { (_) in
                    self.felt.isHidden = YES
                }
                
                if let ci = icon {
                    /*UIView.transition(with: knapp, duration: transitionDuration, options: .transitionCrossDissolve, animations: {
                        
                    }, completion: nil)*/
                    self.knapp.setImage(ci, for: .normal)
                }
                
                let maske = CAShapeLayer()
                maske.path = CGPath(rect: CGRect(x: 0, y: 0, width: self.expandableWidth, height: self.frame.height), transform: nil)
                maske.fillColor = UIColor.systemGreen.cgColor
                felt.layer.mask = maske
                
                
                let anim = CABasicAnimation(keyPath: "position")
                anim.fromValue = [0, 0]
                anim.toValue = [self.expandableWidth,0]
                anim.duration = transitionDuration
                anim.isRemovedOnCompletion = YES
                anim.delegate = PositionAnimationCompletionHandler(maske, completion: {
                    self.felt.isHidden = YES
                    self.felt.constraints(affectingLayoutFor: .width).first?.constant = 0
                    self.constraints(affectingLayoutFor: .width).first?.constant = 30
                    self.frame.size.width = 30
                })
                maske.add(anim, forKey: "position")
                maske.position = CGPoint(x: self.expandableWidth, y: 0)
            
                self.felt.text = ""
                self.felt.sendActions(for: .editingChanged)

            case false:
                //Skal opne
                felt.alpha = 0
                felt.isHidden = NO
                UIView.animate(withDuration: transitionDuration) {
                    self.felt.alpha = 1
                    self.felt.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
                
                if let ci = closeIcon {
                    self.knapp.setImage(ci, for: .normal)
                    /*UIView.transition(with: knapp, duration: transitionDuration, options: .transitionCrossDissolve, animations: {
                        
                    }, completion: nil)*/
                }
                
                let maske = CAShapeLayer()
                maske.path = CGPath(rect: CGRect(x: 0, y: 0, width: self.expandableWidth, height: self.frame.height), transform: nil)
                maske.fillColor = UIColor.systemGreen.cgColor
                felt.layer.mask = maske
                
                self.felt.isHidden = NO
                self.felt.constraints(affectingLayoutFor: .width).first?.constant = self.expandableWidth
                self.constraints(affectingLayoutFor: .width).first?.constant = self.expandableWidth
                
                let anim = CABasicAnimation(keyPath: "position")
                anim.fromValue = [self.expandableWidth, 0]
                anim.toValue = [0,0]
                anim.duration = transitionDuration
                anim.isRemovedOnCompletion = YES
                anim.delegate = PositionAnimationCompletionHandler(maske, completion: {})
                maske.add(anim, forKey: "position")
                maske.position = CGPoint(x: 0, y: 0)
                
        }
    }
}

class PositionAnimationCompletionHandler: NSObject, CAAnimationDelegate {
    
    var obj: CALayer
    var completion: ()->Void
    
    init(_ obj: CALayer, completion: @escaping ()->Void) {
        self.obj = obj
        self.completion = completion
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        Timer.scheduledTimer(withTimeInterval: anim.duration - 0.2, repeats: NO) { (_) in
            guard let animasjon = anim as? CABasicAnimation,
                  let pos = animasjon.toValue as? [CGFloat]
            else { return }
            self.obj.position = CGPoint(x: pos[0], y: pos[1])
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let animasjon = anim as? CABasicAnimation
              //let pos = animasjon.toValue as? [CGFloat]
        else { return }
        if flag {
            completion()
        }
    }
}
