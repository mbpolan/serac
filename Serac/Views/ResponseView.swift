//
//  ResponseView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct ResponseView: View {
    @ObservedObject var response: Response
    @StateObject private var viewModel: ResponseViewModel = ResponseViewModel()
    
    var body: some View {
        VStack {
            if response.valid {
                ResponseMetricsView(response: response)
                
                TabView(selection: $viewModel.tab) {
                    ResponseBodyView(response: response)
                        .tabItem { Text("Body") }
                        .tag(ResponseViewModel.Tab.body)
                    
                    HeadersView(message: response,
                                editable: false)
                        .tabItem { Text("Headers") }
                        .tag(ResponseViewModel.Tab.headers)
                }
            } else {
                Text("Nothing to see here")
                    .foregroundColor(.secondary)
                    .centered(.both)
                    .padding(15)
            }
        }
    }
}

struct ResponseMetricsView: View {
    @ObservedObject var response: Response
    
    var body: some View {
        HStack {
            Group {
                Image(systemName: image)
                Text(statusCode)
                Text(NSLocalizedString("HTTPStatusCode_\(response.statusCode ?? 0)", comment: ""))
            }
            .foregroundColor(color)
            
            Spacer()
            
            Text(duration)
        }
        .padding([.leading, .trailing], 5)
    }
    
    private var statusCode: String {
        guard let statusCode = response.statusCode else {
            return ""
        }
        
        return String(statusCode)
    }
    
    private var duration: String {
        let delta = response.endTime.timeIntervalSince(response.startTime) * 1000
        return String(format: "%.2f ms", delta)
    }
    
    private var color: Color {
        switch response.statusCode ?? 0 {
        case 100...199:
            return .primary
        case 200...299:
            return .green
        case 300...399:
            return .yellow
        case 400...499:
            return .orange
        case 500...599:
            return .red
        default:
            return .primary
        }
    }
    
    private var image: String {
        switch response.statusCode ?? 0 {
        case 100...199:
            return "circle.fill"
        case 200...299:
            return  "checkmark.circle.fill"
        case 300...399:
            return  "arrowleft.arrowright.circle.fill"
        case 400...499:
            return "exclamationmark.circle.fill"
        case 500...599:
            return "x.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
}

class ResponseViewModel: ObservableObject {
    @Published var tab: Tab = .body
    
    enum Tab {
        case body
        case headers
    }
}

// MARK: - Preview

struct ResponseView_Preview: PreviewProvider {
    @State static var response: Response = Response()

    static var previews: some View {
        ResponseView(response: response)
    }
}
