//
//  LocalizedAppConstant.swift
//  Snaptouch_Polaroid
//
//  Created by maximess120 on 21/03/18.
//  Copyright © 2018 maximess142. All rights reserved.
//

import UIKit

class LocalizedAppConstant: NSObject {

}

extension String
{
    func localisedString() -> String
    {
        return NSLocalizedString(self, comment: "")
    }
}

