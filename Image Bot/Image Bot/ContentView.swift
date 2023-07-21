import SwiftUI
import Combine

struct ContentView: View {
    @State private var prompt: String = ""
    @State private var apiKey: String = ""
    @State private var errorText: String? = ""
    @State private var results: [String] = []
    @State private var cancellable: AnyCancellable? = nil
    @State private var selectedImageSize = ImageSizeOption.small
    @State private var selectedNumberOfImagesValue = 1
    
    var body: some View {
        VStack {
            TextField("API Key", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .padding()
            TextField("Enter Image Prompt", text: $prompt)
                .textFieldStyle(.roundedBorder)
                .padding()
            Picker(selection: $selectedImageSize, label: Text("Image Size")) {
                ForEach(ImageSizeOption.allCases, id: \.self) { sizeOption in
                    Text(sizeOption.rawValue).tag(sizeOption)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            Picker(selection: $selectedNumberOfImagesValue, label: Text("Picker")) {
                ForEach(1...10, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            Button(action: {
                submit()
            }) {
                Image(systemName: "paperplane")
                    .font(.title)
            }
            .padding()
            
            Spacer()
            ScrollView {
                let columnsCount = selectedNumberOfImagesValue < 3 ? selectedNumberOfImagesValue : 3
                let columns: [GridItem] = Array(repeating: .init(.flexible()), count: columnsCount)
                LazyVGrid(columns: columns) {
                    ForEach(results, id: \.self) { imageUrlString in
                        if let imageUrl = URL(string: imageUrlString) {
                            AsyncImage(url: imageUrl, scale: 1.0) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func submit() {
        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let payload = APIRequest(prompt: prompt,
                                     n: selectedNumberOfImagesValue,
                                     size: selectedImageSize)
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
                        errorText = "Error: \(error.localizedDescription)"
                    case .finished:
                        break
                    }
                },
                receiveValue: { response in
                    results = response.data.compactMap { $0.url }
                    prompt = ""
                }
            )
    }
    
    struct APIResponse: Decodable {
        let created: Date
        let data: [Data]
    }

    struct Data: Decodable {
        let url: String?
        let b64_json: String?
    }

    struct APIRequest: Encodable {
        let prompt: String
        let n: Int
        let size: ImageSizeOption
    }

    enum ImageSizeOption: String, CaseIterable, Identifiable, Codable {
        case small = "256x256"
        case medium = "512x512"
        case large = "1024x1024"
        
        var id: ImageSizeOption { self }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDisplayName("Image Preview")
    }
}
