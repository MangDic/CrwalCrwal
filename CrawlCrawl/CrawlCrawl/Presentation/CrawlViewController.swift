//
//  CrawlViewController.swift
//  CrawlCrawl
//
//  Created by 이명직 on 2022/11/17.
//

import UIKit
import SwiftSoup
import RxSwift
import RxCocoa
import Kingfisher

class CrawlViewController: UIViewController {
    // MARK: Properties
    let disposeBag = DisposeBag()
    let dataRelay = BehaviorRelay<[ImageData]>(value: [])
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTableViewData()
        setupLayout()
        bind()
        addTapGesture()
    }
    
    // MARK: Method
    private func loadTableViewData() {
        crawlView.searchRelay.subscribe(onNext: { [weak self] text in
            guard let `self` = self else { return }
            let urlStr = NetworkController.baseUrl + text + NetworkController.subUrl
            let encodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            DispatchQueue.global(qos: .default).async {
                self.loadImageLinkByHTML(urlStr: encodedStr, completion: { data in
                    guard let data = data else { return }
                    self.dataRelay.accept(data)
                })
            }
        }).disposed(by: disposeBag)
    }

    /// url로부터 링크 데이터를 가져옵니다.
    private func loadImageLinkByHTML(urlStr: String, completion: @escaping ([ImageData]?) -> ()) {
        guard let url = URL(string: urlStr) else { return }
        do {
            let html = try String(contentsOf: url, encoding: .utf8)
            let doc: Document = try SwiftSoup.parse(html)
            
            var arr = [ImageData]()
            let body = doc.body()
            let imgArr = try body!.select("img").array()
            
            for img in imgArr {
                let data = try img.attr("data-src")
                let height = try img.attr("height")
                let width = try img.attr("width")
                let title = try img.attr("alt")
                if data == "" || height == "" || title == "" {
                    continue
                }
                arr.append(ImageData(title: title, size: CGSize(width:  Double(width) ?? 0, height: Double(height) ?? 0), url: data))
            }
            completion(arr)
        }
        catch {
            print("Error")
            completion(nil)
        }
    }
    
    private func addTapGesture() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        
        singleTap.numberOfTapsRequired = 1
        singleTap.isEnabled = true
        singleTap.cancelsTouchesInView = false
        
        crawlView.addGestureRecognizer(singleTap)
    }
    
    @objc
    private func endEdit() {
        crawlView.endEditing(true)
    }
    
    // MARK: Binding
    private func bind() {
        crawlView.setupDI(dataRelay: self.dataRelay)
    }
    
    // MARK: View
    lazy var crawlView = CrawlView()
    
    private func setupLayout() {
        view.addSubview(crawlView)
        
        crawlView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }
}
