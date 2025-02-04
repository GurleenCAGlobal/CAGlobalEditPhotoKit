//
//  FiltersManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 21/06/23.
//

import UIKit
import CoreImage

enum Filters: String, CaseIterable {
    case zipLut1 = "ZipLut_1"
    case sin = "Sin"
    case lomo = "Lomo"
    case ad1920 = "AD1920"
    case lenin = "Lenin"
    case sepiaHigh = "SepiaHigh"
    case winter = "Winter"
    case pola669 = "Pola669"
    case polaSX = "PolaSX"
    case food = "Food"
    case glam = "Glam"
    case chest = "Chest"
    case front = "Front"
    case k1Filter = "K1"
    case k2Filter = "K2"
    case k6Filter = "K6"
    case kdynamic = "KDynamic"
    case fridge = "Fridge"
    case orchid = "Orchid"
    case x400 = "X400"
    case fixie = "Fixie"
    case bwFilter = "BW"
    case quozi = "Quozi"
    case celsius = "Celsius"
    case texas = "Texas"
    
}

class FiltersManager: NSObject {
    func getFilterData() -> [String] {
        let color = Filters.allCases.map { options in
            return options.rawValue
        }
        return color
    }
}

extension CIFilter {
    static func filter(withLUT name: String, dimension filterDimensions: Int) -> CIFilter? {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        guard let image = UIImage(named: name, in: bundle, compatibleWith: nil),
              let bitmap = createRGBABitmap(fromImage: image.cgImage),
              let data = createColorCubeData(from: bitmap, width: image.cgImage?.width ?? 0, height: image.cgImage?.height ?? 0, filterDimensions: filterDimensions) else {
            return nil
        }

        let filter = createCIColorCubeFilter(data: data, size: filterDimensions)
        return filter
    }

    private static func createRGBABitmap(fromImage image: CGImage?) -> UnsafeMutablePointer<UInt8>? {
        guard let image = image else {
            return nil
        }
        
        var context: CGContext?
        var colorSpace: CGColorSpace?
        var bitmap: UnsafeMutablePointer<UInt8>?
        var bitmapSize: Int
        var bytesPerRow: Int
        
        let width = image.width
        let height = image.height
        
        bytesPerRow = width * 4
        bitmapSize = bytesPerRow * height
        
        bitmap = malloc(bitmapSize)?.assumingMemoryBound(to: UInt8.self)
        guard let unwrappedBitmap = bitmap else {
            return nil
        }
        
        colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let unwrappedColorSpace = colorSpace else {
            free(unwrappedBitmap)
            return nil
        }
        
        context = CGContext(data: unwrappedBitmap,
                            width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bytesPerRow: bytesPerRow,
                            space: unwrappedColorSpace,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let unwrappedContext = context else {
            free(unwrappedBitmap)
            return nil
        }
        
        unwrappedContext.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return unwrappedBitmap
    }

    private static func createColorCubeData(from bitmap: UnsafeMutablePointer<UInt8>, width: Int, height: Int, filterDimensions: Int) -> UnsafeMutablePointer<Float>? {
        let rowNum = height / filterDimensions
        let columnNum = width / filterDimensions
        
        if width % filterDimensions != 0 || height % filterDimensions != 0 || rowNum * columnNum != filterDimensions {
            print("Invalid colorLUT")
            return nil
        }
        
        let size = filterDimensions * filterDimensions * filterDimensions * MemoryLayout<Float>.size * 4
        let data = malloc(size).assumingMemoryBound(to: Float.self)
        var bitmapOffset = 0
        var zAxis = 0
        
        for _ in 0..<rowNum {
            for yAxis in 0..<filterDimensions {
                let tmp = zAxis
                for _ in 0..<columnNum {
                    for xAxis in 0..<filterDimensions {
                        let red = Float(bitmap[bitmapOffset])
                        let green = Float(bitmap[bitmapOffset + 1])
                        let blue = Float(bitmap[bitmapOffset + 2])
                        let alpha = Float(bitmap[bitmapOffset + 3])
                        
                        let dataOffset = (zAxis * filterDimensions * filterDimensions + yAxis * filterDimensions + xAxis) * 4
                        
                        data[dataOffset] = red / 255.0
                        data[dataOffset + 1] = green / 255.0
                        data[dataOffset + 2] = blue / 255.0
                        data[dataOffset + 3] = alpha / 255.0
                        
                        bitmapOffset += 4
                    }
                    zAxis += 1
                }
                zAxis = tmp
            }
            zAxis += columnNum
        }
        
        free(bitmap)
        return data
    }

    private static func createCIColorCubeFilter(data: UnsafeMutablePointer<Float>, size: Int) -> CIFilter? {
        guard let filter = CIFilter(name: "CIColorCube") else {
            return nil
        }

        filter.setValue(Data(bytesNoCopy: data, count: size, deallocator: .free), forKey: "inputCubeData")
        filter.setValue(size, forKey: "inputCubeDimension")
        return filter
    }
}
