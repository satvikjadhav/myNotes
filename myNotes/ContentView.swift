//
//  ContentView.swift
//  myNotes
//
//  Created by Satvik  Jadhav on 2/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
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
            }
        }
    }
}

#Preview {
    ContentView()
}
