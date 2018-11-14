//
//  LibraryViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/19/17.
//

import UIKit
import ProgressHUD

class LibraryViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    @IBOutlet weak var storyTableView: UITableView!
    var storyLibrary: Library?
    var spinnerView: UIView!
    
    var screenWidth:CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        screenWidth = CGFloat(self.view.bounds.size.width)
        pageController.hidesForSinglePage = true
        
        //Rounded Button & View
        storyTableView.dataSource = self
        storyTableView.delegate = self
        //Remove Cell separator
        storyTableView.separatorStyle = .none
        //Spinner View
        ProgressHUD.show("Loading...", interaction: false)
        loadLibrary()
    }
    
    func fetchCurrentUser(){
        Firebase.shared.observeCurrentUser(completion: { snapshot in
            if let dict = snapshot.value as? [String: Any]{
                if let imgUrl = dict["profileImage"]{
                    g_sProfileImgURL = imgUrl as! String
                }
            }
            ProgressHUD.dismiss()
        })
    }
    
    private func loadLibrary() {
        Library.loadLibrary { (library) in
            ProgressHUD.dismiss()
            self.storyLibrary = library
            self.storyTableView.reloadData()
            
            self.fetchCurrentUser()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == self.storyLibrary?.levels.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "commingCell")
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "storyTVCell") as! StoryTVCell
            cell.parent = self
            
            if let level = self.storyLibrary?.levels[indexPath.section] {
                cell.stories = level.stories
                cell.levelInt = level.level
            }
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let levels = self.storyLibrary?.levels {
            return levels.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let levels = self.storyLibrary?.levels {
            if levels.count == indexPath.section{
                return 48
            }
        }
        return 150
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let levels = self.storyLibrary?.levels{
            if section == levels.count { //More coming soon
                return ""
            }else{
                if let level = self.storyLibrary?.levels[section].level {
                    return "Level \(level)"
                } else {
                    return  "Level"
                }
            }
        }
        return ""
    }
    
}

extension LibraryViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPurchase", for: indexPath)
        let imgBack = cell.viewWithTag(100) as! UIImageView
        imgBack.layer.cornerRadius = 10
        let lblTitle = cell.viewWithTag(101) as! UILabel
        lblTitle.text = "Purchase Level " + String(indexPath.section+1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageController.currentPage = indexPath.section
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: screenWidth, height: 200)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///////
    }
}
