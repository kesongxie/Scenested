//
//  AppDelegate.swift
//  scenested-experiment
//
//  Created by Xie kesong on 4/10/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit
//import CoreLocation
import CoreBluetooth


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var userDeviceToken: String?
    
    var loggedInUser: User?
    
    
  //  var peripheralManager: CBPeripheralManager! //act as source for beacon
    
    var blueToothPeripheralManager: CBPeripheralManager!
    
    var centralManager: CBCentralManager!
    
    var window: UIWindow?
    
    var discoveredPeriperal: CBPeripheral?
    
    var connectedPeriperal = [CBPeripheral]()
    
    var currentNearByUserIdList = [Int]() //convenient for checking whether the detected nearby has already been added to the id list or not
//    var currentNearByUserList = [User]()
   
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
              //initilize logged-in user data
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.rangingInit(_:)), name: NotificationLocalizedString.RangingInitNotificationName, object: nil)
        return true
    }
    
    /*
        this is called when the user logged in
     */
    func rangingInit(notification: NSNotification){
        //specify the interaction types, ask the user permission for sending notification
        let notificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        //register for remote notification, this would use the interation types above
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        // peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        blueToothPeripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        centralManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
       // startForegroundAdvertising()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
   
    
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        //check whether the setting has been modified, ex. If the user disallows specific notification types, avoid using those types when configuring local and remote notifications for your app.
        if notificationSettings.types == .None{
            //the user doesn't allow any notification
            return
        }
    }
    
    //MARK: Local Notification Delegate
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
     //   print("just recieve local notification")
    }
    
    
    
    //MARK: Remote Notification Delegate
    
    //the following methods revoked only when cellular or Wi-Fi connection is  available
    //The device token is your key to sending push notifications to your app on a specific device. Device tokens can change, so your app needs to reregister every time it is launched and pass the received token back to your server.
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        //If registration was successful, send the device token to the server you use to generate remote notifications.
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        userDeviceToken = tokenString
        getLoggedInUser()?.updateUserDeviceTokenForRemoteNotification(userDeviceToken!)
       // Upon receiving the device token, the delegate method calls custom code to deliver that token to its server
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // it is usually better to degrade gracefully and avoid any unnecessary work needed to process or display those notifications.
        
        print("failed to register remote notification with error: \(error.localizedDescription)")
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("------------------------recieve from method 1 -------------------------------")
        self.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: {
            result in
        })
    }
    
    
    
    //Use this method to process incoming remote notifications for your app. Unlike the application:didReceiveRemoteNotification: method, which is called only when your app is running in the foreground, the system calls this method when your app is running in the foreground or background. In addition, if you enabled the remote notifications background mode, the system launches your app (or wakes it from the suspended state) and puts it in the background state when a remote notification arrives. However, the system does not automatically launch your app if the user has force-quit it. In that situation, the user must relaunch your app or restart the device before the system attempts to launch your app automatically again.
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        //userInfo contains payload of the remote notificaiton, the Jason encoded object
        //get the userId(just come acrross) from the userInfo, then when the user swipe to open the app, bring the user to the other user's profile
        //when user swipe and open the notification, this method will be invoked
        
        if let info = userInfo["respondInfo"] as? [String: AnyObject]{
            let comeAccrossUser = User(userInfo: info)
            let param: [String: AnyObject] = [
                "comeAccrossUser": comeAccrossUser,
                "ApplicationStateRawValue": UIApplication.sharedApplication().applicationState.rawValue
            ]
            let comeAccrossUserProfileViewRequestNotification = NSNotification(name: NotificationLocalizedString.ComeAcrossUserProfileViewRequestNotificationName, object: self, userInfo: param)
            NSNotificationCenter.defaultCenter().postNotification(comeAccrossUserProfileViewRequestNotification)
        }
        //if it's background
        //bring to the user's profile page for respondUserId
        
        //if it's in foreground
        //so notification in the ranging tab
        completionHandler(UIBackgroundFetchResult.NoData) //must call the completion handler
    }
    
}

