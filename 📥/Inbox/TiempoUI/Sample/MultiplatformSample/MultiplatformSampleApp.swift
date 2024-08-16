//
//  MultiplatformSampleApp.swift
//  MultiplatformSample
//
//  Created by Cristian Felipe Patiño Rojas on 09/07/2023.
//

import SwiftUI
import TiempoUI

#if os(iOS)
@main
struct iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
#else
@main
struct MacApp: App {
    var body: some Scene {
        WindowGroup {
            Text("hello macOS")
        }
    }
}
#endif
import UserNotifications

func checkPermission() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .authorized: return // @todo sendNotification
        case .denied: return
        case .notDetermined: requestNotificationAuthorization()
        default: return
        }
    }
}
// Método para solicitar permiso para mostrar notificaciones
func requestNotificationAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
        if granted {
           // @todo: sendNotification
        } else {
            print("Permiso denegado para mostrar notificaciones")
        }
    }
}

// Método para enviar la notificación
import UserNotifications

func sendNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Tiempo"
    content.body = "Temporizador"
//    content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1)
    content.sound = UNNotificationSound.init(named:UNNotificationSoundName(rawValue: "marimba1.wav"))

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error al programar la notificación: \(error)")
        } else {
            print("Notificación enviada inmediatamente")
        }
    }
}

import AVFoundation
import Combine

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var timer: AnyCancellable?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // @todo
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Se concedieron los permisos de notificación")
            } else {
                print("Los permisos de notificación fueron denegados")
            }
        }
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

