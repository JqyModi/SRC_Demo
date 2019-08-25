//
//  PagerViewController.swift
//  ScreenRecDemo
//
//  Created by Modi on 2019/8/17.
//  Copyright © 2019年 modi. All rights reserved.
//

import UIKit
//import FSPagerView

private struct Constant {
    static let pageIdentifier = "SOHumaiPageCollectionViewCell"
}

class PagerViewController: UIViewController {

    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            //            self.pagerView.register(SOHumaiPageCollectionViewCell.self, forCellWithReuseIdentifier: Constant.pageIdentifier)
            self.pagerView.register(UINib(nibName: Constant.pageIdentifier, bundle: nil), forCellWithReuseIdentifier: Constant.pageIdentifier)
            
            self.pagerView.itemSize = CGSize(width: 100, height: 30)
            self.pagerView.interitemSpacing = 20
            
            // 设置轮播
            self.pagerView.isInfinite = true
            self.pagerView.transformer = FSPagerViewTransformer(type: .ferrisWheel)
            //            let transform = CGAffineTransform(scaleX: 0.6, y: 0.75)
            //            self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
            self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            
            //            self.pagerView.transformer = FSPagerViewTransformer(type: .cubic)
            //            let transform1 = CGAffineTransform(scaleX: 0.9, y: 0.9)
            //            self.pagerView.itemSize = self.pagerView.frame.size.applying(transform1)
            //            self.pagerView.decelerationDistance = 1
        }
    }
    
    var pageModels = [SOChordModel]() {
        didSet {
            pagerView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPagerView()
    }
    
    func setupPagerView() {
        self.pageModels = SOChordModel.getChords()
    }

}
// MARK: - PageBanner
extension PagerViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return pageModels.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell: SOHumaiPageCollectionViewCell = pagerView.dequeueReusableCell(withReuseIdentifier: Constant.pageIdentifier, at: index) as! SOHumaiPageCollectionViewCell
        //        cell.updateCell(model: Constant.pageModels[index%Constant.pageModels.count])
        cell.updateCell(model: pageModels[index])
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didHighlightItemAt index: Int) {
        NSLog(#function)
    }
    
    func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: FSPagerViewCell, forItemAt index: Int) {
        NSLog(#function)
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
}
