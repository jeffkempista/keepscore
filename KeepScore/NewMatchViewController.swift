import UIKit
import KeepScoreKit

class NewMatchViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var selectedActivityLabel: UILabel!
    @IBOutlet weak var activityTypePicker: UIPickerView!
    @IBOutlet weak var homeTeamNameTextField: UITextField!
    @IBOutlet weak var awayTeamNameTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    let viewModel = NewMatchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneBarButton.enabled = false
        
        homeTeamNameTextField.delegate = self
        awayTeamNameTextField.delegate = self
        
        // Listen for changes in text field text to update the person name label
        homeTeamNameTextField.addTarget(self, action: "textFieldTextChanged:", forControlEvents: .EditingChanged)
        awayTeamNameTextField.addTarget(self, action: "textFieldTextChanged:", forControlEvents: .EditingChanged)
        
        activityTypePicker.dataSource = self
        activityTypePicker.delegate = self
        
        selectedActivityLabel.text = viewModel.selectedActivityLabelText
        activityTypePicker.selectRow(viewModel.selectedActivityIndex, inComponent: 0, animated: false)
    }
    
    func textFieldTextChanged(textField: UITextField) {
        if (textField == homeTeamNameTextField) {
            viewModel.homeTeamName = textField.text!
        } else if (textField == awayTeamNameTextField) {
            viewModel.awayTeamName = textField.text!
        }
        doneBarButton.enabled = viewModel.startButtonEnabled
    }
    
    // MARK: Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    // MARK: Scroll View Delegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(false)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let isPickerVisible = viewModel.activityPickerVisible
        switch indexPath.row {
        case 0:
            if (!isPickerVisible) {
                showActivityPicker()
            } else {
                hideActivityPicker()
            }
            homeTeamNameTextField.userInteractionEnabled = false
            awayTeamNameTextField.userInteractionEnabled = false
        case 2, 3:
            if (isPickerVisible) {
                hideActivityPicker()
            }
            homeTeamNameTextField.userInteractionEnabled = true
            awayTeamNameTextField.userInteractionEnabled = true
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        switch indexPath.row {
        case 1:
            return viewModel.activityPickerVisible ? 216.0 : 0
        default:
            return 44
        }
    }
    
    func showActivityPicker() {
        viewModel.activityPickerVisible = true
        tableView.beginUpdates()
        tableView.endUpdates()
        activityTypePicker.hidden = false
        activityTypePicker.alpha = 0.0
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.activityTypePicker.alpha = 1.0
        }
    }
    
    func hideActivityPicker() {
        viewModel.activityPickerVisible = false
        tableView.beginUpdates()
        tableView.endUpdates()
        activityTypePicker.hidden = true
        activityTypePicker.alpha = 1.0
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.activityTypePicker.alpha = 0.0
        }
    }
    
    // MARK: Picker View Data Source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.supportedActivities.count
    }
    
    // MARK: Picker View Delegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedActivityIndex = row
        selectedActivityLabel.text = viewModel.selectedActivityLabelText
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.supportedActivities[row].getTitle()
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        let match = viewModel.startMatch()
        performSegueWithIdentifier("MatchCreatedSegue", sender: match)
    }
    
}
