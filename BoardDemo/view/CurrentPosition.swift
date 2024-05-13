//
//  CurrentPosition.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/13.
//

import UIKit
import CoreLocation
import KakaoMapsSDK

enum Mode: Int {
    case hidden = 0,
    show,
    tracking
}

// POI의 기능을 조합하여 현위치마커를 구성하는 예제.
class CurrentPosition: BaseMapViewController, GuiEventDelegate, CLLocationManagerDelegate {

    required init?(coder aDecoder: NSCoder) {
        _locationServiceAuthorized = CLAuthorizationStatus.notDetermined
        _locationManager = CLLocationManager()
        _locationManager.distanceFilter = kCLDistanceFilterNone
        _locationManager.headingFilter = kCLHeadingFilterNone
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _currentHeading = 0
        _currentPosition = GeoCoordinate()
        _mode = .hidden
        _moveOnce = false
        super.init(coder: aDecoder)

        _locationManager.delegate = self
    }

    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)

        mapController?.addView(mapviewInfo)
    }

    override func viewInit(viewName: String) {
        print("OK")
        createSpriteGUI()
        createLabelLayer()
        createPoiStyle()
        createPois()
        createWaveShape()
    }

    func createLabelLayer() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let positionLayerOption = LabelLayerOptions(layerID: "PositionPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
        let _ = manager.addLabelLayer(option: positionLayerOption)
        let directionLayerOption = LabelLayerOptions(layerID: "DirectionPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10)
        let _ = manager.addLabelLayer(option: directionLayerOption)
    }

    func createPoiStyle() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let marker = PoiIconStyle(symbol: UIImage(named: "map_ico_marker.png"))
        let perLevelStyle1 = PerLevelPoiStyle(iconStyle: marker, level: 0)
        let poiStyle1 = PoiStyle(styleID: "positionPoiStyle", styles: [perLevelStyle1])
        manager.addPoiStyle(poiStyle1)

        let direction = PoiIconStyle(symbol: UIImage(named: "map_ico_marker_direction.png"), anchorPoint: CGPoint(x: 0.5, y: 0.995))
        let perLevelStyle2 = PerLevelPoiStyle(iconStyle: direction, level: 0)
        let poiStyle2 = PoiStyle(styleID: "directionArrowPoiStyle", styles: [perLevelStyle2])
        manager.addPoiStyle(poiStyle2)

        let area = PoiIconStyle(symbol: UIImage(named: "map_ico_direction_area.png"), anchorPoint: CGPoint(x: 0.5, y: 0.995))
        let perLevelStyle3 = PerLevelPoiStyle(iconStyle: area, level: 0)
        let poiStyle3 = PoiStyle(styleID: "directionPoiStyle", styles: [perLevelStyle3])
        manager.addPoiStyle(poiStyle3)
    }

    func createPois() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let positionLayer = manager.getLabelLayer(layerID: "PositionPoiLayer")
        let directionLayer = manager.getLabelLayer(layerID: "DirectionPoiLayer")

        // 현위치마커의 몸통에 해당하는 POI
        let poiOption = PoiOptions(styleID: "positionPoiStyle", poiID: "PositionPOI")
        poiOption.rank = 1
        poiOption.transformType = .decal    //화면이 기울여졌을 때, 지도를 따라 기울어져서 그려지도록 한다.
        let position: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)

        _currentPositionPoi = positionLayer?.addPoi(option:poiOption, at: position)

        // 현위치마커의 방향표시 화살표에 해당하는 POI
        let poiOption2 = PoiOptions(styleID: "directionArrowPoiStyle", poiID: "DirectionArrowPOI")
        poiOption2.rank = 3
        poiOption2.transformType = .absoluteRotationDecal

        _currentDirectionArrowPoi = positionLayer?.addPoi(option:poiOption2, at: position)

        // 현위치마커의 부채꼴모양 방향표시에 해당하는 POI
        let poiOption3 = PoiOptions(styleID: "directionPoiStyle", poiID: "DirectionPOI")
        poiOption3.rank = 2
        poiOption3.transformType = .decal

        _currentDirectionPoi = directionLayer?.addPoi(option:poiOption3, at: position)

        _currentPositionPoi?.shareTransformWithPoi(_currentDirectionArrowPoi!)  //몸통이 방향표시와 위치 및 방향을 공유하도록 지정한다. 몸통 POI의 위치가 변경되면 방향표시 POI의 위치도 변경된다. 반대는 변경안됨.
        _currentDirectionArrowPoi?.shareTransformWithPoi(_currentDirectionPoi!) //방향표시가 부채꼴모양과 위치 및 방향을 공유하도록 지정한다.
    }

    // 현위치 마커에 원형 물결효과를 주기 위해 원형 Polygon을 추가한다.
    func createWaveShape() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getShapeManager()
        let layer = manager.addShapeLayer(layerID: "shapeLayer", zOrder: 10001, passType: .route)

        let shapeStyle = PolygonStyle(styles: [
            PerLevelPolygonStyle(color: UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1.0), level: 0)
        ])
        let shapeStyleSet = PolygonStyleSet(styleSetID: "shapeLevelStyle")
        shapeStyleSet.addStyle(shapeStyle)
        manager.addPolygonStyleSet(shapeStyleSet)

        let options = PolygonShapeOptions(shapeID: "waveShape", styleID: "shapeLevelStyle", zOrder: 1)
        let points = Primitives.getCirclePoints(radius: 10.0, numPoints: 90, cw: true)
        let polygon = Polygon(exteriorRing: points, hole: nil, styleIndex: 0)

        options.polygons.append(polygon)
        options.basePosition = MapPoint(longitude: 0, latitude: 0)

        let shape = layer?.addPolygonShape(options)
        _currentDirectionPoi?.shareTransformWithShape(shape!)   //현위치마커 몸통이 Polygon이 위치 및 방향을 공유하도록 지정한다.
    }

    func createAndStartWaveAnimation() {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        let manager = mapView?.getShapeManager()
        let layer = manager?.getShapeLayer(layerID: "shapeLayer")
        let shape = layer?.getPolygonShape(shapeID: "waveShape")
        let waveEffect = WaveAnimationEffect(datas: [
            WaveAnimationData(startAlpha: 0.8, endAlpha: 0.0, startRadius: 10.0, endRadius: 100.0, level: 0)
        ])
        waveEffect.hideAtStop = true
        waveEffect.interpolation = AnimationInterpolation(duration: 1000, method: .cubicOut)
        waveEffect.playCount = 5

        let animator = manager?.addShapeAnimator(animatorID: "circleWave", effect: waveEffect)
        animator?.addPolygonShape(shape!)
        animator?.start()
    }

    // 현위치마커 버튼 GUI
    func createSpriteGUI() {
        let mapView = mapController?.getView("mapview") as! KakaoMap
        let spriteLayer = mapView.getGuiManager().spriteGuiLayer
        let spriteGui = SpriteGui("ButtonGui")

        spriteGui.arrangement = .horizontal
        spriteGui.bgColor = UIColor.clear
        spriteGui.splitLineColor = UIColor.white
        spriteGui.origin = GuiAlignment(vAlign: .bottom, hAlign: .right)

        let button = GuiButton("CPB")
        button.image = UIImage(named: "track_location_btn.png")

        spriteGui.addChild(button)

        spriteLayer.addSpriteGui(spriteGui)
        spriteGui.delegate = self
        spriteGui.show()
    }

    func guiDidTapped(_ gui: KakaoMapsSDK.GuiBase, componentName: String) {
//        let mapView = mapController?.getView("mapview") as! KakaoMap
        let button = gui.getChild(componentName) as! GuiButton
        switch _mode {
            case .hidden:
                _mode = .show   //현위치마커 표시
                button.image = UIImage(named: "track_location_btn_pressed.png")
                _timer = Timer.init(timeInterval: 0.3, target: self, selector: #selector(self.updateCurrentPositionPOI), userInfo: nil, repeats: true)
                RunLoop.current.add(_timer!, forMode: RunLoop.Mode.common)
                startUpdateLocation()
                _currentPositionPoi?.show()
                _currentDirectionArrowPoi?.show()
                createAndStartWaveAnimation()
                _moveOnce = true
                break;
            case .show:
                _mode = .tracking   //현위치마커 추적모드
                button.image = UIImage(named: "track_location_btn_compass_on.png")
                let mapView = mapController?.getView("mapview") as! KakaoMap
                let trackingManager = mapView.getTrackingManager()
                trackingManager.startTrackingPoi(_currentDirectionArrowPoi!)
                trackingManager.isTrackingRoll = true
                _currentDirectionArrowPoi?.hide()
                _currentDirectionPoi?.show()
                break;
            case .tracking:
                _mode = .hidden     //현위치마커 숨김
                button.image = UIImage(named: "track_location_btn.png")
                _timer?.invalidate()
                _timer = nil
                stopUpdateLocation()
                _currentPositionPoi?.hide()
                _currentDirectionPoi?.hide()
                let mapView = mapController?.getView("mapview") as! KakaoMap
                let trackingManager = mapView.getTrackingManager()
                trackingManager.stopTracking()
        }
        gui.updateGui()
    }

    @objc func updateCurrentPositionPOI() {
        _currentPositionPoi?.moveAt(MapPoint(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude), duration: 150)
        _currentDirectionArrowPoi?.rotateAt(_currentHeading, duration: 150)

        if _moveOnce {
            let mapView: KakaoMap = mapController?.getView("mapview") as! KakaoMap
            mapView.moveCamera(CameraUpdate.make(target: MapPoint(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude), mapView: mapView))
            _moveOnce = false
        }
//        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
//        let manager = mapView?.getShapeManager()
//        let layer = manager?.getShapeLayer("shapeLayer")
//        let shape = layer?.getShape("waveShape")
    }

    func startUpdateLocation() {
        if _locationServiceAuthorized != .authorizedWhenInUse {
            _locationManager.requestWhenInUseAuthorization()
        }
        else {
            _locationManager.startUpdatingLocation()
            _locationManager.startUpdatingHeading()
        }
    }

    func stopUpdateLocation() {
        _locationManager.stopUpdatingHeading()
        _locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        _locationServiceAuthorized = status
        if _locationServiceAuthorized == .authorizedWhenInUse && (_mode == .show || _mode == .tracking) {
            _locationManager.startUpdatingLocation()
            _locationManager.startUpdatingHeading()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _currentPosition.longitude = locations[0].coordinate.longitude
        _currentPosition.latitude = locations[0].coordinate.latitude

        if let location = locations.first {
                print("위도: \(location.coordinate.latitude)")
                print("경도: \(location.coordinate.longitude)")
            }

//        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
//        let manager = mapView?.getMapMovablePoiManager()
//        let poi = manager?.getMovablePoi("me")
//        poi?.updatePosition(_currentPosition)
//        manager?.animateMovablePois(pois: [poi!], duration: 1000)

    //        NSLog("CurrentLocation: %f, %f", locations[0].coordinate.longitude, locations[0].coordinate.latitude)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        _currentHeading = newHeading.trueHeading * Double.pi / 180.0
    }

    var _timer: Timer?
    var _currentPositionPoi: Poi?
    var _currentDirectionArrowPoi: Poi?
    var _currentDirectionPoi: Poi?
    var _currentHeading: Double
    var _currentPosition: GeoCoordinate
    var _mode: Mode
    var _moveOnce: Bool
    var _locationManager: CLLocationManager
    var _locationServiceAuthorized: CLAuthorizationStatus
}

