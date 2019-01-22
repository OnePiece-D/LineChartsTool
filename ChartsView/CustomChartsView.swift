//
//  CustomChartView.swift
//  Demo
//
//  Created by wyl on 2019/1/17.
//  Copyright © 2019年 CLZ. All rights reserved.
//

import UIKit
//必须的
import Charts
//如使用frame布局则不需要引入这个框架
import SnapKit

//MARK:model坐标点数据模型
class CustomChartsModel: NSObject {
    //x轴内容
    var x : Double?
    //y轴内容
    var y : Double?
    //x轴单位
    var xMeasure : xAxisDateValueFormatType = .monthAndDay
    //y轴保留小数点位数 0，1，2，3
    var yDecimal : Int = 0
    //y轴单位 元
    var yMeasure : String?
}

//MARK:代理
@objc
protocol CustomChartViewDelegate {
    @objc optional func markerSelectedAction(_ selected:Bool)
}

//MARK:折线表
class CustomChartView: UIView {
    //MARK:可用属性
    open var marker : CustomBalloonMarker = CustomBalloonMarker.config()
    //设置marker是否可选中
    open var markerSelected : Bool = false {
        didSet {
            selectedMarker(markerSelected)
        }
    }
    //手动选中marker点的回调
    open var markerSelectedBlock : ((Bool)->())?
    @objc open weak var delegate: CustomChartViewDelegate?
    
    //MARK:私有
    fileprivate var lineChartView : LineChartView?
    
    //用于设置xy的label显示样式
    struct LabelStyle {
        var font : UIFont?
        var color : UIColor?
        init(_ color:UIColor,_ font:UIFont) {
            self.color = color
            self.font = font
        }
    }
    
    //MARK:init
    override init(frame: CGRect) {
        super.init(frame: frame)
        createChartsView(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(frame: CGRect,frameXMax:CGFloat=UIScreen.main.bounds.size.width,nodataText:String?,target:AnyObject? = nil) {
        self.init(frame: frame)
        
        if let tg = target as? CustomChartViewDelegate {
            self.delegate = tg
        }
        
        marker.rightMax_x = frameXMax
        if let text = nodataText {
            lineChartView?.noDataText = text
        }
        //设置xy轴显示内容
        let textColor : UIColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        let xlabelStyle : LabelStyle = LabelStyle(textColor,UIFont.systemFont(ofSize: 12))
        let ylabelStyle : LabelStyle = LabelStyle(textColor,UIFont.systemFont(ofSize: 12))
        setX_And_LeftAxisStyle(xAxisStyle: xlabelStyle,
                               leftAxisStyle: ylabelStyle)
    }
}

//MARK:调用方法
extension CustomChartView {
    //自动布局
    //需要引入snpkit，如果用frame此条可忽略
    open func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.makeConstraints(closure)
        lineChartView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        })
    }
    open func updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.updateConstraints(closure)
        lineChartView?.snp.updateConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        })
    }
    open func remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.remakeConstraints(closure)
        lineChartView?.snp.remakeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        })
    }
    
    /// 数据布局
    ///
    /// - Parameters:
    ///   - chartsData: xy数据内容  [CustomChartsModel]
    ///   - xCount: x轴显示label个数
    ///   - xForce: 是否强制显示x轴label个数
    ///   - xDateType: x轴显示时间类型 默认 MM/dd
    ///   - yCount: y轴显示个数
    ///   - yMax: Optional y轴最大
    open func updateChartsData(_ chartsData:[CustomChartsModel],
                               xCount:Int,xForce:Bool,xDateType:xAxisDateValueFormatType = .monthAndDay,
                               yCount:Int,yMax:Double?=nil) {
        //x轴数据
        let xDateValue = DateValueFormatter()
        xDateValue.dateItemType = xDateType
        xDateValue.dateArr = chartsData.map({$0.x ?? 0})
        lineChartView?.xAxis.valueFormatter = xDateValue
        
        lineChartView?.xAxis.setLabelCount(xCount, force: xForce)
        lineChartView?.xAxis.avoidFirstLastClippingEnabled = true
        lineChartView?.leftAxis.labelCount = yCount
        if let yMax = yMax {
            lineChartView?.leftAxis.axisMaximum = yMax
        }
        //y轴数据
        let xyData = chartsData
        
        let block: (CustomChartsModel) -> ChartDataEntry = { (model) -> ChartDataEntry in
            return ChartDataEntry(x: model.x ?? 0, y: model.y ?? 0, data: model as AnyObject)
        }
        let dataEntry = xyData.map({block($0)})
        let dataSet = LineChartDataSet(values: dataEntry, label: nil)
        
        configDataSetStyle(dataSet)
        
        lineChartView?.data = LineChartData(dataSet: dataSet)
    }
}

//MAKR:表数据代理
extension CustomChartView : ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //
        chartValueSelected(true)
    }
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        //
        chartValueSelected(false)
    }
    
    func chartValueSelected(_ selected:Bool) {
        markerSelected = selected
        markerSelectedBlock?(selected)
    }
}

