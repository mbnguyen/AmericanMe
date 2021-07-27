//
//  DialogViewController.swift
//  American Me
//
//  Created by Minh Nguyen on 10/24/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import UIKit

protocol DialogViewControllerProtocol {
    func dialogDismissed()
    func newTest()
    func goHome()
}

class DialogViewController: UIViewController {
    
    var totalQuestion = 0
    var correctAnswer = 0
    
    var delegate: DialogViewControllerProtocol?

    @IBOutlet weak var titileLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var cardView: AllCardView!
    @IBOutlet weak var reviewTestButton: AllButton!
    @IBOutlet weak var newTestButton: AllButton!
    @IBOutlet weak var goHomeButton: AllButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cardView.configCard()
        
        reviewTestButton.configButton()
        newTestButton.configButton()
        goHomeButton.configButton()
        
        updateUI()
    }
    
    func updateUI() {
        
        var percent = Double(correctAnswer) / Double(totalQuestion) * 100
        
        DispatchQueue.main.async {
            
            if percent >= 60 {
                
                self.titileLabel.text = GeneralData.passedTitle
            } else {
                
                self.titileLabel.text = GeneralData.failedTitle
            }
            self.contentLabel.text = "You correctly answered \(self.correctAnswer) out of \(self.totalQuestion) questions."
        }
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        
        // Dismiss the Dialog
        dismiss(animated: true, completion: nil)
        
        // Notify delegate
        delegate?.dialogDismissed()
    }
    
    @IBAction func newTestButtonTapped(_ sender: Any) {
        
        // Dismiss the Dialog
        dismiss(animated: true, completion: nil)
        
        // Notify delegate
        delegate?.newTest()
    }
    
    @IBAction func goHomeButtonTapped(_ sender: Any) {
        
        // Dismiss the Dialog
        dismiss(animated: true, completion: nil)
        
        // Notify delegate
        delegate?.goHome()
    }
    

}
