//
//  JWDatePickerView.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/10/13.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

/*
 
    使用方法
    pickerMode:JWDatePickerMode? 日期选择模式
    minDate:Date?  最小日期
    maxDate:Date?  最大日期
    date:Date?     当前日期
    enableLimited:Bool? 限制滚动区域模式 开启后最大最小日期至少有一个有值时有效
    unitStrClosure:((NSCalendar.Unit)-> String)? 获取单位的闭包 例如：年 月 日 时 分 秒
    didSelectedDateClosure:((Date)->())? 选中了日期
 */

/*
    时间控件的模式
 */
public enum JWDatePickerMode:Int{
    
       case dateAndTime// 年月日  时  分  秒
       case dateAndHour// 年月日  时
       case dateAndTimeRYear// 月日 时 分 秒
       case time//  时 分 秒
       case timeRSecond//  时 分
       case date// 年   月   日
       case dateAddHour// 年 月 日  时
       case dateAndTimeRSecond// 年月日  时  分
       case dateAndTimeRYearAndSecond// 月日  时  分   3
       case dateAndTimeForAllComponent// 年 月  日  时  分 秒
}




public class JWDatePickerView: UIView,UIPickerViewDelegate,UIPickerViewDataSource{
    
    
    //MARK:公有方法 和 公有属性
    
    //获取单位
    public var unitStrClosure:((NSCalendar.Unit)-> String)?
    
    //选中日期
   public var didSelectedDateClosure:((Date)->())?
    
    //无限滚动的最大范围
    private let MaxRangeValue:Int = 88888
    
    //记录当日期选择模式中 无限滚动选项的当前日期 对应组选项索引
    private var currentIndex:Int?
    
    //是否正在滚动
    private var currentOperationComponent:Int = 0
    
    public typealias UnitType = Calendar.Component
    
    /**
     *   最小日期
     */
    private var _minDate:Date?
    public var minDate:Date?{
        set{
            
            if let minD = newValue{
                _minDate = newValue
                 //设置最大日期  如果最小日期比最大日期还要大
                if let tempMaxDate =  maxDate{
                    //最小日期 比最大日期大
                    if minD.compare(tempMaxDate) == ComparisonResult.orderedDescending{
                       //设置最大日期为最小日期
                       _maxDate = minD
                    }else{
                        //如果是需要限制在短时间内的
                        let unitSubArray:[UnitType] = (pickerModeDict[pickerMode!]?.first!)!
                        if unitSubArray.first !=  .year && unitSubArray.last ==  .day{
                            let destinationDate =  getDateAddOrReduceYear(date: minD, isAdd: true)
                            
                            //如果最大日期超过最小日期一年后的范围
                            if tempMaxDate.compare(destinationDate) == ComparisonResult.orderedDescending{
                                _maxDate =  destinationDate
                            }
                        }
                    }
                }else{//最大日期没有值，如果模式需要限制在一年内
                    let unitSubArray:[UnitType] = (pickerModeDict[pickerMode!]?.first!)!
                    if unitSubArray.first !=  .year && unitSubArray.last ==  .day{
                       
                        //一年后的日期
                        let destinationDate:Date = self.getDateAddOrReduceYear(date: minD, isAdd: true)
                        //修改掉
                        _maxDate = destinationDate
                    }
                }
                
                //验证当前日期
                if let currentDate = self.date{
                    //判断当前日期是否在范围内
                    
                    //当前时间比最小时间
                    if currentDate.compare(minD) == ComparisonResult.orderedAscending{
//                        _date = minD
                        self.date = minD
                    }
                    
                    //判断最大日期的范围
                    if let tempMaxDate = maxDate{
                         if currentDate.compare(tempMaxDate) == ComparisonResult.orderedDescending{//当前时间比最大时间大
//                             _date =  tempMaxDate
                            self.date = tempMaxDate
                         }
                    }
                }else{
//                    _date =  minD
                    self.date = minD
                }
                
                //刷新
                toCurentDate(animated: false)
            }else
            {
                _minDate = newValue
                
                //刷新
                toCurentDate(animated: false)
            }
        }
        get{
            
            if _minDate ==  nil {
                
                let unitSubArray:[UnitType] = (pickerModeDict[pickerMode!]?.first!)!
                if unitSubArray.first !=  .year && unitSubArray.last ==  .day{
                    
                    //如果最大日期有值
                    if let tempMaxDate = _maxDate{
                        let destinationDate = getDateAddOrReduceYear(date: tempMaxDate, isAdd: false)
                        
                        //设置时间
                        self.minDate =  destinationDate
                    }else{
                        if let date = self.date{
                        //判断最小日期是否在一年的范围内
                        var addComps:DateComponents = DateComponents()
                        
                        //闰年
                        if self.isLeapYear(year: (self.currentDateCompnents?.year)!){
                            addComps.day = -((366-1)/2)
                        }else{
                            addComps.day = -((365-1)/2)
                        }
                        
                        //日期
                        let lastDate:Date = calendar.date(byAdding: addComps, to:date)!
                        
                        _minDate =  lastDate
                    }
                    }
                }
            }
            
            return _minDate
        }
    }
    
    
    /**
     *   最大日期
     */
    private var _maxDate:Date?
    public var maxDate:Date?
        {
        set{
            if let maxD = newValue{
                _maxDate = maxD
                //设置最小日期  如果最大日期比最小日期还要小
                if let tempMinDate =  minDate{
                    //最大日期 比最小日期小
                    if maxD.compare(tempMinDate) == ComparisonResult.orderedAscending{
                        //设置最小日期为最大日期
                        _minDate = maxD
                    }else{
                        //如果是需要限制在短时间内的
                        let unitSubArray:[UnitType] = (pickerModeDict[pickerMode!]?.first!)!
                        if unitSubArray.first !=  .year && unitSubArray.last ==  .day{
                            let destinationDate =  getDateAddOrReduceYear(date: maxD, isAdd: false)
                            
                            //如果最小日期超过最大日期一年后的范围
                            if tempMinDate.compare(destinationDate) == ComparisonResult.orderedAscending{
                                _minDate =  destinationDate
                            }
                        }
                    }
                }else{//最大日期没有值，如果模式需要限制在一年内
                    let unitSubArray:[UnitType] = (pickerModeDict[pickerMode!]?.first!)!
                    if unitSubArray.first !=  .year && unitSubArray.last ==  .day{
                        
                        //一年后的日期
                        let destinationDate:Date = self.getDateAddOrReduceYear(date: maxD, isAdd: false)
                        //修改掉
                        _minDate = destinationDate
                    }
                }
                
                //验证当前日期
                if let currentDate = self.date{
                    //判断当前日期是否在范围内
                    
                    if let tempMinDate = minDate{
                        //当前时间比最小时间
                        if currentDate.compare(tempMinDate) == ComparisonResult.orderedAscending{
//                            _date = tempMinDate
                            self.date = tempMinDate
                        }
                    }
                    
                    //判断最大日期的范围
                    if currentDate.compare(maxD) == ComparisonResult.orderedDescending{//当前时间比最大时间大
//                        _date =  maxD
                        self.date = maxD
                    }
                }else{
//                    _date =  maxD
                    self.date = maxD
                }

                
                //刷新
                toCurentDate(animated: false)
            }else
            {
                _maxDate = newValue
                
                //刷新
                toCurentDate(animated: false)
            }
            
        }
        get{
            if _maxDate ==  nil {
                let unitSubArray:[UnitType] = (pickerModeDict[pickerMode!]?.first!)!
                if unitSubArray.first !=  .year && unitSubArray.last ==  .day{
                    
                    //如果最大日期有值
                    if let tempMinDate = _minDate{
                        let destinationDate = getDateAddOrReduceYear(date: tempMinDate, isAdd: true)
                        
                        //设置时间
                        self.maxDate =  destinationDate
                    }else{
                        if let date = self.date{
                            //判断最小日期是否在一年的范围内
                            var addComps:DateComponents = DateComponents()
                            
                            //闰年
                            if self.isLeapYear(year: (self.currentDateCompnents?.year)!){
                                addComps.day = (366-1)/2
                            }else{
                                addComps.day = (365-1)/2
                            }
                            
                            //日期
                            let lastDate:Date = calendar.date(byAdding: addComps, to:date)!
                            
                            _maxDate =  lastDate
                        }
                    }
                    
                    
                }
            }
            
            return _maxDate
        }
    }
    
