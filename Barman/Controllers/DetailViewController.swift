//
//  DetailViewController.swift
//  Barman
//
//  Created by JanZelaznog on 26/02/23.
//

import UIKit
// para validar el permiso de uso de la camara necesitamos las clases de este framework
import AVFoundation
// para utilizar el app de correo
import MessageUI


class DetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ingredientsTextField: UITextField!
    @IBOutlet weak var directionsTextField: UITextField!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var stackViewContainerBottomConstraint: NSLayoutConstraint!
    
    var drink: Drink?
// uiimagepickercontroller siempre debe ser una property para que se mantenga la referencia
    var ipc: UIImagePickerController!
    
    @IBAction func btnCamaraTouch(_ sender: Any) {
        // validar permisos para usar la camara
        switch AVCaptureDevice.authorizationStatus(for:.video) {
        case .authorized: // el usuario ya dió los permisos para usarla
            self.mostrarPicker(tipo:UIImagePickerController.SourceType.camera)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for:.video) { nuevovalor in
                if nuevovalor {
                    self.mostrarPicker(tipo:UIImagePickerController.SourceType.camera)
                }
            }
        default:
            let ac = UIAlertController(title: "Error", message:"Se requiere la cámara. Desea configurar los permisos en settings?", preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .default) {
                alertaction in
                let configURL = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(configURL!)
            }
            let action2 = UIAlertAction(title: "ahora no", style: .default)
            ac.addAction(action)
            ac.addAction(action2)
            self.present(ac, animated: true)
        }
    }
    
    func mostrarPicker( tipo: UIImagePickerController.SourceType) {
        ipc = UIImagePickerController()
        ipc.delegate = self
        ipc.sourceType = tipo
        ipc.allowsEditing = true
        self.present(ipc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // si NO se permite la edición de la foto, hay que buscar la foto elegida, en esta llave:
        //if let imagen = info[.originalImage] as? UIImage {
        
        // si se permite la edición de la foto, hay que buscar la foto elegida, en esta llave:
        if let imagen = info[.editedImage] as? UIImage {
            imageView.image = imagen
            print("la imagen ya debe estar actualizada")
            saveImageDocumentDirectory(string: "nueva_foto.png", image: imageView.image!)
        }
        picker.dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let drink = drink {
            let shareBarButtonItem: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem:.action, target: self, action: #selector(share))
            self.navigationItem.rightBarButtonItem = shareBarButtonItem
            self.title = drink.name
            self.nameTextField.text = drink.name
            self.nameTextField.isEnabled = false
            self.ingredientsTextField.text = drink.ingredients
            self.ingredientsTextField.isEnabled = false
            self.directionsTextField.text = drink.directions
            self.directionsTextField.isEnabled = false
            self.addPhotoButton.isHidden = true
            self.navigationItem.leftBarButtonItem = nil
        } else {
            self.addPhotoButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
            initializeTextFields()
            updateSaveBarButtonItemState()
            registerForKeyNotification()
            self.nameTextField.delegate = self
            self.ingredientsTextField.delegate = self
            self.directionsTextField.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var imgUrl = URL(string: "")
        if let documentsURL = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask).first, let drink = drink {
            imgUrl = documentsURL.appendingPathComponent(drink.img)
        }
        
        if let imgUrl = imgUrl, FileManager.default.fileExists(atPath:imgUrl.path) {
            print("File is available")
            self.imageView.image = UIImage(contentsOfFile: imgUrl.path)
        }
        else {
            if NetworkReachability.shared.isConnected {
                self.imageView.image = UIImage(named: "empty_drink.png")
                guard var url = URL(string: Sites.baseURL), let stringImg = drink?.img else { return }
                url.appendPathComponent(stringImg)
                let configuration = URLSessionConfiguration.ephemeral
                let session = URLSession(configuration: configuration)
                let request = URLRequest (url: url)
                let task = session.dataTask(with: request) { [self] bytes, response, error in
                    if error == nil {
                        guard let data = bytes, let uiImage = UIImage(data: data) else { return }
                        DispatchQueue.main.sync {
                            self.imageView.image = uiImage
                        }
                        saveImageDocumentDirectory(string: stringImg, image: uiImage)
                    }
                }
                task.resume()
            } else {
                showNoWifiAlert()
            }
        }
    }
    
    func saveImageDocumentDirectory(string: String, image: UIImage) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let documents = documents else { return }
        let url = documents.appendingPathComponent(string)
        if let data = image.pngData() {
            do {
                try data.write(to: url)
            } catch {
                print("Unable to Write Image Data to Disk")
            }
        }
    }
    
    func showNoWifiAlert() {
        let alertController = UIAlertController (title: "Connection error", message: "Go to Settings?", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: "App-Prefs:root=WIFI") else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func share() {
        let elementos = ["Inventé un nuevo trago!", imageView.image as Any] as [Any]
        let avc = UIActivityViewController(activityItems:elementos, applicationActivities:nil)
        avc.excludedActivityTypes = [.postToFacebook, .postToWeibo]
        self.present(avc, animated: true)
        /*
        // compartir por correo electrónico con el app de Mail
        if MFMailComposeViewController.canSendMail() {
            let mcvc = MFMailComposeViewController()
            mcvc.delegate = self
            mcvc.mailComposeDelegate = self
            mcvc.setSubject("Inventé un nuevo trago!")
            mcvc.setToRecipients(["jan.zelaznog@gmail.com"])
            mcvc.setMessageBody("<b>\(drink?.name ?? "")</b><br>\(drink?.directions ?? "")", isHTML:true)
            mcvc.addAttachmentData(imageView.image!.jpegData(compressionQuality: 0.5)!, mimeType:"", fileName:"miBebida.jpg")
            self.present(mcvc, animated: true)
        }
        */
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .sent {
            // hacer algo?
        }
        controller.dismiss(animated: true)
    }
    
    @objc func save() {
        
    }
    
    func updateSaveBarButtonItemState() {
        let name = nameTextField.text ?? ""
        let ingredients = ingredientsTextField.text ?? ""
        let directions = directionsTextField.text ?? ""
        saveBarButtonItem.isEnabled = !name.isEmpty && !ingredients.isEmpty && !directions.isEmpty
    }
    
    func initializeTextFields() {
        nameTextField.text = ""
        ingredientsTextField.text = ""
        directionsTextField.text = ""
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if nameTextField.isEditing || ingredientsTextField.isEditing || directionsTextField.isEditing {
            moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.stackViewContainerBottomConstraint, keyboardWillShow: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.stackViewContainerBottomConstraint, keyboardWillShow: false)
    }
    
    func moveViewWithKeyboard(notification: NSNotification, viewBottomConstraint: NSLayoutConstraint, keyboardWillShow: Bool) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        if keyboardWillShow {
            let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0) // Check if safe area exists
            let bottomConstant: CGFloat = 20
            viewBottomConstraint.constant = keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
        } else {
            viewBottomConstraint.constant = 20
        }
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    func registerForKeyNotification() {
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.keyboardWillShow),
                    name: UIResponder.keyboardWillShowNotification,
                    object: nil)

                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.keyboardWillHide),
                    name: UIResponder.keyboardWillHideNotification,
                    object: nil)
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveBarButtonItemState()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "saveUnwind" else { return }
        let name = nameTextField.text!
        let ingredients = ingredientsTextField.text!
        let directions = directionsTextField.text!
        
        drink = Drink(name: name, img: "", ingredients: ingredients, directions: directions)
    }
}
