//
//  ViewController.swift
//  firebaseRose
//
//  Created by Joy on 2019/5/23.
//  Copyright © 2019 Joy. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    var plants = [QueryDocumentSnapshot]()
    var isfirstGetImage = true
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewDidLoad")
       
        let image = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = view.center
        activityIndicatorView.startAnimating()
        
        
        let firestore = Firestore.firestore()//建立儲藏庫實體
           firestore.collection("plants").order(by: "update", descending: true).addSnapshotListener { (querySnapshot, error) in
               if let querySnapshot = querySnapshot {
                
                   //第一次至firebase取資料
                    if self.isfirstGetImage == true {
                       self.plants = querySnapshot.documents
                       print(self.plants)
                       
                       self.isfirstGetImage = false                             //在第一次之後都算非第一次
                       DispatchQueue.main.async {
                          self.activityIndicatorView.removeFromSuperview()
                          self.myCollectionView.reloadData()
                       }
                
                   //非第一次至firebase取資料
                   }else if self.isfirstGetImage == false {
                        let documentChange = querySnapshot.documentChanges[0]    //第一個文件
                        if documentChange.type == .added {                       //如果switch case是新增
                           self.plants.insert(documentChange.document, at: 0)    //不再重取，而是取第一個放到array中
                           self.myCollectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
                        }
                   }else{
                       print("self.isfirstGetImage fail")
                   }
            }
        }
    }
    
    

    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(plants.count)
        return plants.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "plantCell", for: indexPath) as! PlantsCollectionViewCell
        
        let plant = plants[indexPath.row]
        

        //print(post.data()["name"] as? String)
        cell.collectViewImage.image = nil
        if let imgString: String = plant.data()["imgurl"] as? String {
            getImage(url: URL(string: imgString)) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        print("URL:\(URL(string: imgString))")
                        cell.collectViewImage.image = image
                    }
                }
            }
        }
        return cell
        
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToAddPlants"  {
             //..
        }else if segue.identifier == "GoToViewPlant" {
            let indexPath = myCollectionView.indexPathsForSelectedItems?.first
            let row = indexPath?.item
            let controller = segue.destination as! ToViewPlantsViewController
            controller.plant = plants[(indexPath?.row)!]
            
            //controller.planttext = plants[(indexPath?.row)!].data()["name"] as? String 只傳名字
        }else{
            print("segue fail")
        }
    }
    

}




//取得照片函式，將controller元件有關於completionHandler 作處理
// @escaping 是於程式執行完畢後執行
func getImage(url: URL?, completionHandler:  @escaping (UIImage?) -> ()) {
    if let url = url {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completionHandler(image)
            } else {
                completionHandler(nil)
            }
        }
        task.resume()
    }
}
