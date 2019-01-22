//
//  CustomChartsTest.swift
//  Demo
//
//  Created by wyl on 2019/1/22.
//  Copyright © 2019年 CLZ. All rights reserved.
//

import UIKit
import SnapKit

//范例:
//view
//testMyCharts(view)

//添加到cell
//testMyCharts(cell)

//添加view
func testMyCharts(_ view:UIView) -> CustomChartView {
    let mychartView = CustomChartView(frame: CGRect(x: 14, y: 50, width: SCREEN_WDITH-28, height: 200),frameXMax:SCREEN_WDITH-14,nodataText:"没有数据")
    view.addSubview(mychartView)
    return mychartView
}
func testMyChartsSnp(_ view:UIView) -> CustomChartView {
    let mychartView = CustomChartView(frame: .zero,frameXMax:SCREEN_WDITH-14,nodataText:"没有数据")
    view.addSubview(mychartView)
    mychartView.makeConstraints { (make) in
        make.leading.equalTo(14)
        make.top.equalTo(50)
        make.width.equalTo(SCREEN_WDITH-28)
        make.height.equalTo(200)
    }
    return mychartView
}

//刷新数据
func testUpdateCharts(_ mychartView:CustomChartView,chartsData:[CustomChartsModel]) {
    mychartView.updateChartsData(chartsData,
                                 xCount: 4, xForce: true, xDateType: .monthAndDay,
                                 yCount: 4)
}


//测试数据
func testChartsData() -> ([CustomChartsModel]) {
    var chartsData : [CustomChartsModel] = []
    let xValues = [1569901474,1569987874,1570074274,1570160674,1570247074,1570333474,1570419874,
                   1570506274,1570592674,1570679074,1570765474,1570851874,1570938274,1571024674,
                   1571111074,1571197474,1571283874,1571370274,1571456674,1571543074,1571629474,
                   1571715874,1571802274,1571888674,1571975074,1572061474,1572147874,1572234274,
                   1572320674,1572407074,1572493474]
    let yValues = [200.0,100.0,899.0,300.0,0.0,555.0,888.0,
                   200.0,100.0,899.0,300.0,0.0,555.0,888.0,
                   200.0,100.0,899.0,300.0,0.0,555.0,888.0,
                   200.0,100.0,899.0,300.0,0.0,555.0,888.0,
                   333.0,666,777]
    
    for (index,x) in xValues.enumerated() {
        let model = CustomChartsModel()
        model.x = Double(x)
        model.y = yValues[index]
        model.yMeasure = "元"
        chartsData.append(model)
    }
    return chartsData
}
