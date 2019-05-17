//
//  HMMarkupRenderer.swift
//  HMMarkup
//
//  Created by Philip Hayes on 11/14/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit.UIFont
public typealias Font = UIFont
#elseif os(OSX)
import AppKit.NSFont
public typealias Font = NSFont
#endif

public final class HMMarkupRenderer {
    struct Config {
        var baseLanguage:Int = 1 //0 renders the keys
        
    }
    static var translation:Dictionary<String, String>?
    
	private let baseFont: Font
	
	public init(baseFont: Font) {
		self.baseFont = baseFont
	}
	
	public func render(text: String) -> NSAttributedString {
		let elements = HMMarkupParser.parse(text: text)
		let attributes = [NSAttributedString.Key.font: baseFont]
		
		return elements.map { $0.render(withAttributes: attributes) }.joined()
	}
	public func render(text: String, template:Dictionary<String, String>) -> NSAttributedString {
		var text = text
		for (key, value) in template {
			text = text.replacingOccurrences(of: "{\(key)}", with: value)
		}
		return render(text: text)
	}
}

private extension HMMarkupNode {
	func render(withAttributes attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
		guard let currentFont = attributes[NSAttributedString.Key.font] as? Font else {
			fatalError("Missing font attribute in \(attributes)")
		}
		
		switch self {
		case .text(let text):
			return NSAttributedString(string: text, attributes: attributes)
			
		case .strong(let children):
			var newAttributes = attributes
			newAttributes[NSAttributedString.Key.font] = currentFont.boldFont()
			return children.map { $0.render(withAttributes: newAttributes) }.joined()
			
		case .emphasis(let children):
			var newAttributes = attributes
			newAttributes[NSAttributedString.Key.font] = currentFont.italicFont()
			return children.map { $0.render(withAttributes: newAttributes) }.joined()
			
		case .delete(let children):
			var newAttributes = attributes
			newAttributes[NSAttributedString.Key.strikethroughStyle] = NSUnderlineStyle.single.rawValue
			newAttributes[NSAttributedString.Key.baselineOffset] = 0
			return children.map { $0.render(withAttributes: newAttributes) }.joined()
		case .underline(let children):
			var newAttributes = attributes
			newAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
			newAttributes[NSAttributedString.Key.baselineOffset] = 0
			return children.map { $0.render(withAttributes: newAttributes) }.joined()
		}
	}
}

extension Array where Element: NSAttributedString {
	func joined() -> NSAttributedString {
		let result = NSMutableAttributedString()
		for element in self {
			result.append(element)
		}
		return result
	}
}

#if os(iOS) || os(tvOS) || os(watchOS)
extension UIFont {
	func boldFont() -> UIFont? {
		return addingSymbolicTraits(.traitBold)
	}
	
	func italicFont() -> UIFont? {
		return addingSymbolicTraits(.traitItalic)
	}
	
	func addingSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
		let newTraits = fontDescriptor.symbolicTraits.union(traits)
		guard let descriptor = fontDescriptor.withSymbolicTraits(newTraits) else {
			return nil
		}
		
		return UIFont(descriptor: descriptor, size: 0)
	}
}
#elseif os(OSX)
extension NSFont {
	func boldFont() -> NSFont? {
		return NSFontManager.shared.convert(self, toHaveTrait: .boldFontMask)
	}
	
	func italicFont() -> NSFont? {
		return NSFontManager.shared.convert(self, toHaveTrait: .italicFontMask)
	}
}
#endif
