//
//  AppDelegate.swift
//  Notes
//
//  Created by Sami Youssef on 9/14/18.
//  Copyright © 2018 Sami Youssef. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let navigationController = UINavigationController(rootViewController: NotesViewController())
        window?.rootViewController = navigationController
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        return true
    }

}

