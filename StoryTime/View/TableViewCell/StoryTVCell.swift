//
//  StoryTVCell.swift
//  
//
//  Created by 123 on 12/20/17.
//

import UIKit

class StoryTVCell: UITableViewCell {

    @IBOutlet weak var storyCollectionView: UICollectionView!
    var tableSection: Int = 0
    var parent : UIViewController = UIViewController()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    
}
// MARK: UICollectionView
extension StoryTVCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath) as! StoryCVCell
        cell.viewStory.layer.cornerRadius = 10
        cell.viewStory.layer.borderWidth = 1
        print("section is for \(indexPath.row)", tableSection)
        cell.lblStory.text? = "story\(tableSection) \(indexPath.row + 1)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(" selected section is for \(indexPath.row + 1)", tableSection)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        parent.navigationController?.pushViewController(nextViewController, animated: true)
    }
}










