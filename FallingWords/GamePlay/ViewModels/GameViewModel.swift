//
//  GameViewModel.swift
//  FallingWords
//
//  Created by Ankur Arya on 17/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

struct QuizResult {
    var isCorrect: Bool? = nil
    var lives: Int = 3
    var score: Int = 0
}

class GameViewModel {

    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let repo: WordsRepo
    private var allWords = [Word]()
    let currentWord = BehaviorRelay<Word?>(value: nil)
    let currentOption = BehaviorRelay<Word?>(value: nil)
    let quizResult: BehaviorRelay<QuizResult>
    let error = PublishRelay<Error>()

    //MARK: Initialiser
    init(repo: WordsRepo) {
        self.repo = repo
        self.quizResult = .init(value: QuizResult())
    }

    func fetchAllWords() {
        repo.getAllWords().subscribe(onSuccess: { (words) in
            self.allWords = words
        }) { (error) in
            self.error.accept(error)
        }.disposed(by: disposeBag)
    }

    func getRandomWord() {
        precondition(!allWords.isEmpty, "There are no words available")
        let randomWord = allWords.randomElement()!
        currentWord.accept(randomWord)
        getRandomOption(forWord: randomWord)
    }

    /// Check if given answer is correct or not.
    /// - Parameter rightSelected: User's selection.
    func checkAnswer(_ rightSelected: Bool) {
        guard let word = currentWord.value,
            let option = currentOption.value
            else { return }
        let isCorrect = (word.english == option.english) == rightSelected
        updateResult(isCorrect: isCorrect)
    }

    func handleTimeOut() {
        updateResult(isCorrect: false)
    }

    // MARK: Private Methods

    /// Update result based on the correctness of user's selection.
    /// - Parameter isCorrect: Answer based on user's selection.
    private func updateResult(isCorrect: Bool) {
        let currentLives = isCorrect ? quizResult.value.lives : quizResult.value.lives - 1
        let score = isCorrect ? quizResult.value.score + 1: quizResult.value.score
        let result = QuizResult(isCorrect: isCorrect, lives: currentLives, score: score)
        quizResult.accept(result)
        currentLives == 0 ? resetGame() : ()
    }

    private func resetGame() {
        currentWord.accept(nil)
        currentOption.accept(nil)
        quizResult.accept(QuizResult())
    }

    /// Get random word to display as an option on screen.
    /// - Parameter current: Current word displayed on screen.
    ///  It will be added to the array so that when random word
    ///  is choosen it will have good probablity.
    private func getRandomOption(forWord current: Word) {
        precondition(!allWords.isEmpty, "There are no words available")
        let noOfItems =  allWords.count <= 5 ? 1 : 3
        var randomOptions = Array(allWords.shuffled().prefix(noOfItems))
        randomOptions.append(current)
        let option = randomOptions.randomElement()
        currentOption.accept(option)
    }
}
