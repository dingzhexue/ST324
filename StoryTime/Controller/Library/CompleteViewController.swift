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
//    @IBOutlet weak var imgSpeedBefore: UIImageView!
//    @IBOutlet weak var imgSpeedNow: UIImageView!
//    @IBOutlet weak var imgAccBefore: UIImageView!
//    @IBOutlet weak var imgAccNow: UIImageView!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblAccuracy: UILabel!
    
    var story: Library.Level.Story?
    var levelStr = 0
    var timeCnt = 0
    var wrongCnt = 0
    
    var wrongCntBefore = 0
    var timeCntBefore = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblTitle.text = story?.name
        lblLevel.text = "Level \(levelStr)"
        print("Time Spent: \(timeCnt) seconds, Wrong Count: \(wrongCnt)")
        
        print(Firebase.shared.currentUserId())
        
        Firebase.shared.observeResult(id: Firebase.shared.currentUserId(), level: levelStr, story: (story?.name)!, completion: { snapshot in
            if let dict = snapshot.value as? [String: Any]{
                self.wrongCntBefore = dict["wrongcount"] as! Int
                self.timeCntBefore = dict["time"] as! Int
                print("WrongCnt Before \(self.wrongCntBefore), Time Before \(self.timeCntBefore)")
//                self.modifyChart()
            }
            
            Firebase.shared.postResult(id: Firebase.shared.currentUserId(), level: self.levelStr, story: (self.story?.name)!, wrongCount: self.wrongCnt, time: self.timeCnt, onSuccess: {
                print("Post Success")
            })
        })
    }

//    func modifyChart(){
//        if wrongCnt > wrongCntBefore {
//            if wrongCntBefore == 0 {
//                imgAccBefore.isHidden = true
//            }else{
//                let percent = CGFloat(wrongCntBefore) / CGFloat(wrongCnt)
//                changeHeight(imgView:imgAccBefore, percent: percent)
//            }
//        } else {
//            if wrongCnt == 0 {
//                imgAccNow.isHidden = true
//            }else{
//                let percent = CGFloat(wrongCnt) / CGFloat(wrongCnt)
//                changeHeight(imgView:imgAccNow, percent: percent)
//            }
//        }
//
//        if timeCnt > timeCntBefore{
//            if timeCntBefore == 0 {
//                imgSpeedBefore.isHidden = true
//            } else {
//                let percent = CGFloat(timeCntBefore) / CGFloat(timeCnt)
//                changeHeight(imgView: imgSpeedBefore, percent: percent)
//            }
//        } else {
//            if timeCnt == 0 {
//                imgSpeedNow.isHidden = true
//            } else {
//                let percent = CGFloat(timeCnt) / CGFloat(timeCntBefore)
//                changeHeight(imgView: imgSpeedNow, percent: percent)
//            }
//        }
//    }
//    func changeHeight(imgView: UIImageView, percent: CGFloat){
//        let height = imgView.frame.size.height
//        let newHeight = height * percent
//
//        let orgRect = imgView.frame
//        let newRect = CGRect(origin: CGPoint(x: orgRect.origin.x, y: orgRect.origin.y + (height - newHeight)), size: CGSize(width: orgRect.size.width, height: newHeight))
//        imgView.frame = newRect
//    }
    
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
