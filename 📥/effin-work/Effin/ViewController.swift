//
//  ViewController.swift
//  Effin
//
//  Created by Cristian Patiño Rojas on 15/11/23.
//

import UIKit

struct Order {}
extension Order: Decodable {}

struct JSON {
    let data: Data?
    init(data: Data? = nil) {self.data = data}
}

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
}


// 1. ¿Por qué OrderProcessing tiene dependencias a génericos?
//
// Ya que lleva el prefijo "Order", ¿no debería de devolver, en vez de un json, un objeto Order ?
// En caso de que se quiera mantener genérico, no debería de llevar un nombre más genérico ? algo como "ResourceProcesor" ?
// Algo como:

protocol ResourceProcessor: AnyObject {
    associatedtype ResponseType: Decodable
    associatedtype ViewModelType
    var resource: Resource { get }
    var state: ViewState<ViewModelType> { get set }
    func map(_ response: ResponseType) -> ViewModelType
}

extension ResourceProcessor {
    func processResource() {
        state = .loading
        resource.get { [weak self] result in
            guard let self else { return }
            do {
                guard let data = result.data else { return }
                let decoded = try JSONDecoder().decode(ResponseType.self, from: data)
                self.state = .success(map(decoded))
            } catch {
                self.state = .failure(error)
            }
        }
    }
}

protocol OrderProcessor: ResourceProcessor {
    associatedtype ResponseType  = Order
    associatedtype ViewModelType = OrderUI
}

struct OrderUI {
    /// Formatea las varialbes de order correctamente para ser consumidas por la vista
    init(from order: Order) {}
}

class ViewControllerBis: UIViewController, OrderProcessor {
    var resource: Resource { OrderResource() }
    /// 1. ¿Qué pasa si Order viene de la api, pero es diferente al modelo que queremos usar en la vista?
    /// Podemos tener un OrderUI
    var state: ViewState<OrderUI> = .idle { didSet { updateUI() }}
    
    func updateUI() {
        switch state {
        case .idle: break
        case .loading: break
        case .success(let order): onSuccess(order: order)
        case .failure(let error): print(error)
        }
    }
    
    fileprivate func onSuccess(order: OrderUI) {}
    
    func map(_ response: Order) -> OrderUI {
        .init(from: response)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        processResource()
    }
}

protocol OrderProcessing: AnyObject {
    var order: Resource { get }
    var json: JSON { get set }
}

extension OrderProcessing {
    func processOrder() {
        order.get { [weak self] in self?.json = $0 }
    }
}

protocol Resource {
    func get(completion: @escaping (JSON) -> Void)
    func get() async throws -> JSON
}

struct OrderResource: Resource {
    func get(completion: @escaping (JSON) -> Void) {}
    func get() async throws -> JSON { .init() }
}

class ViewController: UIViewController, OrderProcessing {
    var order: Resource { OrderResource() }
    var json = JSON() { didSet { updateUI() }}
    
    func updateUI() {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        processOrder()
    }
}
