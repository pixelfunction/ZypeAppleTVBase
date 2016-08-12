//
//  VideoModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/11/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit


public class VideoModel: BaseModel {
    
    private(set) internal var videoId = ""
    private(set) internal var videoURL = ""
    private(set) public var descriptionString: String = ""
    
    private(set) public var durationValue = 0
    
    private(set) public var ratingValue = 0.0
    private(set) public var purchasePrice: String = ""
    private(set) public var purchaseRequired: Bool = false
    private(set) public var rentalDuration: Int = 0
    private(set) public var rentalPrice: String = ""
    private(set) public var rentalRequired = false
    private(set) public var subscriptionRequired = false
    private(set) public var onAir = false
    
    private(set) public var episode: Int = 0
    private(set) public var series: Int = 0
    
    private(set) public var categoryValueIDs = Array<String>()
    private(set) public var categories = Dictionary<String, Array<String> >()
    
    private(set) public var thumbnails = Array<ThumbnailModel>()
    private(set) public var images = Array<ThumbnailModel>()
    
    private(set) public var fullJson = Dictionary<String, AnyObject>()
    
    init(fromJson: Dictionary<String, AnyObject>)
    {
        super.init(json: fromJson)
        fullJson = fromJson
        
        do {
            videoId = try SSUtils.stringFromDictionary(fromJson, key: kJSON_Id)
        }
        catch _ {
            ZypeLog.error("Exception: VideoModel | Init Video Id")
        }
        
        do {
            descriptionString = try SSUtils.stringFromDictionary(fromJson, key: kJSONDescription)
        }
        catch _ {
            ZypeLog.error("Exception: VideoModel | Init Description")
        }
        
        do {
            durationValue = try SSUtils.intagerFromDictionary(fromJson, key: kJSONDuration)
        }
        catch _ {
            ZypeLog.error("Exception: VideoModel | Init Duration")
        }
        
        do {
            ratingValue = try SSUtils.doubleFromDictionary(fromJson, key: kJSONRating)
        }
        catch _ {
            ZypeLog.error("Exception: VideoModel | Init Rating")
        }
      
        do {
            episode = try SSUtils.intagerFromDictionary(fromJson, key: kJSONEpisode)
        }
        catch _ {
           // ZypeLog.error("Exception: VideoModel | Init Episode")
        }
        
        do {
            series = try SSUtils.intagerFromDictionary(fromJson, key: kJSONSeries)
        }
        catch _ {
           // ZypeLog.error("Exception: VideoModel | Init Series")
        }
        
        do {
            subscriptionRequired = try SSUtils.boolFromDictionary(fromJson, key: kJSONSubscriptionRequired)        }
        catch _ {
             ZypeLog.error("Exception: VideoModel | Subscription Required")
        }
        
        do {
            onAir = try SSUtils.boolFromDictionary(fromJson, key: kJSONSubscriptionRequired)        }
        catch _ {
            ZypeLog.error("Exception: VideoModel | On Air")
        }
        
        self.loadPrices(fromJson)
        self.loadThumbnails(fromJson[kJSONThumbnails] as? Array<AnyObject>)
        self.loadImages(fromJson[kJSONImages] as? Array<AnyObject>)
        self.loadCategories(fromJson[kJSONCategories] as? Array<AnyObject>)
    }
    
    public func getThumbnailByHeight(height: Int) -> ThumbnailModel?
    {
        var value = thumbnails.first
        for thumbnail in self.thumbnails
        {
            if thumbnail.height > height
            {
                break
            }
            value = thumbnail
        }
        return value
    }
    
    public func getVideoObject(type: VideoUrlType, completion:(playerObject: VideoObjectModel?, error: NSError?) -> Void)
    {
        ZypeAppleTVBase.sharedInstance.getVideoObject(self, type: type, completion: completion)
    }
    
    private func loadThumbnails(thumbnails: Array<AnyObject>?)
    {
        do
        {
            if (thumbnails != nil)
            {
                for value in thumbnails!
                {
                    let height = try SSUtils.intagerFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONHeight)
                    let width = try SSUtils.intagerFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONWidth)
                    let url = try SSUtils.stringFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONUrl)
                    let nameValue = value[kJSONName]
                    let name = ((nameValue as? String) != nil) ? (nameValue as! String) : ""
                    self.thumbnails.append(ThumbnailModel(height: height, width: width, url: url, name: name))
                }
            }
        }
        catch _
        {
            ZypeLog.error("Exception: VideoModel | Load Thumbnails")
        }
    }
    
    private func loadImages(images: Array<AnyObject>?)
    {
        do
        {
            if (images != nil)
            {
                for value in images!
                {
                    let url = try SSUtils.stringFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONUrl)
                    let nameValue = value[kJSONTitle]
                    let name = ((nameValue as? String) != nil) ? (nameValue as! String) : ""
                    self.images.append(ThumbnailModel(height: 0, width: 0, url: url, name: name))
                }
            }
        }
        catch _
        {
            ZypeLog.error("Exception: VideoModel | Load Images")
        }
    }
    
    private func loadCategories(categories: Array<AnyObject>?)
    {
        do
        {
            if (categories != nil)
            {
                for item in categories!
                {
                    let title = try SSUtils.stringFromDictionary(item as? Dictionary<String, AnyObject>, key: kJSONTitle)
                    self.categories[title] = Array()
                    let values = item[kJSONValue] as? Array<String>
                    if (values != nil)
                    {
                        self.categories[title] = values
                        for value in values!
                        {
                            self.categoryValueIDs.append(SSUtils.categoryToId(title, categoryValue: value))
                        }
                    }
                }
            }
        }
        catch _
        {
            ZypeLog.error("Exception: VideoModel | Load Categories")
        }
    }
    
    private func loadPrices(fromJson: Dictionary<String, AnyObject>)
    {
        do {
            purchasePrice = try SSUtils.stringFromDictionary(fromJson, key: kJSONPurchasePrice)
            purchaseRequired = try SSUtils.boolFromDictionary(fromJson, key: kJSONPurchaseRequired)
            rentalDuration = try SSUtils.intagerFromDictionary(fromJson, key: kJSONRentalDuration)
            rentalPrice = try SSUtils.stringFromDictionary(fromJson, key: kJSONRentalPrice)
            rentalRequired = try SSUtils.boolFromDictionary(fromJson, key: kJSONRentalRequired)
        }
        catch _
        {
          //  ZypeLog.error("Exception: VideoModel | Load Prices")
        }
    }
    
    public func getId() -> String{
        return videoId
    }
    
    public func getUrl() -> String{
        return videoURL
    }
    
    public func changeTitle(title: String) {
        self.titleString = title
    }
}
