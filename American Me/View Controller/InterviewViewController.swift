//
//  InterviewViewController.swift
//  American Me
//
//  Created by Minh Nguyen on 9/14/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import UIKit
import Speech

class InterviewViewController: UIViewController{
    
    // MARK: Properties

    private var speechManager = SpeechManager()
    private var textToSpeech = TextToSpeechManager()
    
    private var currentIndexQuestion = 0
    private var indexesQuestions = [Int]()
    private var index = 0
    
    private var userAnswers = [Int : NSAttributedString]()
    private var correctedQuestions = Set<Int>()
    
    private var timer: Timer?
    private var seconds: Int = GeneralData.maxTimeInSecond
    
    private var dialogController: DialogViewController?

    // Progress UI
    @IBOutlet weak var questionProgressView: CircularProgressBar!
    @IBOutlet weak var questionProgressLabel: UILabel!
    
    @IBOutlet weak var timeProgressView: CircularProgressBar!
    @IBOutlet weak var timeProgressLabel: UILabel!
    
    
    @IBOutlet weak var pointProgressView: CircularProgressBar!
    @IBOutlet weak var pointProgressLabel: UILabel!
    
    // UIView
    @IBOutlet weak var answerCardView: AnswerCardView!
    
    
    // Labels
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var answerTextView: UITextView!
    
    // Buttons
    @IBOutlet weak var readButton: RoundButton!
    
    @IBOutlet weak var speakButton: RoundButton!
    
    @IBOutlet weak var backButton: BackButton!
    
    @IBOutlet weak var nextButton: NextButton!
    
    
    // MARK: View Controller Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the record buttons until authorization has been granted.
        speakButton.isEnabled = false
        
        // Asynchronously make the authorization request.
        speechManager.delegate = self
        OperationQueue.main.addOperation {
            self.speechManager.requestAuth()
        }
        
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        speechManager.speechRecognizer.delegate = self
        
        // Make sure the data is available
        let localStorageManager = LocalStorageManager()
        localStorageManager.delegate = self
        localStorageManager.downloadQuestionDataIfNeeded()
        
        prepareTest()
        
        // UI Builder
        readButton.configButton()
        answerCardView.configCard()
        backButton.configButton()
        nextButton.configButton()
        speakButton.configButton()
        updateUI()
        
        // Initialize DialogController
        dialogController = storyboard?.instantiateViewController(identifier: Identifier.dialogController) as? DialogViewController
        dialogController?.modalPresentationStyle = .overCurrentContext
        dialogController?.delegate = self
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        
        performSegue(withIdentifier: Identifier.segueGoToHome, sender: self)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        textToSpeech.stop()
        stopRecognizer()
        if index - 1 >= 0 {
            
            index -= 1
            currentIndexQuestion = indexesQuestions[index]
            updateUI()
        }
        
        LocalStorageManager.saveGeneralDataLocally()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        textToSpeech.stop()
        stopRecognizer()
        if index + 1 < indexesQuestions.count {
            
            index += 1
            currentIndexQuestion = indexesQuestions[index]
            updateUI()
        } else if index + 1 == indexesQuestions.count {
            
            // This is the last question of the test
            // Show the DialogController
            if dialogController != nil {
                
                dialogController!.totalQuestion = indexesQuestions.count
                dialogController!.correctAnswer = correctedQuestions.count
                dialogController!.updateUI()
                present(dialogController!, animated: true, completion: nil)
            }
            
            // Saving the test result to ProgressManager
            saveTestResult()
        }
        
