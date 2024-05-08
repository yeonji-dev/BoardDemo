//
//  Trend.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/07.
//
import Foundation

struct ResponseContainer: Codable {
    var code: Int
    var idea: String?
    var body: [Trend]

    enum CodingKeys: String, CodingKey {
        case code = "CODE"
        case idea = "IDEA"
        case body = "BODY"
    }
}

// 각 'BODY' 항목에 대한 모델
struct Trend: Codable {
    var bno: Int
    var regdate: String
    var title: String

    enum CodingKeys: String, CodingKey {
        case bno = "bno"
        case regdate = "regdate"
        case title = "title"
    }
}
