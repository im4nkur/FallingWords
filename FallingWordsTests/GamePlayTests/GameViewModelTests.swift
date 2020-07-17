//
//  FallingWordsTests.swift
//  FallingWordsTests
//
//  Created by Ankur Arya on 17/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import XCTest
import RxSwift

@testable import FallingWords

class GameViewModelTests: XCTestCase {
    var gameViewModel: GameViewModel!
    var disposeBag: DisposeBag!
    var mockRepo: WordsMockRepo!

    lazy var word: Word = {
         return Word(english: "holidays", spanish: "vacaciones")
    }()

    override func setUpWithError() throws {
        let mockRepo = WordsMockRepo()
        gameViewModel = GameViewModel(repo: mockRepo)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        gameViewModel = nil
    }

    func testGetRandomWord() {
        let exp = expectation(description: "Get word")
        getRequiredData()
        gameViewModel.currentWord
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (word) in
                exp.fulfill()
                XCTAssertNotNil(word)
            }).disposed(by: disposeBag)

        waitForExpectations(timeout: 1) { (error) in
            if error != nil {
                XCTFail("Did not fulfill expectations")
            }
        }
    }

    private func getRequiredData() {
        gameViewModel.fetchAllWords()
        gameViewModel.getRandomWord()
    }

    func testCorrectAnswerIncreaasesScoreByOnePoint() {
        gameViewModel.currentWord.accept(word)
        gameViewModel.currentOption.accept(word)
        var currentScore = gameViewModel.quizResult.value.score
        gameViewModel.checkAnswer(true)
        currentScore += 1
        XCTAssertEqual(currentScore, gameViewModel.quizResult.value.score)
    }

    func testWrongAnswerDecreasesLivesByOnePoint() {
        gameViewModel.currentWord.accept(word)
        gameViewModel.currentOption.accept(word)
        var livesRemaining = gameViewModel.quizResult.value.lives
        gameViewModel.checkAnswer(false)
        livesRemaining -= 1
        XCTAssertEqual(livesRemaining, gameViewModel.quizResult.value.lives)
    }

    func testGameOver() {
        gameViewModel.handleTimeOut()
        gameViewModel.handleTimeOut()
        gameViewModel.handleTimeOut()
        let remainingLives = gameViewModel.quizResult.value.lives
        let expectedLives = 3 // As we are resetting the lives and scrore to default values on game over.
        let score = gameViewModel.quizResult.value.score
        let expactedScore = 0
        XCTAssertEqual(expactedScore, score)
        XCTAssertEqual(expectedLives, remainingLives)

    }
}
