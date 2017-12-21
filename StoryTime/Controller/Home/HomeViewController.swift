//
//  HomeViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/19/17.
//

import UIKit

class HomeViewController: BaseViewController {

    
    @IBOutlet weak var btnLibrary: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Circle Button.
        btnLibrary.layer.cornerRadius = btnLibrary.frame.width / 2
        btnLibrary.clipsToBounds = true
        //        btnLibrary.layer.borderColor = UIColor(red:255.0/255.0, green:0.0, blue:0.0, alpha: 1.0).cgColor
        //        btnLibrary.layer.borderWidth = 1        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func btnLibraryClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "ToShowLibrarySegue", sender: self)
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
