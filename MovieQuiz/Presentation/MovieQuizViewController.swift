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
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        
        tryReloadData()
        activityIndicator.hidesWhenStopped = true
        
        presenter.viewController = self
        makeCornersToImageView()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        presenter.didRecieveNextQuestion(question: question)
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
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showNextQuestion() {
        presenter.switchToNextQuestion()
        questionFactory?.requestNextQuestion()
        showLoadingIndicator()
    }
    
    func showResults() {
        guard let statisticService = statisticService else { return }
        statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        
        let bestGame = statisticService.bestGame
        let resultModel = QuizResultViewModel(
            title: "Этот раунд окончен!",
            text:
            """
                Ваш результат \(presenter.correctAnswers)/10
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
            """,
            buttonText: "Сыграть еще раз"
        )
        alertPresenter?.requestPresentAlert(resultModel) { [weak self] _ in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.presenter.resetCorrectAnswers()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func toggleButtons(state: Bool) {
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
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func resetImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func showQuestionResultOnImageView(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
}
