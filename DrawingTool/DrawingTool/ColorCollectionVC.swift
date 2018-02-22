//
//  ColorCollectionVC.swift
//  DrawingTool
//
//  Created by Rohit on 22/02/18.
//  Copyright © 2018 Rohit. All rights reserved.
//

import UIKit

class ColorCollectionVC: UICollectionViewCell {
    /// IBOutlet
    @IBOutlet weak var colorView: UIView!
    ///
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    ///
    override func layoutSubviews() {
        super.layoutSubviews()
        // MARK: - set cell view cornerRadius and border
        colorView.layer.cornerRadius = colorView.frame.width / 2
        colorView.clipsToBounds = true
        colorView.layer.borderWidth = 1.0
        colorView.layer.borderColor = UIColor.white.cgColor
    }
    // MARK: - set cell view animation
    /// set animation on selected cell
    override var isSelected: Bool {
        didSet {
            if isSelected {
                let previouTransform =  colorView.transform
                UIView.animate(withDuration: 0.2, animations: {
                    self.colorView.transform = self.colorView.transform.scaledBy(x: 1.3, y: 1.3)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self.colorView.transform  = previouTransform
                    }
                })
            }
        }
    }
}
