//
//  ATSelectOptionController.swift
//  ATKit
//
//  Created by Rupendra on 14/06/21.
//  Copyright © 2021 Rupendra. All rights reserved.
//

import UIKit


open class ATSelectOptionController: UIAlertController {
    private var optionTableView: UITableView!
    private var options: Array<Option>?
    
    private var datePicker: UIDatePicker!
    
    private var completion :((Option?) -> ())?
    private var dateCompletion :((Date?) -> ())?
    
    public var type :SelectType = .singleSelect
    
    public enum SelectType {
        case singleSelect
        case date
        case time
        case dateTime
    }
    
    
    public override var preferredStyle: UIAlertController.Style {
        return .actionSheet
    }
    
    
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
        
        let aMargin:CGFloat = 10.0
        let aRect = CGRect(x: aMargin, y: aMargin + 26.0, width: self.view.bounds.size.width - (aMargin * 4.0), height: 220.0)
        
        switch self.type {
        case .singleSelect:
            self.optionTableView = UITableView(frame: aRect)
            self.optionTableView.backgroundColor = UIColor.clear
            self.optionTableView.separatorInset = UIEdgeInsets.zero
            self.optionTableView.dataSource = self
            self.optionTableView.delegate = self
            self.optionTableView.tableFooterView = UIView()
            self.view.addSubview(self.optionTableView)
            
            self.optionTableView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[optionTableView]-|", options: [], metrics: nil, views: ["optionTableView" : self.optionTableView]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-26-[optionTableView(==180)]-124-|", options: [], metrics: nil, views: ["optionTableView" : self.optionTableView]))
            
            self.optionTableView.reloadData()
        case .dateTime, .time, .date:
            self.datePicker = UIDatePicker(frame: aRect)
            self.datePicker.backgroundColor = UIColor.clear
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
            self.view.addSubview(self.datePicker)
            
            self.datePicker.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[datePicker]-|", options: [], metrics: nil, views: ["datePicker" : self.datePicker]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-26-[datePicker(==180)]-124-|", options: [], metrics: nil, views: ["datePicker" : self.datePicker]))
            
            self.addAction(UIAlertAction(title: "Done", style: .default, handler: {_ in
                self.didSelectDone()
            }))
        }
        
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            self.didSelectCancel()
        }))
    }
    
    
    public func show(presenter pController: UIViewController, options pOptionArray :Array<Option>, callback pCallback: @escaping ((Option?) -> ())) {
        self.options = pOptionArray
        self.completion = pCallback
        
        pController.present(self, animated: true, completion: nil)
    }
    
    
    public func show(presenter pController: UIViewController, callback pCallback: @escaping ((Date?) -> ())) {
        self.dateCompletion = pCallback
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

    func didSelectCancel() {
        self.completion?(nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func didSelectDone() {
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
