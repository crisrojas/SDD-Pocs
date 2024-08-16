//
//  Notifications.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//
import Foundation

extension Notification.Name {
    static let login: Self  = .init(rawValue: "com.myapp.login ")
    static let logout: Self = .init(rawValue: "com.myapp.logout")
}

protocol IRadio: IEmitter, IObserver {}
protocol IEmitter {}
protocol IObserver {}

extension IEmitter {
    func post(_ notification: Notification.Name) {
        NotificationCenter.default.post(name: notification, object: nil)
    }
}

extension IObserver {
    func observe(_ notification: Notification.Name, _ selector: Selector) {
        NotificationCenter
        .default
        .addObserver(
            self,
            selector: selector,
            name: Notification.Name.logout,
            object: nil
        )
    }
}

final class Observer: IObserver {
    
    func startObserving() {observeAuthEvents()}
    
    func observeAuthEvents() {
        observe(.login , #selector(login ))
        observe(.logout, #selector(logout))
    }
    
    @objc func logout() {print("login out")}
    @objc func login () {print("login in ")}
}

final class Emitter: IEmitter {}

fileprivate func main() {
    let observer = Observer()
    observer.startObserving()
    
    let emitter  = Emitter()
    emitter.post(.logout)
    emitter.post(.login )
    
    final class Radio: IRadio {
        var loginS : Selector {#selector(login )}
        var logoutS: Selector {#selector(logout)}
        
        func observe(_ notification: Notification.Name) {
            switch notification {
            case .login : observe(notification, #selector(login))
            case .logout: observe(notification, #selector(logout))
            default: return
            }
        }
        
        @objc private func login () {print("login from radio" )}
        @objc private func logout() {print("logout from radio")}
    }
    
    let radio = Radio()
    radio.observe(.login , radio.loginS)
    radio.observe(.logout, radio.logoutS)
    radio.observe(.login)
    radio.observe(.logout)
    radio.post(.login )
    radio.post(.logout)
}
