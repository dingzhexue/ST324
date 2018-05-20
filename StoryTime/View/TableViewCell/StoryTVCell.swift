//
//  StoryTVCell.swift
//  
//
//  Created by 123 on 12/20/17.
//

import UIKit
import Hero
class StoryTVCell: UITableViewCell {

    @IBOutlet weak var storyCollectionView: UICollectionView!
    
    var parent: LibraryViewController? //Parent ViewController
    var stories: [Library.Level.Story] = []
    var levelInt = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        storyCollectionView.delegate = self
        storyCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    
}
// MARK: UICollectionView
extension StoryTVCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storyCVCell", for: indexPath) as! StoryCVCell
        //Rounded Button
        cell.viewStory.layer.cornerRadius = 10
        cell.viewStory.layer.borderWidth = 1
        if stories.count != 0 {
            cell.lblStory.text? = stories[indexPath.row].refId.capitalized
            cell.imgStory.sd_setImage(with: URL(string: stories[indexPath.row].iconURL), completed: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let previewViewController = parent?.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController {
            previewViewController.story = stories[indexPath.row]
            previewViewController.levelStr = self.levelInt
            self.parent?.navigationController?.pushViewController(previewViewController, animated: true)
        }
    }
}










