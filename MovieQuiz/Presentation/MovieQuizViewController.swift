import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
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
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        
        tryReloadData()
        activityIndicator.hidesWhenStopped = true
        
        makeCornersToImageView()
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
        hideLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
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
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        toggleButtons(state: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.toggleButtons(state: true)
            
            guard self.isLastQuestion else {
                self.showNextQuestion()
                return
            }
            self.showResults()
        }
    }
    
    private func showNextQuestion() {
        currentQuestionIndex += 1
        questionFactory?.requestNextQuestion()
        showLoadingIndicator()
    }
    
    private func showResults() {
        guard let statisticService = statisticService else { return }
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let resultModel = QuizResultViewModel(
            title: "Этот раунд окончен!",
            text:
            """
                Ваш результат \(correctAnswers)/10
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
            """,
            buttonText: "Сыграть еще раз"
        )
        alertPresenter?.requestPresentAlert(resultModel) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func verifyCorrectness(statement: Bool) {
        let isCorrect = currentQuestion?.correctAnswer == statement
        if isCorrect { correctAnswers += 1 }
        showAnswerResults(isCorrect: isCorrect)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        
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
    
    private func makeCornersToImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let errorModel = QuizResultViewModel(
            title: "Ошибка загрузки",
            text: message,
            buttonText: "Попробовать еще раз")
        alertPresenter?.requestPresentAlert(errorModel) { [weak self] _ in
            guard let self = self else { return }
            self.tryReloadData()
        }
    }
    
    private func tryReloadData() {
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}
