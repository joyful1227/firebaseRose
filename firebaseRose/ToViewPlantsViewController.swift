//
//  ToViewPlantsViewController.swift
//  firebaseRose
//
//  Created by Joy on 2019/5/23.
//  Copyright © 2019 Joy. All rights reserved.
//

import UIKit
import Firebase

class ToViewPlantsViewController: UIViewController {

    
    @IBOutlet weak var toViewPageImage: UIImageView!
    
    @IBOutlet weak var toViewPageCategory: UILabel!
    @IBOutlet weak var toViewPageName: UILabel!
    @IBOutlet weak var toViewPageDescription: UILabel!
    @IBOutlet weak var toViewPageGrowdate: UILabel!
    
    //var plants = [QueryDocumentSnapshot]()
    var plant : QueryDocumentSnapshot?
    //var planttext: String?
    //var plantt: [String: Any]
    //var test: QueryDocumentSnapshot
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("plant",plant)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let plant = plant {
            self.toViewPageCategory.text = "種類： \(plant.data()["category"] as? String ?? "")"
            self.toViewPageName.text = "名稱： \(plant.data()["name"] as? String ?? "")"
            self.toViewPageDescription.text = "\(plant.data()["description"] as? String ?? "")"
            
            //如果種植日期是Timestamp 格式，才進行格式化
            if let timeStamp = plant.data()["update"] as? Timestamp {
               let date =  Date(timeIntervalSince1970: TimeInterval(timeStamp.seconds))
               let formatter = DateFormatter()
               formatter.dateStyle = .short
               formatter.timeStyle = .short
               self.toViewPageGrowdate.text = "種植日期： \(formatter.string(from: date))"
            
            //透過url取得照片顯示
            if let imgString: String = plant.data()["imgurl"] as? String {
//               if let url = URL(string: imgString) {
//                  let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//                      if let data = data {
//                          DispatchQueue.main.async {                                           self.toViewPageImage.image = UIImage(data: data)
//                          }
//
//                       }
//                  }
//                  task.resume()
//               }
                getImage(url: URL(string: imgString)) { (image) in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.toViewPageImage.image = image
                        }
                    }
                }
           }

                
        }else {
            print("plant not found")
        }
        

      }
  }

}


