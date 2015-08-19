//
//  LiveMatchInterfaceController.swift
//  KeepScore
//
//  Created by Jeff Kempista on 8/18/15.
//  Copyright © 2015 Jeff Kempista. All rights reserved.
//

import WatchKit
import Foundation


class LiveMatchInterfaceController: WKInterfaceController {

    @IBOutlet var homeTeamLabel: WKInterfaceLabel!
    @IBOutlet var awayTeamLabel: WKInterfaceLabel!
    @IBOutlet var homeButton: WKInterfaceButton!
    @IBOutlet var awayButton: WKInterfaceButton!
    
    var homeScore = 0 {
        didSet {
            homeButton.setTitle("\(homeScore)")
        }
    }
    var awayScore = 0 {
        didSet {
            awayButton.setTitle("\(awayScore)")
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let workoutSession = context as? WorkoutSessionContext, let homeTeamName = workoutSession.homeTeam, let awayTeamName = workoutSession.awayTeam {
            
            self.setTitle("")
            
            self.homeTeamLabel.setText(homeTeamName)
            self.awayTeamLabel.setText(awayTeamName)
            
            homeScore = 0
            awayScore = 0
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func homeButtonTapped() {
        WKInterfaceDevice.currentDevice().playHaptic(.Success)
        homeScore++
    }

    @IBAction func awayButtonTapped() {
        WKInterfaceDevice.currentDevice().playHaptic(.Success)
        awayScore++
    }
}
