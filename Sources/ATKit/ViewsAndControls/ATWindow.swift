//
//  ATWindow.swift
//  ATKit
//
//  Created by Rupendra on 14/01/18.
//  Copyright © 2018 Rupendra. All rights reserved.
//

#if canImport(UIKit)
import UIKit


/**
 The ATWindow adds various functionalities to UIWindow, e.g. dismiss keyboard on tap on screen, adjust text-field frame as per keyboard visible/hidden.
 */
public class ATWindow: UIWindow {
    
    // MARK:- Dismiss Keyboard - Variables
    
    /**
     The variable allows to dismiss the keyboard on tapping anywhere outside the editable controls (UITextField, UITextView etc.).
     
     **Usage Example**
     ```swift
     (UIApplication.shared.keyWindow as! ATWindow).shouldDismissKeyboardOnTap = true
     ```
     * You can write above line of code in `application:didFinishLaunchingWithOptions:`, `viewDidLoad` or any other suitable method.
     * Make sure application keyWindow is initialized as ATWindow.
     
     - SeeAlso: `addDismissKeyboardExemptedRestorationId(_ pRestorationId :String)` `removeDismissKeyboardExemptedRestorationId(_ pRestorationId :String)`
     */
    public var shouldDismissKeyboardOnTap :Bool = false
    
    private var dismissKeyboardExemptedRestorationIds :Array<String> = Array<String>()
    
    public weak var dataSource :ATWindowDataSource?
    
    
    // MARK:- Adjust Pan For Keyboard - Variables
    
    /**
     The variable allows to adjust window pan according to keyboard, i.e. when keyboard comes up, the application page will move up to make editable control (UITextField, UITextView etc.) visible.
     
     **Usage Example**
     ```swift
     (UIApplication.shared.keyWindow as! ATWindow).shouldAdjustPanForKeyboard = true
     ```
     * You can write above line of code in `application:didFinishLaunchingWithOptions:`, `viewDidLoad` or any other suitable method.
     * Make sure application keyWindow is initialized as ATWindow.
     
     - SeeAlso: `addAdjustPanExemptedRestorationId(_ pRestorationId :String)` `removeAdjustPanExemptedRestorationId(_ pRestorationId :String)`
     */
    public var shouldAdjustPanForKeyboard :Bool = false
    
    private var adjustPanExemptedRestorationIds :Array<String> = Array<String>()
    
    private var currentKeyboardFrame :CGRect?
    
    private var originalWindowOrdinate :CGFloat?
    

    // MARK: - Initialization / De-Initialization Methods
    
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
    override public init(frame:CGRect) {
        super.init(frame:frame)
        self.initialize()
    }
    
    
    /**
     Overridden method from superclass.
     */
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    
    private func initialize() {
        self.initializeForAdjustPanForKeyboard()
        self.initializeForDismissKeyboard()
    }
    
    
    deinit {
        self.deinitializeForAdjustPanForKeyboard()
    }
    
}



// MARK:- Adjust Pan For Keyboard

extension ATWindow {
    
