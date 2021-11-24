//
//  ActiveVariableSet.swift
//  Serac
//
//  Created by Mike Polan on 11/21/21.
//

import Combine
import SwiftUI

// MARK: - Property Wrapper

@propertyWrapper
struct ActiveVariableSet: DynamicProperty {
    @ObservedObject private var model = ActiveVariableSetModel()
    private var cancelables: Set<AnyCancellable> = Set()
    
    init() {
        UserDefaults.standard.publisher(for: \.activeVariableSet)
            .assign(to: \ActiveVariableSetModel.activeVariableSetID, on: model)
            .store(in: &cancelables)
        
        UserDefaults.standard.publisher(for: \.variableSets)
            .assign(to: \ActiveVariableSetModel.rawVariableSets, on: model)
            .store(in: &cancelables)
        
        model.rawVariableSets = UserDefaults.standard.variableSets
    }
    
    var wrappedValue: VariableSet? {
        return model.variableSets.first(where: { $0.id == model.activeVariableSetID })
    }
}

// MARK: - Model

class ActiveVariableSetModel: ObservableObject {
    @Published var variableSets: [VariableSet] = []
    @Published var activeVariableSetID: String?
    
    @Published var rawVariableSets: String? {
        didSet {
            // when a variable set is updated, refresh the model with the latest data
            guard let rawVariableSets = rawVariableSets?.data(using: .utf8),
                  let newVariableSets = try? JSONDecoder().decode([VariableSet].self, from: rawVariableSets) else {
                      variableSets = []
                      return
                  }
            
            variableSets = newVariableSets
        }
    }
}

// MARK: - Extensions

extension UserDefaults {
    @objc var activeVariableSet: String? {
        get {
            return string(forKey: "activeVariableSet")
        }
        set {
            set(newValue, forKey: "activeVariableSet")
        }
    }
    
    @objc var variableSets: String? {
        get {
            string(forKey: "variableSets")
        }
        set {
            set(newValue, forKey: "variableSets")
        }
    }
}
