//
//  PNBarChart.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/6/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit
import QuartzCore

public enum AnimationType {
    case Default
    case Waterfall
}

public class PNBarChart: UIView {
    
    // MARK: Variables
    
    public  var xLabels: NSArray = [] {
        
        didSet{
            if showLabel {
                xLabelWidth = (self.frame.size.width - (chartEdgeInsets.left + chartEdgeInsets.right)) / CGFloat(self.xLabels.count)
            }
        }
    }
    var labels: NSMutableArray = []
    var yLabels: NSArray = []
    public var yValues: NSArray = [] {
        didSet{
            if (yMaxValue != nil) {
                yValueMax = yMaxValue
            }else{
                self.getYValueMax(yValues)
            }
            
            xLabelWidth = (self.frame.size.width - (chartEdgeInsets.left + chartEdgeInsets.right)) / CGFloat(yValues.count)
        }
    }
    
    var bars: NSMutableArray = []
    public var xLabelWidth:CGFloat!
    public var yValueMax: CGFloat!
    public var strokeColor: UIColor = PNGreenColor
    public var strokeColors: NSArray = []
    public var xLabelHeight:CGFloat = 11.0
    public var yLabelHeight:CGFloat = 20.0
    
    /**
     The width for the vertical labels.
     */
    public var yChartLabelWidth:CGFloat = 18.0
    
    /*
    yLabelFormatter will format the ylabel text
    */
    public var yLabelFormatter = ({(yValue: CGFloat) -> NSString in
        return ""
    })
    
    public var chartEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    /*
    showLabel if the Labels should be deplay
    */
    
    public var showLabel = true
    
    /*
    showChartBorder if the chart border Line should be deplay
    */
    
    public var showChartBorder = false
    
    /*
    chartBottomLine the Line at the chart bottom
    */
    
    public var chartBottomLine:CAShapeLayer = CAShapeLayer()
    
    /*
    chartLeftLine the Line at the chart left
    */
    
    public var chartLeftLine:CAShapeLayer = CAShapeLayer()
    
    /*
    barRadius changes the bar corner radius
    */
    public var barRadius:CGFloat = 0.0
    
    /*
    barWidth changes the width of the bar
    */
    public var barWidth:CGFloat!
    
    /*
    labelMarginTop changes the width of the bar
    */
    public var labelMarginTop: CGFloat = 0
    
    /*
    barBackgroundColor changes the bar background color
    */
    public var barBackgroundColor:UIColor = UIColor.grayColor()
    
    /*
    labelTextColor changes the bar label text color
    */
    public var labelTextColor: UIColor = PNGreyColor
    
    /*
    labelFont changes the bar label font
    */
    public var labelFont: UIFont = UIFont.systemFontOfSize(11.0)
    
    /*
    xLabelSkip define the label skip number
    */
    public var xLabelSkip:Int = 1
    
    /*
    yLabelSum define the label skip number
    */
    public var yLabelSum:Int = 4
    
    /*
    yMaxValue define the max value of the chart
    */
    public var yMaxValue:CGFloat!
    
    /*
    yMinValue define the min value of the chart
    */
    public var yMinValue:CGFloat!
    
    /*
    animationType defines the type of animation for the bars
    Default (All bars at once) / Waterfall (bars in sequence)
    */
    public var animationType : AnimationType = .Default
    
    public var delegate:PNChartDelegate!
    
    /**
     * This method will call and stroke the line in animation
     */
     
     // MARK: Functions
    
