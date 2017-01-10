//
//  JWCalendarViewController.swift
//  KitDemo
//
//  Created by 朱建伟 on 2017/1/4.
//  Copyright © 2017年 zhujianwei. All rights reserved.
//

import UIKit


//如果要修改不同状态按钮的颜色，修改它

//不在范围内
let dayNoneColor:UIColor = UIColor.white
let dayNoneTextColor:UIColor = UIColor(white: 0.7, alpha: 1)

//普通
let dayNormalColor:UIColor = UIColor.white
let dayNormalTextColor:UIColor = UIColor(white: 0.1, alpha: 1)

//选中
let daySelectedColor:UIColor = UIColor.red
let daySelectedTextColor:UIColor = UIColor.white

//禁用
let dayDisabledColor:UIColor = UIColor.green
let dayDisabledTextColor:UIColor = UIColor.white


//协议
public protocol JWCalendarViewControllerDelegate:NSObjectProtocol {
    
    //点击了确定
    func calendarViewController(calendarViewController:JWCalendarViewController,clickConfirm daySelectdItems:[(Date,DateComponents,DayItemState)],and dayDisabledItems:[(Date,DateComponents,DayItemState)]);
    
    //点击了单天
    func  calendarViewController(calendarViewController:JWCalendarViewController,didSelectedDate dayItems:(Date,DateComponents,DayItemState))
}


public class JWCalendarViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource{

    //是否开启网格模式
   public  var enableGrid:Bool = true{
        didSet{
            self.collectionView?.reloadData()
        }
    }
    
    public weak var delegate:JWCalendarViewControllerDelegate?
    
