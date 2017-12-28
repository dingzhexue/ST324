//
//  LibraryViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/19/17.
//

import UIKit

class LibraryViewController: BaseViewController {

    
    @IBOutlet weak var btnBuyAllLibrary: UIButton!
    @IBOutlet weak var storyTableView: UITableView!
    var storyLibrary: Library?
    var spinnerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Rounded Button & View
        btnBuyAllLibrary.layer.cornerRadius = 20
        btnBuyAllLibrary.layer.borderWidth = 2
        //Spinner View
        spinnerView = UIViewController.displaySpinner(onView: self.view)
        loadLibrary()
        
    }
    
    private func loadLibrary() {
        Library.loadLibrary { (library) in
            UIViewController.removeSpinner(spinner: self.spinnerView)
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

extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let level = self.storyLibrary?.levels[section].level {
             return "Level \(level)"
        }
        return ""
    }
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}









