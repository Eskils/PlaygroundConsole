//
//  AppDelegate.swift
//  PlaygroundKonsoll
//
//  Created by Eskil Sviggum on 26/07/2020.
//

import UIKit
#if targetEnvironment(macCatalyst)
import Cocoa
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        LanguageManager.setupCurrentLanguage()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        sceneSessions.forEach { (session) in
            (session.scene as? UIWindowScene)?.windows.forEach({ (window) in
                guard let konsoll = window.rootViewController as? KonsollKontroller else { return }
                
                konsoll.mottakar.avsluttAvlytting()
                konsoll.status = .Inaktiv
                
                let wt = konsoll.mottakar.webTjenar!
                
                wt.responsHandler = nil
                if wt.isRunning { wt.stop() }
            })
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        application.windows.forEach { (window) in
            guard let konsoll = window.rootViewController as? KonsollKontroller else { return }
            
            konsoll.mottakar.avsluttAvlytting()
            konsoll.status = .Inaktiv
            
            let wt = konsoll.mottakar.webTjenar!
            
            wt.responsHandler = nil
            if wt.isRunning { wt.stop() }
        }
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        builder.remove(menu: .format)
        let keyCommands: [UIKeyCommand] = [
            UIKeyCommand(title: "Kopier adresse".localized, image: UIImage(systemName: "doc.on.doc"), action: #selector(KonsollKontroller.kopierAdresse), input: "c", modifierFlags: [.command, .shift]),
            UIKeyCommand(title: "Rensk konsoll".localized, image: UIImage(systemName: "trash"), action: #selector(KonsollKontroller.rensk), input: "e", modifierFlags: [.command]),
            UIKeyCommand(title: "Skru av/på sanntidsscrolling".localized, image: UIImage(systemName: "arrow.down.right"), action: #selector(KonsollKontroller.toggleSanntidsscroll), input: "s", modifierFlags: [.alternate])
        ]
        
        for menuElement in keyCommands {
                let menu = UIMenu(title: menuElement.title, image: menuElement.image, identifier: UIMenu.Identifier(rawValue: menuElement.title), options: .displayInline, children: [menuElement])
                builder.insertChild(menu, atEndOfMenu: .file)
            }
            
        }
        
    }

