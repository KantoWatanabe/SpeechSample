//
//  Alert.swift
//  SpeechSample
//
//  Created by 渡辺幹人 on 2020/05/24.
//  Copyright © 2020 渡辺幹人. All rights reserved.
//

import Foundation
import UIKit

final class Alert {
    
    class func show(_ controller: UIViewController, title: String, msg: String, handler: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let handler = handler {
                handler()
            }
        }))
        controller.present(alert, animated: true, completion: nil)
    }
}
