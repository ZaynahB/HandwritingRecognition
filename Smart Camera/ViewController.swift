//
//  ViewController.swift
//  Smart Camera
//
//  Created by Zaynah Bhanji on 2018-01-23.
//  Copyright © 2018 Zaynah Bhanji. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var digitLabel: UILabel!
    @IBOutlet weak var canvasView: CanvasView!
    
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
    }
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else {fatalError("cannot load Vision ML model")}
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        
        self.requests = [classificationRequest]
        
    }
    
    func handleClassification(request:VNRequest, error:Error?) {
        guard let observations = request.results else {print("no results"); return}
        
        let classifications = observations
            .flatMap({$0 as? VNClassificationObservation})
            .filter({$0.confidence > 0.8})
            .map({$0.identifier})
        
        DispatchQueue.main.async {
            self.digitLabel.text = classifications.first
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        canvasView.clearCanvas()
    }
    
    @IBAction func recognize(_ sender: Any) {
        let image = UIImage(view: canvasView)
        let scaledImage = scaleImage(image: image, tosize: CGSize(width: 28, height: 28))
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])
        
        do {
            try imageRequestHandler.perform(self.requests)
        }catch{
            print(error)
        }
        
    }
    
    func scaleImage(image:UIImage, tosize size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

