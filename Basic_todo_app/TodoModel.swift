//
//  TodoModel.swift
//  Basic_todo_app
//
//  Created by Waseem Abbas on 01/10/2025.
//

import Foundation
import CoreData

struct TodoModel : Identifiable  {
    let id : UUID
    var title : String
    var body : String
    var isCompleted : Bool
    init(id: UUID = UUID(), title: String, body: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.body = body
        self.isCompleted = isCompleted
    }
}

extension TodoModel {
    init (entity : TodoEntity ) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.body = entity.body ?? ""
        self.isCompleted = entity.isCompleted
    }
}
extension TodoEntity {
    func update (model : TodoModel , context : NSManagedObjectContext) {
        self.id = model.id
        self.title = model.title
        self.body = model.body
        self.isCompleted = model.isCompleted
    }
}
