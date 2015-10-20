//
//  MatchTests.swift
//  KeepScore
//
//  Created by Jeff Kempista on 9/14/15.
//  Copyright © 2015 Jeff Kempista. All rights reserved.
//

import XCTest
@testable import KeepScoreKit

class MatchTests: XCTestCase {
    
    var sut = Match(activityType: .Soccer, homeTeamName: "Home", awayTeamName: "Away")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIncrementingHomeTeamScoreIncrementsScore() {
        sut.incrementHomeTeamScore()
        
        XCTAssertEqual(1, sut.homeTeamScore)
        XCTAssertEqual(0, sut.awayTeamScore)
        
        sut.incrementHomeTeamScore()
        
        XCTAssertEqual(2, sut.homeTeamScore)
        XCTAssertEqual(0, sut.awayTeamScore)
    }
    
    func testIncrementAwayTeamScoreIncrementsScore() {
        sut.incrementAwayTeamScore()
        
        XCTAssertEqual(0, sut.homeTeamScore)
        XCTAssertEqual(1, sut.awayTeamScore)
        
        sut.incrementAwayTeamScore()
        
        XCTAssertEqual(0, sut.homeTeamScore)
        XCTAssertEqual(2, sut.awayTeamScore)
    }
    
    func testIncrementBothHomeTeamAndAwayTeamsScoresIncrementsBothScores() {
        sut.incrementAwayTeamScore()
        XCTAssertEqual(0, sut.homeTeamScore)
        XCTAssertEqual(1, sut.awayTeamScore)
        
        sut.incrementHomeTeamScore()
        
        XCTAssertEqual(1, sut.homeTeamScore)
        XCTAssertEqual(1, sut.awayTeamScore)
    }
    
    func testRevertLastScoreBeforeAnyScoresDoesNotRevert() {
        sut.revertLastScore()
        
        XCTAssertEqual(0, sut.homeTeamScore)
        XCTAssertEqual(0, sut.awayTeamScore)
    }
    
    func testRevertLastScoreAfterOneScoreRevertsTheScore() {
        sut.incrementHomeTeamScore()
        
        XCTAssertEqual(1, sut.homeTeamScore)
        XCTAssertEqual(0, sut.awayTeamScore)
        
        sut.revertLastScore()
        
        XCTAssertEqual(0, sut.homeTeamScore)
        XCTAssertEqual(0, sut.awayTeamScore)
    }
    
    func testRevertTwiceAfterTwoScoresRevertsToZero() {
        sut.incrementHomeTeamScore()
        sut.incrementAwayTeamScore()
        
        XCTAssertEqual(1, sut.homeTeamScore)
        XCTAssertEqual(1, sut.awayTeamScore)
        
        sut.revertLastScore()
        
        XCTAssertEqual(1, sut.homeTeamScore)
        XCTAssertEqual(0, sut.awayTeamScore)
        
        sut.revertLastScore()
        
        XCTAssertEqual(0, sut.homeTeamScore)
        XCTAssertEqual(0, sut.awayTeamScore)
    }
    
}
