//
//  PharmService.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/23.
//

import Foundation
import CoreLocation
import Alamofire

class PharmService: NSObject, XMLParserDelegate{
    var datas: PharmData?
    var currentElement = ""
    var currentHeader: PharmData.Header?
    var currentBody: PharmData.Body?
    var currentItems: [PharmData.Body.Item] = []
    var currentItem: PharmData.Body.Item?
    var currentValue = ""
    var resultCode: String = ""
    var errorMessage: String?
    var center: CLLocationCoordinate2D

    init(center: CLLocationCoordinate2D) {
        self.center = center
    }

    static func createPharmData(center: CLLocationCoordinate2D, completion: @escaping (PharmData?, String?) -> Void) {
        let poiDataDuty = PharmService(center: center)
        poiDataDuty.fetchPharmData(completion: completion)
    }

    func updateCenter(_ newCenter: CLLocationCoordinate2D, completion: @escaping (PharmData?, String?) -> Void) {
        self.center = newCenter
        fetchPharmData(completion: completion) // 새로운 좌표로 데이터 요청
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            currentElement = elementName
            currentValue = ""
            if elementName == "item" {
                currentItem = PharmData.Body.Item(hpid: "", latitude: 0, longitude: 0, dutyName: "", dutyAddr: "", distance: 0)
            } else if elementName == "header" {
                currentHeader = PharmData.Header(resultCode: "", resultMsg: "")
            } else if elementName == "body" {
                currentBody = PharmData.Body(items: PharmData.Body.Items(item: []), numOfRows: 0, pageNo: 1, totalCount: 0)
            }
        }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if !currentValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    switch elementName {
                    case "resultCode":
                        resultCode = currentValue
                        currentHeader?.resultCode = currentValue
                    case "resultMsg":
                        currentHeader?.resultMsg = currentValue
                    case "hpid":
                        currentItem?.hpid = currentValue
                    case "latitude":
                        currentItem?.latitude = Double(currentValue) ?? 0
                    case "longitude":
                        currentItem?.longitude = Double(currentValue) ?? 0
                    case "dutyName":
                        currentItem?.dutyName = currentValue
                    case "dutyAddr":
                        currentItem?.dutyAddr = currentValue
                    case "distance":
                        currentItem?.distance = Double(currentValue) ?? 0
                    case "numOfRows":
                        currentBody?.numOfRows = Int(currentValue) ?? 10
                    case "pageNo":
                        currentBody?.pageNo = Int(currentValue) ?? 1
                    case "totalCount":
                        currentBody?.totalCount = Int(currentValue) ?? 0
                    default:
                        break
                    }
                }

                if elementName == "item" {
                    if let item = currentItem {
                        currentItems.append(item)
                        currentItem = nil
                    }
                } else if elementName == "items" {
                    currentBody?.items = PharmData.Body.Items(item: currentItems)
                } else if elementName == "body" {
                    if let body = currentBody {
                        datas = PharmData(header: currentHeader!, body: body)
                        currentBody = nil
                        currentHeader = nil
                        currentItems.removeAll()
                    }
                }

                currentValue = ""
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        // 파싱 완료 시 호출
        if resultCode == "00" {
            //print("Parsed Data: \(datas)")
        } else {
            if let errorMessage = errorMessage {
                print("Error: \(errorMessage)")
            } else {
                print("Unknown error occurred.")
            }
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parsing Error: \(parseError.localizedDescription)")
    }

    func fetchPharmData(completion: @escaping (PharmData?, String?) -> Void) {
        guard let pharmApiUrl = Bundle.main.object(forInfoDictionaryKey: "PHARM_API_URL") as? String else { return }
        guard let commonApiKey = Bundle.main.object(forInfoDictionaryKey: "COMMON_API_KEY") as? String else { return }
        let url = "http://" + pharmApiUrl
        let parameters: Parameters = [
            "serviceKey": commonApiKey,
            "WGS84_LON": center.longitude,
            "WGS84_LAT": center.latitude,
            "pageNo" : 1,
            "numOfRows": 30
        ]

        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.default)
            .response{ response in
                switch response.result {
                        case .success(let data):
                            if let data = data {
                                let parser = XMLParser(data: data)
                                parser.delegate = self
                                parser.parse()
                                completion(self.datas, nil)
                            } else {
                                print("데이터가 없습니다.")
                                completion(nil, "데이터가 없습니다.")
                            }
                        case .failure(let error):
                            print("요청 실패: \(error.localizedDescription)")
                            completion(nil, "요청 실패: \(error.localizedDescription)")
                        }
            }
    }
}
