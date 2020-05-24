//
//  SpeechRecognizer.swift
//  SpeechSample
//
//  Created by 渡辺幹人 on 2020/05/24.
//  Copyright © 2020 渡辺幹人. All rights reserved.
//

import Foundation
import Speech

protocol SpeechRecognizerDelegate {
    func receiveResult(result: SFSpeechRecognitionResult)
    func onError(error: Error)
    func availabilityDidChange(available: Bool)
}

extension SpeechRecognizerDelegate {
    func onError(error: Error) {
        print(error)
    }
    func availabilityDidChange(available: Bool) {
        print("available did change \(available)")
    }
}

class SpeechRecognizer: NSObject {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja_JP"))
    private var recognitionTask: SFSpeechRecognitionTask?
    
    var delegate: SpeechRecognizerDelegate?
    
    func requestAuthorization(_ completion: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void) {
        if SFSpeechRecognizer.authorizationStatus() == .authorized {
            completion(.authorized)
        } else {
            SFSpeechRecognizer.requestAuthorization { (authStatus) in
                completion(authStatus)
            }
        }
    }
    
    func recognize(url: URL) {
        // 前回のタスクがあればキャンセル
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        let recognitionRequest = SFSpeechURLRecognitionRequest(url: url)
        recognitionRequest.shouldReportPartialResults = true
        
        // デバイス認識を有効に
        if self.speechRecognizer!.supportsOnDeviceRecognition {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        
        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            if let result = result {
                self.delegate?.receiveResult(result: result)
                isFinal = result.isFinal
            }
            if let error = error {
                self.delegate?.onError(error: error)
            }
            
            if isFinal {
                self.recognitionTask = nil
            }
        }
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        self.delegate?.availabilityDidChange(available: available)
    }
}
