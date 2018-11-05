//
//  PlaceCell.swift
//  SunsetSunrise
//
//  Created by Ozzy on 11/3/18.
//  Copyright © 2018 TestTask. All rights reserved.
//

import RxSwift

protocol PlaceCellViewModelProtocol: class {
    var placeModel: Variable<Prediction> { get }
}

class PlaceCellViewModel: PlaceCellViewModelProtocol {
    var placeModel: Variable<Prediction>
    
    init(placeModel: Prediction) {
        self.placeModel = Variable(placeModel)
    }
}

final class PlaceCell: UITableViewCell {
    @IBOutlet private weak var locationNameLabel: UILabel!
    private let disposeBag = DisposeBag()
    
    var viewModel: PlaceCellViewModelProtocol? {
        didSet {
            if viewModel != nil {
                bind()
            }
        }
    }
    
    // MARK: - Superclass
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Private
    private func bind() {
        guard let viewModel = viewModel else { return }
        viewModel.placeModel.asDriver().drive(onNext: { [weak self] (model) in
            guard let self = self else { return }
            self.locationNameLabel.text = model.description
        }).disposed(by: disposeBag)
    }
}
