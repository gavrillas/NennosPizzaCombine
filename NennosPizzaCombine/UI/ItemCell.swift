//
//  ItemCell.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 05..
//

import Combine
import UIKit

protocol ItemCellViewModel {
    var isImageHidden: Bool { get }
    var titleText: String { get }
    var priceText: String { get }
    var buttonTap: PassthroughSubject<Void, Never> { get }
}

class ItemCell: UITableViewCell {
    @IBOutlet private var imageButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!

    private var subscriptions = Set<AnyCancellable>()

    override func prepareForReuse() {
        super.prepareForReuse()

        subscriptions = Set<AnyCancellable>()
    }

    func config(with viewModel: ItemCellViewModel) {
        imageButton.isHidden = viewModel.isImageHidden
        titleLabel.text = viewModel.titleText
        priceLabel.text = viewModel.priceText

        imageButton.tap
            .sink(receiveValue: { viewModel.buttonTap.send() })
            .store(in: &subscriptions)
    }
}
