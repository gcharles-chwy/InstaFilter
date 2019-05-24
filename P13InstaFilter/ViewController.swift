//
//  ViewController.swift
//  P13InstaFilter
//
//  Created by Encompass on 5/23/19.
//  Copyright © 2019 gthevirtuoso. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "YACIFP"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }

    @IBAction func changeFilter(_ sender: Any) {
            let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle:  .actionSheet)
            ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        guard imageView.image != nil else {return}
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved", message: "Your image has been saved to your photos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else
        {return}
        dismiss(animated: true)
        currentImage = image
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
            
            
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else {return}
        currentFilter = CIFilter(name: action.title!)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

}