//MARK: PeripheralManagerDelegate App acts as source
extension AppDelegate: CBPeripheralManagerDelegate{
    
    //when call the addService of CBPeripheralManager class, this delegate method gets called.
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
    }
    
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        request.value =  NSData(bytes: &loggedInUser!.id , length: sizeof(loggedInUser!.id.dynamicType))
        blueToothPeripheralManager.respondToRequest(request, withResult: .Success) //called this method exactly once per readRequest
    }
    
    
    
    
    func startAdvertising(){
        blueToothPeripheralManager.stopAdvertising()
        if !blueToothPeripheralManager.isAdvertising{
            let cBUUID = AppCBUUID
            //construct the characteristic
            let characteristic = CBMutableCharacteristic(type: cBUUID, properties: CBCharacteristicProperties.Read, value: nil, permissions: CBAttributePermissions.Readable) //specify  the value to nil because it depends on which user is currently loggedin the App
            
            //construct the service
            let service = CBMutableService(type: cBUUID, primary: true) //primary set to true beacause the id of the user unchanged regardlessly which device it references to
            service.characteristics = [characteristic]
            
            //add service to the peripheralManager
            blueToothPeripheralManager.addService(service) //publish the service and chracteristic

            let blueToothAdvertisingData:[String: AnyObject] =
                [
                    CBAdvertisementDataServiceUUIDsKey: [ service.UUID ],
                ]
            blueToothPeripheralManager.startAdvertising(blueToothAdvertisingData)
        }else{
            print("blue tooth advertising has already started")
        }
    }
    
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error != nil{
            print(error)
        }else{
           print("start advertising")
        }
    }
    
    
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        //check whether the bluetooth is powered on or not
        let userDefault = NSUserDefaults.standardUserDefaults()
        if userDefault.objectForKey(NSUserDefaultNameKey.BluetoothEnableMessagePrompted) != nil{
            if blueToothPeripheralManager!.state == .PoweredOn{
                startAdvertising()
            }
        }else{
            //prompt only for the first time
            if blueToothPeripheralManager != nil{
                switch blueToothPeripheralManager!.state{
                case .PoweredOn:
                    startAdvertising()
                default:
                    //prompt the user to turn on the bluetooth sharing
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertController(title: "Turn on Bluetooth", message: "Turn on bluetooth to allow sharing profiles with your near-by friends", preferredStyle: .Alert)
                        
                        let dontAllowAction = UIAlertAction(title: "Don't Allow", style: .Default, handler: nil)
                        let goToSettingAction = UIAlertAction(title: "Ok", style: .Default, handler: {
                            _ in
                            if let url = NSURL(string: "prefs:root=Bluetooth"){
                                UIApplication.sharedApplication().openURL(url)
                            }
                        })
                        alert.addAction(dontAllowAction)
                        alert.addAction(goToSettingAction)
                        userDefault.setBool(true, forKey: NSUserDefaultNameKey.BluetoothEnableMessagePrompted)
                        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            }
        }
    }
}



//MARK: CBCentralManagerDelegate for central

extension AppDelegate: CBCentralManagerDelegate{
    
