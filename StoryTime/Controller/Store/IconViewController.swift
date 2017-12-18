//
//  IconViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/15/17.
//

import UIKit

class IconViewController: BaseViewController {

    @IBOutlet weak var iconCollectionView: UICollectionView!
    
    var icons: [Icon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadIcons()
    }
    
    func loadIcons() {
        Icon.loadIcons { (icons) in
            self.icons = icons
            self.iconCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: UICollectionView
extension IconViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding:CGFloat = 30
        let width = (collectionView.bounds.size.width - padding * 3) / 2
        
        return CGSize.init(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as! IconCell
        
        let icon = icons[indexPath.row]
        cell.activityIndicator.startAnimating()
        Icon.loadIconImage(icon.refId + ".png") { (image) in
            cell.iconImageView.image = image
            cell.activityIndicator.stopAnimating()
        }
        
        return cell
    }
}
