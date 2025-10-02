import SwiftUI
import CoreData

enum Filtering {
    case all
    case complete
    case incomplete
}

struct TodoView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State private var searchText: String = ""
    @State private var filter: Filtering = .all
    @StateObject var vm: TodoViewmodel
    @State private var title: String = ""
    @State private var titleBody: String = ""
    
    // For editing
    @State private var editingTodo: TodoModel? = nil
    @State private var editTitle: String = ""
    @State private var editBody: String = ""
    @State private var showingEditSheet = false
    
    init(context: NSManagedObjectContext) {
        _vm = StateObject(wrappedValue: TodoViewmodel(context: context))
    }
    
    var filteredTodos: [TodoModel] {
        vm.todos.filter { todo in
            let matchesSearch = searchText.isEmpty ||
                                todo.title.localizedCaseInsensitiveContains(searchText) ||
                                todo.body.localizedCaseInsensitiveContains(searchText)
            
            switch filter {
            case .all:
                return matchesSearch
            case .complete:
                return matchesSearch && todo.isCompleted
            case .incomplete:
                return matchesSearch && !todo.isCompleted
            }
        }
    }
    
    var body: some View {
        VStack {
            // Add new todo
            TextField("Enter title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Description", text: $titleBody)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Add") {
                vm.addTodo(title: title, body: titleBody)
                title = ""
                titleBody = ""
                vm.fetchTodo()
            }
            .disabled(title.isEmpty || titleBody.isEmpty)
            .padding(.vertical)
            
            // Search
            TextField("Search todos...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Filter
            Picker("Filter", selection: $filter) {
                Text("All").tag(Filtering.all)
                Text("Completed").tag(Filtering.complete)
                Text("Incomplete").tag(Filtering.incomplete)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            List {
                ForEach(filteredTodos) { todo in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(todo.title)
                                .font(.headline)
                            Spacer()
                            Button {
                                vm.toggleTodo(todo)
                            } label: {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.isCompleted ? .green : .gray)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            // ✏️ Edit button
                            Button("Edit") {
                                editingTodo = todo
                                editTitle = todo.title   // preload
                                editBody = todo.body     // preload
                                showingEditSheet = true
                            }
                        }
                        Text(todo.body)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { filteredTodos[$0] }.forEach(vm.deleteTodo)
                }
            }

        }
        .padding()
        .onAppear {
            vm.fetchTodo()
        }
        .sheet(isPresented: $showingEditSheet) {
            if let todo = editingTodo {
                VStack(spacing: 20) {
                    Text("Edit Todo")
                        .font(.headline)
                    
                    TextField("Title", text: $editTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Description", text: $editBody)
                        .textFieldStyle(.roundedBorder)
                    
                    HStack {
                        Button("Cancel") {
                            showingEditSheet = false
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button("Save") {
                            vm.updateTodo(todo, newTitle: editTitle, newBody: editBody)
                            showingEditSheet = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    TodoView(context: PersistenceController.shared.container.viewContext)
}
