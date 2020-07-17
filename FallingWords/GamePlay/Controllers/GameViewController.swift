//
//  ViewController.swift
//  FallingWords
//
//  Created by Ankur Arya on 17/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GameViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var remainingLivesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentWordLabel: UILabel!
    @IBOutlet weak var optionWordLabel: UILabel!
    @IBOutlet weak var wrongButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var optionWordTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var resultImage: UIImageView!

    // MARK: Properties
    var viewModel: GameViewModel!
    private let disposeBag = DisposeBag()
    private let timeDuration: Double = 10
    private let yOffset: CGFloat = 50
    private let animationKey = "OptionWordAnimation"
    private let yPositionKey = "position.y"
    private let gameOverSegueID = "ShowGameOverViewController"
    private var timer: Timer?

    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchAllWords()
    }

    // MARK: View Setup Methods
    private func setupButtons() {
        wrongButton.rx.tap.subscribe(onNext: { _ in
            self.viewModel.checkAnswer(false)
        }).disposed(by: disposeBag)

        rightButton.rx.tap.subscribe(onNext: { _ in
            self.viewModel.checkAnswer(true)
        }).disposed(by: disposeBag)

        playButton.rx.tap.subscribe(onNext: { _ in
            self.playingState(true)
        }).disposed(by: disposeBag)
    }

    // MARK: Animation
    private func animateOptionWord() {
        optionWordLabel.layer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: yPositionKey)
        animation.duration = timeDuration
        animation.fromValue = -yOffset
        animation.toValue = view.bounds.height + yOffset
        optionWordLabel.layer.add(animation, forKey: animationKey)
        startTimer()
    }

    // MARK: Timer
    private func startTimer() {
        DispatchQueue.global(qos: .background).async {
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(withTimeInterval: self.timeDuration, repeats: false, block: { _ in
                    self.viewModel.handleTimeOut()
                })
                RunLoop.current.run()
            }
        }
    }

    private func stopTimer() {
        DispatchQueue.global(qos: .background).async {
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }

    // MARK: Game result handling
    private func handleGameOver() {
        self.playingState(false)
        self.performSegue(withIdentifier: gameOverSegueID, sender: nil)
    }

    private func handleResult(_ result: QuizResult) {
        remainingLivesLabel.text = "LIVES: \(result.lives)"
        scoreLabel.text = "SCORE: \(result.score)"
        guard let isCorrect = result.isCorrect else { return }
        stopTimer()
        if result.lives == 0 {
            handleGameOver()
        } else {
            showResult(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showResult(false)
                self.viewModel.getRandomWord()
            }
            self.resultImage.image = isCorrect ? #imageLiteral(resourceName: "Right") : #imageLiteral(resourceName: "Wrong")
        }
    }

    private func showResult(_ showResult: Bool) {
        self.resultImage.isHidden = !showResult
        self.currentWordLabel.isHidden = showResult
        self.optionWordLabel.isHidden = showResult
        self.rightButton.isHidden = showResult
        self.wrongButton.isHidden = showResult
    }

    private func playingState(_ isPlaying: Bool) {
        self.currentWordLabel.isHidden = !isPlaying
        self.optionWordLabel.isHidden = !isPlaying
        self.playButton.isHidden = isPlaying
        self.rightButton.isHidden = !isPlaying
        self.wrongButton.isHidden = !isPlaying
        isPlaying ? self.viewModel.getRandomWord() : ()
    }

    // MARK: Viewmodel binding
    private func bindViewModel() {
        viewModel.currentWord
            .compactMap{ $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (word) in
                guard let self = self else { return }
                self.animateOptionWord()
                self.currentWordLabel.text = word.english
            }).disposed(by: disposeBag)

        viewModel.currentOption
            .compactMap{ $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (word) in
                guard let self = self else { return }
                self.optionWordLabel.text = word.spanish
            }).disposed(by: disposeBag)

        viewModel.quizResult
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (result) in
                guard let self = self else { return }
                self.handleResult(result)
            }).disposed(by: disposeBag)

        viewModel.error
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (error) in
                guard let self = self else { return }
                self.showAlert(forError: error)
            }).disposed(by: disposeBag)
    }

    //MARK: Error Alert
    private func showAlert(forError error: Error) {
        self.playButton.isEnabled = false
        let alert = UIAlertController(title: "Oops!!", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
