//
//  CustomBalloonMarker.swift
//  Demo
//
//  Created by wyl on 2019/1/16.
//  Copyright © 2019年 CLZ. All rights reserved.
//

import UIKit
import Charts

fileprivate let markerBigerFont : CGFloat = 4.0

class CustomBalloonMarker: BalloonMarker {
    //右边界用于判断汽泡的显示左右
    var rightMax_x : CGFloat = UIScreen.main.bounds.size.width
    //框框圆角度
    var radius : CGFloat = 4.0
    
    //要放大的字
    var frontLabel  : String = ""
    var bigerLabel  : String = ""
    var behindLabel : String = ""
    
    
    //放大字体字号
    open var biger_drawAttributes = [NSAttributedString.Key : AnyObject]()
    fileprivate var textFont : CGFloat = 10.0
    
    class func config(textColor:UIColor = .white,
                      textFont:CGFloat=10,
                      backgroundColor:UIColor = UIColor(red: 13/255, green: 114/255, blue: 1, alpha: 1.0),
                      insets:UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 0, right: 8),
                      minimumSize : CGSize = CGSize(width: 10, height: 25),
                      arrowSize : CGSize = CGSize(width: 5, height: 5)) -> CustomBalloonMarker {
        //字号调整
        let fitFont : CGFloat = textFont + markerBigerFont/3.0
        let markerTextFont = UIFont.systemFont(ofSize: fitFont)
        let marker = CustomBalloonMarker(color: backgroundColor,
                                         font: markerTextFont,
                                         textColor: textColor,
                                         insets: insets)
        marker.textFont = textFont
        marker.minimumSize = minimumSize
        marker.arrowSize = arrowSize
        
        return marker
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        if let dataModel = entry.data as? CustomChartsModel {
            let xString : String =  xDateValueFormat(dataModel.x ?? 0,
                                                     dateType: dataModel.xMeasure)
            frontLabel = xString + " "
            
            switch dataModel.yDecimal {
            case 0:
                if let y = dataModel.y {
                    bigerLabel = String(format: "%.0f", y)
                }
            case 1:
                if let y = dataModel.y {
                    bigerLabel = String(format: "%.1f", y)
                }
            case 2:
                if let y = dataModel.y {
                    bigerLabel = String(format: "%.0f", y)
                }
            default:
                if let y = dataModel.y {
                    bigerLabel = String(format: "%f", y)
                }
                break
            }
            behindLabel = dataModel.yMeasure ?? ""
            
            let xyString : String = String(format: "%@%@%@", frontLabel,bigerLabel,behindLabel)
            setLabel(xyString)
            
            //设置字体
            _drawAttributes[.font] = UIFont.systemFont(ofSize: textFont)
            biger_drawAttributes[.font] = UIFont.systemFont(ofSize: textFont + markerBigerFont)
            biger_drawAttributes[.paragraphStyle] = _drawAttributes[.paragraphStyle]
            biger_drawAttributes[.foregroundColor] = _drawAttributes[.foregroundColor]
        }
    }
    
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let label = label else { return }
        
        
        let xSpace : CGFloat = 4.6
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x += xSpace
        rect.origin.y -= size.height
        
        var showRight : Bool = true
        if bigerLabel.count > 0 {
            let normalSize = bigerLabel.size(withAttributes: _drawAttributes)
            let bigerSize = bigerLabel.size(withAttributes: biger_drawAttributes)
            let offSetWidth = bigerSize.width - normalSize.width + 1
            if rect.origin.x + rect.size.width + offSetWidth >= rightMax_x {
                //左边
                showRight = false
            }
        }
        
        
        context.saveGState()
        context.setFillColor(color.cgColor)
        
        if !showRight {
            //左边
            rect.origin.x -= 2*xSpace+rect.size.width
            if offset.y > 0
            {
                //下面
                context.beginPath()
                
                context.move(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + arrowSize.height+radius))
                context.addArc(center: CGPoint(
                    x: rect.origin.x+radius,
                    y: rect.origin.y + arrowSize.height+radius),
                               radius: radius, startAngle: CGFloat(-Double.pi), endAngle: CGFloat(-Double.pi/2), clockwise: false)
                
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width - arrowSize.width,
                    y: rect.origin.y + arrowSize.height))
                //arrow vertex
                context.addLine(to: CGPoint(
                    x: point.x-xSpace,
                    y: point.y))
                
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y + rect.size.height-radius))
                context.addArc(center: CGPoint(
                    x: rect.origin.x + rect.size.width-radius,
                    y: rect.origin.y + rect.size.height-radius),
                               radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi/2), clockwise: false)
                
                context.addLine(to: CGPoint(
                    x: rect.origin.x+radius,
                    y: rect.origin.y + rect.size.height))
                context.addArc(center: CGPoint(
                    x: rect.origin.x+radius,
                    y: rect.origin.y + rect.size.height-radius),
                               radius: radius, startAngle: CGFloat(Double.pi/2), endAngle: CGFloat(-Double.pi), clockwise: false)
                
