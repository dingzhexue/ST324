//
//  PreviewViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/19/17.
//

import UIKit

class PreviewViewController: BaseViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imagePreStory: UIImageView!
    @IBOutlet weak var lblStoryName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var txtSummary: UITextView!
    @IBOutlet weak var txtKeyMetrics: UITextView!
    var levelIdx = 0
    var storyIdx = 0
    var storyLibrary: Library?
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePreStory.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        //Get All Datas
        if let  library = storyLibrary {
            Library.loadStoryScreenshot(library.levels[levelIdx].stories[storyIdx], { (image) in
                self.imagePreStory.image = image!
            })
            lblStoryName.text? = library.levels[levelIdx].stories[storyIdx].name
            lblLevel.text? = "Level \(library.levels[levelIdx].level)"
            txtSummary.text = library.levels[levelIdx].stories[storyIdx].summary
            txtKeyMetrics.text = library.levels[levelIdx].stories[storyIdx].keyMetrics
        }
        print(levelIdx, storyIdx)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnPreImageClickedToExperienceView(_ sender: Any) {
        let preView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExperienceViewController") as! ExperienceViewController
        preView.isHeroEnabled = true
        preView.heroModalAnimationType = .push(direction: .left)
        preView.story = self.storyLibrary?.levels[levelIdx].stories[storyIdx]
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
