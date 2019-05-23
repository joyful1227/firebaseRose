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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        //print("viewDidLoad")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        //print("viewWillAppear")
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = view.center
        
        activityIndicatorView.startAnimating()
        
        let firestore = Firestore.firestore()//建立儲藏庫實體
        firestore.collection("plants").order(by: "update", descending: true).getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                
                self.plants = querySnapshot.documents
                print(self.plants)
                DispatchQueue.main.async {
                    
                    self.myCollectionView.reloadData()
                    self.activityIndicatorView.removeFromSuperview()
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
            if let url = URL(string: imgString) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data {
                        DispatchQueue.main.async {
                            if let currentIndexPath = collectionView.indexPath(for: cell),currentIndexPath == indexPath {
                                cell.collectViewImage.image = UIImage(data: data)
                            }
                            
                        }
                    }
                }
                task.resume()
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
            controller.planttext = plants[(indexPath?.row)!].data()["name"] as? String
            //controller.test = plants[(indexPath?.row)!]
        }else{
            print("segue fail")
        }
    }
    

}

