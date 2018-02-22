//
//  ViewController.swift
//  DrawingTool
//
//  Created by Rohit on 21/02/18.
//  Copyright © 2018 Rohit. All rights reserved.
//

import UIKit

class DrawingBoardVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: - @IBOutlet
    @IBOutlet weak var imgDrawingBoard: UIImageView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    // MARK: - Variable declaration
    /// set hex# colo
    var colorCollection = [String]()
    /// set selected color
    var colors: String = String()
    /// tempImage
    var tempImageView = UIImageView()
    /// set last point
    var lastPoint = CGPoint.zero
    /// set swiped or not
    var swiped: Bool = false
    /// for open gallary
    var imagePicker =  UIImagePickerController()
    /// set if image is selecte in gallary
    var isImageSelect: Bool = false
    /// set selected image in galllary
    var takeImage = UIImage()
    /// set color value
    var colorValue = Int()
    
    // MARK: - View life cycel
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        colorCollection = ["", "0000FF", "00FFFF", "FF0000", "FFFF00", "A52A2A", "008000", "FFA500", "800080", "FF00FF", "A9A9A9", "000000", "ffffff", "d3d3d3", "808080"]
        tempImageView.frame = imgDrawingBoard.frame
        self.view.addSubview(tempImageView)
    }
    
    // MARK: - @IBAction
    /// Take photo in gallary
    @IBAction func btnTakePhoteAction(_ sender: UIButton) {
        openGallary()
    }
    /// Reset drawing
    @IBAction func btnResetAction(_ sender: Any) {
        if isImageSelect == true {
            if tempImageView.image != nil {
                let alert = UIAlertController(title: "Reset", message: "Reset both image and drawing Or only drawing.", preferredStyle: .alert)
                let bothAction = UIAlertAction(title: "Both", style: .default, handler: { (UIAlertAction) in
                    self.imgDrawingBoard.image = nil
                    self.tempImageView.image = nil
                    self.isImageSelect = false
                })
                let drawAcrion = UIAlertAction(title: "Drawing", style: .default, handler: {(UIAlertAction) in
                    self.tempImageView.image = nil
                })
                alert.addAction(bothAction)
                alert.addAction(drawAcrion)
                present(alert, animated: true, completion: nil)
            } else {
                imgDrawingBoard.image = nil
                self.isImageSelect = false
            }
        } else {
            tempImageView.image = nil
            imgDrawingBoard.image = nil
        }
    }
    /// Save image in gallary
    @IBAction func btnSaveAction(_ sender: Any) {
        if tempImageView.image == nil {
            let alert = UIAlertController(title: "Alert", message: "First draw something on image after save image.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Save", style: .default, handler: { (UIAlertActon) in
                UIGraphicsBeginImageContext(self.imgDrawingBoard.frame.size)
                self.imgDrawingBoard.image?.draw(in: CGRect(x: 0, y: 0, width: self.imgDrawingBoard.frame.size.width, height: self.imgDrawingBoard.frame.size.height), blendMode: .normal, alpha: 1.0)
                self.tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.imgDrawingBoard.frame.size.width, height: self.imgDrawingBoard.frame.size.height), blendMode: .normal, alpha: 1.0)
                self.imgDrawingBoard.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.tempImageView.image = nil
                if self.isImageSelect != true {
                    if let image = self.imgDrawingBoard.image {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                    self.imgDrawingBoard.image = nil
                } else {
                    if let image = self.imgDrawingBoard.image {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                    self.imgDrawingBoard.image = self.takeImage
                }
            })
            ac.addAction(okAction)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(ac, animated: true)
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    //MARK: - Open gallary for select photos
    /// Open gallary
    func openGallary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: { () -> Void in
            self.isImageSelect = true
            self.imgDrawingBoard.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            if let image = self.imgDrawingBoard.image {
                self.takeImage = image
            }
        })
    }
    
    
    // MARK: - Touch events
    /// set start point
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.imgDrawingBoard)
        }
    }
    /// draw on moving area
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: imgDrawingBoard)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    /// set end points
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }
    
    // MARK: - Draw on image
    /// Draw Colour Line on image
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(imgDrawingBoard.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: imgDrawingBoard.frame.size.width, height: imgDrawingBoard.frame.size.height))
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        context?.setLineCap(.round)
        context?.setLineWidth(10.0)
        if colorValue == 0 {
            context?.setStrokeColor(UIColor(hex: colors).cgColor)
            context?.setBlendMode(.normal)
        } else {
            context?.setBlendMode(.clear)
        }
        context?.strokePath()
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = 1.0
        UIGraphicsEndImageContext()
    }
}

// MARK: - Class Extensions
/// CollectionView Delegate method
extension DrawingBoardVC: UICollectionViewDelegate {
    ///
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            colorValue = 1
        } else {
            colors = colorCollection[indexPath.item]
            colorValue = 0
        }
    }
}
/// CollectionView DataSource method
extension DrawingBoardVC: UICollectionViewDataSource {
    ///
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    ///
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorCollection.count
    }
    ///
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ColorCollectionVC else {
            fatalError("error in cell")
        }
        if indexPath.item == 0 {
            cell.colorView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "eraser"))
        } else {
            cell.colorView.backgroundColor = UIColor(hex: colorCollection[indexPath.item ])
        }
        return cell
    }
}
/// convert hex# color in UIColor
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
