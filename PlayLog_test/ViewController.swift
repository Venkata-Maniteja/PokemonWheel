//
//  ViewController.swift
//  PlayLog_test
//
//  Created by Rupika Sompalli on 25/01/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, CAAnimationDelegate {
    
    var pokeballX: NSLayoutConstraint?
    var pokeballY: NSLayoutConstraint?
    var ballRadius = 20
    var trackRadius = 100
    let trackOffset = 10
    var lastPoint : CGPoint?
    
    var degrees = 0{
        didSet{
            degreeLabel.text = "\(oldValue)"
        }
    }
    var track : WheelView!
    var ball : UIButton!
    @IBOutlet weak var trackHolder : UIView!
    @IBOutlet weak var degreeLabel : UILabel!
    @IBOutlet weak var gallery : UIImageView!
     var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        prepareCircle()
        createPokeBall()
        let touch = UIPanGestureRecognizer(target: self, action:#selector(dragBall(recognizer:)))
        trackHolder.addGestureRecognizer(touch)
        requestPhotos()
        
    }
    
  
    private func prepareCircle() {
        track = WheelView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        trackHolder.addSubview(track)
        track.backgroundColor = UIColor.white
        trackHolder.sendSubviewToBack(track)
        track.translatesAutoresizingMaskIntoConstraints = false
        track.centerXAnchor.constraint(equalTo: trackHolder.centerXAnchor).isActive = true
        track.centerYAnchor.constraint(equalTo: trackHolder.centerYAnchor).isActive = true
        track.widthAnchor.constraint(equalToConstant: CGFloat(2 * trackRadius)).isActive = true
        track.heightAnchor.constraint(equalToConstant: CGFloat(2 * trackRadius)).isActive = true
    }
    
    private func createPokeBall() {
        
        ball = UIButton()
        ball.setBackgroundImage(UIImage(named: "pokeball"), for: .normal)
        ball.addTarget(self, action: #selector(randomRotate), for: .touchUpInside)
        track.addSubview(ball)
        
        ball.translatesAutoresizingMaskIntoConstraints = false
        
        // Width/Height contraints:
        ball.widthAnchor.constraint(equalToConstant: CGFloat(2 * ballRadius)).isActive = true
        ball.heightAnchor.constraint(equalToConstant: CGFloat(2 * ballRadius)).isActive = true
        
        // X/Y constraints:
        let offset = pointOnCircumference(0.0)
        pokeballX = ball.centerXAnchor.constraint(equalTo: track.centerXAnchor, constant: offset.x)
        pokeballY = ball.centerYAnchor.constraint(equalTo: track.centerYAnchor, constant: offset.y)
        
        pokeballX?.isActive = true
        pokeballY?.isActive = true
    }
    
    @objc func dragBall(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .began || recognizer.state == .changed{
            let finger = recognizer.location(in: self.trackHolder)
            
            let distance = getDistanceFromTrack(finger: finger)
            
            if distance < CGFloat(trackRadius) + CGFloat(ballRadius){
                // Angle from track center to touch location:
                let theta = atan2(finger.y - track.center.y, finger.x - track.center.x)
                
                // Update X/Y contraints of the ball:
                let offset = pointOnCircumference(theta)
                updateBall(point: offset)
                
            }
        }else{
            animateImages()
        }
        
    }
    
    @objc func randomRotate(){
        let randDegree = Int.random(in: 0...360)
        
        var points = [CGPoint]()
        
        for degree in 0...randDegree{
            if let point = track.pointMapper[degree]{
                points.append(point)
            }
        }
        
        let theta = convertToRads(deg: CGFloat(randDegree))
        let offset = pointOnCircumference(theta)
        updateBall(point: offset)
       
        
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animation.duration = 1
        animation.repeatCount = 0
        animation.values = points
        animation.delegate = self
        animation.calculationMode = CAAnimationCalculationMode.paced 
        ball.layer.add(animation, forKey: "sample")
       
        
        degrees = randDegree
        
        animateImages()
        

    }
    
    
    func updateBall(point:CGPoint){
        if let ballXconstraint = pokeballX, let ballYconstraint = pokeballY {
            ballXconstraint.constant = point.x
            ballYconstraint.constant = point.y
        }
    }
    
    
    func convertToDegress(rads:CGFloat){
        let conDeg = rads * 180/CGFloat.pi
        if conDeg > 0{
            degrees = Int(conDeg)
        }else{
            degrees =  360 + Int(conDeg)
        }
    }
    
    func convertToRads(deg:CGFloat) -> CGFloat{
        var conRad = deg * CGFloat.pi/180
        if deg > 0 && deg <= CGFloat(180){
            return conRad
        }else{
           let deg = deg - 360
            conRad = deg * CGFloat.pi/180
            return conRad
        }
    }
    
    
    func getDistanceFromTrack(finger:CGPoint) ->CGFloat{
        let point1 = pow(finger.x-track.center.x, 2)
        let point2 = pow(finger.y-track.center.y, 2)
        return sqrt(point1 + point2)
    }
    
    private func pointOnCircumference(_ theta: CGFloat) -> CGPoint {
        let x = cos(theta) * CGFloat(trackRadius-trackOffset)
        let y = sin(theta) * CGFloat(trackRadius-trackOffset)
        
        convertToDegress(rads: theta)
        
        return CGPoint(x: x, y: y)
    }
    
    //Photos
    func requestPhotos(){
        
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
                case .authorized:
                                        print("authorised")
                                        self.getPhotos()
                case .restricted:
                                        print("restricted")
                case .denied:
                                        print("denied")
                default:
                                        print("defualt")
            }
        }
        
    }

    func getPhotos(){
         let request = PHImageRequestOptions()
        images.removeAll()
        images = [UIImage]()
        request.isSynchronous = true
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        let result : PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
        result.enumerateObjects { (asset, i, nil) in
            self.images.append(self.getAssetThumbnail(asset: asset))
        }
        print(images)
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func animateImages(){
        
        let rand = Int.random(in: 0...images.count-1)
        
        gallery.image = images[rand]
        
       let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        
        gallery.layer.add(transition, forKey: "imageChange")
    }

}

extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}

