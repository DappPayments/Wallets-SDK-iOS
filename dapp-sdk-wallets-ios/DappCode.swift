//
//  DappCode.swift
//  dapp-sdk-wallets-ios
//
//  Created by Rodrigo Rivas on 10/11/19.
//  Copyright © 2019 Dapp. All rights reserved.
//

import Foundation

public class DappCode {
    
    public var id: String!
    
    public var description: String!
    
    public var amount: Double!
    
    public var user: DappUser!
    
    public var json = [String: Any]()
    
    public init(with data: [String: Any]) {
        if let id = data["id"] as? String {
            self.id = id
        }
        if let description = data["description"] as? String {
            self.description = description
        }
        if let amount = data["amount"] as? Double {
            self.amount = amount
        }
        if let userData = data["dapp_user"] as? [String: Any] {
            self.user = DappUser(with: userData)
        }
        self.json = data
    }
}
