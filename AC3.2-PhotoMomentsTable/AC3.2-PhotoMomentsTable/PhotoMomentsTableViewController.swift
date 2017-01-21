//
//  PhotoMomentsTableViewController.swift
//  AC3.2-PhotoMomentsTable
//
//  Created by Harichandan Singh on 1/21/17.
//  Copyright © 2017 Harichandan Singh. All rights reserved.
//

import UIKit
import Photos

class PhotoMomentsTableViewController: UITableViewController {
    //MARK: - Properties
    var collectionFetchResult: PHFetchResult<PHCollection>!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = PHFetchOptions()
//        let sort = NSSortDescriptor(key: "startDate", ascending: false)
//        options.sortDescriptors = [sort]
//        let cutoffDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 10 * -1)
//        let predicate = NSPredicate(format: "startDate > %@", cutoffDate)
//        options.predicate = predicate
        
        let momentsLists = PHCollectionList.fetchMomentLists(with: .momentListCluster, options: nil)
        for i in 0..<momentsLists.count {
            print("Title: ", momentsLists[i].localizedTitle ?? "no title")
            let moments = momentsLists[i]
            let collectionList = PHCollectionList.fetchCollections(in: moments, options:options)
            
            // for use in a table
            self.collectionFetchResult = collectionList
            print("collectionFetchResult count: \(self.collectionFetchResult.count)")
            
//            for j in 0..<collectionFetchResult.count {
//                if let collection = collectionList[j] as? PHAssetCollection {
//                    printAssetsInList(collection: collection)
//                }
//            }
        }
        print(collectionFetchResult.count)
    }
    
    func printAssetsInList(collection: PHAssetCollection) {
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        print("\n---\(assets.count)---\n")
        for j in 0..<assets.count {
            print(assets[j])
            if j > 10 {
                break
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.collectionFetchResult.count
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let collection = self.collectionFetchResult[section] as! PHAssetCollection
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        return assets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photosCell", for: indexPath)

        let manager = PHImageManager.default()
        
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        let collection = self.collectionFetchResult[indexPath.section] as! PHAssetCollection
        
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        let asset = assets[indexPath.row]
        
        if let creationDate = asset.creationDate {
            cell.textLabel?.text = DateFormatter.localizedString(from: creationDate,
                                                                         dateStyle: .medium,
                                                                         timeStyle: .medium
            )
        } else {
            cell.textLabel?.text = "Unknown date"
        }
        
        cell.tag = Int(manager.requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0),
                             contentMode: .aspectFill,
                             options: nil) { (image: UIImage?, _) in
                                
                                if let destinationCell = tableView.cellForRow(at: indexPath),
                                    let unwrappedImage = image {
                                    print("The loaded image: \(unwrappedImage)")
                                    destinationCell.imageView?.image = unwrappedImage
                                    
                                    DispatchQueue.main.async {
                                        cell.setNeedsLayout()
                                    }
                                }
        })
        
        return cell
    }

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
