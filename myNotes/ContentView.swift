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
            Text(note.title)
                .font(.largeTitle)
                .bold()
                .strikethrough(note.isCompleted)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(note.content)
                .font(.body).padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button(action: {viewModel.toggleCompletion(note: note)}) {
                Text(note.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                    .foregroundColor(.white)
                    .padding()
                    .background(note.isCompleted ? Color.red : Color.green)
                    .cornerRadius(5)
            }
            .padding(.bottom, 20)
            .shadow(radius: 5)
        }
        .padding()
        .navigationTitle("Note Details")
        .toolbar {
            Button(action: {
                showEditView = true
            }) {
                Image(systemName: "pencil")
            }
            .shadow(radius: 5)
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
            // Adding this so that the app automatically saves the notes when updated.
            UserDefaults.standard.set(data, forKey: "notes")
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
                        viewModel.saveNotes()
                    } else {
                        viewModel.addNote(title: title, content: content)
                        viewModel.saveNotes()
                    }
                    dismiss()
                }
                .shadow(radius: 5)
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
                            Image(systemName: note.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(note.isCompleted ? .green : .gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title)
                                    .font(.headline)
                                    .foregroundColor(note.isCompleted ? .secondary : .primary)
                                    .strikethrough(note.isCompleted)
                                
                                Text(note.content)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 8)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .onDelete(perform: viewModel.deleteNote)
            }
            .listStyle(.plain)
            .navigationTitle("Notes")
            .toolbar {
                Button(action: {
                    selectedNote = nil
                    showAddNote = true
                }) {
                    Image(systemName: "plus")
                }
                .shadow(radius: 3)
            }
            .sheet(isPresented: $showAddNote) {
                AddEditNoteView(viewModel: viewModel, note: selectedNote)
            }
        }
    }
}

#Preview {
    ContentView()
}
