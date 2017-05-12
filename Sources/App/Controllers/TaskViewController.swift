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
    
    

    
}
