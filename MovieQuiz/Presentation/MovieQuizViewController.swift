import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var alertPresenter: AlertPresenter?
    private var questionFactory: QuestionFactoryProtocol?
    private let questionsAmount = 10
    private var currentQuestion: QuizQuestion?
    
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    
    private var isLastQuestion: Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
        let fileManager = FileManager.default
        var documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let textFile = "top250MoviesIMDB.json"
        documentUrl.appendPathComponent(textFile)
        
        let jsonString = try! String(contentsOf: documentUrl)
        let data = jsonString.data(using: .utf8)!
        
        do {
            let movies = try JSONDecoder().decode(Top.self, from: data)
        } catch {
            print("failed to parse: \(error)")
        }
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        verifyCorrectness(statement: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        verifyCorrectness(statement: true)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        prepareView(question: question)
    }
    
    // MARK: - AlertPresenterDelegate
    func didRecieveAlert(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func prepareView(question: QuizQuestion) {
        currentQuestion = question
        let viewModel = convert(model: question)
        imageView.layer.borderWidth = 0
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func showAnswerResults(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        toggleButtons(state: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.toggleButtons(state: true)
            if !self.isLastQuestion {
                self.showNextQuestion()
                return
            }
            self.showResults()
        }
    }
    
    private func showNextQuestion() {
        currentQuestionIndex += 1
        questionFactory?.requestNextQuestion()
    }
    
    private func showResults() {
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: "Ваш результат \(correctAnswers)/10",
            buttonText: "Сыграть еще раз",
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.requestPresentAlert(alertModel)
        correctAnswers = 0
    }
    
    private func verifyCorrectness(statement: Bool) {
        let isCorrect = currentQuestion?.correctAnswer == statement
        if isCorrect { correctAnswers += 1 }
        showAnswerResults(isCorrect: isCorrect)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage()
        
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func toggleButtons(state: Bool) {
        noButton.isEnabled = state
        yesButton.isEnabled = state
        
        UIView.animate(withDuration: 0.5, delay: 0.0, animations: {
            self.noButton.backgroundColor = state ? .white : .lightGray
            self.yesButton.backgroundColor = state ? .white : .lightGray
        }, completion: nil)
    }
}
