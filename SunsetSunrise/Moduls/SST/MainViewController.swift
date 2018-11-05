//
//  MainViewController.swift
//  SunsetSunrise
//
//  Created by Ozzy on 11/3/18.
//  Copyright © 2018 TestTask. All rights reserved.
//

import RxSwift
import RxCocoa

final class MainViewController: UIViewController {
    @IBOutlet private weak var sunriseLabel: UILabel!
    @IBOutlet private weak var sunsetLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel: MainViewViewModelProtocol = MainViewViewModel()
    private var disposeBag = DisposeBag()
    
    // MARK: - Superclass
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        bind()
    }
    
    private func bind() {
        searchBar.rx.text.orEmpty.asDriver()
            .throttle(0.7)
            .filter { $0 != "" }
            .drive(viewModel.input)
            .disposed(by: disposeBag)
        
        let dataSourceObservable = viewModel.output.asObservable().skip(2)
            .share(replay: 3, scope: .whileConnected)
        let selectedObservable = tableView.rx.itemSelected.asObservable()
        
        dataSourceObservable.subscribe(onNext: { (predictions) in
          print(predictions)
        }).disposed(by: disposeBag)
        
        dataSourceObservable.asObservable().bind(to: tableView.rx
            .items(cellIdentifier: "\(PlaceCell.self)",
                cellType: PlaceCell.self)) { _, prediction, cell in
                    cell.viewModel = PlaceCellViewModel(placeModel: prediction)
            }.disposed(by: disposeBag)
        
        let combined = Observable.combineLatest(selectedObservable, dataSourceObservable)
        combined.asObservable().bind { [weak self] (indexPath, predictions) in
            guard let self = self else { return }
            self.viewModel.sunsetSunrise(by: predictions[indexPath.row])
            self.tableView.deselectRow(at: indexPath, animated: true)
            }.disposed(by: disposeBag)
        
        viewModel.sunsetSunriseModel.asDriver().drive(onNext: { [weak self] (model) in
            guard let self = self,
                let model = model else { return }
            self.sunriseLabel.text = "Sunrise: \(model.sunrise)"
            self.sunsetLabel.text = "Sunset: \(model.sunset)"
        }).disposed(by: disposeBag)
        
        viewModel.isLoading.asDriver().drive(onNext: { (loading) in
            if loading {
                self.activityIndicator.isHidden = !loading
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Private
    private func registerCell() {
        tableView.register(UINib(nibName: "\(PlaceCell.self)", bundle: nil), forCellReuseIdentifier: "\(PlaceCell.self)")
    }
}
