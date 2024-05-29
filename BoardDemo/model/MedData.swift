//
//  MedData.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/23.
//

import Foundation
import CoreLocation

struct MedData: Codable {

    struct Header: Codable{
        var resultCode: String
        var resultMsg: String
    }

    struct Body: Codable{
        struct Items: Codable{
            let item: [Item]
        }
        struct Item: Codable{
            var hpid: String
            var latitude: Double
            var longitude: Double
            var dutyName: String
            var dutyDiv: String
            var distance: Double
            var position: CLLocationCoordinate2D {
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
        var items: Items
        var numOfRows: Int
        var pageNo: Int
        var totalCount: Int
    }

    let header: Header
    let body: Body
}


