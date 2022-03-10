//
//  CartViewController.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 12..
//

import Combine
import UIKit

class CartViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var drinksBarButton: UIBarButtonItem!

    private var datasource: [ItemCellViewModel] = []

    var coordinator: Coordinator?
    var viewModel: CartViewModelProtocol?

    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        bindUI()
    }

    private func bindViewModel() {}

    private func bindUI() {
        drinksBarButton.tapPublisher
            .sink(receiveValue: { [weak self] in
                self?.coordinator?.showDrinks()
            }).store(in: &subscriptions)

        viewModel?.tableData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tableData in
                self?.datasource = tableData
                self?.tableView.reloadData()
            }).store(in: &subscriptions)
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as? ItemCell else { return UITableViewCell() }
        cell.config(with: datasource[indexPath.row])
        return cell
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        44
    }
}
