//
//  MovieLanguage.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import Foundation

enum MovieLanguage: String, CaseIterable {
    case english = "en"
    case french = "fr"
    case japanese = "ja"
    case german = "de"
    case hindi = "hi"
    case chinese = "zh"
    case italian = "it"
    case spanish = "es"
    case korean = "ko"
    case portuguese = "pt"
    case russian = "ru"
    case bengali = "bn"
    case polish = "pl"
    case arabic = "ar"
    case dutch = "nl"
    case greek = "el"
    case hebrew = "he"
    case hungarian = "hu"
    case indonesian = "id"
    case malay = "ms"
    case norwegian = "no"
    case swedish = "sv"
    case thai = "th"
    case turkish = "tr"
    case vietnamese = "vi"
    case finnish = "fi"
    case danish = "da"
    case czech = "cs"
    case ukrainian = "uk"
    case filipino = "tl"
    case romanian = "ro"
    
    var name: String {
        switch self {
        case .english: return "English"
        case .french: return "French"
        case .japanese: return "Japanese"
        case .german: return "German"
        case .hindi: return "Hindi"
        case .chinese: return "Chinese"
        case .italian: return "Italian"
        case .spanish: return "Spanish"
        case .korean: return "Korean"
        case .portuguese: return "Portuguese"
        case .russian: return "Russian"
        case .bengali: return "Bengali"
        case .polish: return "Polish"
        case .arabic: return "Arabic"
        case .dutch: return "Dutch"
        case .greek: return "Greek"
        case .hebrew: return "Hebrew"
        case .hungarian: return "Hungarian"
        case .indonesian: return "Indonesian"
        case .malay: return "Malay"
        case .norwegian: return "Norwegian"
        case .swedish: return "Swedish"
        case .thai: return "Thai"
        case .turkish: return "Turkish"
        case .vietnamese: return "Vietnamese"
        case .finnish: return "Finnish"
        case .danish: return "Danish"
        case .czech: return "Czech"
        case .ukrainian: return "Ukrainian"
        case .filipino: return "Filipino"
        case .romanian: return "Romanian"
        }
    }
    
    static func from(code: String) -> MovieLanguage? {
        return MovieLanguage(rawValue: code)
    }
}

