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
    @State private var cancellable: AnyCancellable? = nil
    @State private var messages: [Message] = []
    @State private var noteText = "My meeting notes..."
    @State private var prompt = ""
    @State private var resultText: String = "Result..."
    @State private var selectedPrompt: MeetingPrompt = .noPrompt
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                TextEditor(text: $noteText)
                    .padding(.all, 10.0)
                
                TextEditor(text: $resultText)
                    .padding(.all, 10.0)
                
                Picker("Select Prompt", selection: $selectedPrompt) {
                    ForEach(MeetingPrompt.allCases) { prompt in
                        Text(prompt.rawValue)
                            .tag(prompt)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.bottom, 30)
                
                HStack {
                    TextField("Custom Prompt...", text: $prompt)
                        .padding(.all, 10.0)
                    Button(action: {
                        submit()
                    }) {
                        Image(systemName: "paperplane")
                            .font(.title)
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("My Notes")
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

        messages.append(Message(role: .user, content: "\(selectedPrompt) \(prompt) \(noteText)"))

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
    
    enum MeetingPrompt: String, CaseIterable, Identifiable {
        case noPrompt = ""
        case meetingDateTime = "Please state the date and time of the meeting for the record."
        case attendees = "Kindly provide a list of all attendees present in the meeting."
        case agenda = "Could you outline the agenda topics discussed during the meeting?"
        case actionItems = "What are the action items identified during the meeting and who is responsible for each?"
        case deadlines = "Can you specify the deadlines for each action item?"
        case decisionsMade = "Please highlight any significant decisions or resolutions made during the meeting."
        case nextSteps = "What are the next steps or follow-up actions to be taken after the meeting?"
        case meetingObjectives = "What were the main objectives or goals of this meeting?"
        case challengesAndConcerns = "Were there any challenges or concerns raised during the meeting?"
        case upcomingMeetings = "Are there any upcoming meetings scheduled to continue the discussion on specific topics?"
        
        var id: String { self.rawValue }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
