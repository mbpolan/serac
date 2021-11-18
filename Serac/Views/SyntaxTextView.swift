//
//  SyntaxTextView.swift
//  Serac
//
//  Created by Mike Polan on 10/2/21.
//

import Combine
import SwiftUI

// based on: https://gist.github.com/unnamedd/6e8c3fbc806b8deb60fa65d6b9affab0

struct SyntaxTextView: NSViewRepresentable {
    @AppStorage("activeVariableSet") var activeVariableSet: String?
    @AppStorage("variableSets") var variableSets: [VariableSet] = []
    @Binding var text: String
    @Binding var adaptor: SyntaxAdaptor
    var isEditable: Bool = true
    var observeVariables: Bool = true
    
    var onEditingChanged: () -> Void       = {}
    var onCommit        : () -> Void       = {}
    var onTextChange    : (String) -> Void = { _ in }
    
    init(string: Binding<String>,
         isEditable: Bool,
         adaptor: Binding<SyntaxAdaptor>,
         observeVariables: Bool,
         onCommit: @escaping() -> Void = {}) {
        
        self._text = string
        self.isEditable = isEditable
        self._adaptor = adaptor
        self.observeVariables = observeVariables
        self.onCommit = onCommit
    }
    
    init(data: Binding<Data>,
         isEditable: Bool,
         adaptor: Binding<SyntaxAdaptor>,
         observeVariables: Bool) {
        
        self._text = Binding<String>(
            get: { String(decoding: data.wrappedValue, as: UTF8.self) },
            set: { value in
                if let updated = value.data(using: .utf8) {
                    data.wrappedValue = updated
                } else {
                    data.wrappedValue = Data()
                }
            }
        )
        self.isEditable = isEditable
        self._adaptor = adaptor
        self.observeVariables = observeVariables
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(
            text: text,
            isEditable: isEditable,
            adaptor: adaptor,
            variables: variables
        )
        
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateNSView(_ view: CustomTextView, context: Context) {
        // for uneditable views, only update the text on the view if it has changed. this
        // method can get called for a variety of reasons, and to avoid unnecessary updates
        // to the text view, we can check if the contents of the text have changed. rendering
        // large text (unchanging) content is expensive, so we need to avoid it as much as possible.
        if isEditable || text != view.text || view.variables?.id != activeVariableSet {
            view.text = text
            view.variables = variables
        }
        
        view.selectedRanges = context.coordinator.selectedRanges
        view.adaptor = adaptor
    }
    
    private var variables: VariableSet? {
        if observeVariables {
            return variableSets.first(where: { $0.id == activeVariableSet ?? "" }) ?? .empty
        }
        
        return nil
    }
}

// MARK: - Preview

struct SyntaxTextView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SyntaxTextView(
                string: .constant("{ \"foo\": 123}"),
                isEditable: true,
                adaptor: .constant(JSONSyntaxAdaptor()),
                observeVariables: false)
        }
    }
}

// MARK: - Coordinator

extension SyntaxTextView {
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: SyntaxTextView
        var selectedRanges: [NSValue] = []
        
        init(_ parent: SyntaxTextView) {
            self.parent = parent
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onEditingChanged()
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onCommit()
        }
    }
}

// MARK: - CustomTextView

final class CustomTextView: NSView {
    private var isEditable: Bool
    weak var delegate: NSTextViewDelegate?
    
    var text: String {
        didSet {
            updateTextStorage(text)
        }
    }
    
    var adaptor: SyntaxAdaptor {
        didSet {
            guard type(of: adaptor) != type(of: self.adaptor) else {
                return
            }
            
            textView.textStorage?.setAttributedString(adaptor.decorate(text, variables: variables))
        }
    }
    
    var variables: VariableSet? {
        didSet {
            updateTextStorage(text)
        }
    }
    
    var selectedRanges: [NSValue] = [] {
        didSet {
            guard selectedRanges.count > 0 else {
                return
            }
            
            textView.selectedRanges = selectedRanges
        }
    }
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        layoutManager.addTextContainer(textContainer)
        
        let textView = CustomNSTextView(frame: .zero,
                                        textContainer: textContainer,
                                        adaptor: adaptor)
        
        textView.autoresizingMask = .width
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.delegate = self.delegate
        textView.drawsBackground = true
        textView.isEditable = self.isEditable
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.isContinuousSpellCheckingEnabled = false
        textView.isAutomaticTextCompletionEnabled = false
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude,
                                  height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0,
                                  height: contentSize.height)
        textView.allowsUndo = true
        
        return textView
    }()
    
    init(text: String, isEditable: Bool, adaptor: SyntaxAdaptor, variables: VariableSet?) {
        self.isEditable = isEditable
        self.text = text
        self.adaptor = adaptor
        self.variables = variables
        
        super.init(frame: .zero)
        
        // for uneditable text views, force an initial update of the underlying
        // text storage
        if !isEditable {
            updateTextStorage(text)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDraw() {
        super.viewWillDraw()
        
        setupScrollViewConstraints()
        setupTextView()
    }
    
    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setupTextView() {
        scrollView.documentView = textView
    }
    
    private func updateTextStorage(_ text: String) {
        textView.textStorage?.setAttributedString(adaptor.decorate(text, variables: variables))
    }
}

final class CustomNSTextView: NSTextView {
    
    private var adaptor: SyntaxAdaptor
    
    init(frame frameRect: NSRect,
         textContainer container: NSTextContainer?,
         adaptor: SyntaxAdaptor) {
        
        self.adaptor = adaptor
        super.init(frame: frameRect, textContainer: container)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func insertText(_ string: Any, replacementRange: NSRange) {
        if let string = string as? String {
            super.insertText(adaptor.update(string: string), replacementRange: replacementRange)
        } else {
            super.insertText(string, replacementRange: replacementRange)
        }
    }
}
