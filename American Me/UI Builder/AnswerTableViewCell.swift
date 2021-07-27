//
//  AnswerTableViewCell.swift
//  American Me
//
//  Created by Minh Nguyen on 9/29/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import UIKit

protocol AnswerTableViewCellDelegate {
    
    func speakerButtonTapped(text: String?)
}

class AnswerTableViewCell: UITableViewCell {
    
    var delegate: AnswerTableViewCellDelegate?

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var speakerButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func speakerButtonTapped(_ sender: Any) {
        speakerButton.setTitleColor(UIColor.lightGray, for: .selected)
        delegate?.speakerButtonTapped(text: answerLabel.text)
    }
}
