import Vapor
import HTTP

class Customer: NodeRepresentable {
    
    var id :Int!
    var firstName :String!
    var lastName :String!
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node :["id":self.id,"firstName":self.firstName,"lastName":self.lastName])
    }
}

let drop = Droplet()

drop.get("hello") { request in
    
    return try JSON(node :["message":"Hello, world!"])
}

//JSON
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

//nesting localhost:8080/foo/bar
drop.get("foo","bar") {request in
    return "foo bar"
}

//errors
drop.get("404") {request in
    throw Abort.notFound
}

drop.get("error") {request in
    throw Abort.custom(status: .badRequest, message: "Sorry!")
}

//redirect
drop.get("vapor") {request in
    return Response(redirect: "https://vapor.codes")
}

//parameters

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



drop.run()
