//
//  AddViewController.swift
//  firebaseRose
//
//  Created by Joy on 2019/5/23.
//  Copyright © 2019 Joy. All rights reserved.
//

import UIKit
import Firebase

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var addIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var inputCategory: UITextField!
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputDescription: UITextField!
    
    
    @IBOutlet weak var photoButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        let image = info[.originalImage] as? UIImage
        photoButton.setImage(image, for: .normal)            //將照片設在按鈕上
        photoButton.imageView?.contentMode = .scaleAspectFit //照片是否填滿
        photoButton.setTitle(nil, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    
    //提交鈕
    @IBAction func clickSubmit(_ sender: Any) {
        upload()
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
