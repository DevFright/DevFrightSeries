//
//  ContentView.swift
//  Note Taking GPT
//
//  Created by Matthew Newill on 22/07/2023.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var apiKey = ""

    
    var body: some View {
        NavigationView {
            VStack {
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .padding()
            }
            .padding()
            .navigationTitle("My Notes")
        }
    }
    
    struct APIResponse: Decodable {
        let id: String?
        let object: String
        let created: Int
        let model: String
        let choices: [Choice]
        let usage: Usage
    }

    struct Usage: Decodable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }

    struct APIRequest: Encodable {
        let model: Model
        let messages: [Message]
    }

    struct Choice: Decodable {
        let index: Int
        let message: Message
        let finish_reason: String
    }

    struct Message: Codable {
        let role: Role
        let content: String
    }

    enum Role: String, Codable {
        case system
        case user
        case assistant
        case function
    }

    enum Model: String, Codable {
        case gpt_3_5_turbo = "gpt-3.5-turbo"
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
