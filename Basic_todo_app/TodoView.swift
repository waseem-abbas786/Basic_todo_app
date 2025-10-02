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
    }
}

#Preview {
    TodoView(context: PersistenceController.shared.container.viewContext)
}
