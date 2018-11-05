//
//  MainViewViewModel.swift
//  SunsetSunrise
//
//  Created by Ozzy on 11/3/18.
//  Copyright © 2018 TestTask. All rights reserved.
//

import RxSwift

protocol MainViewViewModelProtocol: class {
    var sunsetSunriseModel: Variable<SunsetSunriseModel?> { get }
    var input: Variable<String> { get set }
    var output: Variable<[Prediction]> { get }
    func sunsetSunrise(by model: Prediction)
    var isLoading: Variable<Bool> { get }
}

final class MainViewViewModel: MainViewViewModelProtocol {
    
    var isLoading: Variable<Bool> = Variable(false)
    var input: Variable<String> = Variable("")
    var output: Variable<[Prediction]> = Variable([Prediction]())
    var sunsetSunriseModel: Variable<SunsetSunriseModel?>
    
    private var apiManager: RestAPIManagerProtocol = RestAPIManager()
    private var disposeBag = DisposeBag()
    
    // MARK: - Init
    init() {
        sunsetSunriseModel = Variable(nil)
        bind()
    }
    
    // MARK: - Binding
    private func bind() {
        
        input.asObservable().bind { [weak self] (input) in
            guard let self = self else { return }
            self.isLoading.value = true
            self.apiManager.autoCompletePlace(input: input).asObservable()
                .bind(onNext: { (predictions) in
                    self.output.value = predictions
                    self.isLoading.value = false
                })
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    func sunsetSunrise(by model: Prediction) {
        isLoading.value = true
        apiManager.getPlace(input: model.placeId)
            .asObservable()
            .bind { [weak self] (model) in
            guard let self = self else { return }
            self.apiManager.getSunriseSunsetInformation(
                lat: "\(model.geometry.location.lat)",
                lng: "\(model.geometry.location.lng)")
                .asObservable().bind(to: self.sunsetSunriseModel)
                .disposed(by: self.disposeBag)
                self.isLoading.value = false
        }.disposed(by: disposeBag)
    }
}