    public  func strokeChart() {
        self.viewCleanupForCollection(labels)
        
        if showLabel{
            //Add x labels
            var labelAddCount:Int = 0
            for var index:Int = 0; index < xLabels.count; ++index {
                labelAddCount += 1
                
                if labelAddCount == xLabelSkip {
                    let labelText:NSString = xLabels[index] as! NSString
                    let label:PNChartLabel = PNChartLabel(frame: CGRectZero)
                    label.font = labelFont
                    label.textColor = labelTextColor
                    label.textAlignment = NSTextAlignment.Center
                    label.text = labelText as String
                    label.sizeToFit()
                    let labelXPosition:CGFloat  = ( CGFloat(index) *  xLabelWidth + chartEdgeInsets.left + xLabelWidth / 2.0 )
                    
                    label.center = CGPointMake(labelXPosition,
                        self.frame.size.height - xLabelHeight - chartEdgeInsets.bottom + label.frame.size.height / 2.0 + labelMarginTop)
                    labelAddCount = 0
                    
                    labels.addObject(label)
                    self.addSubview(label)
                }
            }
            
            //Add y labels
            
            let yLabelSectionHeight:CGFloat = (self.frame.size.height - (chartEdgeInsets.top + chartEdgeInsets.bottom) - xLabelHeight) / CGFloat(yLabelSum)
            
            for var index:Int = 0; index < yLabelSum; ++index {
                let labelText:NSString = yLabelFormatter((yValueMax * ( CGFloat(yLabelSum - index) / CGFloat(yLabelSum) ) ))
                
                let label:PNChartLabel = PNChartLabel(frame: CGRectMake(0,yLabelSectionHeight * CGFloat(index) + chartEdgeInsets.top - yLabelHeight/2.0, yChartLabelWidth, yLabelHeight))
                
                label.font = labelFont
                label.textColor = labelTextColor
                label.textAlignment = NSTextAlignment.Right
                label.text = labelText as String
                
                labels.addObject(label)
                self.addSubview(label)
            }
        }
        
        self.viewCleanupForCollection(bars)
        //Add bars
        let chartCavanHeight:CGFloat = frame.size.height - (chartEdgeInsets.top + chartEdgeInsets.bottom) - xLabelHeight
        var index:Int = 0
        
        for valueObj: AnyObject in yValues{
            let valueString = valueObj as! NSNumber
            let value:CGFloat = CGFloat(valueString.floatValue)
            
            let grade = value / yValueMax
            
            var bar:PNBar!
            var barXPosition:CGFloat!
            
            if barWidth > 0 {
                
                barXPosition = CGFloat(index) *  xLabelWidth + chartEdgeInsets.left + (xLabelWidth / 2.0) - (barWidth / 2.0)
            }else{
                barXPosition = CGFloat(index) *  xLabelWidth + chartEdgeInsets.left + xLabelWidth * 0.25
                if showLabel {
                    barWidth = xLabelWidth * 0.5
                    
                }
                else {
                    barWidth = xLabelWidth * 0.6
                    
                }
            }
            
            bar = PNBar(frame: CGRectMake(barXPosition, //Bar X position
                frame.size.height - chartCavanHeight - xLabelHeight - chartEdgeInsets.bottom, //Bar Y position
                barWidth, // Bar witdh
                chartCavanHeight)) //Bar height
            
            //Change Bar Radius
            bar.barRadius = barRadius
            
            //Change Bar Background color
            bar.backgroundColor = barBackgroundColor
            
            //Bar StrokColor First
            if strokeColor != UIColor.blackColor() {
                bar.barColor = strokeColor
            }else{
                bar.barColor = self.barColorAtIndex(index)
            }
            
            if(self.animationType ==  .Waterfall)
            {
                let indexDouble : Double = Double(index)
                
                // Time before each bar starts animating
                let barStartTime = indexDouble-(0.9*indexDouble)
                
                bar.startAnimationTime = barStartTime
                
            }
            
            //Height Of Bar
            bar.grade = grade
            
            //For Click Index
            bar.tag = index
            
            bars.addObject(bar)
            addSubview(bar)
            
            index += 1
        }
        
        //Add chart border lines
        
        if showChartBorder{
            chartBottomLine = CAShapeLayer()
            chartBottomLine.lineCap      = kCALineCapButt
            chartBottomLine.fillColor    = UIColor.whiteColor().CGColor
            chartBottomLine.lineWidth    = 1.0
            chartBottomLine.strokeEnd    = 0.0
            
            let progressline:UIBezierPath = UIBezierPath()
            
            let yOffset: CGFloat = frame.size.height - xLabelHeight - chartEdgeInsets.bottom
            progressline.moveToPoint(CGPointMake(chartEdgeInsets.left, yOffset))
            progressline.addLineToPoint(CGPointMake(frame.size.width, yOffset))
            
            progressline.lineWidth = 1.0
            progressline.lineCapStyle = CGLineCap.Square
            chartBottomLine.path = progressline.CGPath
            
            
            chartBottomLine.strokeColor = PNGreyColor.CGColor;
            
            
            let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 0.5
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathAnimation.fromValue = 0.0
            pathAnimation.toValue = 1.0
            chartBottomLine.addAnimation(pathAnimation, forKey:"strokeEndAnimation")
            chartBottomLine.strokeEnd = 1.0;
            
            layer.addSublayer(chartBottomLine)
            
            //Add left Chart Line
            
            chartLeftLine = CAShapeLayer()
            chartLeftLine.lineCap      = kCALineCapButt
            chartLeftLine.fillColor    = UIColor.whiteColor().CGColor
            chartLeftLine.lineWidth    = 1.0
            chartLeftLine.strokeEnd    = 0.0
            
            let progressLeftline:UIBezierPath = UIBezierPath()
            
            progressLeftline.moveToPoint(CGPointMake(chartEdgeInsets.left, frame.size.height - xLabelHeight - chartEdgeInsets.bottom))
            progressLeftline.addLineToPoint(CGPointMake(chartEdgeInsets.left,  chartEdgeInsets.top))
            
            progressLeftline.lineWidth = 1.0
            progressLeftline.lineCapStyle = CGLineCap.Square
            chartLeftLine.path = progressLeftline.CGPath
            
            
            chartLeftLine.strokeColor = PNGreyColor.CGColor
            
            
            let pathLeftAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathLeftAnimation.duration = 0.5
            pathLeftAnimation.timingFunction =  CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathLeftAnimation.fromValue = 0.0
            pathLeftAnimation.toValue = 1.0
            chartLeftLine.addAnimation(pathAnimation, forKey:"strokeEndAnimation")
            
            chartLeftLine.strokeEnd = 1.0
            
            layer.addSublayer(chartLeftLine)
        }
        
    }
    
