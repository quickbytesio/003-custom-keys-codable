//
//  Models.swift
//  Quickbytes Example Swift
//
//  Created by Aaron Brethorst on 10/3/17.
//  Copyright © 2017 Quickbytes. All rights reserved.
//

import Foundation

public struct Feed: Codable {
    let title: String
    let id: URL
    let copyright: String
    let country: String
    let iconURL: URL
    let updatedAt: Date
    let feedItems: [FeedItem]

    enum CodingKeys: String, CodingKey {
        case title
        case id
        case copyright
        case country
        case iconURL = "icon"
        case updatedAt = "updated"
        case feedItems = "results"
    }
}

public struct FeedItem: Codable {
    let developer: String
    let developerURL: URL
    let artworkURL: URL
    let copyright: String
    let name: String
    let releasedAt: Date
    let URL: URL

    enum CodingKeys: String, CodingKey {
        case developer = "artistName"
        case developerURL = "artistUrl"
        case artworkURL = "artworkUrl100"
        case copyright
        case name
        case releasedAt = "releaseDate"
        case URL = "url"
    }
}

public class AppStoreDecoder {
    /// Decodes the `updated` fields in `Feed` structs.
    lazy var dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    /// Decodes the `releaseDate` fields in `FeedItem` structs.
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// Decodes a Feed with embedded `FeedItem`s
    // and multiple date formats.
    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = self.dateTimeFormatter.date(from: dateString) {
                return date
            }

            if let date = self.dateFormatter.date(from: dateString) {
                return date
            }

            return Date()
        }
        return decoder
    }()

    public func decodeFeed(from data: Data) -> Feed {
        let feedWrapper = try! self.decoder.decode([String: Feed].self, from: data)
        return feedWrapper["feed"]!
    }
}
