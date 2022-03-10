//
//  HomeViewController.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 01..
//

import Combine
import UIKit

class HomeViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addBarButton: UIBarButtonItem!
    @IBOutlet private var cartBarButton: UIBarButtonItem!
    private var datasource = [PizzaCellViewModel]()

    private var subscriptions = Set<AnyCancellable>()
    var coordinator: Coordinator?
    var viewModel: HomeViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        navigationItem.backButtonTitle = ""

        bindViewModel()
    }

    private func bindViewModel() {
        guard let viewModel = viewModel else { return }

        viewModel.tableData
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.handleCompletion(completion: completion)
            }, receiveValue: { [weak self] tableData in
                guard let self = self else { return }
                self.datasource = tableData
                self.tableView.reloadData()
            }).store(in: &subscriptions)

        viewModel.selectedPizza
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.handleCompletion(completion: completion)
            }, receiveValue: { [weak self] viewModel in
                self?.coordinator?.showPizzaDetails(viewModel: viewModel)
            }).store(in: &subscriptions)

        addBarButton.tapPublisher
            .sink { [weak self] in
                self?.viewModel?.customPizzaSubject.send(())
            }.store(in: &subscriptions)

        cartBarButton.tapPublisher
            .sink(receiveValue: { [weak self] in
                self?.coordinator?.showCart()
            }).store(in: &subscriptions)
    }

    private func handleCompletion(completion: Subscribers.Completion<PizzaServiceError>) {
        switch completion {
        case let .failure(error):
            showError(error: error)
        case .finished:
            return
        }
    }

    private func showError(error: PizzaServiceError) {
        let message = error.localizedDescription
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PizzaCell") as? PizzaCell else { return UITableViewCell() }
        cell.config(with: datasource[indexPath.row])
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        178
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selectedIndex.send(indexPath)
    }
}
