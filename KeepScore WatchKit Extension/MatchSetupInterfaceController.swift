//
//  MatchSetupInterfaceController.swift
//  KeepScore WatchKit Extension
//
//  Created by Jeff Kempista on 8/17/15.
//  Copyright © 2015 Jeff Kempista. All rights reserved.
//

import WatchKit
import Foundation

class MatchSetupInterfaceController: WKInterfaceController {

    let teams: [WKPickerItem] = [WKPickerItem(title: "Home"), WKPickerItem(title: "Away"), WKPickerItem(title: "Shirts"), WKPickerItem(title: "Skins"), WKPickerItem(title: "LIV"), WKPickerItem(title: "MUN")]
    
    @IBOutlet var homeTeamPicker: WKInterfacePicker!
    @IBOutlet var awayTeamPicker: WKInterfacePicker!
    
    var workoutSession: WorkoutSessionContext!
    var selectedHomeTeam: String?
    var selectedAwayTeam: String?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let workoutSession = context as? WorkoutSessionContext {
            self.workoutSession = workoutSession
            self.setTitle(workoutSession.activityType.getTitle())
        }
        
        self.homeTeamPicker.setItems(teams)
        self.awayTeamPicker.setItems(teams)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func homeTeamSelected(value: Int) {
        self.selectedHomeTeam = teams[value].title
    }
    
    @IBAction func awayTeamSelected(value: Int) {
        self.selectedAwayTeam = teams[value].title
    }
    
    @IBAction func startButtonTapped() {
        WKInterfaceDevice.currentDevice().playHaptic(.Start)
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        self.workoutSession.homeTeam = self.selectedHomeTeam
        self.workoutSession.awayTeam = self.selectedAwayTeam
        
        return self.workoutSession
    }
    
}
