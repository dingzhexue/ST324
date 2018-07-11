//
//  PreviewViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/19/17.
//

import UIKit
import ProgressHUD

class PreviewViewController: BaseViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imagePreStory: UIImageView!
    @IBOutlet weak var lblStoryName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var lblKeyMetrics: UILabel!
    
    var story: Library.Level.Story?
    var levelStr = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //ProgressHUD.show("Loading...", interaction: false)
        imagePreStory.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        //Get All Datas
        if let story = self.story  {
            /*Library.loadStoryScreenshot(story, { (image) in
                if image != nil{
                    self.imagePreStory.image = image
                }
                ProgressHUD.dismiss()
            })*/
            imagePreStory.sd_setImage(with: URL(string: story.previewURL), completed:nil)
            lblStoryName.text? = story.name
            lblLevel.text? = "Level \(levelStr)"
            lblSummary.text = story.summary
            lblKeyMetrics.text = story.keyMetrics
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnPreImageClickedToExperienceView(_ sender: Any) {
        if let experienceViewController = storyboard?.instantiateViewController(withIdentifier: "ExperienceViewController") as? ExperienceViewController {
            experienceViewController.story = self.story
            experienceViewController.levelStr = self.levelStr
            navigationController?.pushViewController(experienceViewController, animated: true)
        }
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
