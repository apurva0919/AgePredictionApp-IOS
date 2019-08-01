//
//  AgeViewController.swift
//  AgePrediction4
//
//  Created by Apurva Jain on 4/21/19.
//  Copyright © 2019 Apurva Jain. All rights reserved.
//

import UIKit
import CoreML
import Vision
class AgeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    var image: UIImage!
    var finalAge: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        ageLabel.text = finalAge

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}
