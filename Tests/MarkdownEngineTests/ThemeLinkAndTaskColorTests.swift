//
//  ThemeLinkAndTaskColorTests.swift
//  MarkdownEngineTests
//
//  Finished links and checked task boxes take the embedder's theme colors.
//  `NSTextView` draws `.link` runs with its own `linkTextAttributes`, so the
//  theme's `link` color only shows when those attributes come from the theme.
//

import AppKit
import Testing
@testable import MarkdownEngine

@MainActor
struct ThemeLinkAndTaskColorTests {

    @Test func linkAttributesUseTheThemeLinkColor() throws {
        var theme = MarkdownEditorTheme.default
        theme.link = .systemOrange

        let attributes = theme.linkTextAttributes
        let color = try #require(attributes[.foregroundColor] as? NSColor)
        #expect(color == .systemOrange)
        #expect(attributes[.underlineStyle] as? Int == NSUnderlineStyle.single.rawValue)
        #expect(attributes[.cursor] as? NSCursor == .pointingHand)
    }

    @Test func checkedTaskUsesBodyTextUnlessThemed() {
        var theme = MarkdownEditorTheme.default
        #expect(theme.taskCheckboxColor(isChecked: true) == theme.bodyText)

        theme.checkedTaskCheckbox = .systemOrange
        #expect(theme.taskCheckboxColor(isChecked: true) == .systemOrange)
    }

    @Test func uncheckedTaskUsesMutedText() {
        var theme = MarkdownEditorTheme.default
        theme.checkedTaskCheckbox = .systemOrange
        #expect(theme.taskCheckboxColor(isChecked: false) == theme.mutedText)
    }
}
