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
    
    var avgPrc = 0
    var hospName = ""
    
    let itemCd: String = "ABZ010001"
    var KEY: String = "M0j%2FyDxQTLEvDEjW3vg0lD4ypKN%2Bo%2Fm7leqrri%2FoXMEBHav1qfUDiEq5DQn0nRBzy3oV48c24mge%2FPPCJtVTTw%3D%3D"
    
    var xmlParser = XMLParser()
    
    var currentElement = ""                // 현재 Element
    var item:[String:String] = [:]  // item[key] => value
    var elements:[[String:String]] = []
    
    var results : [NonPayData] = []
    
    func requestNonPayInfo() {
        // OPEN API 주소
        let url = "https://apis.data.go.kr/B551182/nonPaymentDamtInfoService/getNonPaymentItemHospList2?serviceKey=\(KEY)" + "&itemCd=\(itemCd)"
        guard let xmlParser = XMLParser(contentsOf: URL(string: url)!) else { return }
        
        xmlParser.delegate = self;
        xmlParser.parse()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        requestNonPayInfo()
        print("----this is result----")
        print(results)
        print("---------------------")
        findLatLong(hospName: "가톨릭대학교인천성모병원")
        
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
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            results.append(NonPayData(hospName: hospName, avgPrice: avgPrc/2))
        }
    }
}


extension ViewController {
    func findLatLong(hospName : String) {
        let headers: HTTPHeaders = [
                    "Authorization": KEY
                ]
                
        let parameters: [String: Any] = [
                    "query": hospName,
                    "page": 1,
                    "size": 15
                ]
                
        AF.request("https://dapi.kakao.com/v2/local/search/keyword.json", method: .get,
             parameters: parameters, headers: headers)
             .responseJSON(completionHandler: { response in
                 switch response.result {
                 case .success(let value):
                      print(value)
                   case .failure(let error):
                       print(error)
                   }
               })
    }
}



/*
 if let detailsPlace = JSONDecoder(value)["documents"].array{
     for item in detailsPlace{
          let placeName = item["place_name"].string ?? ""
          let roadAdressName = item["road_address_name"].string ?? ""
          let longitudeX = item["x"].string ?? ""
          let latitudeY = item["y"].string ?? ""
          }
           
       }
 */
