
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatAppViewModel()

    var body: some View {
        NavigationView {
            ChatAppView(viewModel: viewModel)
                .navigationBarTitle("Chat with GPT", displayMode: .inline)
        }
    }
}

struct ChatAppView: View {
    @ObservedObject var viewModel: ChatAppViewModel

    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.messages) { message in
                    MessageView(message: message)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            MessageInputView(userInput: $viewModel.userInput, action: {
                viewModel.sendMessage()
            })
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}

struct MessageView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.sender == "You" { Spacer() }
            Text(message.content)
                .padding()
                .background(message.sender == "You" ? Color.blue : Color.gray)
                .cornerRadius(10)
            if message.sender == "GPT" { Spacer() }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MessageInputView: View {
    @Binding var userInput: String
    let action: () -> Void

    var body: some View {
        HStack {
            TextField("Type a message...", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: action) {
                Text("Send")
            }
            .disabled(userInput.isEmpty)
        }
    }
}
