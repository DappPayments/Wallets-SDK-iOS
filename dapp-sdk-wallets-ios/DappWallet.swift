//
//  Dapp.swift
//  dapp-sdk-wallets-ios
//
//  Created by Rodrigo Rivas on 9/9/19.
//  Copyright © 2019 Dapp. All rights reserved.
//

import Foundation
import AVFoundation

typealias ResponseHandler = (_ data: [String: Any]?, _ error: DappError?) -> ()

public enum DappEnviroment: Int {
    case production = 0
    case sandbox
    
    internal func getServer() -> String {
        switch self {
        case .production:
            return "https://wallets.dapp.mx/v1/"
        case .sandbox:
            return "https://wallets-sandbox.dapp.mx/v1/"
        }
    }
}

public protocol DappWalletDelegate {
    func dappWalletSuccess(code: DappCode)
    
    func dappWalletFailure(error: DappError)
}

public class DappWallet {
    
    public var enviroment = DappEnviroment.production
    
    public var apiKey = ""
    
    public static let shared = DappWallet()
    
    public func canReadQRWithCamera() -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        return !(authStatus == .restricted || authStatus == .denied)
    }
    
    public func isValid(DappCode code: String) -> Bool {
        guard let url = URL(string: code), let host = url.host, host == "dapp.mx" else {
            return false
        }
        
        var comps = url.pathComponents
        comps.removeFirst()
        
        guard let p = comps.first, p == "c" else {
            return false
        }
        
        return true
    }
    
    public func readDappCode(code: String, delegate: DappWalletDelegate) {
        if apiKey.count == 0 {
            delegate.dappWalletFailure(error: .keyIsNotSet)
            return
        }
        
        guard let url = URL(string: code), let host = url.host, host == "dapp.mx" else {
            delegate.dappWalletFailure(error: .invalidDappCode)
            return
        }
        
        var comps = url.pathComponents
        comps.removeFirst()
        
        guard let p = comps.first, p == "c" else {
            delegate.dappWalletFailure(error: .invalidDappCode)
            return
        }
        
        let handler: ResponseHandler = { (data, error) in
            if let e = error {
                delegate.dappWalletFailure(error: e)
                return
            }
            
            delegate.dappWalletSuccess(code: DappCode(with: data!))
        }
        
        dappRequest(url: "\(enviroment.getServer())/dapp-codes/\(url.lastPathComponent)", handler: handler)
    }
    
    internal func dappRequest(url: String, handler: @escaping ResponseHandler) {
        var request = URLRequest(url: URL(string: url)!)
        let authData = "\(apiKey):".data(using: String.Encoding.utf8)!
        let base64 = authData.base64EncodedString()
        request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let e = error {
                DispatchQueue.main.async {
                    handler(nil, DappError.error(error: e))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    handler(nil, DappError.responseError(msg: nil))
                }
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                DispatchQueue.main.async {
                    handler(nil, DappError.responseError(msg: nil))
                }
                return
            }
            
            guard let rc = json["rc"] as? Int else {
                DispatchQueue.main.async {
                    handler(nil, DappError.responseError(msg: nil))
                }
                return
            }
            
            if rc != 0 {
                DispatchQueue.main.async {
                    handler(nil, DappError.responseError(msg: json["msg"] as? String))
                }
                return
            }
            
            guard let jsonData = json["data"] as? [String: Any] else {
                DispatchQueue.main.async {
                    handler(nil, DappError.responseError(msg: nil))
                }
                return
            }
            DispatchQueue.main.async {
                handler(jsonData, nil)
            }
        }
        task.resume()
    }
}
