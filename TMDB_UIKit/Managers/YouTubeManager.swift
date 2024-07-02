//
//  YouTubeManager.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class YouTubeManager {
    private let apiKey = K.Strings.api_youtube.value
    private let baseURL = K.Strings.youtube_url.value

    func fetchTrailer(for movieTitle: String, completion: @escaping (String?) -> Void) {
        let url = "\(baseURL)/search"
        let parameters: [String: Any] = [
            "part": "snippet",
            "q": "\(movieTitle) trailer",
            "key": apiKey,
            "maxResults": 1
        ]

        AF.request(url, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("YouTube API Response: \(json)")
                if let videoId = json["items"].array?.first?["id"]["videoId"].string {
                    let embedURL = "https://www.youtube.com/embed/\(videoId)"
                    print("Embed URL: \(embedURL)")
                    completion(embedURL)
                } else {
                    print("No videoId found in YouTube response")
                    completion(nil)
                }
            case .failure(let error):
                print("Error fetching YouTube video: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
