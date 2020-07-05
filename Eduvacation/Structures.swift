//
//  Structures.swift
//  Eduvacation
//
//  Created by Ashwin Rajesh on 7/3/20.
//  Copyright © 2020 AshwinR. All rights reserved.
//

import Foundation

var defString = String(stringLiteral: "")
var defInt = -1

struct Question: Codable {
    var answer: String?
    var question: String?
}

struct Cities: Codable {
    var cities: [City]?
}

struct City: Codable {
    var name: String?
    var lat: Float?
    var lng: Float?
    var pop: Int?
}

struct Result: Codable {
    var results: [Place]?
}

struct Place: Codable {
    var name: String?
    var userRatingsTotal: Int?
    var geometry: Geometry?
    var types: [String]?
}

struct Geometry: Codable {
    var location: Location?
    var viewport: Viewport?
}

struct Location: Codable {
    var lat: Float?
    var lng: Float?
}

struct Viewport: Codable {
    var southwest: Location?
    var northeast: Location?
}

struct UserData: Codable, CustomStringConvertible {
    var page: Int?
    var perPage: Int?
    var total: Int?
    var totalPages: Int?
    var data: [User]?
    
    var description: String {
        var desc = """
        page = \(page ?? defInt)
        records per page = \(perPage ?? defInt)
        total records = \(total ?? defInt)
        total pages = \(totalPages ?? defInt)
        Users:
        
        """
        if let users = data {
            for user in users {
                desc += user.description
            }
        }
        
        return desc
    }
}

struct Multiply: Codable {
    var result: Int?
}

struct BookData: Codable, CustomStringConvertible {
    var length: Int?
    var books: [Book]?
    
    var description: String {
        var desc = """
        Length = \(length ?? defInt)
        Books:
        
        """
        if let b = books {
            for book in b {
                desc += book.description
            }
        }
        
        return desc
    }
    
}

struct Book: Codable, CustomStringConvertible {
    var author: String?
    var firstSentence: String?
    var id: Int?
    var title: String?
    
    var description: String {
        return """
        ------------
        Author = \(author ?? defString)
        First Sentence = \(firstSentence ?? defString)
        Id = \(id ?? defInt)
        Title = \(title ?? defString)
        ------------
        """
    }
}


struct SingleUserData: Codable {
    var data: User?
}


struct User: Codable, CustomStringConvertible {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var avatar: String?
    
    var description: String {
        return """
        ------------
        id = \(id ?? defInt)
        firstName = \(firstName ?? defString)
        lastName = \(lastName ?? defString)
        avatar = \(avatar ?? defString)
        ------------
        """
    }
}


struct JobUser: Codable, CustomStringConvertible {
    var id: String?
    var name: String?
    var job: String?
    var createdAt: String?
    
    var description: String {
        return """
        id = \(id ?? defString)
        name = \(name ?? defString)
        job = \(job ?? defString)
        createdAt = \(createdAt ?? defString)
        """
    }
}
