//
//  SOHumaiPageCollectionViewCell.swift
//  SnapOke
//
//  Created by Modi on 2019/7/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
//import FSPagerView

class SOHumaiPageCollectionViewCell: FSPagerViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var titleBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = self.bounds.height/2
        self.layer.masksToBounds = true
        
        titleBtn.isUserInteractionEnabled = false
    }

    func updateCell(model: SOChordModel) {
        self.backgroundColor = UIColor.clear
        titleBtn.backgroundColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 0.5)
        let title = model.data_categoryCn
        let image = model.data_imageName
        self.image.image = UIImage(named: image)
        self.title.text = title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
