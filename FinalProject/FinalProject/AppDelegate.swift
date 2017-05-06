//
//  AppDelegate.swift
//
//  Created by Hank Sway on 4/24/17.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    var window: UIWindow?
    var pattern: [[Int]] = []
    var userDefaults: UserDefaults?
    
    func convertData(text: String) -> Any? {
        if let data = text.data(using: .utf8) {
            do { return try JSONSerialization.jsonObject(with: data, options: []) }
            catch { print(error.localizedDescription) }
        }
        return nil
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let file = "data"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(file)
            
            do {
                let data = try String(contentsOf: path, encoding: String.Encoding.utf8)
                let json = convertData(text: data)
                if let dataArray = json as? NSArray {
                    if let nameDict = dataArray[0] as? NSDictionary {
                        if let array = nameDict["saved"] as? [[Int]] { pattern = array }
                    }
                }
            }
            catch { print("error reading file") }
        }
        
        userDefaults = UserDefaults.standard
        userDefaults?.setValue(pattern, forKey: "pattern")
        userDefaults?.synchronize()
        return true
    }
}
