//
//  LibraryViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/19/17.
//

import UIKit

class LibraryViewController: BaseViewController {

    
    @IBOutlet weak var btnBuyAllLibrary: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Rounded Button & View
        btnBuyAllLibrary.layer.cornerRadius = 20
        btnBuyAllLibrary.layer.borderWidth = 2
        
        loadLibrary()
    }
    
    private func loadLibrary() {
        Library.loadLibrary { (library) in
            storyLibrary = library
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        let preView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        preView.isHeroEnabled = true
        preView.heroModalAnimationType = .pull(direction: .right)
        
        self.hero_replaceViewController(with: preView)
    }
}

extension LibraryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let stories = storyLibrary?.levels[section].stories {
            return stories.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as! StoryCVCell
        if let stories = storyLibrary?.levels[indexPath.section].stories {
            cell.lblStory.text? = "\(stories[indexPath.row].refId)"
        }
        cell.viewCell.layer.cornerRadius = 10
        cell.viewCell.layer.borderWidth = 2
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let levels = storyLibrary?.levels {
            return levels.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as! StoryCRView
        if let levels = storyLibrary?.levels {
            header.lblHeader.text? = "Level \(levels[indexPath.section].level)"
        }
        
        
        return header
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        levelIdx = indexPath.section
        storyIdx = indexPath.row
        
        let preView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        preView.isHeroEnabled = true
        preView.heroModalAnimationType = .push(direction: .left)
        
        self.hero_replaceViewController(with: preView)
    }
}











