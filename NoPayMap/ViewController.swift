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
    let mapView = MTMapView()
    
    var mapItems = [MTMapPOIItem]()
    var avgPrc = 0
    var hospName = ""
    
    let itemCd: String = "ABZ010001"
    
    let OPEN_KEY: String = "M0j%2FyDxQTLEvDEjW3vg0lD4ypKN%2Bo%2Fm7leqrri%2FoXMEBHav1qfUDiEq5DQn0nRBzy3oV48c24mge%2FPPCJtVTTw%3D%3D"
    var xmlParser = XMLParser()
    
    var currentElement = ""                // 현재 Element
    var item:[String:String] = [:]  // item[key] => value
    var elements:[[String:String]] = []
    
    static var hospInfoList : [HospInfo] = []
//    static var hospCoorList : [HospCoor] = []
    func requestNonPayInfo() {
        // OPEN API 주소
        let url = "https://apis.data.go.kr/B551182/nonPaymentDamtInfoService/getNonPaymentItemHospList2?serviceKey=\(OPEN_KEY)" + "&itemCd=\(itemCd)"
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
                     
                     ViewController.hospInfoList[ind].hospLong = adLong as! Double

                     ViewController.hospInfoList[ind].hospLat = adLat as! Double
                     
                     
                case .failure(let error):
                     print("error 났어요")
                     print(error)
                     
                   }
                 
                    
                 
               })
        
//        print("dicValue[x]")
//        print(dicValue["x"] as! Double)
//        print("dicValue[y]")
//        print(dicValue["y"] as! Double)
//        return
  
        }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        requestNonPayInfo()
        print("----this is result----")
        print(ViewController.hospInfoList)
        print("---------------------")
        ViewController.hospInfoList[3].hospName = "test입니다"
        print("----this is testresult----")
        print(ViewController.hospInfoList)
        print("---------------------")
        self.view.addSubview(mapView)
        mapView.delegate = self
        mapView.baseMapType = .standard
        mapView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
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

extension ViewController {
    func poiItem(id: Int, latitude: Double, longitude: Double, imageName: String) -> MTMapPOIItem {
        let item = MTMapPOIItem()
        item.tag = id
        item.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        item.showAnimationType = .noAnimation
        return item
    }
    
//    mapView.addPOIItem()
   
}
