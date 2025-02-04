//
//  CAGEditViewModel.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import CoreImage
class CAEditViewModel: NSObject {
    
    private var effectManager = EffectManager()
    private var adjustsManager = AdjustManager()
    private(set) var filterData = [FilterModel]()
    private(set) var adjustData = [FilterModel]()
    override init() {
        super.init()
        self.callFuncToGetFilterData()
        self.callFuncToGetAdjustsData()
    }
    
    // Fetches filter data from the filter manager
    func callFuncToGetFilterData() {
        self.filterData = self.effectManager.getFilterData()
    }
    
    // Fetches filter data from the filter manager
    func callFuncToGetAdjustsData() {
        self.adjustData = self.adjustsManager.getAdjustsData()
    }
    
    func commonBundle() -> Bundle {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!
        return bundle
    }
}

