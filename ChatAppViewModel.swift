
import Foundation
import Combine

class ChatAppViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var userInput: String = ""
    @Published var isLoading: Bool = false

    private var apiKey: String {
        guard let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            fatalError("API Key not found in configuration")
        }
        return apiKey
    }

    func sendMessage() {
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        addMessage(sender: "You", content: trimmedInput)
        fetchResponse(from: trimmedInput)
        userInput = ""
    }

    private func fetchResponse(from input: String) {
        isLoading = true

        // Prepare the request to OpenAI API
        let url = URL(string: "https://api.openai.com/v1/engines/davinci/completions")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let body: [String: Any] = ["prompt": input, "max_tokens": 150]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        // Perform the network request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let data = data, let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responses = responseDict["choices"] as? [[String: Any]],
                   let firstResponse = responses.first,
                   let text = firstResponse["text"] as? String {
                    self?.addMessage(sender: "GPT", content: text)
                } else {
                    // Handle error or no data scenario
                    self?.addMessage(sender: "GPT", content: "Sorry, I couldn't fetch a response.")
                }
            }
        }.resume()
    }

    private func addMessage(sender: String, content: String) {
        let message = ChatMessage(sender: sender, content: content)
        DispatchQueue.main.async {
            self.messages.append(message)
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: String
    let content: String
}
