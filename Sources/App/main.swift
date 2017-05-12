import Vapor
import HTTP
import Foundation
import VaporSQLite

class Customer: NodeRepresentable {
    
    var customerId :Int!
    var firstName :String!
    var lastName :String!
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node :["id":self.customerId,"firstName":self.firstName,"lastName":self.lastName])
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
// post to create a new customer into the db
drop.post("customers","create") { request in
    guard let firstName = request.json?["firstName"]?.string,
        let lastName = request.json?["lastName"]?.string else {
            throw Abort.badRequest
    }
    
    let result = try drop.database?.driver.raw("INSERT INTO Customers(firstName,lastName) VALUES(?,?)",[firstName,lastName])
    
    return try JSON(node :result)
}
//fetching customers via api

drop.get("customers","all") { request in
    
    var customers = [Customer]()

    let result = try drop.database?.driver.raw("SELECT customerId,firstName,lastName FROM Customers;")
    
    guard let nodeArray = result?.nodeArray else {
        return try JSON(node :customers)
    }
    
    for node in nodeArray {
        let customer = Customer()
        customer.customerId = node["customerId"]?.int
        customer.firstName = node["firstName"]?.string
        customer.lastName = node["lastName"]?.string
        
        customers.append(customer)
    }
    
    return try JSON(node :customers)
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
    customer1.customerId = 1
    customer1.firstName = "Hayden"
    customer1.lastName = "Goldman"
    
    let customer2 = Customer()
    customer2.customerId = 2
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

//Mark: Validation

drop.post("register") { request in
    
    let email :Valid<Email> = try request.data["email"].validated()
    return "Valid \(email)"
}

drop.post("unique") {request in
    
    // a,b,c
    guard let inputCommaSeparated = request.data["input"]?.string else {
        throw Abort.badRequest
    }
    
    let unique :Valid<Unique<[String]>> = try inputCommaSeparated.components(separatedBy: ",").validated()
    return "Valid \(unique)"
}

drop.post("keys") { request in
    guard let keyCode = request.data["keyCode"]?.string else {
        throw Abort.badRequest
    }
    
    let key :Valid<Matches<String>> = try keyCode.validated(by :Matches("Secret"))
    
    return "Valid \(key)"
}

//Mark: Custom Validation


//password validation in a custom class so you can call it throughout the app

class PasswordValidator : ValidationSuite {
    
    static func validate(input value: String) throws {
        let evaluation = !OnlyAlphanumeric.self && Count.containedIn(low: 5, high: 12)
        
        try evaluation.validate(input: value)
    }
    
}



drop.post("register") { request in
    
    guard let inputPassword = request.data["password"]?.string else {
        throw Abort.badRequest
    }
    
    //not using a custonm class
//    let password = try inputPassword.validated(by : !OnlyAlphanumeric.self && Count.containedIn(low: 5, high: 12))
    
    //using custom class
    
    //isValid will return true is parameters are passed, false if not
    let isValid = inputPassword.passes(PasswordValidator.self)
    
    //isTested does the same as above but in a diffrent way. if not valid throws the error
//    let isTested = try inputPassword.tested(by: PasswordValidator.self)
    
    let password :Valid<PasswordValidator> = try inputPassword.validated()
    
    return "Valid \(password)"

}


//Mark: Basic Controller

let controller = TaskViewController()
controller.addRoutes(drop: drop)






drop.run()
