//
//  RemoveBackground.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 21/11/24.
//

import Foundation
import UIKit
import Vision

class BackgroundRemover {

    private func createMaskImage(from pixelBuffer: CVPixelBuffer) -> UIImage {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let transform = CGAffineTransform(translationX: 0, y: ciImage.extent.size.height).scaledBy(x: 1, y: -1)
        let flippedImage = ciImage.transformed(by: transform)

        // Invert the mask
        let invertedFilter = CIFilter(name: "CIColorInvert", parameters: [
            kCIInputImageKey: flippedImage
        ])!

        guard let invertedImage = invertedFilter.outputImage else {
            return UIImage()
        }

        // Convert to UIImage
        let context = CIContext()
        if let cgImage = context.createCGImage(invertedImage, from: invertedImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return UIImage()
    }

    func removeBackground(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let normalizedCGImage = image.normalized().cgImage else {
            completion(nil)
            return
        }

        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        let requestHandler = VNImageRequestHandler(cgImage: normalizedCGImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
                if let result = request.results?.first as? VNPixelBufferObservation {
                    let maskImage = self.createMaskImage(from: result.pixelBuffer)
                    let compositedImage = self.applyMask(maskImage, to: image.normalized())
                    DispatchQueue.main.async {
                        completion(compositedImage)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("Failed to perform segmentation: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }


//    private func createMaskImage(from pixelBuffer: CVPixelBuffer) -> UIImage {
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//        let transform = CGAffineTransform(translationX: 0, y: ciImage.extent.size.height).scaledBy(x: 1, y: -1)
//        let flippedImage = ciImage.transformed(by: transform)
//        let context = CIContext()
//        if let cgImage = context.createCGImage(flippedImage, from: flippedImage.extent) {
//            return UIImage(cgImage: cgImage)
//        }
//        return UIImage()
//    }


    private func applyMask(_ mask: UIImage, to image: UIImage) -> UIImage? {
        // Begin a new context with transparency enabled (alpha channel)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)  // 'false' for transparent background
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Set the blend mode to alpha and the image as background
        context.setBlendMode(.normal)
        image.draw(at: .zero)

        // Ensure the mask is available
        guard let maskCgImage = mask.cgImage else { return nil }

        // Clip the context to the mask: the image will only be visible where the mask is non-transparent
        context.clip(to: CGRect(origin: .zero, size: image.size), mask: maskCgImage)

        // Fill the clipped region with transparent background (the image outside the mask will be transparent)
        context.clear(CGRect(origin: .zero, size: image.size))  // Clear the context where the mask is not present

        // Get the final image with transparency where the mask is applied
        let result = UIGraphicsGetImageFromCurrentImageContext()

        // End the image context
        UIGraphicsEndImageContext()

        return result
    }



 
    func hasForeground(in image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(false)
            return
        }
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
                if let result = request.results?.first as? VNPixelBufferObservation {
                    let pixelBuffer = result.pixelBuffer
                    let foregroundRatio = self.calculateForegroundRatio(from: pixelBuffer)

                    // Define a threshold for foreground presence
                    let hasForeground = foregroundRatio > 0.1 // e.g., 10%
                    DispatchQueue.main.async {
                        completion(hasForeground)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                print("Failed to perform segmentation: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    private func calculateForegroundRatio(from pixelBuffer: CVPixelBuffer) -> Float {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return 0 }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)

        let threshold: UInt8 = 127 // Foreground threshold
        var foregroundCount = 0
        var totalCount = 0

        for y in 0..<height {
            let row = baseAddress + y * rowBytes
            for x in 0..<width {
                let pixel = row.assumingMemoryBound(to: UInt8.self)[x]
                if pixel > threshold {
                    foregroundCount += 1
                }
                totalCount += 1
            }
        }

        return Float(foregroundCount) / Float(totalCount)
    }
}
