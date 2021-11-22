//
//  FormDataRequestBodyView.swift
//  Serac
//
//  Created by Mike Polan on 11/20/21.
//

import SwiftUI

// MARK: - View

struct FormDataRequestBodyView: View {
    @AppStorage("activeVariableSet") var activeVariableSet: String?
    @AppStorage("variableSets") var variableSets: [VariableSet] = []
    @ObservedObject var request: Request
    @StateObject private var viewModel: FormDataRequestBodyViewModel = FormDataRequestBodyViewModel()
    
    var body: some View {
        ScrollView {
            KeyValueTableView(
                data: $viewModel.formData,
                labels: ["Key", "Value"],
                editable: true,
                formatter: formatter,
                persistAppState: false,
                onChange: handleChange)
                .padding([.leading, .trailing], 10)
        }
        .onAppear(perform: updateModel)
        .onChange(of: viewModel.formData, perform: updateRequest)
    }
    
    private var variables: VariableSet? {
        variableSets.first(where: { $0.id == activeVariableSet ?? "" })
    }
    
    private var formatter: TextFormatter {
        TextFormatter(adaptors: [
            VariableFormatAdaptor(variables: variables)
        ])
    }
    
    private func updateModel() {
        viewModel.formData = request.body.components(separatedBy: "&").map { item in
            let pair = item.components(separatedBy: "=")
            
            return KeyValuePair(
                pair.first?.removingPercentEncoding ?? pair.first ?? "",
                pair.last?.removingPercentEncoding ?? pair.last ?? "")
        }
    }
    
    private func updateRequest(_ formData: [KeyValuePair]) {
        request.body = formData.map { pair in
            let key = pair.key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? pair.key
            let value = pair.value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? pair.value
            
            return "\(key)=\(value)"
        }.joined(separator: "&")
    }
    
    private func handleChange() {
        updateRequest(viewModel.formData)
    }
}

// MARK: - View Model

class FormDataRequestBodyViewModel: ObservableObject {
    @Published var formData: [KeyValuePair] = []
}

// MARK: - Preview

struct FormDataRequestBodyView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        request.body = "foo=bar&bing=baz"
        return FormDataRequestBodyView(request: request)
            .frame(width: 500, height: 300)
    }
}
