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
    
    var plants = [QueryDocumentSnapshot]()
    var planttext: String?
    //var plantt: [String: Any]
    //var test: QueryDocumentSnapshot
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let planttext = planttext {
        let firestore = Firestore.firestore()//建立儲藏庫實體
        firestore.collection("plants").order(by: "update", descending: true).getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                
                self.plants = querySnapshot.documents
                print(self.plants)
                for plant in self.plants {
                    if plant.data()["name"] as! String == planttext {
                        
                        self.toViewPageCategory.text = "種類： \(plant.data()["category"] as? String ?? "")"
                        self.toViewPageName.text = "名稱： \(plant.data()["name"] as? String ?? "")"
                        self.toViewPageDescription.text = "\(plant.data()["description"] as? String ?? "")"
                        //self.toViewPageGrowdate.text = "種植日期： \(String(describing: plant.data()["update"] as? Date))"
                        //print("種類： \(plant.data()["category"] as? String ?? "")")
                        //print("名稱： \(plant.data()["name"] as? String ?? "")")
                        
                        
                        if let timeStamp = plant.data()["update"] as? Timestamp {
                            
                            let date =  Date(timeIntervalSince1970: TimeInterval(timeStamp.seconds))
                            let formatter = DateFormatter()
                            formatter.dateStyle = .short
                            formatter.timeStyle = .short
                            self.toViewPageGrowdate.text = "種植日期： \(formatter.string(from: date))"
                        }
                        
                        if let imgString: String = plant.data()["imgurl"] as? String {
                            if let url = URL(string: imgString) {
                                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                                    if let data = data {
                                        DispatchQueue.main.async {
                                            self.toViewPageImage.image = UIImage(data: data)
                                            }
                                        
                                        }
                                    }
                                task.resume()
                                }
                            
                            }
                        }
                        
                        //break
                       
                        
                    }
                }

            }
          }
        }
        

    



}
