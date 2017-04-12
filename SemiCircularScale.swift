//
//  SemiCircularScale.swift
//  RewardzWeightReader
//
//  Created by Rewardz on 11/04/17.
//  Copyright © 2017 Rewardz. All rights reserved.
//

import UIKit

@IBDesignable class SemiCircularScale: UIView {
    
     var backColor : UIColor = UIColor(red: 0.012, green: 0.663, blue: 0.957, alpha: 1.000)
    
    @IBInspectable var indicatorColor : UIColor = UIColor(red: 0.012, green: 0.663, blue: 0.957, alpha: 1.000){
        didSet{
            indicatorCircleLayer.strokeColor = indicatorColor.cgColor
        }
    }
    @IBInspectable var baseColor : UIColor = UIColor.gray{
        didSet{
            baseSemiCircleLayer.strokeColor = baseColor.cgColor
        }
    }
    
    @IBInspectable var reading : CGFloat = 50 {
       
        
        didSet{
            if (reading < CGFloat (minReading)){
                self.reading = CGFloat (minReading)
            }else if (reading > CGFloat (maxReading)){
                self.reading  =  CGFloat (maxReading)
            }
            let x = Double(reading - CGFloat(minReading))/Double(maxReading - minReading)
            indicatorCircleLayer.strokeEnd  = CGFloat(x)
            showReading()
        }
    }

    @IBInspectable var scaleWidth : CGFloat = 2.0 {
        didSet{
            baseSemiCircleLayer.lineWidth = CGFloat(scaleWidth)
            indicatorCircleLayer.lineWidth = CGFloat(scaleWidth)
        }
    }
    @IBInspectable var minReading : Int = 40{
        didSet{
            
           prepareMarkers()
        }
        
    }
    @IBInspectable var maxReading : Int = 100 {
        
        didSet{
           prepareMarkers()
        }
    }
    @IBInspectable var delta : Int = 5 {
        didSet{
            prepareMarkers()
        }
    }
    @IBInspectable var markerLabelColor : UIColor = UIColor.gray{
        didSet{
            for index in 0...markerLabels.count-1 {
                let label = markerLabels[index]
                label.textColor = markerLabelColor
                
            }
        }
    }

    private var markerLabels = [UILabel]()
    private var markers = [String](){
        
        didSet{
            setupMarkers()
        }
    }
    @IBInspectable var markerLabelHeight : CGFloat = 10 {
        didSet{
            prepareMarkers()
        }
    }
    
    @IBInspectable var indicatorImage : UIImage? = UIImage(named: "needle.png"){
        didSet{
            prepareMarkers()
        }
    }
    
    
    private var indicatorView = UIView()
    