    /*
        Invoked when the central manager’s state is updated.
     
        You implement this required method to ensure that Bluetooth low energy is supported and available to use on the central device. You should issue commands to the central manager only when the state of the central manager is powered on, as indicated by the CBCentralManagerStatePoweredOn constant. A state with a value lower than CBCentralManagerStatePoweredOn implies that scanning has stopped and that any connected peripherals have been disconnected. If the state moves below CBCentralManagerStatePoweredOff, all CBPeripheral objects obtained from this central manager become invalid and must be retrieved or discovered again. For a complete list and discussion of the possible values representing the state of the central manager, see the CBCentralManagerState enumeration in CBCentralManager Class Reference.
     
     */
    func centralManagerDidUpdateState(central: CBCentralManager) {
        let state = central.state
        switch state{
        case .PoweredOn:
            print("power on")
            let serviceUUID = [ CBUUID(NSUUID:  NSUUID(UUIDString: APPUUID)! ) ]
            central.scanForPeripheralsWithServices(serviceUUID, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        case .PoweredOff:
            break
            //send a notification that telling that the bluetooth is currently power off
        default:
            break
        }
        let stateUpdatedNotification = NSNotification(name: NotificationLocalizedString.CentralManagerStateUpdatedNotificationName, object: self, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(stateUpdatedNotification)
    }
    
    
    //after calling scanForPeripheralsWithServices, the central manager calls this each time when it discovers a new peripheral
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        let discoveredPeripheral = peripheral
        if !connectedPeriperal.contains(discoveredPeripheral){
            print("found new CBPeripheral")
            print(peripheral)
            connectedPeriperal.append(discoveredPeripheral)
            //make the connection
            centralManager.connectPeripheral(connectedPeriperal.last!, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        //Before you begin interacting with the peripheral, you should set the peripheral’s delegate to ensure that it receives the appropriate callbacks, like this:
        peripheral.delegate = self
        
        //after the connection has been made, this allows the central to discover the service provided by the peripheral
        peripheral.discoverServices([AppCBUUID]) //this would fire the callback "didDiscoverServices" of the peripheral delegate object
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("connection renounced")
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print(error?.localizedDescription)
    }
}


//MARK: CBPeripheralDelegate for interation between pheripheral and central, read write request, etc
extension AppDelegate: CBPeripheralDelegate{
    //check what kind of services the peripheral provided
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let services = peripheral.services{
            for service in services{
                peripheral.discoverCharacteristics([AppCBUUID], forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let chracteristics = service.characteristics{
            for characteristic in chracteristics{
                //  After you have found a characteristic of a service that you are interested in, you can read the characteristic’s value by calling the readValueForCharacteristic: method of the CBPeripheral class, specifying the appropriate characteristic, like this:
                peripheral.readValueForCharacteristic(characteristic)
            }
        }
    }
    
    //When you attempt to read the value of a characteristic, the peripheral calls the peripheral:didUpdateValueForCharacteristic:error: method of its delegate object to retrieve the value. If the value is successfully retrieved, you can access it through the characteristic’s value property, like this:
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error == nil{
            if let retrievedData = characteristic.value{
                var comeAccrossUserId = 0
                retrievedData.getBytes(&comeAccrossUserId, length: sizeof(comeAccrossUserId.dynamicType))
                
                if !currentNearByUserIdList.contains(comeAccrossUserId){
                    self.currentNearByUserIdList.insert(comeAccrossUserId, atIndex: 0)
                    let param = [
                        "currentNearByUserIdList": currentNearByUserIdList
                    ]
                    
                    print(currentNearByUserIdList)
                    print("notification posted")

                    let nearbyUserIdUpdatedNotification = NSNotification(name: NotificationLocalizedString.NearByUserIdUpdatedNotificationName, object: self, userInfo: param)
                    NSNotificationCenter.defaultCenter().postNotification(nearbyUserIdUpdatedNotification)
                }
                    
                    
                    //post a notification to the nearbyViewController so that it can upadte the interface accordingly.
                
                
            //      pass the current user id and the one just came accross as well to the server, it's up to the server to determine whether the push notification should be send or not.
                if loggedInUser?.id != nil{
                    Feature.rangingSimilarFeatureBetweenUsersById(userRequestId: loggedInUser!.id!, userComeAcrossId: comeAccrossUserId)
                }
                
                //Disconnect from a Device When You Have All the Data You Need
                //if don't call cancelPeripheralConnection, the device is still using blue tooth which is bad for the user's device battery life
                centralManager.cancelPeripheralConnection(peripheral)
                if connectedPeriperal.contains(peripheral){
                    if let index = connectedPeriperal.indexOf(peripheral){
                        connectedPeriperal.removeAtIndex(index)
                       // print("just removed new CBPeripheral")
                    }
                }
            }
        }
    }
}