        LocalStorageManager.saveGeneralDataLocally()
    }
    
    
    @IBAction func speakButtonTapped(_ sender: Any) {
        
        textToSpeech.stop()
        if speechManager.isRunning() {
            stopRecognizer()
        } else {
            startRecognizer()
        }
    }
    
    @IBAction func readButtonTapped(_ sender: Any) {
        textToSpeech.speak(string: questionLabel.text!)
    }
    
    // MARK: UI Builder
    
    func updateUI() {
        DispatchQueue.main.async {
            if self.currentIndexQuestion >= 0 && self.currentIndexQuestion < QuestionData.getQuestionCount() {
                self.questionLabel.text = QuestionData.questions[self.currentIndexQuestion].question
            }
            
            if self.correctedQuestions.contains(self.currentIndexQuestion) {
                // If this question has been correctly answered
                self.answerTextView.attributedText = self.userAnswers[self.currentIndexQuestion]
            } else {
                // If this question has not been correctly answered
                self.answerTextView.text = GeneralData.waitingToStartRegconizer
                self.answerTextView.textColor = .white
            }
            
            self.textToSpeech.speak(string: self.questionLabel.text!)
            
            // Update image for next button
            if self.index == self.indexesQuestions.count - 1 {
                self.nextButton.setImage(UIImage(named: Identifier.imageDoneTick), for: .normal)
            } else {
                self.nextButton.configButton()
            }
        }
        
        updateQuestionProgress()
        updatePointProgress()
        updateUISpeakButton()
    }
    
    func updateUISpeakButton() {
        
        DispatchQueue.main.async {
            if self.speechManager.isRunning() == false {
                self.speakButton.setImage(UIImage(named: Identifier.microphoneImage), for:[])
            } else {
                self.speakButton.setImage(UIImage(named: Identifier.microphoneMutedImage), for:[])
            }
        }
        
    }
    
    func colorTheMatchedWords(ranges: [NSTextCheckingResult]) {
        
        let attributesWhite: [NSAttributedString.Key: Any] = [
            .foregroundColor: answerTextView.textColor!,
            .font: answerTextView.font!
        ]
        
        let attributesGreen: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.green,
            .font: answerTextView.font!
        ]
        
        let attributedString = NSMutableAttributedString()
        let string = NSMutableAttributedString(string: answerTextView.text)
        string.addAttributes(attributesWhite, range: NSRange(location: 0, length: answerTextView.text.utf16.count))
        for match in ranges {
            string.addAttributes(attributesGreen, range: match.range)
        }
        attributedString.append(string)
        
        if let answers = QuestionData.getAnswers(currentIndexQuestion: currentIndexQuestion) {
            attributedString.append(NSAttributedString(string: "\n\nCorrect answer:", attributes: attributesWhite))
            for answer in answers{
                attributedString.append(NSAttributedString(string: "\n- \(answer)", attributes: attributesWhite))
            }
        }
        
        answerTextView.attributedText = attributedString
        userAnswers[currentIndexQuestion] = attributedString
    }
    
    // Progress
    
    func updateQuestionProgress() {
        
        DispatchQueue.main.async {
            self.questionProgressLabel.text = "\(self.index + 1) / \(self.indexesQuestions.count)"
            self.questionProgressView.updateProgress(currentProgress: self.index + 1, maxProgress: self.indexesQuestions.count)
        }
    }
    
    func updatePointProgress() {
        
        DispatchQueue.main.async {
            self.pointProgressLabel.text = "\(self.correctedQuestions.count) / \(self.indexesQuestions.count)"
            self.pointProgressView.updateProgress(currentProgress: self.correctedQuestions.count, maxProgress: self.indexesQuestions.count)
        }
    }
    
    // MARK: Alert Section
    func alertView(message: String) {
        
        let controller = UIAlertController.init(title: "Error!", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            controller.dismiss(animated: true, completion: nil)
        }))
        self.present(controller, animated: true, completion: nil)
    }

}

// MARK: Speech Recognition Section
extension InterviewViewController: SFSpeechRecognizerDelegate {
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speakButton.isEnabled = true
            updateUISpeakButton()
        } else {
            speakButton.isEnabled = false
            alertView(message: "Recognition Not Available")
        }
    }
    
    func startRecognizer() {
        
        do {
            try speechManager.startRecording(currentIndexQuestion: currentIndexQuestion)
            // Let the user know to start talking.
            answerTextView.text = GeneralData.waitingForAnswer
            answerTextView.textColor = .white
            updateUISpeakButton()
        } catch {
            speakButton.isEnabled = false
            updateUISpeakButton()
        }
    }
    
    func stopRecognizer() {
        
        speechManager.stop()
        answerTextView.text = GeneralData.waitingToStartRegconizer
        updateUISpeakButton()
    }
}

