//
//  UniqueActivity.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

// MARK: UniqueActivity

protocol UniqueActivity: AnyObject {
    var uniqueActivityTimer: Timer? { get set }
    var uniqueActivityThings: (() -> Void)? { get set }

    func uniqueActivityAndThenRun(_ closure: @escaping () -> Void)
    func cancelUniqueActivity()
}

extension UniqueActivity where Self: UIViewController {
    func uniqueActivityAndThenRun(_ closure: @escaping () -> Void) {
        cancelUniqueActivity()
        uniqueActivityTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            self?.view.isUserInteractionEnabled = false
            if self?.uniqueActivityThings != nil {
                self?.uniqueActivityThings?()
            }
            self?.cancelUniqueActivity()
        })
        uniqueActivityThings = closure
    }

    func cancelUniqueActivity() {
        guard uniqueActivityTimer != nil else {
            return
        }
        uniqueActivityTimer?.invalidate()
        uniqueActivityTimer = nil
        uniqueActivityThings = nil
        view.isUserInteractionEnabled = true
    }
}
