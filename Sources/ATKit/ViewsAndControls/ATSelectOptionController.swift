//
//  ATSelectOptionController.swift
//  ATKit
//
//  Created by Rupendra on 14/06/21.
//  Copyright © 2021 Rupendra. All rights reserved.
//

import UIKit


open class ATSelectOptionController: UIViewController {
    private var containerView: UIView!
    private var contentStackView: UIStackView!
    
    private var optionTableView: UITableView!
    private var options: Array<Option>?
    
    private var datePicker: UIDatePicker!
    
    private var cancelButton: UIButton!
    private var doneButton: UIButton!
    
    private var completion :((Option?) -> ())?
    private var dateCompletion :((Date?) -> ())?
    
    public var type :SelectType = .singleSelect
    
    public enum SelectType {
        case singleSelect
        case date
        case time
        case dateTime
    }
    
    private let sectionBackgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    private let sectionCornerRadius :CGFloat = 10.0
    
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.setup()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    
    public init(type pType :SelectType) {
        super.init(nibName: nil, bundle: nil)
        self.type = pType
        self.setup()
    }
    
    
    private func setup() {
        self.title = "Please Select"
        
        self.view.backgroundColor = UIColor.clear
        
        // Setup container view
        self.containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        self.containerView.backgroundColor = UIColor.clear
        self.containerView.layer.masksToBounds = false
        self.containerView.layer.cornerRadius = self.sectionCornerRadius
        self.containerView.layer.shadowColor = UIColor.black.cgColor
        self.containerView.layer.shadowOpacity = 0.2
        self.containerView.layer.shadowRadius = 16.0
        self.containerView.layer.shadowOffset = CGSize.zero
        self.view.addSubview(self.containerView)
        
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[containerView]-8-|", options: [], metrics: nil, views: ["containerView" : self.containerView!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[containerView]-8-|", options: [], metrics: nil, views: ["containerView" : self.containerView!]))
        
        
        // Setup content view
        self.contentStackView = UIStackView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        self.contentStackView.backgroundColor = UIColor.clear
        self.contentStackView.axis = .vertical
        self.contentStackView.distribution = .equalSpacing
        self.contentStackView.spacing = 8.0
        self.containerView.addSubview(self.contentStackView)
        
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[contentStackView]-0-|", options: [], metrics: nil, views: ["contentStackView" : self.contentStackView!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[contentStackView]-0-|", options: [], metrics: nil, views: ["contentStackView" : self.contentStackView!]))
        
        
        // Setup option table view
        self.optionTableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        self.optionTableView.backgroundColor = self.sectionBackgroundColor
        self.optionTableView.layer.cornerRadius = self.sectionCornerRadius
        self.optionTableView.layer.masksToBounds = true
        self.optionTableView.separatorInset = UIEdgeInsets.zero
        self.optionTableView.dataSource = self
        self.optionTableView.delegate = self
        self.optionTableView.tableFooterView = UIView()
        self.contentStackView.addArrangedSubview(self.optionTableView)
        self.optionTableView.reloadData()
        
        self.optionTableView.translatesAutoresizingMaskIntoConstraints = false
        self.optionTableView.addConstraint(NSLayoutConstraint(item: self.optionTableView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0))
        
        
        // Setup date picker view
        self.datePicker = UIDatePicker(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        self.datePicker.backgroundColor = self.sectionBackgroundColor
        self.datePicker.layer.cornerRadius = self.sectionCornerRadius
        self.datePicker.layer.masksToBounds = true
        if #available(iOS 13.4, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
        }
        switch self.type {
        case .singleSelect:
            break
        case .date:
            self.datePicker.datePickerMode = .date
        case .time:
            self.datePicker.datePickerMode = .time
        case .dateTime:
            self.datePicker.datePickerMode = .dateAndTime
        }
        self.contentStackView.addArrangedSubview(self.datePicker)
        
        self.datePicker.translatesAutoresizingMaskIntoConstraints = false
        self.datePicker.addConstraint(NSLayoutConstraint(item: self.datePicker!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0))
        
        
        // Setup done button
        self.doneButton = UIButton(type: .system)
        self.doneButton.setTitle("DONE", for: .normal)
        self.doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        self.doneButton.backgroundColor = self.sectionBackgroundColor
        self.doneButton.layer.cornerRadius = self.sectionCornerRadius
        self.doneButton.layer.masksToBounds = true
        self.doneButton.addTarget(self, action: #selector(self.didSelectDone), for: .touchUpInside)
        self.contentStackView.addArrangedSubview(self.doneButton)
        
        self.doneButton.translatesAutoresizingMaskIntoConstraints = false
        self.doneButton.addConstraint(NSLayoutConstraint(item: self.doneButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0))
        
        
        // Setup cancel button
        self.cancelButton = UIButton(type: .system)
        self.cancelButton.setTitle("CANCEL", for: .normal)
        self.cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        self.cancelButton.tintColor = UIColor.darkGray
        self.cancelButton.backgroundColor = self.sectionBackgroundColor
        self.cancelButton.layer.cornerRadius = self.sectionCornerRadius
        self.cancelButton.layer.masksToBounds = true
        self.cancelButton.addTarget(self, action: #selector(self.didSelectCancel), for: .touchUpInside)
        self.contentStackView.addArrangedSubview(self.cancelButton)
        
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.cancelButton.addConstraint(NSLayoutConstraint(item: self.cancelButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0))
        
        
        switch self.type {
        case .singleSelect:
            self.datePicker.isHidden = true
            self.optionTableView.isHidden = false
            self.doneButton.isHidden = true
            self.doneButton.isHidden = false
        case .dateTime, .time, .date:
            self.datePicker.isHidden = false
            self.optionTableView.isHidden = true
            self.doneButton.isHidden = false
            self.doneButton.isHidden = false
        }
    }
    
    
    public func show(presenter pController: UIViewController, options pOptionArray :Array<Option>, callback pCallback: @escaping ((Option?) -> ())) {
        self.options = pOptionArray
        self.completion = pCallback
        self.present(presenter: pController)
    }
    
    
    public func show(presenter pController: UIViewController, callback pCallback: @escaping ((Date?) -> ())) {
        self.dateCompletion = pCallback
        self.present(presenter: pController)
    }
    
    
    private func present(presenter pController: UIViewController) {
        pController.definesPresentationContext = true
        self.modalPresentationStyle = .overCurrentContext
        pController.present(self, animated: true, completion: nil)
    }
    
    
    open class Option {
        public var title :String
        public var value :String
        
        public init(title pTitle :String, value pValue :String) {
            self.title = pTitle
            self.value = pValue
        }
    }
    
}


