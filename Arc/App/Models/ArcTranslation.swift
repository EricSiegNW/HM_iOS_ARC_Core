//
//  ArcTranslation.swift
//  arct
//
//  Created by Philip Hayes on 5/17/19.
//  Copyright © 2019 thinkhappymedium. All rights reserved.
//

import Foundation
import HMMarkup
public protocol TranslationKey {
	var rawValue:String { get }
}
public struct ArcTranslation : Codable  {
    public struct Map : Codable {
        public var map:Dictionary<String, String>?
    }
    public var versions:Array<Map>
}

public extension String {
    func localized(_ key:String) -> String {
        if let config = HMMarkupRenderer.config,
            config.shouldTranslate,
            let translation = config.translation
        {
            return translation[key] ?? self
        }
        return self
    }
	func localized(_ key:TranslationKey) -> String {
		let key = key.rawValue
		if let config = HMMarkupRenderer.config,
			config.shouldTranslate,
			let translation = config.translation
		{
			return translation[key] ?? self
		}
		return self
	}
}


