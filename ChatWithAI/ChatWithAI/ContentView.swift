//
//  ContentView.swift
//  ChatWithAI
//
//  Created by Vishal Manhas on 17/07/24.
//

import SwiftUI
import GoogleGenerativeAI

struct ContentView: View {
    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.defaultKey)
    
    @State var userPrompt: String = ""
    @State var messages: [(String, LocalizedStringKey)] = [("Bot", "How can I help you today?")]
    @State var isLoading = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Welcome To Gemini")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.indigo)
                    .padding(.top, 20)
                
                Spacer()
                
                if messages.contains(where: { $0.0 == "User" }){
                    Button(action: {
                        clearChat()
                    }) {
                        Text("Clear Chat")
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(10)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.horizontal, 16)
            
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(messages.indices, id: \.self) { index in
                                let message = messages[index]
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(message.0 == "User" ? "You:" : "Bot:")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(message.1)
                                        .font(.callout)
                                        .padding(10)
                                        .background(message.0 == "User" ? Color.blue.opacity(0.2) : Color.indigo.opacity(0.2))
                                        .cornerRadius(10)
                                        .frame(maxWidth: .infinity, alignment: message.0 == "User" ? .trailing : .leading)
                                }
                                .id(index)
                            }
                        }
                        .padding()
                        .onChange(of: messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo(messages.count - 1, anchor: .bottom) // Scroll to the latest message
                            }
                        }
                    }
                }
                
                if isLoading {
                    HStack(spacing: 10) {
                        Text("Typing")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 8, height: 8)
                            .foregroundColor(.gray)
                            .animation(Animation.easeInOut(duration: 0.5).repeatForever())
                        
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 8, height: 8)
                            .foregroundColor(.gray)
                            .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.2))
                        
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 8, height: 8)
                            .foregroundColor(.gray)
                            .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.4))
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                }        
            }
        }
        .padding()
        
        HStack {
            TextField("Ask Anything...", text: $userPrompt)
                .padding()
                .background(Color.indigo.opacity(0.2))
                .cornerRadius(10)
                .disableAutocorrection(true)
                .font(.title2)
                .lineLimit(5)
            
            Button(action: {
                sendMessage()
            }) {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(10)
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .padding(.trailing, 16)
        }
        .padding()

    }
    
    
    
    func sendMessage() {
        guard !userPrompt.isEmpty else { return }
        
        messages.append(("User", LocalizedStringKey(userPrompt)))
        isLoading = true
        let prompt = userPrompt
        userPrompt = ""
        
        Task {
            do {
                let result = try await model.generateContent(prompt)
                isLoading = false
                let responseText = result.text ?? "No response"
                messages.append(("Bot", LocalizedStringKey(responseText)))
            } catch {
                isLoading = false
                messages.append(("Bot", "Something went wrong: \(error.localizedDescription)"))
            }
        }
    }
    
    func clearChat() {
        messages = [("Bot", "How can I help you today?")]
    }
}

#Preview {
    ContentView()
}