    /**
     *  当前日期
     */
    private var _date:Date?
    public var date:Date?
    {
        set{
            if let d =  newValue {
                if let tempMinD  = minDate{
                    if d.compare(tempMinD) == ComparisonResult.orderedAscending{
                        print("指定日期不在范围内")
                        return
                    }
                }
                if let tempMaxD = maxDate
                {
                    if d.compare(tempMaxD) == ComparisonResult.orderedDescending{
                        print("指定日期不在范围内")
                        return
                    }
                }
                
                
                //设置当前的comps
                currentDateCompnents =  calendar.dateComponents([.year,.day,.month,.hour,.minute,.second]
, from: d)
//                calendar.comp
                _date =  d
                
                 toCurentDate(animated: false)
             
                //刷新
                pickerView.reloadAllComponents()
            }
        }
        get{
            if let d = _date
            {
                return d
            }else
            {
                _date = Date()
                
                //设置当前的comps
                currentDateCompnents =  calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: _date!)
                
                return _date
            }
        }
    }
    
    
    //单位
    private var _unitDescDict:[UnitType:String]!
    private var unitDescDict:[UnitType:String]!{
        set{
            if let dict = newValue {
                _unitDescDict = dict
            }
        }
        get{
            if _unitDescDict == nil {
                _unitDescDict = [UnitType:String]()
                _unitDescDict[UnitType.year] = "年"
                _unitDescDict[UnitType.month] = "月"
                _unitDescDict[UnitType.day] = "日"
                _unitDescDict[UnitType.hour] = "时"
                _unitDescDict[UnitType.minute] = "分"
                _unitDescDict[UnitType.second] = "秒"
            }
            
            return _unitDescDict
        }
    }
    
    /**
     *  pickerModel
     */
    private var _pickerMode:JWDatePickerMode?
    public var pickerMode:JWDatePickerMode?{
        get{
            if _pickerMode == nil
            {
                _pickerMode =  JWDatePickerMode.dateAndTimeForAllComponent
                
            }
            
            return _pickerMode
        }
        set{
            if let mode = newValue {
                _pickerMode =  mode
                
                pickerView.reloadAllComponents()
                
                //切换模式必须滚动到指定
                toCurentDate(animated: false)
            }
        }
    }
    
    //用来记录 当前选中的年月
    private var tempDateCompnents:DateComponents = DateComponents()
    
    
    //用来记录当前date 的 DateComponents
    private var _currentDateCompnents:DateComponents?
    var currentDateCompnents:DateComponents?{
        set{
            if let comps = newValue
            {
                _currentDateCompnents = comps
            }else
            {
                _currentDateCompnents = newValue//可能为nil
            }
        }
        get {
            
            //如果等于 nil 去获取
            if  _currentDateCompnents == nil {
                //设置当前的comps
                _currentDateCompnents =  calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: date!)
            }
            return _currentDateCompnents
        }
    }
    
    //滚动到指定的日期
    func scrollToDate(date:Date?,animated:Bool)
    {
        
        if let d =  date {
            //赋值私有属性
//            _date =  d
            self.date = d
            
            //设置当前的comps
            currentDateCompnents =  calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: d)
            
            toCurentDate(animated: animated)
        }
    }
    
    
    /**
     *  是否是闰年
     */
    public func isLeapYear(year:Int) -> Bool {
        if (year%4==0) {
            if (year%100==0) {
                if (year%400==0) {
                    return true
                }
                //能被 4 100  整除 不能被400 整除的 不是闰年
                return false
            }
            //能被4整除 不能被100整除的 是闰年
            return true
        }
        //不能为4整除 不是闰年
        return false
        
    }
    
    /**
     *  根据对应的年 和月  返回当月对应的天数
     */
   public func numberOfDaysInMonth(year:Int,month:Int) -> Int {
        // 31  28  31  30  31  30  31  31  30  31  30  31
        let daysOfMonth:[Int] = [31,28,31,30,31,30,31,31,30,31,30,31]
        
        let index:Int = (month - 1)
        var  days:Int = daysOfMonth[index]
        
        if (days == 28) {
            if (isLeapYear(year: year)){
                days = 29
            }
        }
        return days
        
    }

    /**
     *  获取一天中的  最小时间   最大时间
     */
   public func dayFirstOrLastDate(date:Date,isLast:Bool) -> Date {
        let dateComps:DateComponents = calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: date)
        let hour:Int = dateComps.hour!
        let minute:Int = dateComps.minute!
        let second:Int = dateComps.second!
        
        var newDateComps:DateComponents =  DateComponents()
        if (isLast) {
            newDateComps.hour = 24 - hour - 1;
            newDateComps.minute = 60 - minute - 1
            newDateComps.second = 60 - second - 1
        }else
        {
            newDateComps.hour = -hour;
            newDateComps.minute = -minute;
            newDateComps.second = -second;
        }
        
        let d:Date = calendar.date(byAdding: newDateComps, to: date)!
        return d

    }
    
    
    
    //MARK:私有属性
    
    //开启后 如果 最大日期 或者 最小日期有值 则单向或者双向有限制 否则无效  默认不开启限制
    private var _enableLimited:Bool?
    public var enableLimited:Bool?{
        set{
            if let enable = newValue{
                _enableLimited = enable
                
                pickerView.reloadAllComponents()
                
                //刷新时间
                toCurentDate(animated: true)
            }
        }
        get{
            if let enable = _enableLimited{
                return enable
            }else
            {
                return false
            }
        }
    }

 
    //[.year,.day,.month,.hour,.minute,.second]    private let [.year,.day,.month,.hour,.minute,.second]:[UnitType] = [.year,.day,.month,.hour,.minute,.second]

 
    //记录 当前日期选中
    private var sourceCompnentRowDict:[Int:Int] = [Int:Int]()
    
    //Calendar
    private let calendar:Calendar = Calendar(identifier: Calendar.Identifier.gregorian)//NSCalendar(identifier: Calendar.Identifier.gregorian)
    
    //MARK:控件
    
    /**
     *  pickerView
     */
    private var pickerView:UIPickerView = UIPickerView()
    
    
    //日期选择控件模式
    private var pickerModeDict:[JWDatePickerMode:[[UnitType]]] = {
        var pickerMode:[JWDatePickerMode:[[UnitType]]] =  [JWDatePickerMode:[[UnitType]]]()
        
          // 年月日 时 分 秒
          pickerMode[.dateAndTime] = [[ .year, .month, .day],[ .hour],[ .minute],[ .second]]
        
          //  月日 时 分 秒
          pickerMode[.dateAndTimeRYear] = [[ .month, .day],[ .hour],[ .minute],[ .second]]
        
          //  年月日 时
          pickerMode[.dateAndHour] = [[ .year, .month, .day],[ .hour]]

        
          // 时分秒
          pickerMode[.time] = [[ .hour],[ .minute],[ .second]]
        
          //时分
          pickerMode[.timeRSecond] = [[ .hour],[ .minute]]
        
          // 年月日
          pickerMode[.date] = [[ .year],[ .month],[ .day]]
        
          // 年 月 日 时
          pickerMode[.dateAddHour] = [[ .year, .month, .day],[ .hour]]
        
          // 年月日  时 分
          pickerMode[.dateAndTimeRSecond] = [[ .year, .month, .day],[ .hour],[ .minute]]
        
          //月日 时 分
          pickerMode[.dateAndTimeRYearAndSecond] = [[ .month, .day],[ .hour],[ .minute],[ .second]]
        
          //年 月  日  时  分 秒
         pickerMode[.dateAndTimeForAllComponent] = [[ .year],[ .month],[ .day],[ .hour],[ .minute],[ .second]]
        
        return pickerMode
    }()
    
    //初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(pickerView)
        
        currentIndex = MaxRangeValue/2
        
        pickerView.dataSource =  self
        
        //跳到当前日期
        toCurentDate(animated: false)
        
        pickerView.delegate =  self
        
    }
    
    required public
    init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK:pickerView代理和数据源
   public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        //1.获取当前模式
        let unitArray:[[UnitType]] = pickerModeDict[pickerMode!]!
        
        //2.返回该模式下的components
        return unitArray.count
    }
    
    
   public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //1.获取当前模式
        let unitArray:[[UnitType]] = pickerModeDict[pickerMode!]!
        //2.判断类型
        
        var rows =  1
        
        let  unitSubArray:[UnitType] = unitArray[component]
        
        let unit:UnitType = unitSubArray.last!
        
        //3.分类型处理
        switch unit {
        case  .year:
            //判断限制模式
            if  limitedEnable() {
                //开启了限制返回数据源
                rows =  numberOfRowsInComponetForLimited(component: component,unit: unit)
            }else
            {
                rows  = MaxRangeValue
            }
            break
        case  .month:
            //判断限制模式
            if  limitedEnable() {
                //开启了限制返回数据源
                rows =  numberOfRowsInComponetForLimited(component: component,unit: unit)
            }else{
                //默认12
                rows = 12
                //第一组的最后一个是 month
                if component == 0 {
                    rows =  MaxRangeValue
                }
            }
            break
        case  .day:
            //判断限制模式
            if  limitedEnable() {
                //开启了限制返回数据源
                rows =  numberOfRowsInComponetForLimited(component: component,unit: unit)
            }else{
                //第一组的最后一个是 days
                if component == 0 {
                    rows = MaxRangeValue
                    if unitSubArray.first !=  .year && unitSubArray.last ==  .day{//如果第一个是月份
                        if isLeapYear(year: (currentDateCompnents?.year)!) {
                            rows =  366-1
                        }else{
                            rows  = 355-1
                        }
                    }
                }else//不是第一组 说明需要考虑 选完月份后 该月的天数问题
                {
                    rows =  numberOfDaysInMonth(year:tempDateCompnents.year!, month: tempDateCompnents.month!)
                }
            }
            break
        case  .hour:
            rows = 24//无论是否开启  数据源 公用
            break
        case  .minute:
            rows  = 60
            break
        case  .second:
            rows = 60
            break
        default:
            
            break
        }
        return rows
    }
    
    
    //获取标题
    internal func  pickerViewTitle(forRow row:Int,forComponent component:Int) -> String {
        
        self.currentOperationComponent =  component
        
        //1.计算增量
        var addComps:DateComponents =  DateComponents()
        
        //2.获取当前模式
        let unitArray:[[UnitType]] = pickerModeDict[pickerMode!]!
        let unitSubArray:[UnitType] = unitArray[component]
        let unit:UnitType = unitSubArray.last!
        
        
        //3.判断是否第一组
        if component == 0 {
            //计算偏差
            switch unit {
            case  .year:
                addComps.year =  row - sourceCompnentRowDict[component]!
                break
            case  .month:
                addComps.month =  row - sourceCompnentRowDict[component]!
                break
            case  .day:
                addComps.day =  row - sourceCompnentRowDict[component]!
                break
            default:
                //剩下的时分秒
                return String(format:"%02zd%@",row,unitDescDict[unit]!)
//                break
            }
            
            
            let tempDate:Date? =  calendar.date(byAdding: addComps, to: date!)
            
            if let tDate:Date = tempDate {
                let dateComps:DateComponents =  calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: tDate)
                
                return getTitle(comps: dateComps, component:component)
            }else
            {
                return "title nil"
            }
        }else
        {
            if unit ==  .month || unit ==  .day{
                return String(format:"%02zd%@",row+1,unitDescDict[unit]!)
            }else{
                return String(format:"%02zd%@",row,unitDescDict[unit]!)
            }
            
        }
    }
    
    
    
   public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        //1.获取当前模式
        let unitArray:[[UnitType]] = pickerModeDict[pickerMode!]!
        
        //2.计算全部的个数
        var totalCount:Int =  0
        var totalComponentCount:Int = 0
        
        var tempComponent = 0
        for unitSubArray:[UnitType]  in unitArray{
            for unit:UnitType in unitSubArray {
                var add:Int = (1 + ( unitDescDict[unit]?.characters.count)!) 
                // 年的话，加位
                if unit ==  .year {
                    add += 1
                }
                //计算总长
                totalCount += add
                //计算当前
                if tempComponent == component {
                    totalComponentCount += add
                }
            }
            tempComponent += 1
        }
        
        //3.更合理的划分
        let width:CGFloat = (pickerView.bounds.width - 20.0)
        let baseWidth:CGFloat = width/CGFloat(unitArray.count)
        let mutiWidth:CGFloat = width -  baseWidth
        
        //4.计算宽度
        let componentWidth:CGFloat = CGFloat(totalComponentCount)/CGFloat(totalCount)*mutiWidth + (baseWidth/CGFloat(unitArray.count))
        
        return componentWidth
        
    }
    
    //返回选项高度
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.bounds.height/5
    }

    
    //返回label
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let title:String = pickerViewTitle(forRow: row, forComponent: component)
        
        var label:UILabel? = nil
        
        if view != nil {
            label = view as! UILabel?
        }else{
            label = UILabel()
            label?.textAlignment = NSTextAlignment.center
//            Font_120_218_317_416_515_614_712_810_908
            label?.font = UIFont.systemFont(ofSize: 18)
            label?.text = title
        }
        return label!
    }
    
    
    //选择停止
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //优化掉
        if self.currentOperationComponent != component{
            return
        }
        
        //1.获取当前模式
        let unitArray:[[UnitType]] = pickerModeDict[pickerMode!]!
        
        //2.遍历 每一组最后一个
        var tempComponent:Int = 0
        
        //用来加减
        var addDateComps:DateComponents =  DateComponents()
        
        for unitSubArray:[UnitType] in unitArray
        {
            //当前选中
            var currentRow:Int = pickerView.selectedRow(inComponent: tempComponent)
            if component == tempComponent {
                currentRow =  row
            }
            //单位
            let unit:UnitType = unitSubArray.last!
            
            
            //分类型处理
            switch unit {
            case  .year:
                addDateComps.year = currentRow - sourceCompnentRowDict[tempComponent]!
                break
            case  .month:
                addDateComps.month = currentRow - sourceCompnentRowDict[tempComponent]!
                break
            case  .day:
                //如果不是第一组才需要验证
                if tempComponent != 0 {
                    //验证日期 因为每一月的天数不一样
                    //1.第一步先计算当前步骤选中的年月
                    let tempDate:Date? = calendar.date(byAdding: addDateComps, to: self.date!)
                    let tempDateComps:DateComponents =  calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: tempDate!)
                    tempDateCompnents.year =  tempDateComps.year
                    tempDateCompnents.month =  tempDateComps.month
                    //2.获取天数
                    let days:Int = numberOfDaysInMonth(year: tempDateComps.year!, month: tempDateComps.month!)
                    //3.判断当前选择项是否越界
                    if  currentRow > days - 1 {//假如目前为 12月 则 31天  索引  30 ，当选择至11月 则 30天  索引 29  若日期为 12月31 则选择回11月30，最大索引变为29 但当前索引为30 则会越界
                        
                        //先选回29再刷新  防止越界闪退
                        pickerView.selectRow(days - 1, inComponent: tempComponent, animated: false)
                        
                        //更新掉 sourceCompentRowDict 和 currentRow
                        currentRow =  days - 1
                    }
                    //刷新月份coponent 不同的月份天数不同 随时更新
                    pickerView.reloadComponent(tempComponent)
                }
                
                //计算时间
                addDateComps.day =  currentRow - sourceCompnentRowDict[tempComponent]!
                break
            case  .hour:
                addDateComps.hour = currentRow - sourceCompnentRowDict[tempComponent]!
                break
            case  .minute:
                addDateComps.minute = currentRow - sourceCompnentRowDict[tempComponent]!
                break
            case  .second:
                addDateComps.second = currentRow - sourceCompnentRowDict[tempComponent]!
                break
            default:
                
                break
            }
            tempComponent += 1
        }
        
        let date:Date? = calendar.date(byAdding: addDateComps, to: self.date!)
        if let d =  date {

            //标记
            var compareFlag:Bool = true
            
            //如果存在最小的时间
            if let minD:Date = minDate {
                //当前日期小于最小日期
                if(d.compare(minD) == ComparisonResult.orderedAscending){
                    if let closure =  didSelectedDateClosure
                    {
                        closure(minD)
                    }
                    scrollToDate(date: minD, animated: true)
                    compareFlag = false
                }
            }
            
            //如果存在最大时间
            if let maxD:Date = maxDate {
                //当前日期大于当前日期
                if(d.compare(maxD) == ComparisonResult.orderedDescending){
                    if let closure =  didSelectedDateClosure
                    {
                        closure(maxD)
                    }
                    scrollToDate(date: maxD, animated: true)
                    compareFlag = false
                }
            }
            
            //日期已定
            if compareFlag
            {
                //如果未开启限制模式，则自动滚动 无限滚动
 
                scrollToDate(date: d, animated: false)
                if let closure =  didSelectedDateClosure
                {
                    closure(d)
                }
            }
        }
    }
    
    
    //滚动到指定页
    internal func toCurentDate(animated:Bool) {
        
        tempDateCompnents.year =  currentDateCompnents?.year
        tempDateCompnents.month = currentDateCompnents?.month
        
        //1.获取当前模式
        let unitArray:[[UnitType]] = pickerModeDict[pickerMode!]!
        
        //2.设置选中
        var comps:DateComponents =  currentDateCompnents!
        
        //3.分类型处理
        var component:Int =  0
        var tempRow:Int = 0
        for unitSubArray:[UnitType] in unitArray{
            let unit:UnitType =  unitSubArray.last!
            
            switch unit {
                case  .year:
                    //判断限制模式
                    if  limitedEnable() {
                        //开启了限制返回数据源
                        tempRow = selectedRowInComponentForLimited(component: component, unit: unit)
                    }else{
                            //第一组的最后一个是 year
                            tempRow =  currentIndex!
                    }
                    break
                case  .month:
                    //判断限制模式
                    if  limitedEnable() {
                        //开启了限制返回数据源
                        tempRow = selectedRowInComponentForLimited(component: component, unit: unit)
                    }else{
                        if  component == 0 {
                            //第一组的最后一个是 month
                            tempRow = currentIndex!
                        }else
                        {
                            //指向 month
                            tempRow = comps.month!-1
                        }
                    }
                    break
                case  .day:
                    //判断限制模式
                    if  limitedEnable() {
                        //开启了限制返回数据源
                        tempRow = selectedRowInComponentForLimited(component: component, unit: unit)
                    }else{
                        if component == 0{
                            if unitSubArray.first !=  .year && unitSubArray.last ==  .day {//如果第一个是月份 即不是年
                                if isLeapYear(year: (currentDateCompnents?.year)!) {
                                    //第一组的最后一个是 Day
                                    tempRow = (366-1)/2-1
                                }else{
                                    //第一组的最后一个是 Day
                                    tempRow = (365-1)/2-1
                                }
                            }else{
                                //第一组的最后一个是 Day
                                tempRow = currentIndex!
                            }
                        }else
                        {
                            //指向 day
                            tempRow = comps.day! - 1
                        }
                    }
                    break
                case  .hour:
                    //判断限制模式
                    if  limitedEnable() {
                        //开启了限制返回数据源
                        tempRow = selectedRowInComponentForLimited(component: component, unit: unit)
                    }else{
                           //指向 hour
                        tempRow = comps.hour!
                    }
                break
                case  .minute:
                    //判断限制模式
                    if  limitedEnable() {
                        //开启了限制返回数据源
                        tempRow = selectedRowInComponentForLimited(component: component, unit: unit)
                    }else{
                        //指向 minute
                        tempRow = comps.minute!
                    }
                    break
                case  .second:
                    //判断限制模式
                    if  limitedEnable() {
                        //开启了限制返回数据源
                        tempRow = selectedRowInComponentForLimited(component: component, unit: unit)
                    }else{
                        //指向 second
                        tempRow = comps.second!
                    }
                    break
                default:
                    //
                break
            }
            
            //滑动到指定选项
            pickerView.selectRow(tempRow, inComponent: component, animated:
                animated)
            //存储
            sourceCompnentRowDict[component] = tempRow
            
            component += 1
            
            
        }
        pickerView.reloadAllComponents()
    }
    
    //布局
    override public func layoutSubviews() {
        super.layoutSubviews()

        let pickerX:CGFloat = 0
        let pickerY:CGFloat = 0
        let pickerW:CGFloat = bounds.width
        let pickerH:CGFloat = bounds.height
        pickerView.frame =  CGRect(x: pickerX, y: pickerY, width: pickerW, height: pickerH)
    }
    
    
    //获取标题
    internal func getTitle(comps:DateComponents,component:Int) -> String
    {
        var m_str:String = String()
        
        //1.获取当前模式
        let unitArray:[[UnitType]] = pickerModeDict[pickerMode!]!
        let subArray:[UnitType] = unitArray[component]
        
        for unit:UnitType in subArray{
            //分类型处理
            switch unit {
            case  .year:
                m_str.append(String(format: "%04zd%@", comps.year!,unitDescDict[unit]!))
                break
            case  .month:
                m_str.append(String(format: "%02zd%@", comps.month!,unitDescDict[unit]!))
                break
            case  .day:
                m_str.append(String(format: "%02zd%@", comps.day!,unitDescDict[unit]!))
                break
            case  .hour:
                m_str.append(String(format: "%02zd%@", comps.hour!,unitDescDict[unit]!))
                break
            case  .minute:
                m_str.append(String(format: "%02zd%@", comps.minute!,unitDescDict[unit]!))
                break
            case  .second:
                m_str.append(String(format: "%02zd%@", comps.second!,unitDescDict[unit]!))
                break
            default:
                
                break
            }
        }
        return m_str
    }

    
    //MARK:用于开始限制功能部分
    
    //获取限制状态
    internal func limitedEnable() -> Bool {
  
        //如果未开启
        if(!enableLimited!)
        {
            let unitSubArray:[UnitType] = (pickerModeDict[pickerMode!]?.first!)!
            if unitSubArray.first !=  .year && unitSubArray.last ==  .day{
               return true
            }
        }
        //默认
        return enableLimited!
        
    }
    
    //限制情况下的 数据源
    internal func numberOfRowsInComponetForLimited(component:Int,unit:UnitType) -> Int {
            //当前情况下表示第一个
            let minD:Date? =  minDate
            //当前情况下表示第一个
            let maxD:Date? = maxDate
        
            var numberOfRows = 0

            //分类型处理
            switch unit {
                case  .year:
                    if  minD != nil && maxD != nil {//都有值
                        numberOfRows =  calendar.dateComponents([.year], from: getDateRemoveStopLastUnit(date: minD!, lastUnit: .year ,isFromDate: true), to: getDateRemoveStopLastUnit(date: maxD!, lastUnit: .year,isFromDate: false)).year!+1
                    }else{
                        numberOfRows =  MaxRangeValue
                    }
                    break
                case  .month:
                    if component == 0 {
                        if  minD != nil && maxD != nil {//都有值
                             numberOfRows =  calendar.dateComponents([.month], from: getDateRemoveStopLastUnit(date: minD!, lastUnit: .year,isFromDate: true), to: getDateRemoveStopLastUnit(date: maxD!, lastUnit: .year,isFromDate: false)).month!
                        }else{
                             numberOfRows = MaxRangeValue
                        }
                    }else
                    {
                        numberOfRows = 12
                    }
                    break
                case  .day:
                    if component == 0 {
                            if  minD != nil && maxD != nil {//都有值
                                    numberOfRows =  calendar.dateComponents([.day], from: getDateRemoveStopLastUnit(date: minD!, lastUnit: .day,isFromDate: true), to: getDateRemoveStopLastUnit(date: maxD!, lastUnit: .day,isFromDate: false)).day!+1
                            }else if minD == nil && maxD == nil {
                                if  isLeapYear(year: (self.currentDateCompnents?.year!)!) {
                                    numberOfRows = 366-1
                                }else
                                {
                                    numberOfRows = 365-1
                                }
                            }else if minD != nil{//只有最小日期
                                let comps:DateComponents = calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: minD!)
                                if  isLeapYear(year: (comps.year!)) {
                                    numberOfRows = 366-1
                                }else
                                {
                                    numberOfRows = 365-1
                                }
                            }else if maxD != nil{
                                let comps:DateComponents = calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: maxD!)
                                if  isLeapYear(year: (comps.year!)) {
                                    numberOfRows = 366
                                }else
                                {
                                    numberOfRows = 365
                                }
                            }
                    }else
                    {
                        numberOfRows = numberOfDaysInMonth(year:tempDateCompnents.year!, month: tempDateCompnents.month!)
                    }
                    break
                case  .hour:
                    numberOfRows = 24
                    break
                case  .minute:
                    numberOfRows = 60
                    break
                case  .second:
                    numberOfRows = 60
                    break
                default:
                    
                    break
            }
        return numberOfRows
    }
 
    //选中row
    internal func  selectedRowInComponentForLimited(component:Int,unit:UnitType) -> Int {
        
        //当前情况下表示第一个
        let minD:Date? =  minDate
        //当前情况下表示第一个
        let maxD:Date? = maxDate
        
        var selectedRows:Int = 0
        
        //分类型处理
        switch unit {
        case  .year:
            if  minD != nil{//都有值
                selectedRows =  calendar.dateComponents( [.year], from: getDateRemoveStopLastUnit(date: minD!, lastUnit:  .year,isFromDate: true), to: getDateRemoveStopLastUnit(date: date!, lastUnit:  .year,isFromDate: false)).year!
            }else if maxD != nil {
                selectedRows = MaxRangeValue - calendar.dateComponents([.year], from: getDateRemoveStopLastUnit(date: date!, lastUnit:  .year,isFromDate: true), to: getDateRemoveStopLastUnit(date: maxD!, lastUnit:  .year,isFromDate: false)).year!
            }else if minD != nil && maxD != nil{
                selectedRows =  calendar.dateComponents([.year], from: getDateRemoveStopLastUnit(date: minD!, lastUnit:  .year,isFromDate: true), to: getDateRemoveStopLastUnit(date: date!, lastUnit:  .year,isFromDate: false)).year!
            }
            break
        case  .month:
                if component == 0 {
                     if  minD != nil && maxD != nil  {//都有值
                       selectedRows = calendar.dateComponents([.month], from: getDateRemoveStopLastUnit(date: minD!, lastUnit:  .month,isFromDate: true), to:getDateRemoveStopLastUnit(date: maxD!, lastUnit:  .month,isFromDate: false)).month!
                     }else if minD == nil && maxD == nil {
                        selectedRows = currentIndex!
                     }else if minD != nil{
                        selectedRows = calendar.dateComponents([.month], from: getDateRemoveStopLastUnit(date: minD!, lastUnit:  .month,isFromDate: true), to: getDateRemoveStopLastUnit(date: maxD!, lastUnit:  .month,isFromDate: false)).month!
                     }else if maxD != nil{
                         selectedRows = MaxRangeValue - calendar.dateComponents([.month], from: getDateRemoveStopLastUnit(date: date!, lastUnit:  .month,isFromDate: true), to: getDateRemoveStopLastUnit(date: maxD!, lastUnit:  .month,isFromDate: false)).month!
                     }
                }else
                {
                    if minD != nil && maxD != nil{
                        selectedRows = (currentDateCompnents?.month)! - 1
                    }else{
                        selectedRows = currentIndex!
                    }
                }
            break
        case  .day:
                 if component == 0 {
                        if  minD != nil && maxD != nil {//都有值
                            selectedRows =  calendar.dateComponents([.day], from: getDateRemoveStopLastUnit(date: minD!, lastUnit:  .day,isFromDate: true), to: getDateRemoveStopLastUnit(date: date!, lastUnit: .day,isFromDate: false)).day!
                        }else if minD == nil && maxD == nil {
                            if  isLeapYear(year: (self.currentDateCompnents?.year!)!) {
                                selectedRows =  (366-1)/2
                            }else
                            {
                                selectedRows = (365-1)/2
                            }
                        }else if minD != nil{
                            selectedRows = calendar.dateComponents( [.day], from: getDateRemoveStopLastUnit(date: minD!, lastUnit:  .day,isFromDate: true), to: getDateRemoveStopLastUnit(date: date!, lastUnit:  .day,isFromDate: false)).day!
 
                        }else if maxD != nil{
                            let comps:DateComponents = calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: maxD!)
                            if  isLeapYear(year: (comps.year!)) {
 
                                selectedRows = 366 - 1 - calendar.dateComponents( [.day], from: getDateRemoveStopLastUnit(date: date!, lastUnit:  .day,isFromDate: true), to: getDateRemoveStopLastUnit(date: maxD!, lastUnit:  .day,isFromDate: false)).day!
                            }else
                            {
                                selectedRows = 365 - 1 - calendar.dateComponents([.day], from: getDateRemoveStopLastUnit(date: date!, lastUnit:  .day,isFromDate: true), to: getDateRemoveStopLastUnit(date: maxD!, lastUnit: .day,isFromDate: false)).day!
                            }
                        }
                }else
                {
                    selectedRows = (currentDateCompnents?.day!)!-1//索引
                }
            break
        case  .hour:
            selectedRows = (currentDateCompnents?.hour!)!
            break
        case  .minute:
            selectedRows = (currentDateCompnents?.minute!)!
            break
        case  .second:
            selectedRows = (currentDateCompnents?.second!)!
            break
        default:
            
            break
        }
        return selectedRows
    }
    
    
    //获取一个日期 对应的 前后一年内人的日期
    private func getDateAddOrReduceYear(date:Date,isAdd:Bool) -> Date {
        //判断最小日期是否在一年的范围内
        var addComps:DateComponents = DateComponents()
        if isAdd{
            addComps.year = 1
            addComps.day = -1
        }else{
            addComps.year = -1
            addComps.day = 1
        }
        
        //日期
        let lastDate:Date = calendar.date(byAdding: addComps, to:date)!
        
        return  lastDate
    }
    
    
    //去掉多余的日期部分，保证计算日期的差的准确度
    public func  getDateRemoveStopLastUnit(date:Date,lastUnit:UnitType,isFromDate:Bool) -> Date {
        //初始化
        let unitArray:[UnitType] = [ .year, .month, .day, .hour, .minute, .second]
        
        let dateComps:DateComponents = self.calendar.dateComponents([.year,.day,.month,.hour,.minute,.second], from: date)
        
        
        var flag:Bool = true
        var addDateComps:DateComponents = DateComponents()
        
        //遍历
        for unitRawValue in unitArray{
            switch unitRawValue {
            case  .year:
                if flag {
                    addDateComps.year = 0 
                }else{
                    addDateComps.year = -(dateComps.year)!
                }
                //判断
                if unitRawValue == lastUnit{
                    flag = false
                }
                break
            case  .month:
                if flag {
                    addDateComps.month = 0
                }else{
                    addDateComps.month = -(dateComps.month)!
                }
                //判断
                if unitRawValue == lastUnit{
                    flag = false
                }
                break
            case  .day:
                if flag {
                    addDateComps.day = 0
                }else{
                    addDateComps.day = -(dateComps.day)!
                }
                //判断
                if unitRawValue == lastUnit{
                    flag = false
                }
                break
            case  .hour:
                if flag {
                    addDateComps.hour = 0
                }else{
                    addDateComps.hour = -(dateComps.hour)!
                }
                //判断
                if unitRawValue == lastUnit{
                    flag = false
                }
                break
            case  .minute:
                if flag {
                    addDateComps.minute = 0
                }else{
                    addDateComps.minute = -(dateComps.minute)!
                }
                //判断
                if unitRawValue == lastUnit{
                    flag = false
                }
                break
            case  .second:
                if flag {
                    addDateComps.second = 0
                }else{
                    addDateComps.second = -(dateComps.second)!
                }
                //判断
                if unitRawValue == lastUnit{
                    flag = false
                }
                break
            default:
                break
            }
        }
        
        if !isFromDate{
            addDateComps.second = 1
        }
            
        let lastDate:Date = self.calendar.date(byAdding: addDateComps, to: date)!
        
        return lastDate
    }
}
