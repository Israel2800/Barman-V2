//
//  Constants.swift
//  Barman
//
//  Created by JanZelaznog on 26/02/23.
//

import Foundation
import UIKit

struct File {
    static let main = (name: "drinks", extension: "json")
}

struct CellID {
    static let drinkID = "TableViewCellDrinkID"
}

struct SegueID {
    static let detail = "detailSegueID"
}

struct Sites {
    static let baseURL = "http://janzelaznog.com/DDAM/iOS/drinksimages/"
}

public let baseUrl = "http://janzelaznog.com/DDAM/iOS"
public let colorPrimaryDark:UInt = 0x9933cc
public let colorAccent:UInt = 0xD9E933
public let regularFont:String = "San Francisco"

class Utils {
    class func showMessage(_ message:String) {
        let ac = UIAlertController(title: "", message:message, preferredStyle:.alert)
        let aa = UIAlertAction(title: "ok", style:.default, handler: nil)
        ac.addAction(aa)
        for w in UIApplication.shared.windows {
          if w.isKeyWindow {
              DispatchQueue.main.async {
                  w.rootViewController?.present(ac, animated: true)
              }
              break;
          }
        }
    }
    
    class func UIColorFromRGB(rgbValue: UInt) -> UIColor {
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
}

extension UITextField {
    func customize(_ transparent:Bool) {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5;
        self.layer.borderColor = Utils.UIColorFromRGB(rgbValue: colorAccent).cgColor
        self.backgroundColor = .white
        self.font = UIFont(name: regularFont, size: 16)
        self.textColor = Utils.UIColorFromRGB(rgbValue: colorPrimaryDark)
        if transparent {
            self.backgroundColor = .clear
            self.layer.borderColor = Utils.UIColorFromRGB(rgbValue: colorPrimaryDark).cgColor
            self.textColor = Utils.UIColorFromRGB(rgbValue: colorAccent)
        }
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

/*
class LoginManager {
    
    static func checkLoginStatus(completion: @escaping (Bool) -> Void) {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "customLogin")
        completion(isLoggedIn)
    }
    
    static func saveLoginSession(email: String) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: "customLogin")
        ud.set(email, forKey: "userEmail")
        ud.synchronize()
    }
    
    static func logout() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: "customLogin")
        ud.removeObject(forKey: "userEmail")
        ud.synchronize()
    }
}
*/




