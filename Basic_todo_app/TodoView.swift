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
            
            TextField("Search todos...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            

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
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    TextField("Enter title", text: $title)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    TextField("Description", text: $titleBody)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button {
                        vm.addTodo(title: title, body: titleBody)
                        title = ""
                        titleBody = ""
                        vm.fetchTodo()
                    } label: {
                        Label("Add Todo", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(title.isEmpty || titleBody.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(radius: 2)
                TextField("🔍 Search todos...", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                Picker("Filter", selection: $filter) {
                    Text("All").tag(Filtering.all)
                    Text("Completed").tag(Filtering.complete)
                    Text("Incomplete").tag(Filtering.incomplete)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                List {
                    ForEach(filteredTodos) { todo in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(todo.title)
                                    .font(.headline)
                                    .foregroundColor(todo.isCompleted ? .gray : .primary)
                                    .strikethrough(todo.isCompleted, color: .gray)
                                
                                Spacer()
                                
                                Button {
                                    vm.toggleTodo(todo)
                                } label: {
                                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundColor(todo.isCompleted ? .green : .gray)
                                }
                                .buttonStyle(.borderless)
                                
                                Button {
                                    editingTodo = todo
                                    editTitle = todo.title
                                    editBody = todo.body
                                    showingEditSheet = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.title3)
                                }
                                .buttonStyle(.borderless)
                            }
                            
                            if !todo.body.isEmpty {
                                Text(todo.body)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
>>>>>>> Stashed changes
                        }
                        .padding(8)
                    }
                    .onDelete { indexSet in
                        indexSet.map { filteredTodos[$0] }.forEach(vm.deleteTodo)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .padding()
        .onAppear {
            vm.fetchTodo()
            .navigationTitle("My Todos ✅")
            .onAppear {
                vm.fetchTodo()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )

            .sheet(isPresented: $showingEditSheet) {
                if let todo = editingTodo {
                    VStack(spacing: 20) {
                        Text("Edit Todo")
                            .font(.title2)
                            .bold()
                        
                        TextField("Title", text: $editTitle)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        TextField("Description", text: $editBody)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
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
}

#Preview {
    TodoView(context: PersistenceController.shared.container.viewContext)
}
