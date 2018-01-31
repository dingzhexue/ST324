//
//  CompleteViewController.swift
//  StoryTime
//
//  Created by Lucky on 31/01/2018.
//

import UIKit

class CompleteViewController: UIViewController {
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgSpeedBefore: UIImageView!
    @IBOutlet weak var imgSpeedNow: UIImageView!
    @IBOutlet weak var imgAccBefore: UIImageView!
    @IBOutlet weak var imgAccNow: UIImageView!
    
    var story: Library.Level.Story?
    var levelStr = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblTitle.text = story?.name
        lblLevel.text = "Level \(levelStr)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
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
