//
//  ATTextView.swift
//  ATKit
//
//  Created by Rupendra on 17/02/18.
//  Copyright © 2018 Aurvan.com. All rights reserved.
//

import UIKit


/**
 The ATTextView adds various functionalities to UITextView, e.g. placeholder.
 */
@IBDesignable public class ATTextView: UITextView {
    
    private var placeholderLabel :UILabel?
    private var defaultPlaceholderColor :UIColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
    
    
    /**
     The variable allows to set color for placeholder. Set it to nil to use default placeholder color.
     
     **Usage Example**
     ```swift
     self.messageTextView.placeholderColor = UIColor(red: 173.0/255.0, green: 216.0/255.0, blue: 230.0/255.0, alpha: 1.0)
     ```
     
     - SeeAlso: `placeholder`
     */
    @IBInspectable public var placeholderColor :UIColor? {
        didSet {
            self.updatePlaceholder()
        }
    }
    
    
    /**
     The variable allows to set placeholder for current textview.
     
     **Usage Example**
     ```swift
     self.messageTextView.placeholder = "Type your message here."
     ```
     
     - SeeAlso: `placeholderColor`
     */
    @IBInspectable public var placeholder :String? {
        didSet {
            self.updatePlaceholder()
        }
    }
    
    
    /**
     Initializer.
     */
    required public init(coder pDecoder: NSCoder) {
        super.init(coder:pDecoder)!
        self.initialize()
    }
    
    
    /**
     Initializer.
     */
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.initialize()
    }
    
    
    /**
     Overridden method from superclass.
     */
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    
    private var isInitialized :Bool = false
    
    private func initialize() {
        if self.isInitialized == false {
            self.isInitialized = true
            NotificationCenter.default.addObserver(self, selector: #selector(self.textViewTextDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
            self.updatePlaceholder()
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
    
    
    public override var text: String! {
        didSet {
            self.updatePlaceholder()
        }
    }
    
    
    @objc internal func textViewTextDidChange(_ pNotification: Notification) {
        if pNotification.object != nil && (pNotification.object! as AnyObject).isEqual(self) {
            self.updatePlaceholder()
        }
    }
    
    
    private func updatePlaceholder() {
        if self.placeholderLabel == nil {
            let aPlaceholderLabel = UILabel()
            self.addSubview(aPlaceholderLabel)
            self.placeholderLabel = aPlaceholderLabel
            
            var anAbscissa :CGFloat = 0.0
            anAbscissa += self.textContainer.lineFragmentPadding
            anAbscissa += self.contentInset.left
            
            var aRightPadding :CGFloat = 0.0
            aRightPadding += self.textContainer.lineFragmentPadding
            aRightPadding += self.contentInset.right
            
            var anOrdinate :CGFloat = 3.0
            anOrdinate += self.textContainer.lineFragmentPadding
            anOrdinate += self.contentInset.top
            
            aPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: String(format: "H:|-%0.2f-[aPlaceholderLabel]", anAbscissa), options: [], metrics: nil, views: ["aPlaceholderLabel":aPlaceholderLabel]))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: String(format: "V:|-%0.2f-[aPlaceholderLabel]", anOrdinate), options: [], metrics: nil, views: ["aPlaceholderLabel":aPlaceholderLabel]))
            self.addConstraint(NSLayoutConstraint(item: aPlaceholderLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: aPlaceholderLabel.superview!, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: (0.0 - anAbscissa - aRightPadding)))
        }
        
        self.placeholderLabel?.numberOfLines = 0
        self.placeholderLabel?.textColor = self.placeholderColor ?? self.defaultPlaceholderColor
        self.placeholderLabel?.font = self.font ?? UIFont.systemFont(ofSize: 15.0)
        self.placeholderLabel?.text = self.placeholder
        self.placeholderLabel?.isHidden = !self.text.isEmpty
    }
    
}
