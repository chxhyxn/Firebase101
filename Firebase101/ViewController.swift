//
//  ViewController.swift
//  Firebase101
//
//  Created by chxhyxn on 2022/07/07.
//

import UIKit
import FirebaseDatabase
import SwiftUI

class ViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var numberOfCustomers: UILabel!
    
    let db = Database.database().reference()
    
    var customers: [Customer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabel()
        saveBasicTypes()
//        updateBasicData()
//        deleteBasicData()
        fetchCustomers()
    }
    @IBAction func createCustomer(_ sender: Any) {
        saveCustomers()

    }
    @IBAction func readCustomer(_ sender: Any) {
        fetchCustomers()
    }
    
    @IBAction func updateCustomer(_ sender: Any) {
        updateCustomer()
    }
    
    func updateCustomer() {
        guard customers.isEmpty == false else{ return }
        customers[0].name = "James"
        
        let dict = customers.map({$0.toDictionary})
        db.updateChildValues(["customers": dict])
    }
    
    @IBAction func deleteCustomer(_ sender: Any) {
        deleteCustomer()
    }
    
    func deleteCustomer() {
        db.child("customers").removeValue()
    }
    
    func updateLabel() {
        db.child("firstData").observeSingleEvent(of: .value, with: { snapshot in
            print("--->\(snapshot)")
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.dataLabel.text = value
            }
        })
    }
}

extension ViewController {
    func saveBasicTypes() {
        db.child("int").setValue(3)
        db.child("double").setValue(3.3)
        db.child("str").setValue("string value --> Hello")
        db.child("array").setValue(["a", "b", "c"])
        db.child("dict").setValue(["id":"aa11", "age": 22, "city": "seoul"])
    }

    func saveCustomers() {
        let books = [Book(title: "book name A", author: "Sean Cho"), Book(title: "book name B", author: "Sean Cho")]
        let customer1 = Customer(id: "\(Customer.id)", name: "Jack", books: books)
        Customer.id += 1
        let customer2 = Customer(id: "\(Customer.id)", name: "Jason", books: books)
        Customer.id += 1
        let customer3 = Customer(id: "\(Customer.id)", name: "John", books: books)
        Customer.id += 1
        
        db.child("customers").child(customer1.id).setValue(customer1.toDictionary)
        db.child("customers").child(customer2.id).setValue(customer2.toDictionary)
        db.child("customers").child(customer3.id).setValue(customer3.toDictionary)
        
    }
}

extension ViewController {
    func fetchCustomers() {
        db.child("customers").observeSingleEvent(of: .value, with: { snapshot in
            print("---> \(snapshot.value)")
            do {
                let data = try JSONSerialization.data(withJSONObject: snapshot.value, options: [])
                
                let decoder = JSONDecoder()
                let customers: [Customer] = try decoder.decode([Customer].self, from: data)
                self.customers = customers
                
                print("---> customers: \(customers.count)")
                
                DispatchQueue.main.async {
                    self.numberOfCustomers.text = "# of Customers: \(customers.count)"

                }
            }catch let error{
                print("---> error: \(error.localizedDescription)")
            }
        })
    }
}

extension ViewController {
    func updateBasicData() {
        db.updateChildValues(["int": 4])
        db.updateChildValues(["double": 4.4])
        db.updateChildValues(["str": "updated Hello"])
    }
    
    func deleteBasicData() {
        db.child("int").removeValue()
        db.child("double").removeValue()
        db.child("str").removeValue()
    }
}

struct Customer: Codable {
    let id: String
    var name: String
    let books: [Book]
    
    var toDictionary: [String: Any] {
        let booksArray = books.map({
            $0.toDictionary
        })
        let dict: [String: Any] = ["id": id, "name": name, "books": booksArray]
        return dict
    }
    
    static var id: Int = 0
}

struct Book: Codable {
    let title: String
    let author: String
    
    var toDictionary: [String: Any] {
        let dict = ["title": title, "author": author]
        return dict
    }
}
