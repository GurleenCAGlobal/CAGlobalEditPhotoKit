/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Still Image Texture Provider for MetalImageFilters.
                Uses the MetalKit texture loader to load an still image into a Metal texture.
 */

import MetalKit

/// Uses the MetalKit texture loader to load a still image into a Metal texture.
class StillImageTextureProvider: NSObject {
    /// The source texture for image filter operations.
    var texture: MTLTexture?

    /// Returns an initialized StillImageTextureProvider object with a source texture, or nil in case of failure.
    required init?(device: MTLDevice, imageName: UIImage) {
        super.init()
        
        let loader = MTKTextureLoader(device: device)
        let image = imageName.cgImage
        // The still image is loaded directly into GPU-accessible memory that is only ever read from.
        let options = [
            MTKTextureLoader.Option.textureStorageMode:   MTLStorageMode.private.rawValue,
            MTKTextureLoader.Option.textureUsage:         MTLTextureUsage.shaderRead.rawValue,
            MTKTextureLoader.Option.SRGB:                 0
        ]
        do {
            let fileTexture = try loader.newTexture(cgImage: image!, options: options as [MTKTextureLoader.Option : NSObject]?)
            texture = fileTexture
        } catch let error as NSError {
            print("Error loading still image texture: \(error)")
            return nil
        }
    }
}
