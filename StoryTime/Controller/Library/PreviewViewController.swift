//
//  PreviewViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/19/17.
//

import UIKit
import MBProgressHUD
class PreviewViewController: BaseViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imagePreStory: UIImageView!
    @IBOutlet weak var lblStoryName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var txtSummary: UITextView!
    @IBOutlet weak var txtKeyMetrics: UITextView!
    
    var story: Library.Level.Story?
    var levelStr = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        imagePreStory.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        //Get All Datas
        if let story = self.story  {
            Library.loadStoryScreenshot(story, { (image) in
                self.imagePreStory.image = image!
                MBProgressHUD.hide(for: self.view, animated: true)
            })
            lblStoryName.text? = story.name
            lblLevel.text? = "Level \(levelStr)"
            txtSummary.text = story.summary
            txtKeyMetrics.text = story.keyMetrics
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnPreImageClickedToExperienceView(_ sender: Any) {
        let preView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExperienceViewController") as! ExperienceViewController
        preView.isHeroEnabled = true
        preView.heroModalAnimationType = .push(direction: .left)
        preView.story = self.story
        preView.levelStr = self.levelStr
        self.hero_replaceViewController(with: preView)
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        let preView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LibraryViewController") as! LibraryViewController
        preView.isHeroEnabled = true
        preView.heroModalAnimationType = .pull(direction: .right)
       
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
