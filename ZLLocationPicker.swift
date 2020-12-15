//
//  ZLAddressSelectedView.swift
//  ZLSales
//
//  Created by Leo on 2020/12/15.
//  Copyright © 2020 ZLGJ. All rights reserved.
//

import UIKit

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

let POP_VIEW_HEIGHT:CGFloat = kScreenWidth >= 414 ? 290 : 280
let BTN_COLOR = UIColor(red: 5/255, green: 114/255, blue: 246/255, alpha: 1)
let TOOL_BAR_COLOR = UIColor(red: 246/255, green: 247/255, blue: 248/255, alpha: 1)
let TOP_TITLE_COLOR = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)


enum LocationPickerType {
    case level1(province: String = "上海市")
    case level2(province: String = "上海市", city: String = "上海市")
    case level3(province: String = "上海市", city: String = "上海市", town: String = "黄浦区")
    
    var getLocationArr:[String] {
        switch self {
        case .level1(let province):
            return [province]
        case .level2(let province, let city):
            return [province, city]
        case .level3(let province, let city, let town):
            return [province, city, town]
        }
    }
    
    var address:String {
        return getLocationArr.joined(separator: " ")
    }
}


class ZLLocationPicker: UIView {
    
    
    /// 底部内容视图
    lazy var contentView:UIView = {
        let rect = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: POP_VIEW_HEIGHT)
        var contentView = UIView(frame: rect)
        contentView.backgroundColor = UIColor.white
        return contentView
    }()
    
    
    /// 滚动视图
    lazy var pickerView:UIPickerView = {
        let rect = CGRect(x: 0, y: 40, width: kScreenWidth, height: POP_VIEW_HEIGHT - 40)
        var pickerView = UIPickerView(frame: rect)
        pickerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        pickerView.backgroundColor = UIColor.white
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    
    /// 工具栏视图
    lazy var topToolBar:UIView = {
        let rect = CGRect(x: 0, y: 0, width: kScreenWidth, height: 40)
        var topToolBar = UIView(frame: rect)
        topToolBar.backgroundColor = TOOL_BAR_COLOR
        return topToolBar
    }()
    
    
    /// 标题
    lazy var topTitle:UILabel = {
        let rect = CGRect(x: 70, y: 5, width: kScreenWidth - 140, height: 30)
        var titleLabel = UILabel(frame: rect)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = TOP_TITLE_COLOR
        return titleLabel
    }()
    
    
    /// 取消按钮
    lazy var cancelButton:UIButton = {
        let rect = CGRect(x: 0, y: 5, width: 70, height: 30)
        var cancelBtn = UIButton(type: .system)
        cancelBtn.frame = rect
        cancelBtn.titleLabel?.textAlignment = .center
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cancelBtn.addTarget(self, action: #selector(canceBtnClicked), for: .touchUpInside)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(BTN_COLOR, for: .normal)
        return cancelBtn
    }()
    
    
    /// 完成按钮
    lazy var finishButton:UIButton = {
        let rect = CGRect(x: kScreenWidth - 70, y: 5, width: 70, height: 30)
        var finishBtn = UIButton(type: .system)
        finishBtn.frame = rect
        finishBtn.titleLabel?.textAlignment = .center
        finishBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        finishBtn.addTarget(self, action: #selector(finishBtnClicked), for: .touchUpInside)
        finishBtn.setTitle("确定", for: .normal)
        finishBtn.setTitleColor(BTN_COLOR, for: .normal)
        return finishBtn
    }()
    
    
    /// 是否标题显示当前选择地区
    public var isAppearLociton = false
    
    fileprivate var addressDict:[String: Any] = [:]
    fileprivate var addressArr = [[String: Any]]()
    fileprivate var provinceArray:[String] = []
    fileprivate var cityArray:[String] = []
    fileprivate var townArray:[String] = []
    fileprivate var doneBlock:((String)->())?
    fileprivate var pickerType:LocationPickerType = .level1(province: "上海市") {
        didSet {
            if isAppearLociton == true {
                topTitle.text = pickerType.getLocationArr.joined(separator: "")
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.isUserInteractionEnabled = true
        
        // 初始化子视图
        self.addSubview(contentView)
        self.contentView.addSubview(pickerView)
        self.contentView.addSubview(topToolBar)
        self.topToolBar.addSubview(topTitle)
        self.topToolBar.addSubview(cancelButton)
        self.topToolBar.addSubview(finishButton)
        
        // 初始化数据
        self.loadDataSouce()
        self.setPikcerData()
    }
    
    convenience init(_ locationPickerStyle: LocationPickerType, title:String = "", completeBlock: @escaping (_: String) -> Void) {
        self.init()
        
        self.topTitle.text = title
        self.pickerType = locationPickerStyle
        self.setPikcerData()
        
        doneBlock = { completeBlock($0) }
    }
    
    
    convenience init(_ location: String... ,title:String = "", completeBlock: @escaping (_: String) -> Void) {
        self.init()
        
        switch location.count {
        case 1:
            pickerType = .level1(province: location[0])
        case 2:
            pickerType = .level2(province: location[0], city: location[1])
        case 3:
            pickerType = .level3(province: location[0], city: location[1], town: location[2])
        default:
            print("iuput Error")
        }
        
        self.topTitle.text = title
        self.setPikcerData()
        
        doneBlock = { completeBlock($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 加载相关数据
extension ZLLocationPicker {
    
    fileprivate func setPikcerData() {
        
        pickerView.setNeedsLayout()
        
        switch pickerType {
        case .level1(province: let province):
            
            self.provinceArray = getProvinceArr()
            
            let provinceIndex = provinceArray.firstIndex(of: province) ?? 0
            pickerView.selectRow(provinceIndex, inComponent: 0, animated: true)
            
        case .level2(province: let province, city: let city):
            
            self.provinceArray = getProvinceArr()
            self.cityArray = getCityArr(province)
            
            let provinceIndex = provinceArray.firstIndex(of: province) ?? 0
            let cityIndex = cityArray.firstIndex(of: city) ?? 0
            pickerView.selectRow(provinceIndex, inComponent: 0, animated: true)
            pickerView.selectRow(cityIndex, inComponent: 1, animated: true)
            
        case .level3(province: let province, city: let city, town: let town):
            
            self.provinceArray = getProvinceArr()
            self.cityArray = getCityArr(province)
            self.townArray = getTownArr(province, city: city)
            
            let provinceIndex = provinceArray.firstIndex(of: province) ?? 0
            let cityIndex = cityArray.firstIndex(of: city) ?? 0
            let townIndex = townArray.firstIndex(of: town) ?? 0
            pickerView.selectRow(provinceIndex, inComponent: 0, animated: true)
            pickerView.selectRow(cityIndex, inComponent: 1, animated: true)
            pickerView.selectRow(townIndex, inComponent: 2, animated: true)
        }
    }
    
    fileprivate func loadDataSouce() {
        
        guard let path = Bundle.main.path(forResource: "Address", ofType: "plist") else { return }
        guard let addressDic = NSDictionary(contentsOfFile: path) as? [String:Any] else { return }
        self.addressDict = addressDic

        guard let path2 = Bundle.main.path(forResource: "addressInfo", ofType: "json") else { return }
//        let data =  Data.init(contentsOf: URL.init(fileURLWithPath: path2))
        let url = URL.init(fileURLWithPath: path2)
        guard let jsonData = try? Data.init(contentsOf: url, options: Data.ReadingOptions.alwaysMapped) else {
             return
        }
         let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
        let objects = jsonObject as? [[String: Any]]
        if let array = objects {
            self.addressArr = array
        }
    }
    
    fileprivate func getProvinceArr() -> [String] {
        
        return addressDict.map { $0.key }
    }
    
    fileprivate func getCityArr(_ province: String) -> [String] {
        
        guard let guangdong = addressDict[province] as? [Any],
              let citys = guangdong.first as? [String: Any] else {
            return [] }
        
        return citys.map { $0.key }
    }
    
    fileprivate func getTownArr(_ province:String, city:String) -> [String] {
        
        guard let citysObject = addressDict[province] as? [Any],
              let citys = citysObject.first as? [String: Any],
              let towns = citys[city] as? [String] else {
            return [] }
        
        return towns
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension ZLLocationPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    
    enum ComponentType:Int {
        case province = 0
        case city = 1
        case town = 2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        switch pickerType {
        case .level1:
            return 1
        case .level2:
            return 2
        case .level3:
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        guard let componentType = ComponentType(rawValue: component) else {
            return 0
        }
        
        switch componentType {
        case .province:
            return provinceArray.count
        case .city:
            return cityArray.count
        case .town:
            return townArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        guard let componentType = ComponentType(rawValue: component) else {
            return nil
        }
        
        switch componentType {
        case .province:
            return provinceArray[row]
        case .city:
            return cityArray[row]
        case .town:
            return townArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard let componentType = ComponentType(rawValue: component) else {
            return
        }
        
        switch componentType {
        case .province:
            
            let province = provinceArray[row]
            
            switch pickerType {
            case .level1:
                
                pickerType = .level1(province: province)
                
            case .level2:
                
                cityArray = getCityArr(province)
                pickerView.reloadComponent(1)
                pickerView.selectRow(0, inComponent: 1, animated: true)
                
                let city = cityArray.first!
                pickerType = .level2(province: province, city: city)
                
            case .level3:
                
                cityArray = getCityArr(province)
                pickerView.reloadComponent(1)
                pickerView.selectRow(0, inComponent: 1, animated: true)
                
                guard let firstCity = cityArray.first else { return }
                
                townArray = getTownArr(province, city: firstCity)
                pickerView.reloadComponent(2)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                
                let town = townArray.first!
                pickerType = .level3(province: province, city: firstCity, town: town)
            }
            
        case .city:
            
            let city = cityArray[row]
            
            switch pickerType {
            case .level2(let province, city: _):
                
                pickerType = .level2(province: province, city: city)
                
            case .level3(let province, city: _, town : _):
                
                self.townArray = getTownArr(province, city: city)
                pickerView.reloadComponent(2)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                
                let town = townArray.first!
                pickerType = .level3(province: province, city: city, town: town)
            default:
                break
            }
            
        case .town:
            
            guard case let .level3(province: province, city: city, town : _) = pickerType else { return }
            let town = townArray[row]
            pickerType = .level3(province: province, city: city, town: town)
        }
    }
}

// MARK: - 自定义视图显示
extension ZLLocationPicker {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = [provinceArray, cityArray, townArray][component][row]
        return label
    }
}


// MARK: - 工具栏按钮及点击背景事件
extension ZLLocationPicker {
    
    @objc func finishBtnClicked(_ btn: UIButton) {
        self.doneBlock?(pickerType.address)
        self.removeSelfFromSupView()
    }
    
    @objc func canceBtnClicked(_ btn: UIButton) {
        self.removeSelfFromSupView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeSelfFromSupView()
    }
}

// MARK: - 显示 | 移除视图
extension ZLLocationPicker {
    
    func show() {
        UIApplication.shared.delegate?.window?!.addSubview(self)
        var frame = contentView.frame
        if frame.origin.y == kScreenHeight {
            frame.origin.y -= POP_VIEW_HEIGHT
            UIView.animate(withDuration: 0.3, animations: {
                self.contentView.frame = frame
            })
        }
    }
    func show(inView: UIView) {
//        UIApplication.shared.delegate?.window?.addSubview(self)
        inView.addSubview(self)
        var frame = contentView.frame
        if frame.origin.y == kScreenHeight {
            frame.origin.y -= POP_VIEW_HEIGHT
            UIView.animate(withDuration: 0.3, animations: {
                self.contentView.frame = frame
            })
        }
    }
    func removeSelfFromSupView() {
        var selfFrame = contentView.frame
        if selfFrame.origin.y == kScreenHeight - POP_VIEW_HEIGHT {
            selfFrame.origin.y += POP_VIEW_HEIGHT
            UIView.animate(withDuration: 0.3, animations: {
                self.contentView.frame = selfFrame
            }) { _  in
                self.removeFromSuperview()
            }
        }
    }
}


