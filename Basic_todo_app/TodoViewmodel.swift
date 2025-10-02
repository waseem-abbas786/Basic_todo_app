//
//  TodoViewmodel.swift
//  Basic_todo_app
//
//  Created by Waseem Abbas on 01/10/2025.
//

import Foundation
import CoreData

class TodoViewmodel : ObservableObject {
    @Published var todos : [TodoModel] = []
    
    private let context : NSManagedObjectContext
    init (context : NSManagedObjectContext) {
        self.context = context
    }
    
    func addTodo (title : String , body : String) {
        let model = TodoModel(id: UUID(), title: title, body: body)
        let entity = TodoEntity(context: context)
        entity.update(model: model, context: context)
        saveContext()
        
    }
    func fetchTodo () {
        let request : NSFetchRequest <TodoEntity> = TodoEntity.fetchRequest()
        do {
        let entities = try context.fetch(request)
            self.todos = entities.map {TodoModel(entity: $0)}
        } catch  {
            
        }
    }
    func deleteTodo (_ todo : TodoModel) {
        let request : NSFetchRequest <TodoEntity> = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", todo.id as CVarArg)
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                saveContext()
                fetchTodo()
            }
        } catch  {
            
        }
    }
    func toggleTodo (_ todo : TodoModel) {
        let request : NSFetchRequest <TodoEntity> = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", todo.id as CVarArg)
        do {
            if let entity = try context.fetch(request).first {
                entity.isCompleted.toggle()
                saveContext()
                fetchTodo()
            }
        } catch  {
            
        }
    }
    func updateTodo(_ todo: TodoModel, newTitle: String, newBody: String) {
        let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", todo.id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                entity.title = newTitle
                entity.body = newBody
                try context.save()
                fetchTodo() // refresh todos array
            }
        } catch {
            print("❌ Failed to update todo: \(error)")
        }
    }

    func saveContext () {
        do {
            try context.save()
        } catch  {
            print("Unable to save the data")
        }
    }
}
