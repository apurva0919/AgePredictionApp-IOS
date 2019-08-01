//
//  ViewController.swift
//  AgePrediction4
//
//  Created by Apurva Jain on 4/11/19.
//  Copyright © 2019 Apurva Jain. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var checkAge: UIButton!
    var image: UIImage!
    var finalImage: UIImage!
    var finalAge: String!
    var face:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let image = UIImage(named: "no-photo.png"){
            imageView.image = image
            checkAge.isEnabled = false
          //  checkAge.backgroundColor = UIColor.gray
        }
        imageView.isUserInteractionEnabled  = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTapped)))
        imageView.layer.borderWidth = 6
            imageView.layer.borderColor = UIColor.black.cgColor
        
    }
     @objc func imageTapped(){
        var alert:UIAlertController=UIAlertController(title: "Picture Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        var cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertAction.Style.default)
        {
            UIAlertAction in self.camera()
        }
        
        var galleryAction = UIAlertAction(title: "Select from Album", style: UIAlertAction.Style.default)
        {
            UIAlertAction in self.gallery()
            
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in self.cancel()
            
        }

        alert.addAction(galleryAction)
        
        alert.addAction(cameraAction)

        alert.addAction(cancelAction)

        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func cancel(){
        print("Cancel Clicked")
    }
    
    func gallery(){
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            let alert = UIAlertController(title: "No gallery available", message: "Please select correct option", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        

        
        
    }
    
    func camera(){
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(title: "No camera available", message: "This device does not support camera features.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        present(picker, animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        
        let scale = 640 / max(image.size.width, image.size.height)
        let newHeight = scale * image.size.height
        let newWidth = scale * image.size.width
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        image = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("not able to load image")
        }
        checkAge.isEnabled = true
        print(image.size)
    
        
        // Set the picked image to the UIImageView - imageView
       // imageView.image = resizeImage(image: image, newWidth: 64, newHeight: 64)
       // imageView.image = image
        let image1 = resizeImage(image: image)
        imageView.image = image1
        print(image1.size)
        
        guard let ciImage = CIImage(image: image1) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
      //  print(image.size)
        faceDetection()
        if face > 0 {
        ageDetection(image: ciImage)
        }
        else{
            finalImage = UIImage(named: "no-photo.png")
            finalAge = "No face detected"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showAge" {
            guard let ageViewController = segue.destination as? AgeViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            ageViewController.image = finalImage
            ageViewController.finalAge = finalAge
        }
        
    }
    
    
    func faceDetection(){
        
        var orientation:Int32 = 0
        
      
        switch image.imageOrientation {
        case .up:
            orientation = 1
        case .right:
            orientation = 6
        case .down:
            orientation = 3
        case .left:
            orientation = 8
        default:
            orientation = 1
        }
        
        // vision
        let faceRectangleRequest = VNDetectFaceRectanglesRequest(completionHandler: self.faceDetected)
        
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: CGImagePropertyOrientation(rawValue: CGImagePropertyOrientation.RawValue(orientation))! ,options: [:])
        do {
            try requestHandler.perform([faceRectangleRequest])
        } catch {
            print(error)
        }

    }
    
    @IBAction func faceDetect(_ sender: Any) {
        
        var orientation:Int32 = 0
        
        // detect image orientation, we need it to be accurate for the face detection to work
        switch image.imageOrientation {
        case .up:
            orientation = 1
        case .right:
            orientation = 6
        case .down:
            orientation = 3
        case .left:
            orientation = 8
        default:
            orientation = 1
        }
        
        // vision
        let faceRectangleRequest = VNDetectFaceRectanglesRequest(completionHandler: self.faceDetected)
       // print("mememe\(faceLandmarksRequest)")
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: CGImagePropertyOrientation(rawValue: CGImagePropertyOrientation.RawValue(orientation))! ,options: [:])
        do {
            try requestHandler.perform([faceRectangleRequest])
        } catch {
            print(error)
        }
        //imageView.image = finalImage
    }
    func faceDetected(request: VNRequest, errror: Error?) {
        request.results?.forEach({(result) in
            guard let observations =  result as? VNFaceObservation else {return}
            addFaceRectangleToImage(observations)
            
            
        })
        face = request.results?.count ?? 0
        
        
      /*  guard let observations = request.results as? [VNFaceObservation] else {
            fatalError("unexpected result type!")
        }
        
        for face in observations {
            addFaceRectangleToImage(face)
            print("hello \(face.description)")
        }*/
    }
    
    
    func resizeImage1(image: UIImage, newWidth:CGFloat, newHeight:CGFloat) -> UIImage {
        
      //  let scale = 640 / max(image.size.width, image.size.height)
        //let newHeight = scale * image.size.height
        //let newWidth = scale * image.size.width
        // let newHeight = //image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }

    func addFaceRectangleToImage(_ face: VNFaceObservation) {
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        print(image.description)
        
        // draw the image
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
       // let image2 = resizeImage1(image: image, newWidth: 64, newHeight: 64)
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("not able to convert UIImage to CIImage")
        }
      //  print(image2.size)
       

      //  ageDetection(image: ciImage)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        // draw the face rect
        let w = face.boundingBox.size.width * image.size.width
        let h = face.boundingBox.size.height * image.size.height
        let x = face.boundingBox.origin.x * image.size.width
        let y = face.boundingBox.origin.y * image.size.height
        let faceRect = CGRect(x: x - 35, y: y + 10, width: w + 70, height: h + 80)
        let image3 = ciImage.cropped(to:  CGRect(x: x - 35, y: y + 10, width: w + 70, height: h + 100))
      //  print(image3)
      //  ageDetection(image: image3)
        let image4 = convert(cmage: image3)
        
    
        context?.saveGState()
        context?.setStrokeColor(UIColor.darkGray.cgColor)
        context?.setLineWidth(8.0)
        context?.addRect(faceRect)
        context?.drawPath(using: .stroke)
        context?.restoreGState()
        
        
        
        // get the final image
       finalImage = UIGraphicsGetImageFromCurrentImageContext()
       // print(image4.size)
       let image5 = resizeImage1(image: image4, newWidth: 64, newHeight: 64)
        guard let ciImage2 = CIImage(image: image5) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        print(image5.size)
       // ageDetection(image: ciImage2)
        //finalImage = image5
        
        // end drawing context
       UIGraphicsEndImageContext()
        
      // imageView.image = finalImage
    }
    
    func ageDetection(image: CIImage) {
        
        if let model = try? VNCoreMLModel(for: age6().model) {
            let request = VNCoreMLRequest(model: model, completionHandler: { (corerequest, error) in
                 if let results = corerequest.results as? [VNClassificationObservation] {
                    let Result = results.first
                    DispatchQueue.main.async {
                        self.finalAge = "Your Age is \(Result?.identifier ?? "not available")"
                    }
                }
            })
           // print(request)
            let handler = VNImageRequestHandler(ciImage: image)
            print(handler)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Err :(")
                }
            }
        }
        
}


}