// MARK: SpeechManager Delegate
extension InterviewViewController: SpeechManagerProtocol {
    
    func authStatsRetrieved(auth: AuthStats) {
        DispatchQueue.main.async {
            switch auth {
                case AuthStats.authorized:
                    self.speakButton.isEnabled = true
                    
                case AuthStats.denied:
                    self.speakButton.isEnabled = false
                    self.alertView(message: "User denied access to speech recognition")
                    
                case AuthStats.restricted:
                    self.speakButton.isEnabled = false
                    self.alertView(message: "Speech recognition restricted on this device")
                    
                case AuthStats.notDetermined:
                    self.speakButton.isEnabled = false
                    self.alertView(message: "Speech recognition not yet authorized")
                    
                default:
                    self.speakButton.isEnabled = false
            }
        }
    }
    
    func answerRetrieved(text: String?, questionIndex: Int) {
        if text != nil && currentIndexQuestion == questionIndex {
            answerTextView.text = text
        }
    }
    
    func correctedAnswerRetrieved(ranges: [NSTextCheckingResult], questionIndex: Int) {
        
        if questionIndex == currentIndexQuestion {
            correctedQuestions.insert(questionIndex)
            updatePointProgress()
            updateUISpeakButton()
            colorTheMatchedWords(ranges: ranges)
        }
    }
}

// MARK: LocalStorageManager Delegate
extension InterviewViewController: LocalStorageManagerProtocol{
    func dataRetrieved() {
        updateUI()
    }
}


// MARK: Timer
extension InterviewViewController {
    
    func initializeTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        displayTimer(totalSeconds: seconds)
    }
    
    @objc func timerFired() {
        
        // Decrement the counter
        seconds -= 1
        
        // Update the label
        displayTimer(totalSeconds: seconds)
        
        // Stop the timer if it reaches zero
        if seconds == 0 {
            timer?.invalidate()
            timeProgressLabel.textColor = UIColor.red
        }
    }
    
    func displayTimer(totalSeconds: Int) {
        let minute: Int = totalSeconds / 60
        let second: Int = totalSeconds - (minute * 60)
        timeProgressLabel.text = "\(minute):\(String(format: "%02d", second))"
        timeProgressView.updateProgress(currentProgress: totalSeconds, maxProgress: GeneralData.maxTimeInSecond)
    }
}

// MARK: Questions
extension InterviewViewController {
    
    func getQuestions() {
        
        if let randomQuetions = ProgressManager.getIndexesQuestionsRandom(numberOfQuestions: GeneralData.maxQuestionsAsk) {
            self.indexesQuestions = randomQuetions
        }
    }
}

// MARK: Test
extension InterviewViewController {
    
    func prepareTest() {
        
        currentIndexQuestion = 0
        indexesQuestions = [Int]()
        index = 0
        
        // Get the list of questions
        getQuestions()
        self.currentIndexQuestion = indexesQuestions[index]
        
        userAnswers = [Int : NSAttributedString]()
        correctedQuestions = Set<Int>()
        
        // Timer
        seconds = GeneralData.maxTimeInSecond
        initializeTimer()
    }
    
    func saveTestResult() {
        
        for questionIndex in indexesQuestions {
            
            if correctedQuestions.contains(questionIndex) {
                
                ProgressManager.updateQuestion(indexQuestion: questionIndex, questionType: .answerCorrect)
            } else {
                
                ProgressManager.updateQuestion(indexQuestion: questionIndex, questionType: .answerWrong)
            }
        }
    }
}

// MARK: Dialog Delegate Method
extension InterviewViewController: DialogViewControllerProtocol {
    
    func dialogDismissed() {
        
        speakButton.alpha = 0
        timer?.invalidate()
    }
    
    func newTest() {
        
        speakButton.alpha = 1
        prepareTest()
        updateUI()
    }
    
    func goHome() {
        
        performSegue(withIdentifier: Identifier.segueGoToHome, sender: self)
    }
}
