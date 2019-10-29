//
//  DappError.swift
//  dapp-sdk-wallets-ios
//
//  Created by Rodrigo Rivas on 9/9/19.
//  Copyright © 2019 Dapp. All rights reserved.
//

import Foundation

public enum DappError: LocalizedError {
    
    case cameraNotAllowed
    case error(error: Error)
    case invalidDappCode
    case keyIsNotSet
    case merchantIdIsNotSet
    case responseError(msg: String?)
    
    public var errorDescription: String? {
        switch self {
        case .cameraNotAllowed:
            return "DappError: User did not give permission to use the camera"
        case .error(let error):
            return error.localizedDescription
        case .invalidDappCode:
            return "DappError: QR does not have a valid Dapp Code format"
        case .keyIsNotSet:
            return "DappError: Public Key is not set."
        case .merchantIdIsNotSet:
            return "DappError: Merchant ID is not set."
        case .responseError(let msg):
            if let m = msg {
                return "DappError: \(m)"
            }
            return "DappError: An error has occurred processing the server response."
        }
    }
}
