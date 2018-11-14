//
//  HomeViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/19/17.
//

import UIKit
class HomeViewController: BaseViewController {

    
    @IBOutlet weak var btnSettings: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: g_sKeyReadTutorial)
        {
            performSegue(withIdentifier: "segueHelp", sender: nil)
        }
    }
    @IBAction func onHelp(_ sender: Any) {
        performSegue(withIdentifier: "segueHelp", sender: nil)
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
