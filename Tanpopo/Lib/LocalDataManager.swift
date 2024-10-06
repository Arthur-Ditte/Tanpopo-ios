//
//  LocalDataManager.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 06.10.24.
//


import Foundation

struct LocalDataManager {
    
    func saveDataLocally(data: Data) throws {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "DirectoryError", code: -1, userInfo: nil)
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("userData.json")
        try data.write(to: fileURL)
    }
    
    func loadDataLocally() throws -> Data {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "DirectoryError", code: -1, userInfo: nil)
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("userData.json")
        return try Data(contentsOf: fileURL)
    }
}
