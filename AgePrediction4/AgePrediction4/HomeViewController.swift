//
//  HomeViewController.swift
//  AgePrediction4
//
//  Created by Apurva Jain on 4/28/19.
//  Copyright © 2019 Apurva Jain. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    @IBAction func homeButton(_ sender: Any) {
        performSegue(withIdentifier: "showMain", sender: self)
        
        
    }
    
}
