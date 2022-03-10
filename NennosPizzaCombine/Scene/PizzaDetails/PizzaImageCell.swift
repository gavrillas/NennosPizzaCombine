//
//  PizzaImageCell.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 05..
//

import Kingfisher
import UIKit

class PizzaImageCell: UITableViewCell {
    @IBOutlet private var pizzaImage: UIImageView!

    func config(with imageUrl: String?) {
        if let imageUrl = imageUrl {
            let url = URL(string: imageUrl)
            pizzaImage.kf.setImage(with: url)
        }
    }
}
