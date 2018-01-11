//
//  HomeViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/19/17.
//

import UIKit
import Hero
class HomeViewController: BaseViewController {

    
    @IBOutlet weak var btnLibrary: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Circle Button.
        btnLibrary.layer.cornerRadius = btnLibrary.frame.width / 2
        btnLibrary.clipsToBounds = true
        btnSettings.layer.cornerRadius = btnSettings.frame.width / 2
        btnSettings.clipsToBounds = true
        btnSettings.heroID = "skyWalker"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func btnLibraryClicked(_ sender: Any) {
        if let libraryViewController = storyboard?.instantiateViewController(withIdentifier: "LibraryViewController") as? LibraryViewController {
            navigationController?.pushViewController(libraryViewController, animated: true)
        }
    }
    @IBAction func btnSettingClicked(_ sender: Any) {
        let preView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        preView.isHeroEnabled = true
        preView.heroModalAnimationType = .fade
        
        self.hero_replaceViewController(with: preView)
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
