//
//  Services.swift
//  Barman
//
//  Created by Ángel González on 06/12/24.
//

import Foundation
import CryptoKit

class Services {
    
    func encriptarPassword(_ pass:String) -> String   {
        var newPass = ""
        let salt = ""
        guard let bytes = (pass + salt).data(using: .utf8) else { return "" }
        let hashPass = SHA256.hash(data: bytes)
        newPass = hashPass.compactMap { String(format: "%02x", $0) }.joined()
        return newPass
    }
    
    func loginService (_ username:String, _ password:String, completion:@escaping (Dictionary<String, Any>?) -> Void) {
        if let laURL = URL(string: baseUrl + "/WS/login.php") {
            let sesion = URLSession(configuration: .default)
            var elRequest = URLRequest(url: laURL)
            elRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            elRequest.httpMethod = "POST"
            let cifPassword = encriptarPassword(password)
            let paramString = "username=\(username)&password=\(cifPassword)"
            elRequest.httpBody = paramString.data(using: .utf8)
            let elTask = sesion.dataTask(with: elRequest) { (datos, response, error) in
                if let bytes = datos {
                    do {
                        let diccionario = try JSONSerialization.jsonObject(with: bytes) as! Dictionary<String,Any>
                        completion(diccionario)
                    }
                    catch {
                        print ("ocurrió un error en el response \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            }
            elTask.resume()
        }
    }
}
