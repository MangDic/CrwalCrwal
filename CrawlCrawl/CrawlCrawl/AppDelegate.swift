//
//  AppDelegate.swift
//  CrawlCrawl
//
//  Created by 이명직 on 2022/11/17.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let window = window else { return false }
        let vc = CrawlViewController()
        window.rootViewController = vc
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        return true
    }
}

