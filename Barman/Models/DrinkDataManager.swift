//
//  DringDataManager.swift
//  Barman
//
//  Created by JanZelaznog on 26/02/23.
//

import Foundation

struct DrinkDataManager {

    static func loadDrinks() -> [Drink]? {
        if let file = Bundle.main.url(forResource: File.main.name, withExtension: File.main.extension) {
            guard let data = try? Data(contentsOf: file) else { return nil }
            return try? JSONDecoder().decode([Drink].self, from: data)
        } else {
            return nil
        }
    }
    
    static func update(drinks: [Drink]) {
        guard let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let filePath = directoryPath.appendingPathComponent("drinks.json")
        let json = try? JSONEncoder().encode(drinks)
        try? json?.write(to: filePath)
    }
}

