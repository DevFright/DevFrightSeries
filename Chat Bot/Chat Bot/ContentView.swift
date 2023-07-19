// ContentView.swift
// Chat Bot
//
// Created by Matthew Newill on 14/07/2023.

import SwiftUI
import Combine

struct ContentView: View {
    @State private var prompt: String = ""
    @State private var apiKey: String = ""
    @State private var resultText: String = ""
    @State private var cancellable: AnyCancellable? = nil
    @State private var messages: [Message] = []

    var body: some View {
        VStack {
            TextField("API Key", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .padding()
            TextField("Enter Question", text: $prompt)
                .textFieldStyle(.roundedBorder)
                .padding()
            Button(action: {
                submit()
            }) {
                Image(systemName: "paperplane")
                    .font(.title)
            }
            .padding()
            Text(resultText)
                .padding()
        }
    }

    func submit() {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        messages.append(Message(role: .user, content: prompt))

        do {
            let payload = APIRequest(model: .gpt_3_5_turbo, messages: messages)
            let jsonData = try JSONEncoder().encode(payload)
            request.httpBody = jsonData
        } catch {
            print("Error: \(error)")
            return
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { $0.data }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        resultText = "Error: \(error.localizedDescription)"
                    case .finished:
                        break
                    }
                },
                receiveValue: { response in
                    resultText = response.choices.first?.message.content ?? "No response"
                    messages.append(Message(role: .system, content: resultText))
                    prompt = ""
                }
            )
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
