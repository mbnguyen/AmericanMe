//
//  LearnViewController.swift
//  American Me
//
//  Created by Minh Nguyen on 9/27/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import UIKit

class LearnViewController: UIViewController {
    
    private var textToSpeech = TextToSpeechManager()
    
    @IBOutlet weak var answerCardView: AnswerCardView!
    @IBOutlet weak var cardView: AnswerCardView!
    
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var answerTableView: UITableView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionNumberLabel: UILabel!
    
    @IBOutlet var answerCardTopClosed: NSLayoutConstraint!
    @IBOutlet var answerCardTopOpened: NSLayoutConstraint!
    
    @IBOutlet var questionViewTop: NSLayoutConstraint!
    @IBOutlet var speakerButtonViewTop: NSLayoutConstraint!
    
    
    @IBOutlet weak var speakerButton: RoundButton!
    @IBOutlet weak var answerCardButton: AnswerButton!
    @IBOutlet weak var backButton: BackButton!
    @IBOutlet weak var nextButton: NextButton!
    @IBOutlet weak var learnButton: AllButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up delegate and dataSource for answerTableView
        answerTableView.delegate = self
        answerTableView.dataSource = self
        
        // Make the data ready
        let localStorageManager = LocalStorageManager()
        localStorageManager.delegate = self
        localStorageManager.downloadQuestionDataIfNeeded()
        // LocalStorageManager.loadGeneralData()
        
        // UI Build
        backButton.configButton()
        nextButton.configButton()
        learnButton.configButton()
        speakerButton.configButton()
        answerCardView.configCard()
        cardView.configCard()
        
        updateUI()
        closeAnswer()
    }
    
    @IBAction func questionReadButtonTapped(_ sender: Any) {
        
        if questionLabel.text != nil {
            textToSpeech.speak(string: questionLabel.text!)
        }
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: Identifier.segueGoToHome, sender: self)
        LocalStorageManager.saveGeneralDataLocally()
    }
    
    @IBAction func answerCardButtonTapped(_ sender: Any) {
        if answerCardView.openAnswerCard {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.closeAnswer()
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.openAnswer()
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if QuestionData.currentIndex + 1 < QuestionData.questions.count {
            QuestionData.currentIndex += 1
            flipCard(flipTo: .next)
            LocalStorageManager.saveGeneralDataLocally()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if QuestionData.currentIndex - 1 >= 0 {
            QuestionData.currentIndex -= 1
            flipCard(flipTo: .back)
            LocalStorageManager.saveGeneralDataLocally()
        }
    }
    
    @IBAction func learnButtonTapped(_ sender: Any) {
        if ProgressManager.isLearned(indexQuestion: QuestionData.currentIndex) {
            ProgressManager.updateQuestion(indexQuestion: QuestionData.currentIndex, questionType: .unlearned)
            updateUI()
        } else {
            ProgressManager.updateQuestion(indexQuestion: QuestionData.currentIndex, questionType: .learned)
            updateUI()
        }
    }
    
}

// MARK: UI Builder

extension LearnViewController {
    
    func closeAnswer() {
        
        self.answerCardView.openAnswerCard = false
        self.answerCardTopClosed.isActive = true
        self.answerCardTopOpened.isActive = false
        self.questionViewTop.constant = 150
        self.speakerButtonViewTop.constant = 50
        self.answerCardButton.setImage(UIImage(named: Identifier.imageArrowUp), for: .normal)
        self.answerTableView.alpha = 0
    }
    
    func openAnswer() {
        
        self.answerCardView.openAnswerCard = true
        self.answerCardTopClosed.isActive = false
        self.answerCardTopOpened.isActive = true
        self.questionViewTop.constant = 55
        self.speakerButtonViewTop.constant = 15
        self.answerCardButton.rotateButton()
        self.answerTableView.alpha = 1
    }
    
    func displayQuestion() {
        
        // Check if there are questions and check that the currentQuestionIndex is not out of bound
        guard QuestionData.getQuestionCount() > 0 && QuestionData.currentIndex < QuestionData.getQuestionCount() else {
            return
        }
        
        // Display Question number
        self.questionNumberLabel.text = "Question \(QuestionData.currentIndex + 1) / \(QuestionData.getQuestionCount())"
        
        // Display Tick Image
        if ProgressManager.isLearned(indexQuestion: QuestionData.currentIndex) {
            UIView.transition(with: tickImageView, duration: GeneralData.flipSpeed, options: .curveEaseOut, animations: {
                self.tickImageView.alpha = 1
            }, completion: nil)
            
            learnButton.setTitle(GeneralData.unlearnText, for: .normal)
        } else {
            UIView.transition(with: tickImageView, duration: GeneralData.flipSpeed, options: .curveEaseOut, animations: {
                self.tickImageView.alpha = 0
            }, completion: nil)
            learnButton.setTitle(GeneralData.learnText, for: .normal)
        }
        
        // Display the question text
        DispatchQueue.main.async {
            if GeneralData.useImages == false {
                self.questionLabel.text = QuestionData.getQuestion(currentIndexQuestion: QuestionData.currentIndex)
            } else {
                self.questionLabel.attributedText = QuestionData.getTextWithImage(text: QuestionData.getQuestion(currentIndexQuestion: QuestionData.currentIndex)!, sender: self)
            }
        }
    }
    
    func updateUI() {
        
        displayQuestion()
        
        // Reload the answer table
        answerTableView.reloadData()
    }
    enum flipType {
        case next, back
    }
    func flipCard(flipTo: flipType) {
        switch flipTo {
        case .next:
            UIView.transition(with: self.cardView, duration: GeneralData.flipSpeed, options: [.showHideTransitionViews, .transitionFlipFromRight], animations: nil, completion: nil)
            updateUI()
            closeAnswer()
        case .back:
            UIView.transition(with: self.cardView, duration: GeneralData.flipSpeed, options: [.showHideTransitionViews, .transitionFlipFromLeft], animations: nil, completion: nil)
            //UIView.transition(from: self.cardView, to: self.cardView, duration: GeneralData.flipSpeed, options: [.showHideTransitionViews, .transitionFlipFromLeft], completion: nil)
            updateUI()
            closeAnswer()
        }
    }
}

// MARK: TableView Delegate Methods

extension LearnViewController: UITableViewDelegate, UITableViewDataSource, AnswerTableViewCellDelegate {
    
    func speakerButtonTapped(text: String?) {
        if text != nil {
            textToSpeech.speak(string: text!)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Make sure that the questions array actually contains at least 1 question
        guard QuestionData.getQuestionCount() > 0 else {
            return 0
        }
        
        // Return the number of answers to that question
        return QuestionData.getAnswersCount(currentIndexQuestion: QuestionData.currentIndex)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.answerTableViewCell, for: indexPath) as! AnswerTableViewCell
        
        
        
        // Customize it
        let label = cell.answerLabel
        //view.layoutIfNeeded()
        
        if label != nil {
            
            if GeneralData.useImages == false {
                if let answer =  QuestionData.getAnswer(currentIndexQuestion: QuestionData.currentIndex, indexAnswer: indexPath.row) {
                    label!.text = answer
                }
            } else {
                if let answer =  QuestionData.getTextWithImage(text: QuestionData.getAnswer(currentIndexQuestion: QuestionData.currentIndex, indexAnswer: indexPath.row), sender: self) {
                    label!.attributedText = answer
                }
            }
        }
        
        cell.delegate = self
        
        // Return a cell
        return cell
    }
}

extension LearnViewController: LocalStorageManagerProtocol {
    
    func dataRetrieved() {
        updateUI()
    }
}
