//
//  ContentView.swift
//  myNotes
//
//  Created by Satvik  Jadhav on 2/7/25.
//
import Foundation
import SwiftUI

struct Note: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var isCompleted: Bool = false
}

struct NoteDetailView: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel
    
    var body: some View {
        VStack {
            Text(note.title)
            Text(note.content)
            
            Button(action: {viewModel.toggleCompletion(note: note)}) {
                Text(note.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
            }
        }
        .navigationTitle("Note Details")
    }
}

class NotesViewModel: ObservableObject {
    @AppStorage("notes") private var savedNotes: Data?
    @Published var notes: [Note] = []
    
    init() {
        loadNotes()
    }
    
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
    
    func saveNotes() {
        if let data = try? JSONEncoder().encode(notes) {
            savedNotes = data
        }
    }
        
    func loadNotes() {
        if let data = savedNotes, let decodedNotes = try? JSONDecoder().decode([Note].self, from: data) {
                notes = decodedNotes
            }
    }
}

struct AddEditNoteView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.dismiss) var dismiss  // Access the dismiss function
    
    @State private var title: String = ""
    @State private var content: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextEditor(text: $content)
                
                Button("Save") {
                    viewModel.addNote(title: title, content: content)
                    dismiss()
                }
            }
        }
        .navigationTitle("New Note")
    }
}

struct ContentView: View {
    @StateObject var viewModel = NotesViewModel()
    @State private var showAddNote: Bool = false
    
    var body: some View {

        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                        HStack {
                            if note.isCompleted {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                Text(note.title).strikethrough()
                            } else {
                                Text(note.title)
                            }
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteNote)
            }
            .navigationTitle("Notes")
            .toolbar {
                Button(action: {showAddNote = true}) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddNote) {
                AddEditNoteView(viewModel: viewModel)
            }
        }
        .navigationTitle(Text("Notes"))
    }
}

#Preview {
    ContentView()
}
