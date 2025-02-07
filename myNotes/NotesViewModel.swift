//
//  NotesViewModel.swift
//  myNotes
//
//  Created by Satvik  Jadhav on 2/7/25.
//

import Foundation
import SwiftUI


class NotesViewModel: ObservableObject {
    @AppStorage("notes") private var savedNotes: Data?
    @Published var notes: [Note] = []
    
    
    func addNote(title: String, content: String) {
        let newNote = Note(title: title, content: content)
        notes.append(newNote)
    }
}
