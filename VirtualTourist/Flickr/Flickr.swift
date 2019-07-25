//
//  Constant.swift
//  VirtualTourist
//
//  Created by Shrooq Saleh on 06.07.19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct Flickr {
    struct Flickr {
        static let searchBBoxHalfWidth = 1.0
        static let searchBBoxHalfHight = 1.0
        static let searchLatRange = (-90.0, 90.0)
        static let searchLonRange = (-180.0, 180.0)
    }
    struct FlickrKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let BoundingBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojesoncallback"
        static let Page = "page"
        static let PerPage = "per_page"
        static let Text = "text"
    }
    struct FlickerValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "f09efd2b04ec3271df556993c48bfbcd"
        static let UserSafeSearch = "1"
        static let MediumURL = "url_m"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let PerPage = 9
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
    }
}
import MapKit
class API{
    static func get(with coordinate: CLLocationCoordinate2D, pageNum: Int, completion: @escaping ([URL]?,Error?,String?) ->()){
        let methodParamters = [Flickr.FlickrKeys.Method: Flickr.FlickerValues.SearchMethod,
                               Flickr.FlickrKeys.APIKey: Flickr.FlickerValues.APIKey,
                               Flickr.FlickrKeys.BoundingBox: bboxString(for: coordinate),
                               Flickr.FlickrKeys.SafeSearch: Flickr.FlickerValues.UserSafeSearch,
                               Flickr.FlickrKeys.Extras: Flickr.FlickerValues.MediumURL,
                               Flickr.FlickrKeys.Format: Flickr.FlickerValues.ResponseFormat,
                               Flickr.FlickrKeys.NoJSONCallback: Flickr.FlickerValues.DisableJSONCallback,
                               Flickr.FlickrKeys.Page: pageNum,
                               Flickr.FlickrKeys.PerPage: Flickr.FlickerValues.PerPage
            ] as [String:Any]
        
        //print(bboxString(for: coordinate))
        let request = URLRequest(url: url(from: methodParamters))
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                completion([] ,error ,nil)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                completion(nil,nil,"status code")
                return
            }
            guard let data = data else{
                completion(nil,nil,"No data was returned by the request")
                return
            }
            
            print(String(data: data, encoding: .utf8)!)
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                completion(nil, nil, "Could not parse the data as JSON. ")
                return
            }
            guard let stat = result["stat"] as? String, stat == "ok" else{
                completion(nil, nil, "F1ickr API returned an error. See error code and message in \(result) ")
                return
            }
            guard let photosDictionary = result["photos"]as? [String:Any]else{
                completion (nil, nil, "Cannot find key 'photos' in \(result) ")
                return
            }
            
            guard let photosArray = photosDictionary["photo"] as? [String:Any]else{
                completion(nil, nil, "Cannot find key 'photo' in \(photosDictionary)")
                return
            }
            let photosURLs = photosArray.compactMap {photoDictionary -> URL? in
                guard let url = photosDictionary["url_m"] as? String else {
                    return nil
                }
                return URL(string: url)
            }
            completion (photosURLs, nil, nil)
        }
        task.resume()
    }
    static func url(from par : [String : Any]) -> URL{
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.flickr.com"
        component.path = "/services/rest"
        component.queryItems = [URLQueryItem]()
        for (key, value) in par{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            component.queryItems!.append(queryItem)
        }
        return component.url!
    }
    static func bboxString(for  coordinate: CLLocationCoordinate2D) -> String{
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let minLon = max(longitude - 1.0, -180)
        
        let minLat = max(latitude - 1.0, -90)
        
        let maxLon = min(longitude + 1.0, 180)
        
        let maxLat = min(latitude + 1.0, 90)
        
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
        
    }
}
