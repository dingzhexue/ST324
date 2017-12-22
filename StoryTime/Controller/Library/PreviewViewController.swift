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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePreStory.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        //Get All Datas
        if let  library = storyLibrary {
            imagePreStory.image = UIImage(named: library.levels[levelIdx].stories[storyIdx].screenshotName)!
            lblStoryName.text? = library.levels[levelIdx].stories[storyIdx].name
            lblLevel.text? = "Level \(library.levels[levelIdx].level)"
            txtSummary.text = library.levels[levelIdx].stories[storyIdx].summary
            txtKeyMetrics.text = library.levels[levelIdx].stories[storyIdx].keyMetrics
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