    private func initializeForAdjustPanForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(ATWindow.didReceiveKeyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ATWindow.didReceiveKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ATWindow.textViewTextDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ATWindow.textViewTextDidBeginEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ATWindow.textFieldTextDidBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
    }
    
    
    private func deinitializeForAdjustPanForKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidBeginEditingNotification, object: nil)
    }
    
    
    private func adjustPanForKeyboard() {
        // Find first responder
        let aFirstResponderView :UIView! = self.firstResponder()
        if aFirstResponderView != nil
            && (aFirstResponderView.isKind(of: UITextField.self) || aFirstResponderView.isKind(of: UITextView.self)) {
            if self.currentKeyboardFrame != nil {
                let aKeyboardOrdinate = self.currentKeyboardFrame!.origin.y
                
                var aTextInputOrdinate :CGFloat = 0.0
                var aTextInputHeight :CGFloat = 0.0
                
                var aShouldAdjustPanForKeyboard :Bool = true
                if self.shouldAdjustPanForKeyboard == false {
                    aShouldAdjustPanForKeyboard = false
                }
                
                if aShouldAdjustPanForKeyboard == true && aFirstResponderView.superview != nil {
                    let aTextInputRect = aFirstResponderView.superview!.convert(aFirstResponderView.frame, to: self)
                    if aFirstResponderView.isKind(of: UITextField.self) {
                        aTextInputOrdinate = aTextInputRect.origin.y
                        aTextInputHeight = aTextInputRect.size.height
                    } else if aFirstResponderView.isKind(of: UITextView.self) {
                        aTextInputOrdinate = aTextInputRect.origin.y
                        let aCaretRect :CGRect = (aFirstResponderView as! UITextView).caretRect(for: (aFirstResponderView as! UITextView).selectedTextRange!.start)
                        aTextInputHeight = ((aFirstResponderView as! UITextView).contentSize.height - (aFirstResponderView as! UITextView).contentOffset.y) + aCaretRect.size.height
                        if aTextInputHeight > (aFirstResponderView as! UITextView).frame.height {
                            aTextInputHeight = (aFirstResponderView as! UITextView).frame.height
                        }
                    }
                }
                
                let aDefaultSpacing :CGFloat = 10.0
                
                var aSpacing :CGFloat = 0.0
                if let aDataSource = self.dataSource, let aTextInput = aFirstResponderView as? UITextInput {
                    aSpacing = aDataSource.keyboardPanSpacingForTextInput(aTextInput)
                }
                
                let aPanTotal = aTextInputOrdinate + aTextInputHeight + aSpacing + aDefaultSpacing
                
                if aKeyboardOrdinate <= aPanTotal {
                    let anAdjustmentHeight :CGFloat = aPanTotal - aKeyboardOrdinate
                    if self.originalWindowOrdinate == nil {
                        self.originalWindowOrdinate = self.frame.origin.y
                    }
                    UIView.animate(withDuration: 0.3, animations: {
                        self.frame = CGRect(x: self.frame.origin.x, y: self.originalWindowOrdinate! - anAdjustmentHeight, width: self.frame.size.width, height: self.frame.size.height)
                    })
                }
            }
        }
    }
    
    
    @objc internal func didReceiveKeyboardWillShowNotification(_ sender :Notification!) {
        if let userInfo = sender.userInfo {
            if let aKeyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.currentKeyboardFrame = aKeyboardRect
            }
        }
        self.adjustPanForKeyboard()
    }
    
    
    @objc internal func didReceiveKeyboardWillHideNotification(_ sender :Notification!) {
        if self.originalWindowOrdinate != nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.frame = CGRect(x: self.frame.origin.x, y: self.originalWindowOrdinate!, width: self.frame.size.width, height: self.frame.size.height)
            }, completion: {pCompleted in
                self.originalWindowOrdinate = nil
            })
        }
    }
    
    
    @objc func textViewTextDidChange(_ pNotification: Notification) {
        self.adjustPanForKeyboard()
    }
    
    
    @objc func textViewTextDidBeginEditing(_ pNotification: Notification) {
        self.adjustPanForKeyboard()
    }
    
    
    @objc func textFieldTextDidBeginEditing(_ pNotification: Notification) {
        self.adjustPanForKeyboard()
    }
    
    
    /**
     The function allows to exempt editable controls from adjusting pan according to keyboard.
     
     If you want that the window pan should **not** be adjusted according to keyboard for any specific editable control (UITextField, UITextView etc.), then add its restoration ID using this method. You can set restoration ID for any view in nib, storyboard or via code.
     
     - Parameter pRestorationId: Restoration ID of an editable control that is to be exempted from pan adjustment according to keyboard.
     
     **Usage Example**
     ```swift
     (UIApplication.shared.keyWindow as! ATWindow).addAdjustPanExemptedRestorationId("firstNameTextFieldResId")
     ```
     * You can write above line of code in `application:didFinishLaunchingWithOptions:`, `viewDidLoad` or any other suitable method.
     * Make sure application keyWindow is initialized as ATWindow.
     
     - Precondition: `shouldAdjustPanForKeyboard` of ATWindow should be set as true.
     
     - SeeAlso: `removeAdjustPanExemptedRestorationId(_ pRestorationId :String)` `shouldAdjustPanForKeyboard`
     */
    public func addAdjustPanExemptedRestorationId(_ pRestorationId :String) {
        if self.adjustPanExemptedRestorationIds.contains(pRestorationId) == false {
            self.adjustPanExemptedRestorationIds.append(pRestorationId)
        }
    }
    
    
    /**
     The function allows to remove the exempted editable controls from adjusting pan according to keyboard.
     
     If you have added an editable control to exempt window pan adjustment, but now you dont want to exempt that control, then you can remove it using this method.
     
     **Usage Example**
     ```swift
     (UIApplication.shared.keyWindow as! ATWindow).removeAdjustPanExemptedRestorationId("firstNameTextFieldResId")
     ```
     * You can write above line of code in `application:didFinishLaunchingWithOptions:`, `viewDidLoad` or any other suitable method.
     * Make sure application keyWindow is initialized as ATWindow.
     
     - Parameter pRestorationId: Restoration ID of an editable control that is to be removed from exemption.
     
     - Precondition: `shouldAdjustPanForKeyboard` of ATWindow should be set as true.
     
     - SeeAlso: `addAdjustPanExemptedRestorationId(_ pRestorationId :String)` `shouldAdjustPanForKeyboard`
     */
    public func removeAdjustPanExemptedRestorationId(_ pRestorationId :String) {
        if self.adjustPanExemptedRestorationIds.contains(pRestorationId) == true {
            self.adjustPanExemptedRestorationIds.remove(at: self.adjustPanExemptedRestorationIds.firstIndex(of: pRestorationId)!)
        }
    }
    
}


