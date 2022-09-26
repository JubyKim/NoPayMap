//
//  TableViewController.swift
//  NoPayMap
//
//  Created by JUEUN KIM on 2022/09/26.
//

import Foundation

class TableViewController: UITableViewController {
    
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
        print("this view is called")
        requestNonPayInfo()
        print("----this is result----")
        print(results)
        print("---------------------")

    }

}

extension TableViewController : XMLParserDelegate {
    
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
