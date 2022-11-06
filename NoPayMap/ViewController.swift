//
//  ViewController.swift
//  NoPayMap
//
//  Created by JUEUN KIM on 2022/09/25.
//

import UIKit
import Then
import MapKit
import SnapKit
import Alamofire
import Foundation

class ViewController: UIViewController, MTMapViewDelegate {
    var mapView = MTMapView().then{
        $0.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.5045, longitude: 127.0490)), zoomLevel: 5, animated: false)
    }
    
    var mapItems = [MTMapPOIItem]()

    let infoView = UIView().then{
        $0.backgroundColor = .white
    }
    let hospNameTitle = UILabel().then{
        $0.text = "병원명 : "
        $0.textColor = .black
        $0.font = UIFont(name: "", size: 10)
    }
    let hospPriceTitle = UILabel().then{
        $0.text = "가격 : "
        $0.textColor = .black
        $0.font = UIFont(name: "", size: 10)
    }
    
    let hospNameLabel = UILabel()
    let hospPriceLabel = UILabel()
    
    var avgPrc = 0
    var hospName = ""
    
    let itemCd: String = "ABZ010001"
    let sidoCd: Int = 110000
    let sgguCd: Int = 110001
    
    let OPEN_KEY: String = "M0j%2FyDxQTLEvDEjW3vg0lD4ypKN%2Bo%2Fm7leqrri%2FoXMEBHav1qfUDiEq5DQn0nRBzy3oV48c24mge%2FPPCJtVTTw%3D%3D"
    var xmlParser = XMLParser()
    
    var currentElement = ""                // 현재 Element
    var item:[String:String] = [:]  // item[key] => value
    var elements:[[String:String]] = []
    
    var hospAddList = [HospAdd(id: 0, hospLong: 37.48992442128445, hospLat: 127.03372331742996)
                   ,HospAdd(id: 1, hospLong: 37.5203098449488, hospLat: 127.033999426916)
                   ,HospAdd(id: 2, hospLong: 35.863751470721745, hospLat: 128.60191984251864)
                   ,HospAdd(id: 3, hospLong: 37.50478230187595, hospLat: 127.0484506824516)
                   ,HospAdd(id: 4, hospLong: 37.485342474851066, hospLat: 127.03776229088159)
                   ,HospAdd(id: 5, hospLong: 37.484911725043794, hospLat: 127.03505864524779)
                   ,HospAdd(id: 6, hospLong: 37.5155054931273, hospLat: 127.034694023369)
                   ,HospAdd(id: 7, hospLong: 37.4927889503163, hospLat: 127.046348715929)
                   ,HospAdd(id: 8, hospLong: 37.488172159313585, hospLat: 127.08523237526762)
                    ,HospAdd(id: 9, hospLong: 37.50681892340246, hospLat: 127.03464815597005)
    ]
    
    static var hospInfoList : [HospInfo] = []
    
    func requestNonPayInfo() {
        // OPEN API 주소

        let url = "https://apis.data.go.kr/B551182/nonPaymentDamtInfoService/getNonPaymentItemHospList2?serviceKey=\(OPEN_KEY)" + "&itemCd=\(itemCd)" + "&sidoCd=\(sidoCd)" + "&sgguCd=\(sgguCd)"
        guard let xmlParser = XMLParser(contentsOf: URL(string: url)!) else { return }
        
        xmlParser.delegate = self;
        xmlParser.parse()
    }
    
    let headers: HTTPHeaders = [
                "Authorization": "KakaoAK e9bcbfb89713389a16c296fde3a156fc"
            ]
    
    
    func findAddress(ind: Int) {
        var dicValue = NSDictionary();
//        print("ViewController.hospInfoList)")
//        print(ViewController.hospInfoList)
        let parameters: [String: Any] = [
            "query": ViewController.hospInfoList[ind].hospName,
            "page": 1,
            "size": 15
            ]
        
        AF.request("https://dapi.kakao.com/v2/local/search/keyword.json", method: .get,
             parameters: parameters, headers: headers)
             .responseJSON(completionHandler: { response in
                 switch response.result {
                     
                 case .success(let value):
                     print("success")
                     dicValue = value as! NSDictionary
                     dicValue = (dicValue["documents"] as! Array<Any>)[0] as! NSDictionary
                     print("dicValue")
//                     print(dicValue["x"])
                     var adLat = dicValue["x"]
                     var adLong = dicValue["y"]
                     
                     print([adLong,adLat])
                     
                case .failure(let error):
                     print("error 났어요")
                     print(error)
                     
                   }
                 
                    
                 
               })
  
        }
    
    func poiItem(id: Int, latitude: Double, longitude: Double) -> MTMapPOIItem {
        let item = MTMapPOIItem()
        item.tag = id
        item.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        item.showAnimationType = .noAnimation
        return item
    }
    
    private func fetchMapDetail(id : Int) {
        print("hell0")
        hospNameLabel.text = ViewController.hospInfoList[id].hospName
        hospPriceLabel.text = String(ViewController.hospInfoList[id].avgPrice)
    }
    
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        fetchMapDetail(id: poiItem.tag)
        return false
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestNonPayInfo()
        print("----this is result----")
        print(ViewController.hospInfoList)
        print("---------------------")
        self.view.addSubview(mapView)
        self.view.addSubview(infoView)
        mapView.delegate = self
        mapView.baseMapType = .standard
        mapView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            }
        for i in 0...8 {
            mapView.add(poiItem(id: i, latitude: hospAddList[i].hospLong, longitude: hospAddList[i].hospLat ) )
            
        }
        makeDetailInfoView()
        
    }
    
    func makeDetailInfoView() {
        infoView.addSubview(hospNameTitle)
        infoView.addSubview(hospPriceTitle)
        infoView.addSubview(hospNameLabel)
        infoView.addSubview(hospPriceLabel)
        
        infoView.snp.makeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(100)
            
        }
        hospNameTitle.snp.makeConstraints{
            $0.top.leading.equalTo(infoView).offset(18)
        }
        
        hospPriceTitle.snp.makeConstraints{
            $0.leading.equalTo(infoView).offset(18)
            $0.top.equalTo(hospNameTitle.snp.bottom).offset(10)
        }
        
        hospNameLabel.snp.makeConstraints{
            $0.top.equalTo(hospNameTitle)
            $0.leading.equalTo(hospNameTitle.snp.trailing).offset(8)
        }
        
        hospPriceLabel.snp.makeConstraints{
            $0.top.equalTo(hospNameTitle.snp.bottom).offset(10)
            $0.leading.equalTo(hospPriceTitle.snp.trailing).offset(8)
        }
        
        
    }
}

extension ViewController : XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if currentElement == "maxPrc" { //최대금액
            avgPrc = 0 //갱신
            avgPrc += Int(data)!
        }
        if currentElement == "minPrc" { // 최소금액
            avgPrc += Int(data)!
        }
        if currentElement == "yadmNm" { // 병원명
            hospName = data
        }
        
    }
    
    static var idx = 0;
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            ViewController.hospInfoList.append(HospInfo(id : ViewController.idx,
                                                     hospName: hospName,
                                                     avgPrice: avgPrc/2))
            findAddress(ind:ViewController.idx)
            ViewController.idx += 1
            print("parser시작")
            print(ViewController.hospInfoList)
            
        }

    }
    
}
