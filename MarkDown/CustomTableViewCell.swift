//
//  CustomTableViewCell.swift
//  MarkDown
//
//  Created by iPHTech 15 on 06/11/23.
//

import UIKit

//delegate to identify in which table view cell button was pressed.
protocol MyTableViewCellDelegate: AnyObject {
    //fun of hidden button
//    func didTapButton(cell: CustomTableViewCell)
    func didTapCheckboxView(cell: CustomTableViewCell)
}

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var checkBoxView: UIView!
    
    weak var delegate: MyTableViewCellDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxView.layer.cornerRadius = checkBoxView.layer.bounds.width / 2
        checkBoxView.clipsToBounds = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        checkBoxView.addGestureRecognizer(gesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        addButton.isHidden = true

        // Configure the view for the selected state
    }
//    func configureCheckbox(selected: Bool) {
//            if selected {
//                checkBoxView.backgroundColor = .systemBlue
//            } else {
//                checkBoxView.backgroundColor = .white
//            }
//        }
    
    @objc func didTapView() {

        delegate?.didTapCheckboxView(cell: self)
        
    }
//hidden button
    @IBAction func addButton(_ sender: UIButton) {
//        delegate?.didTapButton(cell: self)
    }
    
    
}
