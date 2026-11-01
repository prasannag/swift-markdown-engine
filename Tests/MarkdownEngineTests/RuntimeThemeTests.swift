//
//  RuntimeThemeTests.swift
//  MarkdownEngineTests
//
//  An embedder that changes the theme while a document is open (for example
//  from a colour setting) sees the open text redrawn in the new colours,
//  without the editor being rebuilt.
//

import AppKit
import SwiftUI
import Testing
@testable import MarkdownEngine

@MainActor
@Suite("Runtime theme changes")
struct RuntimeThemeTests {

    private static let text = "plain [link](https://example.com) tail"

    private func makeEditor() -> (NativeTextViewCoordinator, NativeTextView) {
        _ = NSApplication.shared
        let coordinator = NativeTextViewCoordinator(
            text: .constant(Self.text), fontName: "SF Pro", fontSize: 16,
            isWikiLinkActive: .constant(false), onLinkClick: nil, onInlineSelectionChange: nil
        )
        let tv = NativeTextView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        tv.isEditable = true
        tv.delegate = coordinator
        coordinator.textView = tv
        coordinator.rebuildTextStorageAndStyle(tv, from: Self.text)
        coordinator.lastSyncedText = Self.text
        coordinator.lastComputedStorage = Self.text
        coordinator.previousDisplayLength = (Self.text as NSString).length
        return (coordinator, tv)
    }

    private func recoloredTheme() -> MarkdownEditorTheme {
        var theme = MarkdownEditorTheme.default
        theme.bodyText = .systemRed
        theme.link = .systemOrange
        theme.checkedTaskCheckbox = .systemGreen
        return theme
    }

    @Test("a changed theme restyles the open text and its links")
    func changedThemeRestylesOpenText() throws {
        let (coordinator, tv) = makeEditor()
        let theme = recoloredTheme()

        #expect(coordinator.applyTheme(theme, to: tv))

        let storage = try #require(tv.textStorage)
        #expect(storage.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor == .systemRed)
        #expect(tv.linkTextAttributes?[.foregroundColor] as? NSColor == .systemOrange)
        #expect(coordinator.configuration.theme == theme)
        #expect(tv.configuration.theme == theme)
    }

    @Test("the same theme again leaves the text alone")
    func unchangedThemeIsIgnored() {
        let (coordinator, tv) = makeEditor()

        #expect(coordinator.applyTheme(coordinator.configuration.theme, to: tv) == false)

        let theme = recoloredTheme()
        coordinator.applyTheme(theme, to: tv)
        #expect(coordinator.applyTheme(theme, to: tv) == false)
    }
}
