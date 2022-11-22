//
//  Resource.swift
//  CrawlCrawl
//
//  Created by 이명직 on 2022/11/22.
//
import UIKit

struct R {
    struct String {
        struct Crwal {}
    }
    struct Color {
        struct Crwal {}
    }
}

extension R.String.Crwal {
    static let download_description: (Int) -> String = {
        return "\($0)개의 이미지 다운로드"
    }
    static let downloading_description: (Int) -> String = {
        return "\($0)% 완료"
    }
    static let search_description = "검색"
    static let searching_description = "검색중"
    static let search_placeholder = "검색어를 입력하세요."
    static let complete_download = "다운로드 완료"
}

extension R.Color.Crwal {
    static let normal = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
    static let disabled = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    static let download_complete_layer = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    static let normal_layer = #colorLiteral(red: 0.9117395282, green: 0.9232173562, blue: 0.9230154753, alpha: 1)
    static let cell_title = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    static let white_title = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let toast_background = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
}
