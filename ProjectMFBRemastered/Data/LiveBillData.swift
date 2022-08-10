//
//  LiveBillData.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-08-08.
//

import Foundation
import Combine

@available(iOS 13.0, *)
class LiveBillData: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    var url: URL
    var timeoutInterval: TimeInterval
    private var webSocketTask : URLSessionWebSocketTask!
    @Published var isConnected = false
    @Published var bill: MFBBill? = nil
    @Published var message: String = ""
    
    
    init?(room_id: String, timeoutInterval: TimeInterval) {
        if let url = URL(string: "ws://127.0.0.1:8000/ws/room/") {
            self.url = url
        } else {
            return nil
        }
        self.timeoutInterval = timeoutInterval
    }
    
    
    func connect() {
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let urlRequest = URLRequest(url: url, timeoutInterval: timeoutInterval)
        webSocketTask = urlSession.webSocketTask(with: urlRequest)
        webSocketTask.resume()
        receive()
    }
    
    func send(_ text: String) {
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    func receive() {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("WebSocket Error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        if let result = try? JSONDecoder().decode(MFBBill.self, from: data) {
                            DispatchQueue.main.sync {
                                self.bill = result
                            }
                        }
                    }
                case .data:
                    break
                @unknown default:
                    print("un-implemented case found in BillData")
                }
                self.receive()
            }
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.sync {
            self.isConnected = true
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.isConnected = false
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("here did recive challenge")
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            handleError(error)
        }
    }
    
    func close() {
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
    private func handleError(_ error:Error?){
        if let error = error as NSError? {
            if error.code == 57  || error.code == 60 || error.code == 54{
                isConnected = false
                close()
                //delegate?.webSocketDidDisconnect(self, error)
            } else {
                //delegate?.webSocketReceiveError(error)
            }
        }
    }
    
}
