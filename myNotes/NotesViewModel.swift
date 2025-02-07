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
    
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
    
    func toggleCompletion(note: Note) {
        if let index = notes.firstIndex(where: {$0.id == note.id}) {
            notes[index].isCompleted.toggle()
        }
    }
    
    func updateNote(note: Note, title: String, content: String) {
        if let index = notes.firstIndex(where: {$0.id == note.id}) {
            notes[index].title = title
            notes[index].content = content
        }
    }
}