    //单选
    public var singleSelected:Bool = false{
        willSet{
            //单选
            if !singleSelected{
                if let item = self.navigationItem.rightBarButtonItem{
                    item.title = "确定"
                    
                    item.isEnabled = true
                }
            }else{
                if let item = self.navigationItem.rightBarButtonItem{
                    item.title = ""
                    item.isEnabled = false
                }
            }
        }
    }
    
    
   public  var minDate:Date = Date(){
        willSet{
            
                if self.maxDate == nil{
                    self.maxDate = calendar.date(byAdding: .month, value: maxRange, to:newValue)
                }else{
                    
                    let dayOffset:Int = calendar.dateComponents([.day], from:self.getDateRemoveStopLastUnit(date:newValue, lastUnit: .month, isFromDate: true), to:self.getDateRemoveStopLastUnit(date:self.maxDate!, lastUnit: .month, isFromDate: false)).day!+1
                    
                    if dayOffset < 1{
                        self.maxDate = calendar.date(byAdding: .month, value: maxRange, to:newValue)
                    }
                    
                }
            
            
            self.removeAll(forState: DayItemState.none)
            let dateComps:DateComponents =  calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from:newValue)
            self.addDateCompsArray(dateCompsCount: dateComps.day!-1, usingClosure: {(index) in
                var comps:DateComponents =  DateComponents()
                comps.year = dateComps.year
                comps.month = dateComps.month
                comps.day = index + 1
                return (comps,DayItemState.none)
            })
            
        }
    }
    
    public var maxDate:Date?{
        willSet{
            if let maxDate = newValue{
                
                 let dayOffset:Int = calendar.dateComponents([.day], from:self.getDateRemoveStopLastUnit(date:self.minDate, lastUnit: .month, isFromDate: true), to:self.getDateRemoveStopLastUnit(date:maxDate, lastUnit: .month, isFromDate: false)).day!+1
                
                if dayOffset < 1{
                    self.minDate = calendar.date(byAdding: .month, value: -maxRange, to:maxDate)!
                }
                
                
                self.removeAll(forState: DayItemState.none)
                let dateComps:DateComponents =  calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from:maxDate)
                self.addDateCompsArray(dateCompsCount:numberOfDaysInMonth(year:dateComps.year!, month: dateComps.month!) - dateComps.day!, usingClosure: {(index) in
                    var comps:DateComponents =  DateComponents()
                    comps.year = dateComps.year
                    comps.month = dateComps.month
                    comps.day = dateComps.day! + index + 1
                    return (comps,DayItemState.none)
                })

            }
        }
    }
    
    private var currentDate:Date?
    
    
    //展示某天
    public func scrollToCurrent(dateComps:DateComponents,animated:Bool){
        if let date = calendar.date(from: dateComps){
            scrollToCurrent(date: date, animated: animated)
        }
    }
    
    
    //展示某天
    public func scrollToCurrent(date:Date,animated:Bool){
        //比最小时间小 retrun
        if date.compare(self.minDate) == .orderedAscending{
            return
        }
        
        //如果有最大值
        if let maxDate =  self.maxDate{
            //比最大值大
            if maxDate.compare(date) == .orderedAscending{
                return
            }
        }else{
            
            let monthOffset:Int = calendar.dateComponents([.month], from:self.getDateRemoveStopLastUnit(date:self.minDate, lastUnit: .month, isFromDate: true), to:self.getDateRemoveStopLastUnit(date:date, lastUnit: .month, isFromDate: false)).month!+1
            
            
            if monthOffset < maxRange{
                
                if let colletionView = self.collectionView{
                    colletionView.scrollToItem(at: IndexPath(item: 0, section: monthOffset), at: UICollectionViewScrollPosition.centeredVertically, animated: animated)
                    
                    self.currentDate = nil
                }else{
                    
                    self.currentDate = date
                }
            }
        }
    }
    
    
    //添加日期
   public func addDate(date:Date,forState state:DayItemState)  {
        let dateComps = calendar.dateComponents([.year,.month,.day,.weekday], from: date)
        let monthCountKey:Int = numberOfDaysInMonth(year: dateComps.year!, month: dateComps.month!)
        
        let dayKey:String = String(format:"%zd-%zd-%zd",dateComps.year!,dateComps.month!,dateComps.day!)
        
        if state == .selected{
            self.selectedCount = self.selectedCount + 1
        }
        
        self.daysContainer[monthCountKey]?[dateComps.day! - 1][dayKey] = (date,dateComps,state)
    }
    
    
    //添加日期
   public func addDate(dateComps:DateComponents,forState state:DayItemState)  {
        
        let tempDate:Date? =  calendar.date(from: dateComps)
        
        let monthCountKey:Int = numberOfDaysInMonth(year: dateComps.year!, month: dateComps.month!)
        
        
        let dayKey:String = String(format:"%zd-%zd-%zd",dateComps.year!,dateComps.month!,dateComps.day!)
        
        if let date = tempDate{
            self.daysContainer[monthCountKey]?[dateComps.day! - 1][dayKey] = (date,dateComps,state)
            
            if state == .selected{
                self.selectedCount = self.selectedCount + 1
                
            }
        }
        
    }
    
    //添加日期
   public func addDates(dateArray:[Date],forState state:DayItemState) {
        for date in dateArray{
            addDate(date: date, forState: state)
        }
    }

    
    //  closure 参数 Int:index 索引   返回 Date DateItemState
   public func addDateArray(dateCount:Int,usingClosure:@escaping (Int)->(Date,DayItemState)) {
        for index in 0..<dateCount{
            let result = usingClosure(index)
            addDate(date: result.0, forState: result.1)
        }
    }
    
    
    
    //添加日期
   public func addDates(dateCompsArray:[DateComponents],forState state:DayItemState) {
        for dateComps in dateCompsArray{
            addDate(dateComps: dateComps, forState: state)
        }
    }
    
    
    //  closure 参数 Int:index 索引   返回 Date DateItemState
   public func addDateCompsArray(dateCompsCount:Int,usingClosure:@escaping (Int)->(DateComponents,DayItemState)) {
        for index in 0..<dateCompsCount{
            let result = usingClosure(index)
            addDate(dateComps: result.0, forState: result.1)
        }
    }

    
    //移除所有
   public func  removeAll(){
        
        for (_,group) in self.daysContainer{
            for var dayDict in group {
                dayDict.removeAll()
            }
        }
        
        self.selectedCount = 0
        
        self.collectionView?.reloadData()
    }
    
    //移除所有
   public func  removeAll(forState state:DayItemState){
        
        for (_,group) in self.daysContainer{
            for var dayDict in group {
                
                var removeKeys:[String] = [String]()
                
                for (dayKey,Item) in dayDict{
                    
                    if Item.2 == state {
                        if state == .selected{
                            self.selectedCount = self.selectedCount - 1
                        }
                        removeKeys.append(dayKey)
                    }
                }
                
                //移除
                for key in removeKeys{
                    dayDict.removeValue(forKey: key)
                }
                
            }
        }
        
        self.collectionView?.reloadData()
    }

    
    //移除日期
  public  func removeDate(date:Date)  {
        
        let dateComps = calendar.dateComponents([.year,.month,.day,.weekday], from: date)
        
        let monthCountKey:Int = numberOfDaysInMonth(year: dateComps.year!, month: dateComps.month!)
        
        let dayKey:String = String(format:"%zd-%zd-%zd",dateComps.year!,dateComps.month!,dateComps.day!)
        
        
        
        if let dayItem = self.daysContainer[monthCountKey]?[dateComps.day! - 1].removeValue(forKey: dayKey)
        {
            if dayItem.2 == .selected{
                self.selectedCount = self.selectedCount - 1
            }
        }
    }
    
    
    //移除日期
   public func removeDates(dateArray:[Date]) {
        for date in dateArray{
            removeDate(date: date)
        }
    }
    
    //  closure 参数 Int:index 索引   返回 Date
   public func removeDates(dateCount:Int,usingClosure:@escaping (Int)->Date) {
        for index in 0..<dateCount{
            let date = usingClosure(index)
            removeDate(date:date)
        }
    }
    
    
    //添加日期
  public  func removeDate(dateComps:DateComponents)  {
      
        let monthCountKey:Int = numberOfDaysInMonth(year: dateComps.year!, month: dateComps.month!)
        
        let dayKey:String = String(format:"%zd-%zd-%zd",dateComps.year!,dateComps.month!,dateComps.day!)
        
        
        if let dayItem = self.daysContainer[monthCountKey]?[dateComps.day! - 1].removeValue(forKey: dayKey)
        {
            if dayItem.2 == .selected{
                self.selectedCount = self.selectedCount - 1
            }
        }
    }
    
    
    //添加日期
  public  func removeDateArray(dateCompsArray:[DateComponents]) {
        for dateComps in dateCompsArray{
            removeDate(dateComps: dateComps)
        }
    }
    
    //  closure 参数 Int:index 索引   返回 Date 
  public  func removeDateArray(dateCompsCount:Int,usingClosure:@escaping (Int)->DateComponents) {
        for index in 0..<dateCompsCount{
            let dateComps = usingClosure(index)
            removeDate(dateComps: dateComps)
        }
    }

    
    
    //范围
    private let maxRange:Int = 120
    
    
    let headerView:JWCalendarHeaderView = JWCalendarHeaderView()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.singleSelected{
           self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.done, target: self, action: #selector(JWCalendarViewController.clickConfirm))
            
            self.navigationItem.rightBarButtonItem?.isEnabled = self.selectedCount > 0
            
        }
        
        self.minDate = Date()
        
        self.view.backgroundColor = UIColor.white
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top:0, left: 10, bottom: 8, right: 10)
        
        layout.minimumInteritemSpacing = 0.5
        layout.minimumLineSpacing = 0.5
        
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 40)
        
        
        let itemW:CGFloat = (view.bounds.width - layout.sectionInset.left - layout.sectionInset.right - 6 * layout.minimumInteritemSpacing-1)/7
        
        layout.itemSize = CGSize(width: itemW, height: itemW + 5)
        
        
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y:65 , width: view.bounds.width, height: view.bounds.height-65), collectionViewLayout: layout)
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        self.view.addSubview(collectionView!)
        
        self.view.addSubview(self.headerView)
        self.headerView.frame = CGRect(x:0, y:  self.navigationController != nil ? 64 : 0, width: self.view.bounds.width, height: 65)
        
        
        //注册
        self.collectionView!.register(JWCalendarViewCell.classForCoder(), forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView?.register(JWCalendarSectionView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier)
    
        //当前日期
        if let date = self.currentDate{
            self.scrollToCurrent(date: date, animated: false)
        }
    }

    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let maxDate = self.maxDate{
             let monthOffset:Int = calendar.dateComponents([.month], from:self.getDateRemoveStopLastUnit(date:self.minDate, lastUnit: .month, isFromDate: true), to:self.getDateRemoveStopLastUnit(date:maxDate, lastUnit: .month, isFromDate: false)).month!+1
            
            return monthOffset > 0 ? monthOffset : 1
        }else{
            return maxRange
        }
    }

    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let tempDate:Date =  calendar.date(byAdding: Calendar.Component.month, value:section-1, to:self.minDate)!
        
        let date:Date = calendar.date(bySetting: Calendar.Component.day, value: 1, of: tempDate)!
        
        let dateComps:DateComponents = calendar.dateComponents([.year,.month,.day,.weekday], from: date)
        
        sectionCompsArray[section] = dateComps
        
      
        return numberOfDaysInMonth(year: dateComps.year!, month: dateComps.month!) + dateComps.weekday!-1
    }
    
    
    

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:JWCalendarViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! JWCalendarViewCell
      
        
        cell.leftLineView.isHidden = true
        cell.topLineView.isHidden = true
        
        
        if sectionCompsArray.keys.contains(indexPath.section){
            if let comps =  sectionCompsArray[indexPath.section]{
                
                let week =  comps.weekday! - 1
                
                if indexPath.item < week {
                    cell.dayItemState =  .placeholder
                    cell.titleLabel.text = ""
                    if self.enableGrid{
                        cell.bottomLineView.isHidden = false
                        
                        if indexPath.item == week-1{
                            cell.rightLineView.isHidden = false
                        }else{
                            cell.rightLineView.isHidden = true
                        }
                    }
                }else
                {
                    cell.titleLabel.text = String(format: "%zd", indexPath.item + 1 - week)
                    
                    
                    if self.enableGrid{
                        cell.bottomLineView.isHidden = false
                        cell.rightLineView.isHidden = false
                        
                        if (indexPath.item)%7 == 0 {
                            cell.leftLineView.isHidden = false
                        }
                        
                        if (indexPath.item) < 7{
                            cell.topLineView.isHidden = false
                        }
                    }else{
                        cell.bottomLineView.isHidden = true
                        cell.rightLineView.isHidden = true
                    }
                    
                }
            }
        }else{
            //
            print("过掉了")
        }
        
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if sectionCompsArray.keys.contains(indexPath.section){
            let calendarCell:JWCalendarViewCell = cell as! JWCalendarViewCell
            if let comps =  sectionCompsArray[indexPath.section]{
                
                let week =  comps.weekday! - 1
                
                if indexPath.item >= week {
                    let monthDayCount:Int =  numberOfDaysInMonth(year: comps.year!, month: comps.month!)
                    
                    let dayKey:String = String(format:"%zd-%zd-%zd",comps.year!,comps.month!,indexPath.item + 1 - week)
                    
                    
                    if (self.daysContainer[monthDayCount]?[indexPath.item - week].keys.contains(dayKey))!{
                        
                        let state =  (self.daysContainer[monthDayCount]?[indexPath.item - week][dayKey]!.2)!
                        calendarCell.dayItemState = state
                    }else{
                        calendarCell.dayItemState = .normal
                    }

                }
            }
        }
    }
    
    //选中了单天
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if sectionCompsArray.keys.contains(indexPath.section){
            if var comps =  sectionCompsArray[indexPath.section]{
                
                let week =  comps.weekday! - 1
                
                let day:Int =  indexPath.item + 1 - week
                
                comps.day = day
                
                let state = changeDayState(dateComps: comps)
                
                if let delegate = self.delegate{
                    delegate.calendarViewController(calendarViewController: self, didSelectedDate: (calendar.date(from: comps)!,comps,state))
                }
          
                UIView.performWithoutAnimation {
                    collectionView.reloadItems(at: [indexPath])
                }
                
            }
                
        }

    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView:JWCalendarSectionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath) as! JWCalendarSectionView
        
         if sectionCompsArray.keys.contains(indexPath.section){
            
             if let comps =  sectionCompsArray[indexPath.section]{
                
                let layout:UICollectionViewFlowLayout  = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
                
                headerView.lineView.isHidden = self.enableGrid
                if self.enableGrid{
                    headerView.dateLabel.text  = String(format: "%zd月",(sectionCompsArray[indexPath.section]?.month!)!)
                    
                    let week:Int = (comps.weekday)! - 1
          
                    let offsetX:CGFloat =  (layout.itemSize.width + layout.minimumInteritemSpacing) * CGFloat(week)
                    
                    headerView.dateLabel.frame = CGRect(x: offsetX, y: 0, width: layout.itemSize.width, height: layout.headerReferenceSize.height-headerView.sectionInset.top-headerView.sectionInset.bottom)
                    
                }else{
                    headerView.dateLabel.text  = String(format: "%zd年%02zd月",comps.year!,comps.month!)
                    headerView.dateLabel.frame = CGRect(x: 0, y: 0, width: 100, height: layout.headerReferenceSize.height-headerView.sectionInset.top-headerView.sectionInset.bottom)
                }
            }
        }
        
        return headerView
        
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
    
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
  
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    
    private let reuseIdentifier = "Cell"
    private let reuseHeaderIdentifier = "header"
    
 
    var sectionCompsArray:[Int:DateComponents] = [Int:DateComponents]()
    
    private let calendar:Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    var collectionView:UICollectionView?
    
    
    //选中的数据字段
    private var daysContainer:[Int:[[String:(Date,DateComponents,DayItemState)]]] = {
         var daysContainer =  [Int:[[String:(Date,DateComponents,DayItemState)]]]()
        
        //31天
        daysContainer[31] = [[String:(Date,DateComponents,DayItemState)]]()
        for index in 0..<31{
            daysContainer[31]?.append([String:(Date,DateComponents,DayItemState)]())
        }
        
        //30天
        daysContainer[30] = [[String:(Date,DateComponents,DayItemState)]]()
        for index in 0..<30{
            daysContainer[30]?.append([String:(Date,DateComponents,DayItemState)]())
        }
        
        //29天
        daysContainer[29] = [[String:(Date,DateComponents,DayItemState)]]()
        for index in 0..<29{
            daysContainer[29]?.append([String:(Date,DateComponents,DayItemState)]())
        }
        
        //28天
        daysContainer[28] = [[String:(Date,DateComponents,DayItemState)]]()
        for index in 0..<28{
            daysContainer[28]?.append([String:(Date,DateComponents,DayItemState)]())
        }
        
        return daysContainer
    }()
    
    
    //改变状态 主要是 selected 与 normal 之间的切换
    private func changeDayState(dateComps:DateComponents) -> DayItemState{
        
        
        let monthCountKey:Int = numberOfDaysInMonth(year: dateComps.year!, month: dateComps.month!)
        
        let dayKey:String = String(format:"%zd-%zd-%zd",dateComps.year!,dateComps.month!,dateComps.day!)
        
        
        if (self.daysContainer[monthCountKey]?[dateComps.day! - 1].keys.contains(dayKey))!{
            self.removeDate(dateComps: dateComps)
            return .normal
        }else{
            self.addDate(dateComps: dateComps, forState: DayItemState.selected)
            return .selected
        }
    }

    
    //设置选中的天数的个数
    private var selectedCount:Int =  0 {
        willSet{
            
            if newValue > 0{
                if let item =  self.navigationItem.rightBarButtonItem{
                    item.isEnabled = true
                }
            }else{
                if let item =  self.navigationItem.rightBarButtonItem{
                    item.isEnabled = false
                }
            }
        }
    }
    
    //点击确定
    func clickConfirm() {
        
        var selectedItems:[(Date,DateComponents,DayItemState)] = [(Date,DateComponents,DayItemState)]()
        
        var disabledItems:[(Date,DateComponents,DayItemState)] = [(Date,DateComponents,DayItemState)]()
        
        for (_,group) in self.daysContainer{
            for dayDict in group {
                for (_,dayItem) in dayDict{
                    if dayItem.2 == .selected{
                        selectedItems.append(dayItem)
                    }else if dayItem.2 == .disabled{
                        disabledItems.append(dayItem)
                    }
                }
            }
        }
        
        if selectedItems.count > 0{
            if let delegate = self.delegate{
                delegate.calendarViewController(calendarViewController: self, clickConfirm: selectedItems, and: disabledItems)
            }
        }
        
        
    }
    
    //去掉多余的日期部分，保证计算日期的差的准确度
   public func  getDateRemoveStopLastUnit(date:Date,lastUnit:Calendar.Component,isFromDate:Bool) -> Date {
        //初始化
        let unitArray:[Calendar.Component] = [.year,.month,.day,.hour,.minute,.second]
        
        let dateComps:DateComponents = self.calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        
        var flag:Bool = true
        var addDateComps:DateComponents = DateComponents()
        
        //遍历
        for unit in unitArray{
            switch unit {
            case .year:
                if flag {
                    addDateComps.year = 0
                }else{
                    addDateComps.year = -(dateComps.year)!
                }
                //判断
                if unit == lastUnit{
                    flag = false
                }
                break
            case .month:
                if flag {
                    addDateComps.month = 0
                }else{
                    if !isFromDate{
                        addDateComps.month = -(dateComps.month)!+2
                    }else{
                        addDateComps.month = -(dateComps.month)!+1
                    }
                }
                //判断
                if unit == lastUnit{
                   
                    flag = false
                }
                break
            case .day:
                if flag {
                    addDateComps.day = 0
                }else{
                    if !isFromDate{
                        addDateComps.day = -(dateComps.day)!+2
                    }else{
                       addDateComps.day = -(dateComps.day)!+1
                    }
                }
                //判断
                if unit == lastUnit{
                   
                    flag = false
                }
                break
            case .hour:
                if flag {
                    addDateComps.hour = 0
                }else{
                    if !isFromDate{
                        addDateComps.hour = -(dateComps.hour)!+1
                    }else{
                        addDateComps.hour = -(dateComps.hour)!
                    }
                    
                }
                //判断
                if unit == lastUnit{
                    
                    flag = false
                }
                break
            case .minute:
                if flag {
                    addDateComps.minute = 0
                }else{
                    if !isFromDate{
                        addDateComps.minute = -(dateComps.minute)!+1
                    }else{
                        addDateComps.minute = -(dateComps.minute)!
                    }
                }
                //判断
                if unit == lastUnit{
                    
                    flag = false
                }
                break
            case .second:
                if flag {
                    addDateComps.second = 0
                }else{
                    if !isFromDate{
                        addDateComps.second = -(dateComps.second)!+1
                    }else{
                        addDateComps.second = -(dateComps.second)!
                    }
                }
                //判断
                if unit == lastUnit{
                    flag = false
                }
                break
            default:
                break
            }
        }
        
       
        
        let lastDate:Date = self.calendar.date(byAdding: addDateComps, to: date)!
        
        return lastDate
    }
}
