//
//  DappUser.swift
//  dapp-sdk-wallets-ios
//
//  Created by Rodrigo Rivas on 10/11/19.
//  Copyright © 2019 Dapp. All rights reserved.
//

import Foundation

public class DappUser {
    
    public var name: String!
    
    public var image: URL?
    
    public var suggestTip: Bool!
    
    public init(with data: [String: Any]) {
        if let name = data["name"] as? String {
            self.name = name
        }
        if let image = data["image"] as? String, let url = URL(string: image) {
            self.image = url
        }
        if let tip = data["suggest_tip"] as? Bool {
            self.suggestTip = tip
        }
    }
}
