//
//  PoiData.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/20.
//

import Foundation
import CoreLocation
import Alamofire

struct PharmData: Codable {

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
            var dutyAddr: String
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