    private var indicatorCircleLayer   = CAShapeLayer()
    private var baseSemiCircleLayer   = CAShapeLayer()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWeightScaleControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWeightScaleControl()
    }

    
    func setupWeightScaleControl(){
        prepareMarkers()
       setupMarkers()
    }
    
    func prepareMarkers()  {
        let diff = maxReading - minReading
        let numberOfMarkers = Int(diff/delta)
        var items = [String]()
        
        for index in 0...numberOfMarkers{
            items.append("\(minReading + index * delta)")
        }
        self.markers = items
    }
    
    func setupMarkers()  {
        for label in markerLabels{
            label.removeFromSuperview()
        }
        markerLabels.removeAll(keepingCapacity: true)
        
        for index in 0...markers.count-1{
            let label = UILabel(frame: CGRect.zero)
            label.font = UIFont.systemFont(ofSize: markerLabelHeight)
            label.text = markers[index]
            label.textAlignment = .left
            label.textColor = markerLabelColor
            self.addSubview(label)
            markerLabels.append(label)
        }
        
    }

    
    var scaleCenter : CGPoint = CGPoint.zero
    var circleRadius : CGFloat = 0
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scaleCenter = CGPoint (x: self.frame.size.width / 2, y: self.frame.size.height )
        circleRadius = self.frame.size.width / 2
        let circlePath = UIBezierPath(arcCenter: scaleCenter, radius: circleRadius, startAngle: CGFloat(M_PI), endAngle: CGFloat(M_PI * 2), clockwise: true)
        
        baseSemiCircleLayer.path = circlePath.cgPath
        baseSemiCircleLayer.strokeColor = baseColor.cgColor
        baseSemiCircleLayer.fillColor = UIColor.clear.cgColor
        baseSemiCircleLayer.lineWidth = scaleWidth
        baseSemiCircleLayer.strokeStart = 0
        baseSemiCircleLayer.strokeEnd  = 1
        self.layer.addSublayer(baseSemiCircleLayer)
        
        indicatorCircleLayer.path = circlePath.cgPath
        indicatorCircleLayer.strokeColor = indicatorColor.cgColor
        indicatorCircleLayer.fillColor = UIColor.clear.cgColor
        indicatorCircleLayer.lineWidth = scaleWidth
        indicatorCircleLayer.strokeStart = 0
        //indicatorCircleLayer.strokeEnd  = 0.5
        
        //let x = Double(reading - CGFloat (minReading))/Double(maxReading - minReading)
        //indicatorCircleLayer.strokeEnd  = CGFloat(x)
        
        self.layer.addSublayer(indicatorCircleLayer)
        
        let perAngle =  M_PI / Double(markerLabels.count-1)
        for index in 0...markerLabels.count-1 {
            let label = markerLabels[index]
           // label.textColor = markerLabelColor
            let labelTextSize = label.text?.size(attributes: [NSFontAttributeName: label.font])
           
            let theta = M_PI + (perAngle * Double(index))
            if ((perAngle * Double(index)) > (M_PI/2)){
                let x = CGFloat ( Double (scaleCenter.x) + Double (circleRadius + scaleWidth/2.0 ) * cos(theta) )
                let y = CGFloat (Double (scaleCenter.y) + Double (circleRadius + scaleWidth/2.0 ) * sin(theta)) - markerLabelHeight
                label.frame = CGRect(x: x, y: y, width: (labelTextSize?.width)!, height: markerLabelHeight)
                //label.textColor = baseColor
                self.bringSubview(toFront: label)
            }else{
                let x = CGFloat ( Double (scaleCenter.x) + Double (circleRadius + scaleWidth/2.0 ) * cos(theta)) - (labelTextSize?.width)!
                let y = CGFloat (Double (scaleCenter.y) + Double (circleRadius + scaleWidth/2.0 ) * sin(theta) ) - markerLabelHeight
                label.frame = CGRect(x: x, y: y, width: (labelTextSize?.width)!, height: markerLabelHeight)
                //label.textColor = baseColor
                self.bringSubview(toFront: label)
            }
            
        }
        indicatorView.removeFromSuperview()
        let  indicatorHeight = scaleWidth
        let needeleImageView = UIImageView(image: indicatorImage)
        needeleImageView.contentMode = .scaleAspectFit
        
        indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height:  indicatorHeight))
        needeleImageView.frame = indicatorView.frame
        indicatorView.addSubview(needeleImageView)
        indicatorView.backgroundColor = UIColor.clear
        self.addSubview(indicatorView)
        showReading()
    
    }
    
    func showReading(){
        indicatorView.layer.anchorPoint = CGPoint(x: 0.5, y: circleRadius/scaleWidth + 0.5)
        indicatorView.center = scaleCenter
        let kgPerDegreeCovered = 180.0 / Double(maxReading - minReading)
        let totalReading = (reading - CGFloat (minReading))
        let degreeForReading = Double(kgPerDegreeCovered) * Double (totalReading)
        //degreeForReading = degreeForReading + CGFloat (-M_PI/2.0)
        
        //let angle =  CGFloat (-M_PI) +  degreeForReading
        
        //let theta = CGFloat (M_PI) * (degreeForReading / 180.0)
        //let angle = CGFloat (M_PI) + degreeForReading
        let sixtyDegree = M_PI * degreeForReading/180.0
        let baseAngle = CGFloat(-M_PI * 1.0 / 2.0)
        indicatorView.layer.transform = CATransform3DMakeRotation( baseAngle + CGFloat (sixtyDegree), 0, 0, 1)
        
        /*let rotate =
        
        let values
        
        indicatorView.transform = CGPointApplyAffineTransform(rotationAngle: theta)*/
        
        
    }
}
