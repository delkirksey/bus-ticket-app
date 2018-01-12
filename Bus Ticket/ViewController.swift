//
//  ViewController.swift
//  Bus Ticket
//
//  Created by Del Shawn Kirksey on 6/30/17.
//  Copyright © 2017 Del Shawn Kirksey. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var curDate: UILabel!
    @IBOutlet weak var curTime: UILabel!
    @IBOutlet weak var secsLabel: UILabel!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var zoneLabel: UILabel!
    
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var activeSecs: NSLayoutConstraint!
    
    let dateForm = DateFormatter()
    let timeForm = DateFormatter()
    var secs:Int = 1
    var qrCodeImage: CIImage!
    var numFlips:Int = 1
    var isConnector:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dateForm.dateStyle = .medium
        curDate.text = "Current Date: " + dateForm.string(from: Date())
        timeForm.timeStyle = .medium
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.touchButton(_:)))
        imgQRCode.isUserInteractionEnabled = true
        imgQRCode.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        isConnector = !isConnector
        zoneLabel.text = isConnector ? "Cincinnati Bell Connector" : "$1.75 Metro Zone 1"
    }
    
    func tick() -> Void {
        if (Int(timeForm.string(from: Date()).components(separatedBy: ":")[0])! < 10) {
            curTime.text = "0" + timeForm.string(from: Date())
        } else {
            curTime.text = timeForm.string(from: Date())
        }
        
        secs += 1
        
        if (secs < 60) {
            secsLabel.text = "Activated " + String(secs) + " seconds ago"
            expLabel.text = "Expires in 4 m : " + String(60 - secs) + " s"
        } else if (secs / 60 == 1) {
            secsLabel.text = "Activated " + String(secs / 60) + " minute and " + String(secs % 60) + " seconds ago"
            expLabel.text = "Expires in 3 m : " + String(60 - secs % 60) + " s"
        } else {
            secsLabel.text = "Activated " + String(secs / 60) + " minutes and " + String(secs % 60) + " seconds ago"
            expLabel.text = "Expires in " + String(4 - (secs / 60)) + " m : " + String(60 - secs % 60) + " s"
        }
        
        generateQRCode()
    }
    
    @IBAction func touchButton(_ sender: Any) {
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromLeft, .showHideTransitionViews]
        
        numFlips += 1
        
        if (numFlips % 2 == 0) {
            UIView.transition(with: secondView, duration: 0.5, options: transitionOptions, animations: {
                self.secondView.isHidden = false
            })
            
            UIView.transition(with: firstView, duration: 0.5, options: transitionOptions, animations: {
                self.firstView.isHidden = true
            })
        } else {
            UIView.transition(with: secondView, duration: 0.5, options: transitionOptions, animations: {
                self.secondView.isHidden = true
            })
            
            UIView.transition(with: firstView, duration: 0.5, options: transitionOptions, animations: {
                self.firstView.isHidden = false
            })
        }
        
        
        
    }
    
    func generateQRCode() {
        let data = String("{\"g\":\"178d15i26g13\",\"s\":\"" + randomString(length: 45) + "\"}").data(using: String.Encoding.isoLatin1)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrCodeImage = filter?.outputImage
        
        displayQRCode()
    }
    
    func displayQRCode() {
        let scaleX = imgQRCode.frame.size.width / qrCodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.width / qrCodeImage.extent.size.height
        
        let transfromedImage = qrCodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        imgQRCode.image = UIImage(ciImage: transfromedImage)
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    
}
