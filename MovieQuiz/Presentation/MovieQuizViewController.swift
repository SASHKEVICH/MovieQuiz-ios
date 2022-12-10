import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        
        activityIndicator.hidesWhenStopped = true
        
        presenter = MovieQuizPresenter(viewController: self)
        tryReloadData()
        makeCornersToImageView()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
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
        presenter?.switchToNextQuestion()
        presenter?.requestNextQuestion()
        showLoadingIndicator()
    }
    
    func showResults() {
        guard let presenter = presenter else { return }
        
        let alertResultsText = presenter.makeResultsMessage()
        let resultModel = QuizResultViewModel(
            title: "Этот раунд окончен!",
            text: alertResultsText,
            buttonText: "Сыграть еще раз"
        )
        alertPresenter?.requestPresentAlert(resultModel) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.restartGame()
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
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let errorModel = QuizResultViewModel(
            title: "Ошибка загрузки",
            text: message,
            buttonText: "Попробовать еще раз")
        alertPresenter?.requestPresentAlert(errorModel) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.restartGame()
        }
    }
    
    private func tryReloadData() {
        showLoadingIndicator()
        presenter?.reloadData()
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
