//
//  AsyncChainedCallsInteractor.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//

import Foundation

//import UIKit

typealias AppResult = Result<String, Error>
typealias AppCompletion = (AppResult) -> Void
typealias ProgressCallback = (Double) -> Void
final class WebService {
    func call1(completion: @escaping AppCompletion) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success("call1 data"))
        }
    }
    func call2(data: String, completion: @escaping AppCompletion) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success("call2 data"))
        }
    }
    func call3(data: String, completion: @escaping AppCompletion) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success("call3 data"))
        }
    }
}

final class GetDataInteractor {
    
    fileprivate let webservice = WebService()
    fileprivate var completion: AppCompletion!
    fileprivate var progressCallback: ProgressCallback?
    
    func callAsFunction(
        completion: @escaping AppCompletion,
        progessCallback: ProgressCallback? = nil) {
            
        self.completion = completion
        self.progressCallback = progessCallback
        ongoinCall = .call1
    }
    
    fileprivate var ongoinCall: CallChain? = .none {
        didSet {
            guard let ongoinCall = ongoinCall else {
                progressCallback?(100.0)
                return
            }
            
            progressCallback?(ongoinCall.progress)
            switch ongoinCall {
            case .call1: call1()
            case .call2(let data): call2(data: data)
            case .call3(let data): call3(data: data)
            }
        }
    }
    
    fileprivate func call1() {
        webservice.call1 { [weak self] result in
            switch result {
            case .success(let data):
                self?.ongoinCall = .call2(data: data)
            case .failure(let error):
                self?.completion(.failure(error))
            }
        }
    }
    
    fileprivate func call2(data: String) {
        webservice.call2(data: data) { [weak self] result in
            switch result {
            case .success(let data):
                self?.ongoinCall = .call3(data: data)
            case .failure(let error):
                self?.completion(.failure(error))
            }
        }
    }
    
    fileprivate func call3(data: String) {
        webservice.call3(data: data) { [weak self] result in
            self?.completion(result)
            self?.ongoinCall = .none
        }
    }
}

// MARK: - Call chain
extension GetDataInteractor {
    fileprivate enum CallChain {
        static var totalCalls = 3
        case call1
        case call2(data: String)
        case call3(data: String)
        
        var callIndex: Int {
            switch self {
            case .call1: return 0
            case .call2: return 1
            case .call3: return 2
            }
        }
        
        var progress: Double {
            Double(callIndex) / Double(Self.totalCalls) * 100
        }
    }
}


final class Presenter {
    
    private let dataGetter = GetDataInteractor()
    
    func getData() {
        dataGetter(
            completion: updateView(_:),
            progessCallback: progressHandler(_:))
    }
    
    // Process data
    func updateView(_ result: AppResult) {
        print(capturedProgress)
        switch result {
        case .success(let message):
            print("Success: \(message)")
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
    
    var capturedProgress = [Double]()
    func progressHandler(_ progress: Double) {
        capturedProgress.append(progress)
    }
}

fileprivate func main() {
    let presenter = Presenter()
    presenter.getData()
}
