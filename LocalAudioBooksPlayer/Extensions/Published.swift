//
//  Published.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation

extension Published:Decodable where Value:Decodable {
    public init(from decoder: Decoder) throws {
        
        let decoded = try Value(from:decoder)
        print("decoding [\(decoded)]")
        self = Published(initialValue:decoded)
    }
}

extension Published:Encodable where Value:Decodable {

    public func encode(to encoder: Encoder) throws {

        let mirror = Mirror(reflecting: self)
        if let valueChild = mirror.children.first(where: { $0.label == "value"
        }) {
            if let value = valueChild.value as? Encodable {
                do {
                    try value.encode(to: encoder)
                    return
                } catch let error {
                    assertionFailure("Failed encoding: \(self) - \(error)")
                }
            }
            else {
                assertionFailure("Decodable Value not decodable. Odd \(self)")
            }
        }
        else {
            assertionFailure("Mirror Mirror on the wall - why no value y'all : \(self)")
        }
    }
}