    func barColorAtIndex(index:Int) -> UIColor
    {
        if (self.strokeColors.count == self.yValues.count) {
            return self.strokeColors[index] as! UIColor
        }
        else {
            return self.strokeColor as UIColor
        }
    }
    
    
    func viewCleanupForCollection( array:NSMutableArray )
    {
        if array.count > 0 {
            for object:AnyObject in array{
                let view = object as! UIView
                view.removeFromSuperview()
            }
            
            array.removeAllObjects()
        }
    }
    
    func getYValueMax(yLabels:NSArray) {
        let max:CGFloat = CGFloat(yLabels.valueForKeyPath("@max.floatValue") as! Float)
        
        
        if max == 0 {
            yValueMax = yMinValue
        }else{
            yValueMax = max
        }
        
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchPoint(touches, withEvent: event)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    func touchPoint(touches: Set<UITouch>, withEvent event: UIEvent!){
        let touch:UITouch = touches.first!
        let touchPoint = touch.locationInView(self)
        let subview = hitTest(touchPoint, withEvent: nil)
        
        if let barView = subview as? PNBar {
            self.delegate?.userClickedOnBarChartIndex(barView.tag)
        }
    }
    
    // MARK: Init
    
    override public init(frame: CGRect)
    {
        super.init(frame: frame)
        barBackgroundColor = PNLightGreyColor
        clipsToBounds = true
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
