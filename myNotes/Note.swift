//
//  Note.swift
//  myNotes
//
//  Created by Satvik  Jadhav on 2/7/25.
//


import Foundation

struct Note: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var isCompleted: Bool = false
}
