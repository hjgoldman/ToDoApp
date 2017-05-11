import Vapor
import HTTP
import Foundation
import VaporSQLite

class Customer: NodeRepresentable {
    
    var id :Int!
    var firstName :String!
    var lastName :String!
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node :["id":self.id,"firstName":self.firstName,"lastName":self.lastName])
    }
}

let drop = Droplet()
//Mark: SQLite

try drop.addProvider(VaporSQLite.Provider.self)

//test to see if SQLite is set up correctly. This should return the version number for SQLite

drop.get("version") { request in
    let result = try drop.database?.driver.raw("SELECT sqlite_version()")
    return try JSON(node :result)
}



drop.get("hello") { request in
    
    return try JSON(node :["message":"Hello, world!"])
}

//Mark: JSON
drop.get("names") {request in
    return try JSON(node :["name":["John","Mary","Mike","Bill"]])
}

//Class that returns JSON
drop.get("customer") {request in
    
    let customer1 = Customer()
    customer1.id = 1
    customer1.firstName = "Hayden"
    customer1.lastName = "Goldman"
    
    let customer2 = Customer()
    customer2.id = 2
    customer2.firstName = "John"
    customer2.lastName = "Doe"
    
    return try JSON(node :[customer1,customer2])
}

//Mark: nesting localhost:8080/foo/bar
drop.get("foo","bar") {request in
    return "foo bar"
}

//Mark: errors
drop.get("404") {request in
    throw Abort.notFound
}

drop.get("error") {request in
    throw Abort.custom(status: .badRequest, message: "Sorry!")
}

//Mark: redirect
drop.get("vapor") {request in
    return Response(redirect: "https://vapor.codes")
}

//Mark: parameters

//drop.get("users",":id") {request in
//    guard let userId = request.parameters["id"]?.int else {
//        throw Abort.notFound
//    }
//
//    return "UserId is \(userId)"
//}

drop.get("users",Int.self) {request, userId in
    
    return "UserId is \(userId)"
}


//Mark: Grouping

//drop.group("tasks") { tasks in
// 
//    //tasks/all
//    tasks.get("all") {request in
//        return "All the tasks"
//    }
//}

let taskGroups = drop.grouped("tasks")

//tasks/all
taskGroups.get("all") { request in
    return "All the tasks"
}

//tasks/create
taskGroups.post("create") { request in
    return "New task"
}

//Mark: Post request

drop.post("users") { request in
   
    
    guard let firstName = request.json?["firstName"]?.string,
          let lastName = request.json?["lastName"]?.string
    else {
        throw Abort.badRequest
    }
    
    return firstName + " " + lastName
}


drop.run()
