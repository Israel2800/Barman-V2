//
//  Drink.swift
//  Barman
//
//  Created by JanZelaznog on 26/02/23.
//

import Foundation

struct Drink: Decodable, Encodable {
    let name: String
    let img: String
    let ingredients: String
    let directions: String
}
