//
//  CameraEventHandler.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/13.
//

import Foundation
import KakaoMapsSDK

class CameraEventHandler: BaseMapViewController{
    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 127.02768, latitude: 37.498254)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)

        mapController?.addView(mapviewInfo)
    }

    override func viewInit(viewName: String) {
        print("OK")

        // 카메라 이동 멈춤 핸들러를 추가한다.
        let mapView = mapController?.getView("mapview") as! KakaoMap
        _cameraStartHandler = mapView.addCameraWillMovedEventHandler(target: self, handler: CameraEventHandler.cameraWillMove)
        _cameraStoppedHandler = mapView.addCameraStoppedEventHandler(target: self, handler: CameraEventHandler.onCameraStopped)
    }

    // 버튼을 클릭하면 카메라를 지정한 위치로 이동시킨다.
    @IBAction func onButtonClicked(_ sender: Any) {
        let mapView = mapController?.getView("mapview") as! KakaoMap
        let cameraUpdate: CameraUpdate = CameraUpdate.make(target: MapPoint(longitude: 126.978365, latitude: 37.566691), zoomLevel: 10, mapView: mapView)
        mapView.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: true, consecutive: false, durationInMillis: 3000))
    }

    // user gesture로부터 발생한 카메라 이동은 걸러내고, move/animateCamera로 이동한 카메라 이동만 구분하기 위해 param을 사용한다.
    func cameraWillMove(_ param: CameraActionEventParam) {
        if(param.by == .notUserAction) {
            print("Camera will move")

            _cameraStartHandler?.dispose()
        }
    }

    // 지정된 위치로 카메라 이동이 멈추면 핸들러가 호출되고, 특정 동작을 한 이후 handler를 dispose한다
    // user gesture로부터 발생한 카메라 이동은 걸러내고, move/animateCamera로 이동한 카메라 이동만 구분하기 위해 param을 사용한다.
    func onCameraStopped(_ param: CameraActionEventParam) {
        if(param.by == .notUserAction)
        {
            let mapView = param.view as! KakaoMap
            let position = mapView.getPosition(CGPoint(x: 0.5, y: 0.5))

            print("CurrentPosition:\(position.wgsCoord.longitude), \(position.wgsCoord.latitude)")

            // handler를 dispose한다.
            _cameraStoppedHandler?.dispose()
        }
    }

    var _cameraStoppedHandler: DisposableEventHandler?
    var _cameraStartHandler: DisposableEventHandler?
}
