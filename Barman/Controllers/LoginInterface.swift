//
//  LoginInterface.swift
//  Barman
//
//  Created by Ángel González on 07/12/24.
//


import Foundation
import UIKit
import AuthenticationServices
import GoogleSignIn

class LoginInterface: UIViewController, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate, CustomLoginViewControllerDelegate {
    
    func customLoginViewController(_ me: CustomLoginViewController, performLogin: Bool) {
        if performLogin {
            // Actualiza el estado del usuario en UserDefaults
            UserDefaults.standard.set(true, forKey: "customLogin")
            UserDefaults.standard.synchronize()
            
            // Realiza la transición a la siguiente pantalla
            self.performSegue(withIdentifier: "loginOK", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginOK" {
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    let actInd = UIActivityIndicatorView(style: .large)
    
    // Implementar cuándo debe aparecer y desaparecer el activity indicator
    func showActivityIndicator(){
        actInd.center = self.view.center
        self.view.addSubview(actInd)
        actInd.startAnimating()
    }
    
    func hideActivityIndicator(){
        actInd.stopAnimating()
        actInd.removeFromSuperview()
    }
    
    func isInternetAvailable() -> Bool {
        return NetworkReachability.shared.isConnected
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Detectar la conexión a internet
        if isInternetAvailable() {
            detectaEstado()
            print("Sí hay conexión a internet")
        } else {
            Utils.showMessage("No hay conexión a Internet.")
        }
    }
    
    func detectaEstado() {
        showActivityIndicator()
        
        // Si es customLogin, hay que revisar en UserDefaults
        if UserDefaults.standard.bool(forKey: "customLogin") {
            self.performSegue(withIdentifier: "loginOK", sender: nil)
            hideActivityIndicator()
        } else {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: "userIdentifier") { state, error in
                DispatchQueue.main.async {
                    switch state {
                    case .authorized:
                        self.performSegue(withIdentifier: "loginOK", sender: nil)
                    default:
                        print("Usuario no logueado con Apple ID")
                    }
                    self.hideActivityIndicator()
                }
            }
            
            GIDSignIn.sharedInstance.restorePreviousSignIn { usuario, error in
                DispatchQueue.main.async {
                    guard let perfil = usuario else {
                        self.hideActivityIndicator()
                        return
                    }
                    print("Usuario: \(perfil.profile?.name ?? ""), Correo: \(perfil.profile?.email ?? "")")
                    self.performSegue(withIdentifier: "loginOK", sender: nil)
                    self.hideActivityIndicator()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let loginVC = CustomLoginViewController()
        loginVC.delegate = self
        self.addChild(loginVC)
        loginVC.view.frame = CGRect(x: 0, y: 45, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(loginVC.view)
        loginVC.didMove(toParent: self)
        
        setupSocialLoginButtons(in: loginVC)
    }

    func setupSocialLoginButtons(in loginVC: CustomLoginViewController) {
        let appleIDBtn = ASAuthorizationAppleIDButton()
        loginVC.view.addSubview(appleIDBtn)
        
        // Colocar el botón de Apple debajo del botón "Acceder"
        appleIDBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appleIDBtn.topAnchor.constraint(equalTo: loginVC.loginButton.bottomAnchor, constant: 20),
            appleIDBtn.centerXAnchor.constraint(equalTo: loginVC.view.centerXAnchor),
        ])
        appleIDBtn.addTarget(self, action: #selector(appleBtnTouch), for: .touchUpInside)
        
        let googleBtn = GIDSignInButton()
        loginVC.view.addSubview(googleBtn)
        
        // Colocar el botón de Google debajo del botón de Apple
        googleBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            googleBtn.topAnchor.constraint(equalTo: appleIDBtn.bottomAnchor, constant: 10),
            googleBtn.centerXAnchor.constraint(equalTo: loginVC.view.centerXAnchor),
            googleBtn.widthAnchor.constraint(equalTo: appleIDBtn.widthAnchor),
            googleBtn.heightAnchor.constraint(equalTo: appleIDBtn.heightAnchor)
        ])
        googleBtn.addTarget(self, action: #selector(googleBtnTouch), for: .touchUpInside)
    }

    
    @objc func googleBtnTouch() {
        if !isInternetAvailable() {
            Utils.showMessage("No hay conexión a Internet.")
            return
        }
        
        showActivityIndicator()
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                self.hideActivityIndicator()
                Utils.showMessage("Jiuston... tenemos un problema: \(error.localizedDescription)")
            } else {
                guard let profile = result?.user else {
                    self.hideActivityIndicator()
                    return
                }
                print("Usuario: \(profile.profile?.name ?? ""), Correo: \(profile.profile?.email ?? "")")
                self.performSegue(withIdentifier: "loginOK", sender: nil)
                self.hideActivityIndicator()
            }
        }
    }
    
    @objc func appleBtnTouch() {
        if !isInternetAvailable() {
            Utils.showMessage("No hay conexión a Internet.")
            return
        }
        
        showActivityIndicator()
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.presentationContextProvider = self
        authController.delegate = self
        authController.performRequests()
    }
}
