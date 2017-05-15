//
//  TaskViewController.swift
//  ToDoApp
//
//  Created by Hayden Goldman on 5/12/17.
//
//

import Vapor
import HTTP
import Foundation

class Task: StringInitializable {
    
    var name :String!

    required init?(from string: String) throws {
        self.name = string
    }
    
    
}

final class TaskViewController {
    
    
    
    func addRoutes(drop :Droplet) {
        
        drop.get("tasks","all",handler :getAllTasks)
        drop.get("tasks",Int.self,handler :getById)
        
    }
    
    func getAllTasks(req :Request) -> ResponseRepresentable {
        return "Get All Tasks"
    }
    
    func getById(req :Request, taskId :Int) -> ResponseRepresentable {
        return "Task Id is \(taskId)"
    }
    
    //RESTFUL route 
    
    func index(_ req :Request) throws -> ResponseRepresentable {
        
        return "Index"
    }
    
    func show(_ req: Request, task :Task) throws -> ResponseRepresentable {
        return "Shows"
    }
    
    
    
}

//RESTFUL Controller 

extension TaskViewController : ResourceRepresentable {

    typealias Model = Task

    
    func makeResource() -> Resource<Model> {
        return Resource (
            index :index,
            show :show
        )
    }

    
}


    
