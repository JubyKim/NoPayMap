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

class ViewController: UIViewController, MTMapViewDelegate {
    let mapView = MTMapView()
    
    override func viewDidLoad() {
        print("heelo")
        super.viewDidLoad()
        self.view.addSubview(mapView)
        mapView.delegate = self
        mapView.baseMapType = .standard

        mapView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            }
    
        TableViewController.init().viewDidLoad()
    }
    

}

