//
//  SimplePOI.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/13.
//

import Foundation
import KakaoMapsSDK
import CoreLocation

class SimplePOI:BaseMapViewController{

    var positions = [MapPoint]()
    var options = [PoiOptions]()
    var pois = [String: Poi]()
    var centerLat: Double = 37.477261
    var centerLon: Double = 127.038128
    var pharmData: PharmData?
    var medData: MedData?

    override func viewDidLoad() {
        super.viewDidLoad()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        PharmService.createPharmData(center: CLLocationCoordinate2D(latitude: self.centerLat, longitude: self.centerLon)) {
            poiData, error in
            if let error = error {
                print("Error fetching data: \(error)")
            } else if let poiData = poiData {
                self.pharmData = poiData
                dispatchGroup.leave()
            }
        }
        dispatchGroup.enter()
        MedService.createMedData(center: CLLocationCoordinate2D(latitude: self.centerLat, longitude: self.centerLon)){
            poiData, error in
            if let error = error {
                print("Error fetching data: \(error)")
            } else if let poiData = poiData {
                self.medData = poiData
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("============= API 요청 완료 =============")
            if let pharmData = self.pharmData {
                self.handlePharmData(pharmData)
            }
            if let medData = self.medData {
                self.handleMedData(medData)
            }
        }
    }

    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: self.centerLon, latitude: self.centerLat)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 16)

        mapController?.addView(mapviewInfo)
    }

    override func viewInit(viewName: String) {
        print("OK")
        createLabelLayer()
        createPoiStyle()
        //createPois()
    }

    // POI가 속할 LabelLayer를 생성한다.
    func createLabelLayer() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()    //LabelManager를 가져온다. LabelLayer는 LabelManger를 통해 추가할 수 있다.

        // 추가할 레이어의 옵션을 지정한다. 옵션에는 레이어에 속할 Label(POI)들의 경쟁방식, 레이어의 zOrder등의 속성을 지정할 수 있다.
        // 경쟁의 의미는 라벨이 표출되어야 하는 영역을 두고 다른 라벨과 경쟁을 함을 의미하고, 경쟁이 발생하게 되면 경쟁에서 이긴 라벨만 그려지게 된다.
        // competitionType : 경쟁의 대상을 지정한다.
        //                   예를 들어, none 으로 지정하게 되면 아무런 라벨과도 경쟁하지 않고 항상 그려지게 된다.
        //                   Upper가 있는 경우, 자신의 상위 레이어의 라벨과 경쟁이 발생한다. Lower가 있는 경우, 자신의 하위 레이어의 라벨과 경쟁한다. Same이 있는 경우, 자신과 같은 레이어에 속한 라벨과도 경쟁한다.
        //                   경쟁은 레이어의 zOrder순(오름차순)으로 진행되며, 레이어에 속한 라벨의 rank순(오름차순)으로 배치 및 경쟁을 진행한다.
        //                   경쟁은 레이어 내의 라벨(자신의 competitionType에 Same이 있는 경우)과 competitionType에 Lower가 있는 경우 자신의 하위 레이어(cocompetitionType에 Upper가 있는 레이어)를 대상으로 진행된다.
        //                   경쟁이 발생하면, 상위 레이어에 속한 라벨이 하위 레이어에 속한 라벨을 이기게 되고, 같은 레이어에 속한 라벨인 경우 rank값이 큰 라벨이 이기게 된다.
        // competitionUnit : 경쟁을 할 때의 영역을 처리하는 단위를 지정한다. .poi의 경우 심볼 및 텍스트 영역 모두가 경쟁영역이 되고, symbolFirst 인 경우 symbol 영역으로 경쟁을 처리하고 텍스트는 그려질 수 있는 경우에 한해 그려진다.
        // zOrder : 레이어의 우선 순위를 결정하는 order 값. 값이 클수록 우선순위가 높다.
        let layerOption = LabelLayerOptions(layerID: "PharmLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10001)
        let _ = manager.addLabelLayer(option: layerOption)

        let medLayerOption = LabelLayerOptions(layerID: "MedLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10000)
        let l = manager.addLabelLayer(option: medLayerOption)
    }

    // POI의 스타일을 생성한다.
    // PoiStyle은 한 개 이상의 레벨별 스타일(PerLevelPoiStyle)로 구성된다.
    // 각 레벨별 스타일을 통해 POI가 어떤 레벨에서 어떻게 그려질 것인지를 지정한다.
    // POI는 스타일이 지정되지 않거나, 지정되었어도 레벨별 스타일이 지정되지 않은 레벨에서는 그려지지 않는다.
    // 레벨별 스타일은 지정된 레벨에서부터 다른 레벨별 스타일이 지정된 레벨까지 적용된다.
    // 예를 들어, style1 을 7레벨, style2를 15 레벨로 지정하면 해당 스타일을 사용하는 POI는 0~6레벨까지는 그려지지 않고 7~14레벨까지는 style1으로 그려지고 14~21레벨까지는 style2로 그려진다.
    func createPoiStyle() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        // 심볼을 지정.
        // 심볼의 anchor point(심볼이 배치될때의 위치 기준점)를 지정. 심볼의 좌상단을 기준으로 한 % 값.
        let iconStyle = PoiIconStyle(symbol: UIImage(named: "pill_16.png"), anchorPoint: CGPoint(x: 0.5, y: 0.5))
        let text1 = PoiTextLineStyle(textStyle: TextStyle(fontSize: 20, fontColor: UIColor.white, strokeThickness: 2, strokeColor: UIColor.blue))
        let textStyle1 = PoiTextStyle(textLineStyles: [text1])
        textStyle1.textLayouts = [PoiTextLayout.bottom]
        let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, textStyle: textStyle1, level: 0)  // 이 스타일이 적용되기 시작할 레벨.
        let poiStyle = PoiStyle(styleID: "PharmStyle", styles: [perLevelStyle])
        manager.addPoiStyle(poiStyle)

        //병원
        let medIconStyle = PoiIconStyle(symbol: UIImage(named: "local_hospital_16.png"), anchorPoint: CGPoint(x: 0.5, y: 0.5))
        let medLevelStyle = PerLevelPoiStyle(iconStyle: medIconStyle, textStyle: textStyle1, level: 0)  // 이 스타일이 적용되기 시작할 레벨.
        let medPoiStyle = PoiStyle(styleID: "medStyle", styles: [medLevelStyle])
        manager.addPoiStyle(medPoiStyle)
    }

