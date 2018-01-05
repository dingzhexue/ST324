//
//  LibraryViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/19/17.
//

import UIKit
import ExpyTableView
import MBProgressHUD
class LibraryViewController: BaseViewController {
    
    
    @IBOutlet weak var btnBuyAllLibrary: UIButton!
    @IBOutlet weak var storyTableView: ExpyTableView!
    var storyLibrary: Library?
    var spinnerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Rounded Button & View
        btnBuyAllLibrary.layer.cornerRadius = 20
        btnBuyAllLibrary.layer.borderWidth = 2
        storyTableView.dataSource = self
        storyTableView.delegate = self
        //Remove Cell separator
        storyTableView.separatorStyle = .none
        //Spinner View
        MBProgressHUD.showAdded(to: self.view, animated: true)
        loadLibrary()
        
    }
    
    private func loadLibrary() {
        Library.loadLibrary { (library) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.storyLibrary = library
            self.storyTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        let preView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        preView.isHeroEnabled = true
        preView.heroModalAnimationType = .pull(direction: .right)
        self.hero_replaceViewController(with: preView)
    }
}

extension LibraryViewController: ExpyTableViewDelegate, ExpyTableViewDataSource {
    
    
    func expandableCell(forSection section: Int, inTableView tableView: ExpyTableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as! HeaderTableViewCell
        //Make your customizations here.
        if let level = self.storyLibrary?.levels[section].level {
            cell.lblHeader.text = "Level \(level)"
        } else {
            cell.lblHeader.text = "Level"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "storyTVCell") as! StoryTVCell
        cell.parent = self
        
        if let level = self.storyLibrary?.levels[indexPath.section] {
            cell.stories = level.stories
            cell.levelInt = level.level
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let levels = self.storyLibrary?.levels {
            return levels.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 35.0
        }else {
            return 150
        }
        
    }
    
    
}










