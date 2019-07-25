//
//  ImageView.swift
//  VirtualTourist
//
//  Created by Shrooq Saleh on 07.07.19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
let imageCatch = NSCache<NSString, AnyObject>()
class ImageView: UIImageView{
    var imageURL: URL!
    private var photo : Photo!{
        didSet{
            if let image = photo.get(){
                stopAnActivityIndicator()
                self.image = image
                return
            }
            guard let url = photo.imageURL else {
                return
            }
            loadImage(with: url)
        }
    }
    
    func setPhoto(_ newPhoto: Photo){
        if photo == nil{
            photo = newPhoto
            
        }else{
            return
        }
    }
    
    func loadImage(with url: URL){
        imageURL = url
        image = nil
        startAnActivityIndicator()
        if let cachedImage = imageCatch.object(forKey: url.absoluteString as NSString) as? UIImage{
            image = cachedImage
            stopAnActivityIndicator()
            return
        }
        URLSession.shared.dataTask(with: url){(data, response, error)in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            guard let downloadedImage = UIImage(data: data!)else{return}
            imageCatch.setObject(downloadedImage, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                self.image = downloadedImage
                self.photo.set(image: downloadedImage)
                try? self.photo.managedObjectContext?.save()
                self.stopAnActivityIndicator()
            }
        }.resume()
}
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.addSubview(activityIndicator)
        self.bringSubviewToFront(activityIndicator)
        return activityIndicator
    }()
    func startAnActivityIndicator(){
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    func stopAnActivityIndicator(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }

}

