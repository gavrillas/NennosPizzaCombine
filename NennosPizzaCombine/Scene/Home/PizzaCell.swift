//
//  PizzaCell.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 04..
//

import Combine
import Kingfisher
import UIKit

class PizzaCell: UITableViewCell {
    @IBOutlet private var pizzaImage: UIImageView!
    @IBOutlet private var pizzaLabel: UILabel!
    @IBOutlet private var ingridientsLabel: UILabel!
    @IBOutlet private var priceButton: UIButton!

    private var subscriptions = Set<AnyCancellable>()

    func config(with viewModel: PizzaCellViewModel) {
        if let imageUrl = viewModel.imageUrl {
            let url = URL(string: imageUrl)
            pizzaImage.kf.setImage(with: url)
        }
        pizzaLabel.text = viewModel.name
        ingridientsLabel.text = viewModel.ingredients
        priceButton.setTitle(viewModel.priceText, for: .normal)

        priceButton.layer.cornerRadius = 5

        priceButton.tap
            .sink(receiveValue: viewModel.addToCart.send(_:))
            .store(in: &subscriptions)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions = Set<AnyCancellable>()
    }
}