//                context.addLine(to: CGPoint(
//                    x: rect.origin.x,
//                    y: rect.origin.y + arrowSize.height))
                context.fillPath()
            }
            else
            {
                //上面
                
                context.beginPath()
                //圆角
                context.move(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y+radius))
                context.addArc(center: CGPoint(
                    x: rect.origin.x+radius,
                    y: rect.origin.y+radius),
                               radius: radius, startAngle: CGFloat(-Double.pi), endAngle: CGFloat(-Double.pi/2), clockwise: false)
                
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width-radius,
                    y: rect.origin.y))
                
                context.addArc(center: CGPoint(
                    x: rect.origin.x + rect.size.width-radius,
                    y: rect.origin.y+radius),
                               radius: radius, startAngle: CGFloat(-Double.pi/2), endAngle: 0, clockwise: false)
                
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: point.y))
                //arrow vertex
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width-arrowSize.width,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                
                context.addLine(to: CGPoint(
                    x: rect.origin.x+radius,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                context.addArc(center: CGPoint(
                    x: rect.origin.x+radius,
                    y: rect.origin.y + rect.size.height - arrowSize.height-radius),
                               radius: radius, startAngle: CGFloat(Double.pi/2), endAngle: CGFloat(Double.pi), clockwise: false)
                
                context.addLine(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y))
                context.fillPath()
            }
        }else {
            //右边
            if offset.y > 0
            {
                //下面
                context.beginPath()
                //rect为左上角
                context.move(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + arrowSize.height))
                //arrow vertex
                context.addLine(to: CGPoint(
                    x: point.x+xSpace,
                    y: point.y))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + arrowSize.width,
                    y: rect.origin.y + arrowSize.height))
                
                //下面的都是圆角
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width-radius,
                    y: rect.origin.y + arrowSize.height))
                context.addArc(center: CGPoint(
                    x: rect.origin.x + rect.size.width-radius,
                    y: rect.origin.y + arrowSize.height+radius),
                               radius: radius, startAngle: CGFloat(-Double.pi/2), endAngle: 0, clockwise: false)
                
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y + rect.size.height-radius))
                context.addArc(center: CGPoint(
                    x: rect.origin.x + rect.size.width-radius,
                    y: rect.origin.y + rect.size.height-radius),
                               radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi/2), clockwise: false)
                
                context.addLine(to: CGPoint(
                    x: rect.origin.x+radius,
                    y: rect.origin.y + rect.size.height))
                
                context.addArc(center: CGPoint(
                    x: rect.origin.x+radius,
                    y: rect.origin.y + rect.size.height-radius),
                               radius: radius, startAngle: CGFloat(Double.pi/2), endAngle: CGFloat(Double.pi), clockwise: false)
                
                context.fillPath()
            }
            else
            {
                //上面
                context.beginPath()
                //rect为左上角的点
                context.move(to: CGPoint(
                    x: point.x+xSpace,
                    y: point.y))
                context.addLine(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y+radius))
                context.addArc(center: CGPoint(
                    x: rect.origin.x+radius,
                    y: rect.origin.y+radius),
                               radius: radius, startAngle: CGFloat(-Double.pi), endAngle: CGFloat(-Double.pi/2), clockwise: false)
                context.addLine(to: CGPoint(
                    x: rect.origin.x+rect.size.width-radius,
                    y: rect.origin.y))
                context.addArc(center: CGPoint(
                    x: rect.origin.x+rect.size.width-radius,
                    y: rect.origin.y+radius),
                               radius: radius, startAngle: CGFloat(-Double.pi/2), endAngle: 0, clockwise: false)
                context.addLine(to: CGPoint(
                    x: rect.origin.x+rect.size.width,
                    y: rect.origin.y+rect.size.height-arrowSize.height-radius))
                context.addArc(center: CGPoint(
                    x: rect.origin.x+rect.size.width-radius,
                    y: rect.origin.y+rect.size.height-arrowSize.height-radius),
                               radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi/2), clockwise: false)
                context.addLine(to: CGPoint(
                    x: rect.origin.x+arrowSize.width,
                    y: rect.origin.y+rect.size.height-arrowSize.height))
                
                
                context.fillPath()
            }
        }
        
        if offset.y > 0 {
            rect.origin.y += self.insets.top + arrowSize.height
        } else {
            rect.origin.y += self.insets.top
        }
        
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        //label.draw(in: rect, withAttributes: _drawAttributes)
        
        if bigerLabel.count > 0 {
            let frontSize = frontLabel.size(withAttributes: _drawAttributes)
            let bigerSize = bigerLabel.size(withAttributes: biger_drawAttributes)
            let bihindSize = behindLabel.size(withAttributes: _drawAttributes)
            //print("label_rect:\(rect),size:\(labelSize),insets:\(self.insets)")
            let frontRect : CGRect = CGRect(x: rect.origin.x,
                                            y: rect.origin.y,
                                            width: self.insets.left+frontSize.width,
                                            height: rect.size.height)
            let bigerRect : CGRect = CGRect(x: frontRect.origin.x+frontRect.size.width,
                                            y: rect.origin.y-(bigerSize.height-frontSize.height)/2,
                                            width: bigerSize.width,
                                            height: rect.size.height)
            let behindRect : CGRect = CGRect(x: bigerRect.origin.x+bigerRect.size.width,
                                             y: rect.origin.y,
                                             width: bihindSize.width,
                                             height: rect.size.height)
            frontLabel.draw(in: frontRect,
                            withAttributes: _drawAttributes)
            bigerLabel.draw(in: bigerRect,
                            withAttributes: biger_drawAttributes)
            behindLabel.draw(in: behindRect,
                             withAttributes: _drawAttributes)
        }else {
            label.draw(in: rect, withAttributes: _drawAttributes)
        }
        
        UIGraphicsPopContext()
        
        context.restoreGState()
        
        //高亮点圆
        setHighLight(context, point: point, radius: 3.0, color: ChartColorTemplates.colorFromString("#008AFF").cgColor)
        setHighLight(context, point: point, radius: 2.0, color: UIColor.white.cgColor)
    }
    
    func setHighLight(_ context:CGContext,point:CGPoint,radius:CGFloat,color:CGColor) {
        context.saveGState()
        context.setFillColor(color)
        
        context.addArc(center: point, radius: radius, startAngle: CGFloat(-Double.pi), endAngle: CGFloat(Double.pi), clockwise: false)
        context.fillPath()
        
        UIGraphicsPopContext()
        context.restoreGState()
    }
}
