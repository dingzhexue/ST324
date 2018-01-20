//
//  SettingsViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/21/17.
//

import UIKit

class SettingsViewController: BaseViewController {

    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnStatistics: UIButton!
    @IBOutlet weak var btnMusic: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Rounded Button
        btnStatistics.layer.cornerRadius = 10
        btnHelp.layer.cornerRadius = 10
        btnMusic.layer.cornerRadius = 10
        btnStatistics.layer.borderWidth = 2
        btnHelp.layer.borderWidth = 2
        btnMusic.layer.borderWidth = 2
        imageUser.layer.cornerRadius = imageUser.frame.width / 2
        imageUser.layer.borderWidth = 2
        //Do any additional setup after loading the view.
        
        //Get User Photo and DisplayName From GameCenter
        if let currentPlayer = GameCenter().currentPlayer {
            currentPlayer.loadPhoto(for: .normal, withCompletionHandler: {(image, error) in
                if image != nil && error != nil {
                    self.imageUser.image = image
                }
                
            })
            if let displayName = currentPlayer.displayName {
                lblUserName.text? = displayName
            }
        }        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnStatisticsClicked(_ sender: Any) {
        
    }
    @IBAction func btnMusicClicked(_ sender: Any) {
        
    }
    @IBAction func btnHelpClicked(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let HelpPageViewController = storyboard.instantiateViewController(withIdentifier: "HelpPageViewController") as! HelpPageViewController
        navigationController?.pushViewController(HelpPageViewController, animated: true)
        
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        let preView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        preView.isHeroEnabled = true
        preView.heroModalAnimationType = .fade//.zoomSlide(direction: HeroDefaultAnimationType.Direction.down)
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
