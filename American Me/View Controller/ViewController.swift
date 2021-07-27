//
//  ViewController.swift
//  American Me
//
//  Created by Minh Nguyen on 9/14/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Properties
    
    
    @IBOutlet weak var learnButton: AllButton!
    @IBOutlet weak var interviewButton: AllButton!
    @IBOutlet weak var progressButton: AllButton!
    @IBOutlet weak var settingButton: AllButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Make the data ready
        let localStorageManager = LocalStorageManager()
        localStorageManager.delegate = self
        localStorageManager.downloadQuestionDataIfNeeded()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        learnButton.configButton()
        interviewButton.configButton()
        progressButton.configButton()
        settingButton.configButton()
    }
    
    @IBAction func interviewButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        _ = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
}

extension ViewController: LocalStorageManagerProtocol {
    
    func dataRetrieved() {
        print("OK")
    }
}

