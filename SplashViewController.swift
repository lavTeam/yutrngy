//
//  SplashViewController.swift
//  dmaker
//
//  Created by Aleksey Larichev on 31.05.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import UIKit
import FirebaseUI
class SplashViewController: UIViewController {

    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterButton.backgroundColor = #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)
        if (Auth.auth().currentUser != nil) {
            enterButton.isHidden = true
            performSegue(withIdentifier: "toMapScreen", sender: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
