//
//  SettingsViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/21/17.
//

import UIKit
import SDWebImage
import MBProgressHUD

class SettingsViewController: BaseViewController , UIImagePickerControllerDelegate,
UINavigationControllerDelegate{

    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnStatistics: UIButton!
    @IBOutlet weak var btnMusic: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    
    var picker:UIImagePickerController?=UIImagePickerController()
    
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
        imageUser.clipsToBounds = true
        
        //Do any additional setup after loading the view.
        
        //Get User Photo and DisplayName From GameCenter
        /*if let currentPlayer = GameCenter().currentPlayer {
            currentPlayer.loadPhoto(for: .normal, withCompletionHandler: {(image, error) in
                if image != nil && error != nil {
                    self.btnPhoto.image(for: .normal)
                }
                
            })
            if let displayName = currentPlayer.displayName {
                lblUserName.text? = displayName
            }
        }*/
        
        picker?.delegate = self
        fetchCurrentUser()
    }
    func fetchCurrentUser(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Firebase.shared.observeCurrentUser(completion: { snapshot in
            if let dict = snapshot.value as? [String: Any]{
                if let imgUrl = dict["profileImage"]{
                    self.imageUser.sd_setImage(with: URL(string: imgUrl as! String), completed: nil)
                }
            }
            MBProgressHUD.hide(for: self.view, animated:true)
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onPhoto(_ sender: Any) {
        openSheet()
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
    
    func openSheet(){
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            self.openCamera()
        }
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Photo Gallery", style: .default)
        { _ in
            self.openGallary()
        }
        actionSheetController.addAction(deleteActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func openGallary()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
            picker!.allowsEditing = true
            picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Photo Gallery Error", message: "Can't access to Photo Gallery", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    func openCamera()
    {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            picker!.allowsEditing = true
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        imageUser.image = chosenImage
        
        let imageData = UIImageJPEGRepresentation(chosenImage, 0.1)
        //imageView.contentMode = .ScaleAspectFit
        //imageView.image = chosenImage
        dismiss(animated: true, completion: {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            Firebase.shared.uploadImage(imageData: imageData!, onSuccess: {(imageURL) in
                Firebase.shared.saveUserProfile(imgUrl: imageURL, onSucess: {
                    MBProgressHUD.hide(for: self.view, animated:true)
                }, onError: { (error) in
                    MBProgressHUD.hide(for: self.view, animated:true)
                })
            }, onError: { (errorMessage) in
                MBProgressHUD.hide(for: self.view, animated:true)
            })
        })
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
