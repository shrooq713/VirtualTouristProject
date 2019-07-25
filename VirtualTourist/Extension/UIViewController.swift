//
//  UIViewController.swift
//  VirtualTourist
//
//  Created by Shrooq Saleh on 06.07.19.
//  Copyright © 2019 Udacity. All rights reserved.
//
import Foundation
import UIKit
extension UIViewController{
    func alert(userMessage:String){
        var myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert);
        let okayAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        myAlert.addAction(okayAction)
        self.present(myAlert,animated: true,completion: nil)
    }
    
}