extension ATSelectOptionController {

    func didSelectOption(_ pOption :Option) {
        self.completion?(pOption)
        self.dismiss(animated: true, completion: nil)
    }

    @objc func didSelectCancel() {
        self.completion?(nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didSelectDone() {
        switch self.type {
        case .singleSelect:
            self.completion?(nil)
        case .dateTime, .time, .date:
            self.dateCompletion?(self.datePicker.date)
        }
        self.dismiss(animated: true, completion: nil)
    }

}


extension ATSelectOptionController :UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in pTableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ pTableView: UITableView, numberOfRowsInSection pSection: Int) -> Int {
        var aReturnVal :Int = 0
        
        if pSection == 0 {
            aReturnVal = (self.options?.count ?? 0)
        }
        
        return aReturnVal
    }
    
    public func tableView(_ pTableView: UITableView, estimatedHeightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = UITableView.automaticDimension
        return aReturnVal
    }
    
    public func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        aReturnVal = UITableView.automaticDimension
        return aReturnVal
    }
    
    public func tableView(_ pTableView: UITableView, cellForRowAt pIndexPath: IndexPath) -> UITableViewCell {
        var aReturnVal :UITableViewCell?
        
        if pIndexPath.section == 0 {
            if let anOptionArray = self.options, pIndexPath.row < anOptionArray.count {
                let anOption = anOptionArray[pIndexPath.row]
                let aCellView :UITableViewCell = pTableView.dequeueReusableCell(withIdentifier: "UITableCellView") ?? UITableViewCell(style: .default, reuseIdentifier: "UITableCellView")
                aCellView.backgroundColor = UIColor.clear
                aCellView.textLabel?.text = anOption.title
                aCellView.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                aReturnVal = aCellView
            }
        }
        
        if aReturnVal == nil {
            aReturnVal = UITableViewCell()
        }
        
        return aReturnVal!
    }
    
    public func tableView(_ pTableView: UITableView, didSelectRowAt pIndexPath: IndexPath) {
        pTableView.deselectRow(at: pIndexPath, animated: true)

        if pIndexPath.section == 0 {
            if let anOptionArray = self.options, pIndexPath.row < anOptionArray.count {
                let anOption = anOptionArray[pIndexPath.row]
                self.didSelectOption(anOption)
            }
        }
    }
    
}
