//
//  ImageData.swift
//  CrawlCrawl
//
//  Created by 이명직 on 2022/11/21.
//
import UIKit

class ImageData {
    var title: String
    var size: CGSize
    var url: String
    var isDownLoad: Bool
    
    init(title: String, size: CGSize, url: String, isDownLoad: Bool = false) {
        self.title = title
        self.size = size
        self.url = url
        self.isDownLoad = isDownLoad
    }
}