//MARK:私有方法
extension CustomChartView {
    //表数据
    fileprivate func createChartsView(frame:CGRect) {
        let lineChartView = LineChartView(frame: CGRect(origin: .zero, size: frame.size))
        lineChartView.delegate = self
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.rightAxis.enabled = false
        //lineChartView.maxVisibleCount = 999
        
        //不要图例
        lineChartView.legend.enabled = false
        
        self.addSubview(lineChartView)
        
        self.lineChartView = lineChartView
    }
    
    //Style
    //设置x，y轴label样式
    fileprivate func setX_And_LeftAxisStyle(xAxisStyle:LabelStyle,
                                            leftAxisStyle:LabelStyle) {
        guard let lineChartView = lineChartView  else {
            return
        }
        //设置x轴
        let xAxis = lineChartView.xAxis
        //xAxis.gridColor = .white
        if let textColor = xAxisStyle.color {
            xAxis.labelTextColor = textColor
        }
        if let font = xAxisStyle.font {
            xAxis.labelFont = font
        }
        
        xAxis.labelPosition = .bottom
        xAxis.axisLineWidth = 0.0
        //xAxis.axisLineColor = .orange
        xAxis.drawGridLinesEnabled = false
        //xAxis.gridColor = .white
        
        //设置y轴
        let leftAxis = lineChartView.leftAxis
        if let textColor = leftAxisStyle.color {
            leftAxis.labelTextColor = textColor
        }
        if let font = leftAxisStyle.font {
            leftAxis.labelFont = font
        }
        leftAxis.labelPosition = .outsideChart
        leftAxis.axisLineWidth = 0.0
        //网格
        leftAxis.gridColor = ChartColorTemplates.colorFromString("#efefef")
        //leftAxis.gridLineCap = .square
        leftAxis.drawGridLinesEnabled = true
        
        //设置最大值
        //leftAxis.axisMaximum = 1000
        //leftAxis.setLabelCount(4, force: false)
    }
    
    //配置每条折线的样式
    fileprivate func configDataSetStyle(_ dataSet:LineChartDataSet) {
        //高亮色
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.highlightColor = ChartColorTemplates.colorFromString("#7BA4F2")
        //曲线颜色
        dataSet.setColor(ChartColorTemplates.colorFromString("#008AFF"),
                         alpha: 1.0)
        //线条
        dataSet.lineWidth = 1.0
        dataSet.drawValuesEnabled = false
        dataSet.mode = .linear
        //dataSet.highlightEnabled = true
        
        //拐点的圈圈
        dataSet.circleRadius = 5.0
        dataSet.circleHoleRadius = 3.0
        dataSet.drawCirclesEnabled = false
        
        //填充颜色
        dataSet.drawFilledEnabled = true
        dataSet.fillColor = ChartColorTemplates.colorFromString("#eff7ff")
        dataSet.fillAlpha = 1.0
    }
    
    //Action
    //是否选中marker点
    fileprivate func selectedMarker(_ selected:Bool) {
        if selected {
            lineChartView?.marker = marker
        }else {
            lineChartView?.marker = nil
        }
        
        //选中线
        if let dataSet = lineChartView?.data?.dataSets.first as? LineChartDataSet {
            dataSet.drawVerticalHighlightIndicatorEnabled = selected
        }
    }
}


//MARK: 设置x轴展示信息
//x轴信息
//日期格式
enum xAxisDateValueFormatType : Int {
    case monthAndDay     = 0
    case onlyHour        = 1
    case onlyMin         = 2
    case hourAndMin      = 3
}

func xDateValueFormat(_ x:TimeInterval,dateType:xAxisDateValueFormatType = .monthAndDay) -> String {
    let dateFormat : DateFormatter = DateFormatter()
    var formatStr : String = ""
    switch dateType {
    case .monthAndDay:
        formatStr = "MM/dd"
    case .onlyHour:
        formatStr = "hh"
    case .onlyMin:
        formatStr = "mm"
    case .hourAndMin:
        formatStr = "hh:mm"
    }
    dateFormat.dateFormat = formatStr
    
    let dateStr : String = dateFormat.string(from: Date(timeIntervalSince1970: x))
    return dateStr
}

class DateValueFormatter : NSObject {
    var dateItemType : xAxisDateValueFormatType = .monthAndDay
    var dateArr : [TimeInterval] = []
}

extension DateValueFormatter : IAxisValueFormatter,IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        //print("stringForValue:\(value)")
        return String(value)
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        //print("stringForValue:\(value)")
        //let index : Int = Int(value)
        //return String(index)
        if dateArr.contains(value) {
            //原来是想要显示服务端给的数据内容的但是由于框架限制自动分配不做过滤
            let xAxis = xDateValueFormat(value, dateType: dateItemType)
            return xAxis
        }else {
            return xDateValueFormat(value, dateType: dateItemType)
            //return ""
        }
    }
}