// MARK:- Dismiss Keyboard

extension ATWindow :UIGestureRecognizerDelegate {
    
    private func initializeForDismissKeyboard() {
        let aTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ATWindow.didTapWindow(_:)))
        aTapGestureRecognizer.cancelsTouchesInView = false
        aTapGestureRecognizer.delegate = self
        self.addGestureRecognizer(aTapGestureRecognizer)
    }
    
    
    public func gestureRecognizer(_ pGestureRecognizer: UIGestureRecognizer, shouldReceive pTouch: UITouch) -> Bool {
        var aReturnVal = true
        if pTouch.view?.isKind(of: UIControl.self) == true {
            aReturnVal = false
        }
        return aReturnVal
    }
    
    
    private func dismissKeyboard(tappedView pTappedView :UIView) {
        var aShouldDismissKeyboard :Bool = true
        
        if aShouldDismissKeyboard == true {
            if self.shouldDismissKeyboardOnTap == false {
                aShouldDismissKeyboard = false
            }
        }
        
        if aShouldDismissKeyboard == true {
            for aRestorationId in self.dismissKeyboardExemptedRestorationIds {
                if aRestorationId == pTappedView.restorationIdentifier {
                    aShouldDismissKeyboard = false
                    break
                }
            }
        }
        
        if aShouldDismissKeyboard == true {
            self.endEditing(true)
        }
    }
    
    
    @objc internal func didTapWindow(_ pSender:UITapGestureRecognizer) {
        let aLocation = pSender.location(ofTouch: 0, in: self)
        let aTappedView :UIView? = self.hitTest(aLocation, with: nil)
        if aTappedView != nil {
            self.dismissKeyboard(tappedView: aTappedView!)
        }
    }
    
    
    /**
     The function allows to exempt view from dismissing keyboard on tap on it.
     
     If you want that the keyboard should **not** be dismissed on tap on a specific view, then add its restoration ID using this method. You can set restoration ID for any view in nib, storyboard or via code.
     
     - Parameter pRestorationId: Restoration ID of a view that is to be exempted from dismissing the keyboard.
     
     **Usage Example**
     ```swift
     (UIApplication.shared.keyWindow as! ATWindow).addDismissKeyboardExemptedRestorationId("firstNameContainerViewResId")
     ```
     * You can write above line of code in `application:didFinishLaunchingWithOptions:`, `viewDidLoad` or any other suitable method.
     * Make sure application keyWindow is initialized as ATWindow.
     
     - Precondition: `shouldDismissKeyboardOnTap` of ATWindow should be set as true.
     
     - SeeAlso: `removeDismissKeyboardExemptedRestorationId(_ pRestorationId :String)` `shouldDismissKeyboardOnTap`
     */
    public func addDismissKeyboardExemptedRestorationId(_ pRestorationId :String) {
        if self.dismissKeyboardExemptedRestorationIds.contains(pRestorationId) == false {
            self.dismissKeyboardExemptedRestorationIds.append(pRestorationId)
        }
    }
    
    
    /**
     The function allows to remove the exempted views from dismissing keyboard on tap on it.
     
     If you have added a view to exempt keyboard dismissing, but now you dont want to exempt that view, then you can remove it using this method.
     
     - Parameter pRestorationId: Restoration ID of a view that is to be removed from exemption.
     
     **Usage Example**
     ```swift
     (UIApplication.shared.keyWindow as! ATWindow).removeDismissKeyboardExemptedRestorationId("firstNameContainerViewResId")
     ```
     * You can write above line of code in `application:didFinishLaunchingWithOptions:`, `viewDidLoad` or any other suitable method.
     * Make sure application keyWindow is initialized as ATWindow.
     
     - Precondition: `shouldDismissKeyboardOnTap` of ATWindow should be set as true.
     
     - SeeAlso: `addDismissKeyboardExemptedRestorationId(_ pRestorationId :String)` `shouldDismissKeyboardOnTap`
     */
    public func removeDismissKeyboardExemptedRestorationId(_ pRestorationId :String) {
        if self.dismissKeyboardExemptedRestorationIds.contains(pRestorationId) == true {
            self.dismissKeyboardExemptedRestorationIds.remove(at: self.dismissKeyboardExemptedRestorationIds.firstIndex(of: pRestorationId)!)
        }
    }
    
}


public protocol ATWindowDataSource: AnyObject {
    func keyboardPanSpacingForTextInput(_ pSender :UITextInput) -> CGFloat
}

#endif