//    // POI를 생성한다.
//    func createPois() {
//        let view = mapController?.getView("mapview") as! KakaoMap
//        let manager = view.getLabelManager()
//        let layer = manager.getLabelLayer(layerID: "PharmLayer")   // 생성한 POI를 추가할 레이어를 가져온다.
//        let poiOption = PoiOptions(styleID: "PharmStyle") // 생성할 POI의 Option을 지정하기 위한 자료를 담는 클래스를 생성. 사용할 스타일의 ID를 지정한다.
//        poiOption.rank = 0
//        poiOption.clickable = true // clickable 옵션을 true로 설정한다. default는 false로 설정되어있다.
//
//        let poi1 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: self.centerLon, latitude: self.centerLat), callback: {(_ poi: (Poi?)) -> Void in
//            print("")
//        }
//        )   //레이어에 지정한 옵션 및 위치로 POI를 추가한다.
//        let _ = poi1?.addPoiTappedEventHandler(target: self, handler: SimplePOI.poiTappedHandler) // poi tap event handler를 추가한다.
//        poi1?.show()
//    }
//
    // POI 탭 이벤트가 발생
    func poiTappedHandler(_ param: PoiInteractionEventParam) {
        let userObject:AnyObject? = param.poiItem.userObject

        if let wrapper = userObject as? Wrapper<PharmData.Body.Item> {
            let unwrappedItem = wrapper.value
            let dutyName = unwrappedItem.dutyName
            openUrl(with: dutyName)
        } else if let wrapper = userObject as? Wrapper<MedData.Body.Item>{
            let unwrappedItem = wrapper.value
            let dutyName = unwrappedItem.dutyName
            openUrl(with: dutyName)
        } else {
            print("Failed to unwrap userObject")
        }
    }

    func openUrl(with query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let openUrl = "https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=0&ie=utf8&query=" + encodedQuery
        if let url = URL(string: openUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Invalid URL")
        }
    }

    func handlePharmData(_ poiData: PharmData){
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PharmLayer")   // 생성한 POI를 추가할 레이어를 가져온다.
        let sortedItems = poiData.body.items.item.sorted{$0.distance < $1.distance}
        let top10Items = sortedItems.prefix(10)

        for data in top10Items {
            let option = PoiOptions(styleID: "PharmStyle", poiID: data.hpid)
            option.rank = 0
            option.clickable = true
            option.addText(PoiText(text: data.dutyName, styleIndex: 0))

            let poi1 = layer?.addPoi(option: option, at: MapPoint(longitude: data.longitude, latitude: data.latitude), callback: {(_ poi: (Poi?)) -> Void in
                if let poi = poi {
                    poi.userObject = Wrapper(data)
                }
            })

            let _ = poi1?.addPoiTappedEventHandler(target: self, handler: SimplePOI.poiTappedHandler)
            poi1?.show()
        }
    }

    func handleMedData(_ poiData: MedData){
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "MedLayer")
        let sortedItems = poiData.body.items.item.sorted{$0.distance < $1.distance}
        let top10Items = sortedItems.prefix(10)
        for data in top10Items {
            let option = PoiOptions(styleID: "medStyle", poiID: data.hpid)
            option.rank = 0
            option.clickable = true
            option.addText(PoiText(text: data.dutyName, styleIndex: 0))

            let poi1 = layer?.addPoi(option: option, at: MapPoint(longitude: data.longitude, latitude: data.latitude), callback: {(_ poi: (Poi?)) -> Void in
                if let poi = poi {
                    poi.userObject = Wrapper(data)
                }
            })
            let _ = poi1?.addPoiTappedEventHandler(target: self, handler: SimplePOI.poiTappedHandler)
            poi1?.show()
        }
    }
}

class Wrapper<T>: NSObject {
    let value: T

    init(_ value: T) {
        self.value = value
    }
}
