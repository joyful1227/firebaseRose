//
//  AddViewController.swift
//  firebaseRose
//
//  Created by Joy on 2019/5/23.
//  Copyright © 2019 Joy. All rights reserved.
//

import UIKit
import Firebase

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UITextFieldDelegate {

    
    @IBOutlet weak var addIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var inputCategory: UITextField!
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputDescription: UITextField!
    
    @IBOutlet weak var suggestionLabel: UILabel!
    
    @IBOutlet weak var photoButton: UIButton!
    var photo: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        suggestionLabel.text = ""
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        suggestionLabel.text = ""
    }

    
    //跳出照片挑選器
    @IBAction func clickAddPhoto(_ sender: Any) {
        let imagepicker = UIImagePickerController()
        imagepicker.sourceType = .photoLibrary
        imagepicker.delegate = self
        present(imagepicker, animated: true, completion: nil)
        
    }
    
    //選擇照片後
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photo = image
            photoButton.setImage(image, for: .normal)            //將照片設在按鈕上
            photoButton.imageView?.contentMode = .scaleAspectFit //照片是否填滿
            photoButton.setTitle(nil, for: .normal)
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    
    //提交鈕
    @IBAction func clickSubmit(_ sender: Any) {
        suggestionLabel.text = ""
        if photo != nil {
            upload()
        }else {
            suggestionLabel.text = "請上傳一張照片!"
        }
        
    }
    
    //當點擊view任何喔一處鍵盤收起
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //按鍵盤上的return鍵可收起鍵盤
    //1.遵從UITextFieldDelegate 且tf需control drag 與view controller連結
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  //要求他響應我們的Responder
        return true
    }
    
    
    //上傳func-----------------------------------------
    func upload() {
        addIndicatorView.startAnimating()
        let inCate = inputCategory.text ?? ""
        let inName = inputName.text ?? ""
        let inDes = inputDescription.text ?? ""
        
        
            let db = Firestore.firestore()
            let storageReference = Storage.storage().reference()
            let fileReference = storageReference.child(UUID().uuidString + ".png")
        
               let image = self.photoButton.image(for: .normal)
                let size = CGSize(width: 99, height: 200)
                UIGraphicsBeginImageContext(size)
                image?.draw(in: CGRect(origin: .zero, size: size))
                let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                if let data = resizeImage?.pngData(){                              //因為去背圖需用png
                    // if let data = resizeImage?.jpegData(compressionQuality: 1) {    //將照片壓縮轉成data後。上傳firebase
                    fileReference.putData(data, metadata: nil, completion: { (metadata, error) in
                        guard let _ = metadata, error == nil else {
                            self.addIndicatorView.stopAnimating()
                            return
                        }
                        
                        fileReference.downloadURL(completion: { (url, error) in  //取得上傳後的照片網址
                            guard let downloadURL = url else {
                                self.addIndicatorView.stopAnimating()
                                return
                            }
                            //存入資料
                            let data: [String: Any] = ["category": inCate,"name": inName,"description": inDes,"update": Date(),"imgurl": downloadURL.absoluteString]
                            db.collection("plants").addDocument(data: data) { (error) in
                                guard error == nil else {
                                    self.addIndicatorView.stopAnimating()
                                    return
                                }
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    }
                    )
                
        }
        
            
        
            
            
        
    }
    
    
    
}
