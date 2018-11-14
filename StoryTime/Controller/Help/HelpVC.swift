//
//  HelpVC.swift
//  StoryTime
//
//  Created by Lucky on 2018/11/14.
//

import UIKit
import SwiftyOnboard

class HelpVC: UIViewController {
    @IBOutlet weak var swiftyOnboard: SwiftyOnboard!
    let pageCnt = 5
    var isFirstLoad = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        swiftyOnboard.style = .light
        swiftyOnboard.delegate = self
        swiftyOnboard.dataSource = self
        //        swiftyOnboard.backgroundColor = UIColor(red: 46/256, green: 46/256, blue: 76/256, alpha: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleSkip() {
        swiftyOnboard?.goToPage(index: pageCnt-1, animated: true)
    }
    
    @objc func handleNext(sender: UIButton) {
        let index = sender.tag
        if index == pageCnt-1{ //Done
            UserDefaults.standard.set(true, forKey: g_sKeyReadTutorial)
            self.dismiss(animated: true, completion: nil)
        }else{ //Next
            swiftyOnboard?.goToPage(index: index + 1, animated: true)
        }
    }
    
    @objc func handlePrev(sender: UIButton) {
        let index = sender.tag
        if index > 0{
            swiftyOnboard?.goToPage(index: index - 1, animated: true)
        }
    }
}

extension HelpVC: SwiftyOnboardDelegate, SwiftyOnboardDataSource {
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return pageCnt
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let view = CustomPage.instanceFromNib() as! CustomPage
        view.image.image = UIImage(named: "help\(index+1)")
        let sDescription = [
            "Read simple stories across\nmultiple reading levels",
            "All stories can be found\nin the library",
            "As you read aloud\nthe animation progresses",
            "Your performance is graded\nbased on accuracy & speed",
            "Have fun &\nkeep reading!"]
        view.subTitleLabel.text = sDescription[index]
        return view
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = CustomOverlay.instanceFromNib() as? CustomOverlay
        overlay?.skip.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        overlay?.btnNext.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        overlay?.btnPrev.addTarget(self, action: #selector(handlePrev), for: .touchUpInside)
        return overlay
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let overlay = overlay as! CustomOverlay
        let currentPage = round(position)
        overlay.contentControl.currentPage = Int(currentPage)
        overlay.btnNext.tag = Int(position)
        overlay.btnPrev.tag = Int(position)
        
        if currentPage == 0.0 {
            overlay.btnPrev.isHidden = true
            overlay.skip.isHidden = false
        }else if currentPage == 4.0{
            overlay.btnPrev.isHidden = false
            overlay.skip.isHidden = true
        }else{
            overlay.btnPrev.isHidden = false
            overlay.skip.isHidden = false
        }
    }
}
