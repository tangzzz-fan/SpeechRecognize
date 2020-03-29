//
//  ContentView.swift
//  SearchBar
//
//  Created by tango on 2020/3/29.
//  Copyright © 2020 tangorios. All rights reserved.
//

import Speech
import SwiftUI
import WebKit

struct ButtonLabel: View {
    private let title: String
    private let background: Color
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.title)
                .bold()
                .foregroundColor(.white)
            Spacer()
        }.padding().background(background).cornerRadius(10)
    }
    
    init(_ title: String, background: Color) {
        self.title = title
        self.background = background
    }
}

struct ContentView: View {
    
    let names = ["Google Flutter", "Apple SwiftUI", "Facebook React", "Alibaba Ant Design", "Kobe", "Swift Coding Challenge", "Microsoft", "Adaptive Cards"]
    @State var recording: Bool = false
    @State var speech: String = ""

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $speech, placeholder: "Search")
                List {
                    ForEach(self.names.filter {
                        self.speech.isEmpty ? true : $0.lowercased().contains(self.speech.lowercased())
                    }, id: \.self) { name in
                        NavigationLink(destination: WebView(keyword:name)) {
                            Text(name)
                        }
                    }
                }
                
                Spacer()

                if recording {
                    Button(action: stopRecording) {
                        ButtonLabel("Stop Recording", background: .red)
                    }
                } else {
                    Button(action: startRecording) {
                        ButtonLabel("Start Recording", background: .blue)
                    }
                }
            }
            .navigationBarTitle(Text( "Search Bar"), displayMode: .inline)
        }
    }
    
    private let recognizer: SpeechRecognizer

    init() {
        guard let recognizer = SpeechRecognizer() else {
            fatalError("Something went wrong...")
        }
        self.recognizer = recognizer
    }
    
    private func startRecording() {
        self.recording = true
        self.speech = ""
        
        recognizer.startRecording { result in
            if let text = result {
                self.speech = text
            } else {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        self.recording = false
        recognizer.stopRecording()
    }
}

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

struct WebView: UIViewRepresentable {
    
    let keyword: String
    
    static let DefaultSearchEngine: String = "https://www.google.com"
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        
        var urlStr = "\(WebView.DefaultSearchEngine)/search?q=\(keyword)"
        
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? WebView.DefaultSearchEngine

        let request =  URLRequest(url: URL(string: urlStr)!)
        uiView.load(request)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
