//
//  ViewController.swift
//  SpeechSample
//
//  Created by 渡辺幹人 on 2020/05/23.
//  Copyright © 2020 渡辺幹人. All rights reserved.
//

import UIKit
import MediaPlayer
import Speech

class ViewController: UIViewController {
    
    // MARK: Property
    
    private var speechRecognizer = SpeechRecognizer()
   
    // MARK: IBOutlet
    
    @IBOutlet weak var resultText: UITextView!


    // MARK: View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        speechRecognizer.delegate = self
    }

    // MARK: IBAction
    
    @IBAction func tapFile(_ sender: Any) {
        self.presentDocumentPicker()
    }
    
    @IBAction func tapMedia(_ sender: Any) {
        if MPMediaLibrary.authorizationStatus() != .authorized {
            MPMediaLibrary.requestAuthorization { (authStatus) in
                DispatchQueue.main.async {
                    if authStatus == .authorized {
                        self.presentMediaPicker()
                    } else {
                        Alert.show(self, title: "エラー", msg: "音声解析のためにメディアライブラリへのアクセスを許可してください", handler: {() -> Void in
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        })
                    }
                }
            }
        } else {
            self.presentMediaPicker()
        }
    }
    
    // MARK: Private Method
   
    private func presentDocumentPicker() {
        let controller = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        controller.delegate = self
        controller.allowsMultipleSelection = false
        self.present(controller, animated: true, completion: nil)
    }
    
    private func presentMediaPicker() {
        let controller = MPMediaPickerController(mediaTypes: .music)
        controller.showsItemsWithProtectedAssets = false
        controller.allowsPickingMultipleItems = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
}

// MARK: SpeechRecognizerDelegate

extension ViewController: SpeechRecognizerDelegate {
    func receiveResult(result: SFSpeechRecognitionResult) {
        self.resultText.text = result.bestTranscription.formattedString
        
        if result.isFinal {
            Alert.show(self, title: "完了", msg: "解析が完了しました", handler: nil)
        }
    }
    
    func onError(error: Error) {
        self.resultText.text = error.localizedDescription
        Alert.show(self, title: "エラー", msg: "解析が失敗しました", handler: nil)
    }
}

// MARK: MPMediaPickerControllerDelegate

extension ViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true)
        
        speechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    guard let url =  mediaItemCollection.items.first?.assetURL else {
                        return
                    }
                    self.speechRecognizer.recognize(url: url)
                } else {
                    Alert.show(self, title: "エラー", msg: "音声解析を許可してください", handler: {() -> Void in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    })
                }
            }
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
}

// MARK: UIDocumentPickerDelegate

extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        speechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    guard let url =  urls.first else {
                        return
                    }
                    self.speechRecognizer.recognize(url: url)
                } else {
                    Alert.show(self, title: "エラー", msg: "音声解析を許可してください", handler: {() -> Void in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    })
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // NOP
    }
}

