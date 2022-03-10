//
//  Pizza.swift
//  NennosPizza
//
//  Created by kristof on 2021. 10. 11..
//

import Foundation

struct Pizza: Codable {
    let ingredients: [Int]
    let name: String
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case ingredients, name
        case imageURL = "imageUrl"
    }
}
