//
//  LiquidCollectionViewLayout.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 10/08/23.
//

import UIKit

//public var cellWidth: CGFloat = 150.0

public protocol LiquidLayoutDelegate {    
    func collectionView(collectionView: UICollectionView, customHeightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
}

public class LiquidCollectionViewLayout: UICollectionViewLayout {

    var delegate: LiquidLayoutDelegate!
    var cellPadding: CGFloat = 3.0
    var cellWidth: CGFloat = 1.0
    var cachedWidth: CGFloat = 0.0
    // Make the number of columns for 2 
    var numberOfColumns : CGFloat = 2.0

    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat  = 0.0
    fileprivate var contentWidth: CGFloat {
        if let collectionView = collectionView {
            let insets = collectionView.contentInset
            return collectionView.bounds.width - (insets.left + insets.right)
        }
        return 0
    }
    fileprivate var numberOfItems = 0

    override public var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override public func prepare() {
        guard let collectionView = collectionView else { return }
        let numberOfColumns = Int(self.numberOfColumns) //Int(contentWidth / cellWidth) // #3
        let numberOfItems = collectionView.numberOfItems(inSection: 0)

        if (contentWidth != cachedWidth || self.numberOfItems != numberOfItems) { // #1
            cache = []
            contentHeight = 0
            self.numberOfItems = numberOfItems
        }

        if cache.isEmpty { // #2
            cachedWidth = contentWidth
            var xOffset = [CGFloat]() //[10, cellWidth + 20, (cellWidth * 2) + 40]
            for column in 0 ..< numberOfColumns
            {
                xOffset.append(CGFloat(column) * cellWidth + CGFloat(column + 0) * 6)
            }
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

            for row in 0 ..< numberOfItems {

                let indexPath = IndexPath(row: row, section: 0)

                let cellHeight = delegate.collectionView(collectionView: collectionView, customHeightForCellAtIndexPath: indexPath, width: cellWidth)
                
                let height = cellPadding +  cellHeight + cellPadding
                let frame = CGRect(x: xOffset[column] + cellPadding, y: yOffset[column], width: cellWidth, height: height)
                let insetFrame = frame.insetBy(dx: 0, dy: cellPadding)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath) // #4
                attributes.frame = insetFrame // #5
                cache.append(attributes) // #6

                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] += height

                if column >= (numberOfColumns - 1) {
                    column = 0
                } else {
                    column += 1
                }
            }
        }
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in cache { // #7
            if attributes.frame.intersects(rect) { // #8
                layoutAttributes.append(attributes) // #9
            }
        }
        return layoutAttributes
    }
}
