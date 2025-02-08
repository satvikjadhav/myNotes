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
    @State private var showEditView = false
    
    var body: some View {
        VStack {
            Text(note.title).font(.largeTitle).bold()
            Text(note.content).font(.body)
            
            Button(action: {viewModel.toggleCompletion(note: note)}) {
                Text(note.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                    .foregroundColor(.white)
                    .padding()
                    .background(note.isCompleted ? Color.red : Color.green)
                    .cornerRadius(5)
            }
        }
        .padding()
        .navigationTitle("Note Details")
        .toolbar {
            Button(action: {
                showEditView = true
            }) {
                Image(systemName: "pencil")
            }
        }
        .sheet(isPresented: $showEditView) {
            AddEditNoteView(viewModel: viewModel, note: note)
        }
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
    var note: Note?
    
    init(viewModel: NotesViewModel, note: Note?) {
        self.viewModel = viewModel
        // Initialize the title state with the note's title, or an empty string if the note is nil
        self._title = State(initialValue: note?.title ?? "")
        // Initialize the content state with the note's content, or an empty string if the note is nil
        self._content = State(initialValue: note?.content ?? "")
        self.note = note
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextEditor(text: $content).frame(height: 200)
            }
            .navigationTitle(note == nil ? "New Note" : "Edit Note")
            .toolbar {
                Button("Save") {
                    if let note = note {
                        viewModel.updateNote(note: note, title: title, content: content)
                    } else {
                        viewModel.addNote(title: title, content: content)
                    }
                    dismiss()
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel = NotesViewModel()
    @State private var showAddNote: Bool = false
    @State private var selectedNote: Note?
    
    var body: some View {

        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                        HStack {
                            if note.isCompleted {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                Text(note.title).bold().strikethrough()
                            } else {
                                Text(note.title).bold()
                            }
                        }
                        Text(note.content)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2) // Show up to 2 lines of content
                    }
                }
                .onDelete(perform: viewModel.deleteNote)
            }
            .navigationTitle("Notes")
            .toolbar {
                Button(action: {
                    selectedNote = nil
                    showAddNote = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddNote) {
                AddEditNoteView(viewModel: viewModel, note: selectedNote)
            }
        }
        .navigationTitle(Text("Notes"))
    }
}

#Preview {
    ContentView()
}
