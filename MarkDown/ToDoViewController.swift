//
//  ViewController.swift
//  MarkDown
//
//  Created by iPHTech 15 on 06/11/23.
//

import UIKit
class ToDoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var textFieldHolderArray = [UITextField]()
    var identifier = false
    var selectedCellList  = [IndexPath]()
    var items = [String]()
    let userDefaults = UserDefaults()
    var counter = 0
    var sampleTextField: UITextField?
    var str = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        sampleTextField?.delegate = self
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        //Set up of initial saving method
        if !UserDefaults().bool(forKey: "setup") {
            UserDefaults().set(true, forKey: "setup")
            UserDefaults().set(0, forKey: "count")
        }
        //added to save text in user default in the upcoming cells.
        let countReceived = UserDefaults().value(forKey: "count") as? Int
        if countReceived! > 0 {
            counter = countReceived!
        }
        updateTask()
    }
    
    @IBAction func addItemButton(_ sender: UIButton) {
        createCustomTextField(textReceived: nil)
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func createCustomTextField(textReceived: String?) {
        sampleTextField =  UITextField(frame: CGRect(x: 60, y: 12, width: 300, height: 40))
        sampleTextField?.text = textReceived
        sampleTextField?.placeholder = "Enter text here"
        sampleTextField?.font = UIFont.systemFont(ofSize: 15)
        sampleTextField?.borderStyle = UITextField.BorderStyle.none
        sampleTextField?.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField?.keyboardType = UIKeyboardType.default
        sampleTextField?.returnKeyType = UIReturnKeyType.done
        sampleTextField?.clearButtonMode = UITextField.ViewMode.whileEditing
        sampleTextField?.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textFieldHolderArray.append(sampleTextField!)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        //extract current inset of tableview
        var contentInset = tableView.contentInset
        //the bottom inset is adjusted to match the height of the keyboard
        contentInset.bottom = keyboardHeight
        //These lines update the content inset and scroll indicator inset of the table view
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // Reset the content inset and scroll indicator inset of the table view when the keyboard hides
        
        //Creates an UIEdgeInsets object with zero insets, meaning no extra space is added around the content of the table view.
        let contentInset = UIEdgeInsets.zero
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    
    deinit {
        // Remove observer when view controller is deallocated to prevent memory leaks
        NotificationCenter.default.removeObserver(self)
    }

    
    func updateTask() {
        items.removeAll()
        textFieldHolderArray.removeAll()
        guard let count = UserDefaults().value(forKey: "count") as? Int else {
            return
        }
        print("count ==== \(count)")
        let end = count
        for x in 0...end {
            print("x === \(x)")
            if let task = UserDefaults().value(forKey: "task_\(x)") as? String {
                print("task received == \(task) at x = \(x)")
                items.append(task)
                createCustomTextField(textReceived: task)
            }
        }
        tableView.reloadData()
    }
}

extension ToDoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textFieldHolderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.delegate = self
        sampleTextField?.delegate = self
        
        // Check if the cell already contains a text field, and remove it if necessary
        cell.contentView.subviews.forEach { subview in
            if subview is UITextField {
                subview.removeFromSuperview()
            }
        }
        cell.contentView.addSubview(textFieldHolderArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("you tapped in section \(indexPath.section) at row \(indexPath.row)")
        let textEntered = textFieldHolderArray[indexPath.row].text
        print("\(String(describing: textEntered))")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("value at index indexPath.row ==== \(textFieldHolderArray[indexPath.row].text)")
            let index = indexPath.row + 1
            print("index ==== \(index)")
            // Remove the corresponding data from UserDefaults and adjust the count
            let countRows = UserDefaults().value(forKey: "count") as? Int ?? 0
            print("countR == \(countRows)")
            if index <= countRows {
                //loop shifts the data in UserDefaults one position up
                for i in index..<countRows {
                    if let text = UserDefaults().value(forKey: "task_\(i + 1)") as? String {
                        UserDefaults().set(text, forKey: "task_\(i)")
                    }
                }
                //since last value has now been moved up one position so delete the last value from UserDefaults as its just duplicate
                UserDefaults().removeObject(forKey: "task_\(countRows)")
                let changeCount = countRows - 1
                UserDefaults().set(changeCount, forKey: "count")
            }
            // Remove the item from the array
            textFieldHolderArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
        tableView.reloadData()
    }
    
    func saveEntryToUserDefault(indexReceived: Int) {
        if let text = textFieldHolderArray[indexReceived].text, !text.isEmpty {
            print(text)
            items.append(text)
            guard let count = UserDefaults().value(forKey: "count") as? Int else {
                return
            }
            let newCount = count + 1
            UserDefaults().set(newCount, forKey: "count")
            //will save each item to a unique key
            UserDefaults().set(text, forKey: "task_\(newCount)")
        }
    }
}


extension ToDoViewController: MyTableViewCellDelegate {
    func didTapButton(cell: CustomTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            print("User did tap cell with index: \(indexPath.row)")
            createCustomTextField(textReceived: nil)
            saveEntryToUserDefault(indexReceived: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    func didTapCheckboxView(cell: CustomTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            print("User did tap cell with index: \(indexPath.row)")
            self.identifier = !identifier
            if self.identifier{
                cell.checkBoxView.backgroundColor = .systemBlue
            }
            else {
                cell.checkBoxView.backgroundColor = .white
            }
        }
    }
}

extension ToDoViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("TextField did end editing method called \(textField.text!)")
        saveEntryToUserDefault(indexReceived: counter)
        counter = counter + 1
        tableView.reloadData()
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        print("TextField should return method called \(textField.text!)")
        //for keyboard dismissal on pressing return key
        textField.resignFirstResponder()
        return true
    }
}
