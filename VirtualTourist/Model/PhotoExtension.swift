//
//  PhotoExtension.swift
//  VirtualTourist
//
//  Created by Shrooq Saleh on 06.07.19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

extension Photo {
    func set(image: UIImage){
        self.imageData = image.pngData()
    }
    func get() -> UIImage? {
        return (imageData == nil) ? nil : UIImage(data: imageData!)
    }
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
