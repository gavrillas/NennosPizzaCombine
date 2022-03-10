//
//  PizzaDetailsViewController.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 05..
//

import Combine
import UIKit

class PizzaDetailsViewController: UIViewController {
    enum CellHeight: Int {
        case image
        case ingredient

        var heightForRow: CGFloat {
            switch self {
            case .image:
                return 300
            case .ingredient:
                return 44
            }
        }
    }

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addToCartButton: UIButton!

    private var subscriptions = Set<AnyCancellable>()
    private var tableData: [SectionModelType] = []

    var viewModel: PizzaDetailsViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        bindViewModel()
    }

    private func bindViewModel() {
        guard let viewModel = viewModel else { return }

        viewModel.tableData.sink(receiveValue: { [weak self] tableData in
            self?.tableData = tableData
            self?.tableView.reloadData()
        }).store(in: &subscriptions)

        viewModel.totalPrice
            .assign(to: \.titleText, on: addToCartButton)
            .store(in: &subscriptions)

        viewModel.newPizzaPublisher
            .assign(to: \.pizzaSubject.value, on: viewModel)
            .store(in: &subscriptions)

        viewModel.title
            .assign(to: \.title, on: self)
            .store(in: &subscriptions)

        viewModel.addedToCart
            .sink(receiveValue: {})
            .store(in: &subscriptions)

        addToCartButton.tap
            .sink(receiveValue: { [weak self] in
                self?.viewModel?.addToCart.send()
            })
            .store(in: &subscriptions)
    }
}

extension PizzaDetailsViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        tableData.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionItem = tableData[indexPath.section].items[indexPath.row] as? PizzaDetailsViewModel.SectionItem else {
            return UITableViewCell()
        }

        switch sectionItem {
        case let .image(imageUrl):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PizzaImageCell") as? PizzaImageCell else { return UITableViewCell() }
            cell.config(with: imageUrl)
            return cell
        case let .ingredient(viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell") as? ItemCell else { return UITableViewCell() }
            cell.config(with: viewModel)
            return cell
        }
    }
}

extension PizzaDetailsViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        viewModel?.selectedIndex.send(indexPath)
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CellHeight(rawValue: indexPath.section)?.heightForRow ?? 44
    }
}
