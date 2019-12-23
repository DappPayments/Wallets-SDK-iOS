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

public enum QRType: Int {
    case dapp = 0
    case codi, codiDapp, unknown
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
    
    public func isValidCodi(_ text: String) -> Bool {
        let qrType = getQRType(text)
        return qrType == .codi || qrType == .codiDapp
    }
    
    public func getQRType(_ qrText: String) -> QRType {
        if let data = qrText.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let jsonV = json["v"] as? [String: Any], let jsonIc = json["ic"] as? [String: Any] {
                if json["TYP"] != nil && json["CRY"] != nil && jsonV["DEV"] != nil && jsonIc["IDC"] != nil && jsonIc["SER"] != nil && jsonIc["ENC"] != nil {
                    if json["dapp"] != nil {
                        return .codiDapp
                    }
                    return .codi
                }
            }
            else if json["dapp"] != nil {
                return .dapp
            }
        }
        
        if let url = URL(string: qrText), let host = url.host, host == "dapp.mx" {
            var comps = url.pathComponents
            comps.removeFirst()
            if let p = comps.first, p == "c" {
                return .dapp
            }
        }
        
        return .unknown
    }
    
    public func isValid(DappCode code: String) -> Bool {
        let qrType = getQRType(code)
        return qrType == .dapp || qrType == .codiDapp
    }
    
    public func getDappId(_ code: String) -> String? {
        guard let url = URL(string: code), let host = url.host, host == "dapp.mx" else {
            if let data = code.data(using: .utf8),
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let dappCode = json["dapp"] as? String {
                   return dappCode
            }
            return nil
        }
        
        var comps = url.pathComponents
        comps.removeFirst()
               
        guard let p = comps.first, p == "c" else {
            return nil
        }
        
        return url.lastPathComponent
    }
    
    public func readDappCode(code: String, delegate: DappWalletDelegate) {
        if apiKey.count == 0 {
            delegate.dappWalletFailure(error: .keyIsNotSet)
            return
        }
        
        let handler: ResponseHandler = { (data, error) in
            if let e = error {
                delegate.dappWalletFailure(error: e)
                return
            }
            
            delegate.dappWalletSuccess(code: DappCode(with: data!))
        }
        
        guard let dappId = getDappId(code) else {
            delegate.dappWalletFailure(error: .invalidDappCode)
            return
        }
        
        dappRequest(url: "\(enviroment.getServer())/dapp-codes/\(dappId)", handler: handler)
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
