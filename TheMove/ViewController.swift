//
//  ViewController.swift
//  TheMove
//
//  Created by User 2 on 2/20/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import TwitterCore
import GoogleSignIn
import SDWebImage
import Alamofire

class ViewController: UIViewController ,GIDSignInUIDelegate,GIDSignInDelegate,XMLParserDelegate{

    @IBOutlet weak var fbBtn: FBSDKLoginButton!
    
    private var networkController : NetworkController!
    private var xmlParser : XMLParser? = nil
    private var accessToken : String?
    
    private var parsingBuffer : String = ""
    private var parsingAttributes = [String : String]()
    private var context: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
         GIDSignIn.sharedInstance().uiDelegate = self
    
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/contacts.readonly"]
        GIDSignIn.sharedInstance().clientID = "443803541018-su0v8fgl68jhnvl1udrsuc8ep7bdgcgk.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().signIn()
//        let loginButton = FBSDKLoginButton()
//        // Optional: Place the button in the center of your view.
//        loginButton.center = view.center
//        loginButton.readPermissions = [
//            "public_profile",
//            "email",
//            "user_friends",
//        ]
//        view.addSubview(loginButton)
//
//        if (FBSDKAccessToken.current() != nil) {
//
//            let token = FBSDKAccessToken.current()
//
//            if (token?.hasGranted("user_friends"))! == true {
//
//                print(token?.hasGranted as Any)
//
//            }
//
//            let params = ["fields": "id, first_name, last_name, name, email, picture"]
//
//            let graphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
//            let connection = FBSDKGraphRequestConnection()
//            connection.add(graphRequest, completionHandler: { (connection, result, error) in
//                if error == nil {
//
//                    if let userData = result as? [String:Any] {
//
//                        print(userData)
//
//                    }
//                } else {
//
//                    print("Error Getting Friends \(String(describing: error))")
//
//                }
//
//            })
//
//            connection.start()
        
        
//
//        let userId = TWTRTwitter.sharedInstance().sessionStore.session()?.userID
//
//        let client = TWTRAPIClient.init(userID: userId)
//
//        print(client)
//
//            let logInButton = TWTRLogInButton(logInCompletion: { session, error in
//                if (session != nil) {
//
//                    print(session?.userName)
//                    self.apicall()
//                } else {
//                    print("check2")
//                    self.apicall()
//                    print("error: \(error?.localizedDescription)");
//                }
//            })
//            logInButton.center = self.view.center
//            self.view.addSubview(logInButton)
    }
        
        func apicall(){
               let userId = TWTRTwitter.sharedInstance().sessionStore.session()?.userID
            
            
            
        }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error?) {
        
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let userAuth = user{
            
            print(userAuth.authentication.accessToken!)
            
            let urlString = "https://www.google.com/m8/feeds/contacts/default/full?access_token=\(userAuth.authentication.accessToken!)"
            
            print(GIDSignIn.sharedInstance().scopes)
            
            Alamofire.request(urlString, method: .get)
                .responseString { (data) in
                  //  self.parseContactsFromData(data: data)
            }
        }
        
        
    }
    
    public func loadContacts() {
        let contactsURL : NSURL = NSURL(string: "https://www.google.com/m8/feeds/contacts/default/thin?max-results=10000")!
        self.networkController.sendRequestToURL(url: contactsURL, completion: { (data, response, error) -> () in
            if (response?.statusCode == 200 && error == nil) {
                
                DispatchQueue.global(qos: .background).async {
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    self.context.parent = delegate.persistentContainer.viewContext
                    
                    self.parseContactsFromData(data: data!)
                }
                
            } else {
                
            }
        })
    }
    
    private func parseContactsFromData(data : NSData) {
        self.parsingBuffer = ""
        self.xmlParser = XMLParser.init(data: data as Data)
        self.xmlParser?.delegate = self
        self.xmlParser?.parse()
    }
    
    // XML Parser delegate methods
    func parserDidStartDocument(_ parser: XMLParser) {
//        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        delegate.clearCoreDataStore()
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        do {
            try self.context.save()
        } catch let error as NSError {
            NSLog("Unresolved error: %@, %@", error, error.userInfo)
        }
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.persistentContainer.viewContext.perform({
            do {
                try delegate.persistentContainer.viewContext.save()
               
            } catch let error as NSError {
                NSLog("Unresolved error: %@, %@", error, error.userInfo)
            } catch {
                fatalError()
            }
        })
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.parsingBuffer = ""
        self.parsingAttributes = attributeDict
        
        if elementName == "entry" {
          //  self.currentObject = GoogleContact(context: self.context)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.parsingBuffer += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        print(qName,elementName)
//        if elementName == "gd:fullName" {
//            NSLog("%@", self.parsingBuffer)
//            self.currentObject!.name = self.parsingBuffer
//
//        } else if elementName == "gd:email" {
//            NSLog("%@", self.parsingBuffer)
//
//            if self.parsingAttributes["primary"] != nil || self.currentObject!.value(forKey: "email") == nil {
//                self.currentObject!.setValue(self.parsingAttributes["address"]! as String, forKey: "email")
//            } else {
//                let email = EmailAddress(context: self.context)
//                email.email = self.parsingAttributes["address"]! as String
//                self.currentObject!.addToEmails(email)
//            }
//
//        } else if elementName == "gd:phoneNumber" {
//            NSLog("%@", self.parsingBuffer)
//            let fmt = NBPhoneNumberUtil()
//            do {
//                var nb_number: NBPhoneNumber? = nil
//                try nb_number = fmt.parse(self.parsingBuffer, defaultRegion: "US")
//                try self.parsingBuffer = fmt.format(nb_number!, numberFormat: .INTERNATIONAL)
//            } catch let error as NSError {
//                NSLog("error")
//            }
//
//            let number = PhoneNumber(context: self.context)
//            number.number = self.parsingBuffer
//            self.currentObject!.addToNumbers(number)
//            self.currentObject!.primaryPhoneNumber = self.parsingBuffer
//
//        } else if elementName == "link" {
//            let rel = self.parsingAttributes["rel"]
//            if rel == "http://schemas.google.com/contacts/2008/rel#photo" {
//                self.currentObject!.setValue(self.parsingAttributes["href"]! as String, forKey: "url")
//                NSLog("%@", self.parsingAttributes["href"]! as String)
//            }
//        }
    }
}



    
//    let userid = UserDefaults.standard.string(forKey: "UserID")
//    let lattitude = UserDefaults.standard.string(forKey: "latitude")
//    let longitude = UserDefaults.standard.string(forKey: "longitude")
//
//    let params = ["fbuserid":userid!,"latitude":lattitude!,"longitude":longitude!,"kmradius":"5"] as [String : Any]
//    print("params values in \(params)" )
//
//    let reachability = Reachability()!
//
//    switch reachability.connection {
//    case .wifi:
//
//    BusinessHandler.shared().localradious(api: Klocalradious, params: params as [String : Any], httpType: .POST) { (response, localradious, error) in
//    //print(localradious as Any)
//    print((localradious!["radius"]) as Any)
//    self.datalist = localradious!
//    print("datafr5iends data is \(self.datafriends)")
//    self.datafriends = []
//    if localradious!["success"] as! Bool == true {
//    for item in (localradious!["radius"]) as! [AnyObject] {
//    print("item data is \(item)")
//    self.datafriends.append(item)
//    print("fb user name is \(item["fbusername"] as! String)")
//    print("fbuser photo is \(String(describing: item["userphoto"] as? String))")
//    }
//    } else{
//    self.displaymessage(usermessage: "No Friends Near By You. Try again")
//    }
//    DispatchQueue.main.async {
//    HUD.flash(.success, delay: 1.0)
//    self.tablevie.reloadData()
//    }
//    }
//    print("Reachable via WiFi")
//    case .cellular:
//    print("Reachable via Cellular")
//    case .none:
//    displaymessage(usermessage: "please check the internet connection")
//
//    print("Network not reachable")
//    }
//
//}let userid = UserDefaults.standard.string(forKey: "UserID")
//let lattitude = UserDefaults.standard.string(forKey: "latitude")
//let longitude = UserDefaults.standard.string(forKey: "longitude")
//
//let params = ["fbuserid":userid!,"latitude":lattitude!,"longitude":longitude!,"kmradius":"5"] as [String : Any]
//print("params values in \(params)" )
//
//let reachability = Reachability()!
//
//switch reachability.connection {
//case .wifi:
//
//    BusinessHandler.shared().localradious(api: Klocalradious, params: params as [String : Any], httpType: .POST) { (response, localradious, error) in
//        //print(localradious as Any)
//        print((localradious!["radius"]) as Any)
//        self.datalist = localradious!
//        print("datafr5iends data is \(self.datafriends)")
//        self.datafriends = []
//        if localradious!["success"] as! Bool == true {
//            for item in (localradious!["radius"]) as! [AnyObject] {
//                print("item data is \(item)")
//                self.datafriends.append(item)
//                print("fb user name is \(item["fbusername"] as! String)")
//                print("fbuser photo is \(String(describing: item["userphoto"] as? String))")
//            }
//        } else{
//            self.displaymessage(usermessage: "No Friends Near By You. Try again")
//        }
//        DispatchQueue.main.async {
//            HUD.flash(.success, delay: 1.0)
//            self.tablevie.reloadData()
//        }
//    }
//    print("Reachable via WiFi")
//case .cellular:
//    print("Reachable via Cellular")
//case .none:
//    displaymessage(usermessage: "please check the internet connection")
//
//    print("Network not reachable")
//}
//
//}
//}

//https://graph.facebook.com/v2.3/1902168423242558/friends?access_token=EAADw18PZAD1cBAI77g0VGtjXaknNvogp0zceaBNIFVwOQccYe2T7eCCkCatlBjpxldhe25PESYqe2L55o3fdEZAPnFrZA9oWlRmq9L0lR7KW8ydWFAcEKmjfgrRLkuLbOVwiS3sVd5ZBM7s7uUjJ9xMNonyH7yKmGhGgj4i7OILP11puZAVsdvCspIehtZAIP57mTNZBsLQWfHgLLhelz0iIwB7qrtUZCWH3Xmmk9cz4OgZDZD

//}



