//
//  HelpPageViewController.swift
//  
//
//  Created by 123 on 1/19/18.
//

import UIKit
import SMPageControl
class HelpPageViewController: UIPageViewController {

    var pageControl = SMPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "Help1ViewController"),
            self.getViewController(withIdentifier: "Help2ViewController"),
            self.getViewController(withIdentifier: "Help3ViewController"),
            self.getViewController(withIdentifier: "Help4ViewController"),
            self.getViewController(withIdentifier: "Help5ViewController"),
            self.getViewController(withIdentifier: "HomeViewController")
        ]
    }()
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        if let firstVC = pages.first
        {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        configurePageControl()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        self.pageControl.numberOfPages = 5
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorImage = UIImage(named: "greyCircle")
        self.pageControl.currentPageIndicatorImage = UIImage(named: "blueCircle")
        
        // self.pageControl.sizeToFit()
        self.view.addSubview(pageControl)
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
extension HelpPageViewController: UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        if nextIndex ==  pages.count {
            self.pageControl.isHidden = true
            pageViewController.dataSource = nil
        }
        guard pages.count > nextIndex else { return nil }
        return pages[nextIndex]
    }
}
extension HelpPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = pages.index(of: pageContentViewController)!
    }
}


















