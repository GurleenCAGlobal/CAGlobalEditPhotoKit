# CAGlobal Photo Editor SDK - Handover Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Key Features](#key-features)
4. [Project Structure](#project-structure)
5. [Integration Guide](#integration-guide)
6. [Configuration](#configuration)
7. [API Reference](#api-reference)
8. [Dependencies](#dependencies)
9. [Build & Deployment](#build--deployment)
10. [Troubleshooting](#troubleshooting)
11. [Maintenance Notes](#maintenance-notes)

---

## Overview

**CAGlobal Photo Editor SDK** is a comprehensive iOS photo editing framework that provides a full-featured photo editing experience. The SDK enables applications to offer professional-grade photo editing capabilities including filters, adjustments, frames, stickers, text overlays, brush tools, and transformation features.

### Key Information
- **Platform**: iOS (Swift)
- **Language**: Swift with Objective-C bridging
- **Minimum iOS Version**: Not specified (check project settings)
- **Bundle ID**: `com.caglobal.CAGlobalPhotoSDK`
- **Main Entry Point**: `CAEditViewController`

---

## Architecture

### Design Pattern
The SDK follows an **MVC (Model-View-Controller)** architecture with the following components:

- **ViewControllers**: Handle user interactions and UI presentation
- **Managers**: Business logic and data management
- **Models**: Data structures and API models
- **Views**: Custom UI components and reusable views
- **Helpers**: Utility classes and extensions

### Core Components

1. **CAEditViewController**: Main editing interface controller
2. **GlobalHelper**: Singleton for shared state management
3. **Managers**: Feature-specific managers (Filters, Stickers, Text, etc.)
4. **BaseViewController**: Base class with common editing utilities

---

## Key Features

### 1. **Image Filters**
- Auto enhancement
- 30+ built-in filters (ZipLut, Sin, Lomo, AD1920, Lenin, SepiaHigh, Winter, Pola669, PolaSX, Food, Glam, Chest, Front, K1, K2, K6, KDynamic, Fridge, Orchid, X400, Fixie, BW, Quozi, Celsius, Texas)
- Filter opacity control
- Real-time preview

### 2. **Adjustments**
- Brightness
- Contrast
- Saturation
- Temperature
- Exposure

### 3. **Frames**
- Multiple frame categories:
  - Mother's Day (20 frames)
  - Kindness (18 frames)
  - Valentine (18 frames)
  - New Year (10 frames)
  - Holiday (16 frames)
  - Winter (9 frames)
  - Thanksgiving (23 frames)
  - Solid (30 frames)
- Dynamic sizing based on photo dimensions
- Landscape and portrait support

### 4. **Stickers**
- Built-in sticker categories:
  - Shapes (64 stickers)
  - Emoticons (58 stickers)
  - Badges (15 stickers)
  - Arrows (2 stickers)
  - Spray (3 stickers)
  - Nature category
  - Sports category
  - Well-being category
- API-based stickers (dynamic loading)
- Custom sticker support
- Sticker transformation (move, resize, rotate, mirror)
- Color tinting for shape stickers

### 5. **Text Overlays**
- Multiple font support (40+ fonts including NotoSans, Montserrat, Avenir, Dense, Sofia, OpenSans, Raleway, HP Simplified, Oswald, Agbalumo, Alatsi, Aleo, Bangers, Baskerville, BebasNeue, Bodoni, Bradley Hand, BubblegumSans, Bungee, Calistoga, Caveat, Comfortaa, Copperplate, Flama, Futura, Galada, Georgia, GillSans, and more)
- Text color customization
- Background color for text
- Text alignment (left, center, right)
- Opacity control
- Text transformation (move, resize, rotate)

### 6. **Brush Tools**
- Drawing with customizable:
  - Color
  - Size
  - Opacity/Transparency
  - Sharpness
- Undo/Redo support for brush strokes

### 7. **Transform Tools**
- Crop with aspect ratio selection
- Rotate
- Flip (horizontal/vertical)
- Mirror
- Angle adjustment with ruler

### 8. **Additional Features**
- Undo/Redo system for all editing actions
- Photo gallery integration
- Custom ruler/canvas support
- Blank canvas creation
- Background removal
- Image save functionality
- Print integration support

---

## Project Structure

```
CAGlobalPhotoEditorSDK/
├── CAGlobalPhotoSDK/
│   ├── AppDelegate/
│   │   └── AppDelegate.swift
│   ├── MainViewController/
│   │   ├── Controller/
│   │   │   └── CAGalleryViewController.swift
│   │   ├── ViewModel/
│   │   │   └── GalleryViewModel.swift
│   │   ├── Views/
│   │   └── Storyboard/
│   ├── ViewControllers/
│   │   ├── BaseViewController/
│   │   │   └── BaseViewController.swift
│   │   ├── EditViewController/
│   │   │   ├── CAEditViewController.swift (Main Editor)
│   │   │   ├── CAEditAdjustOptionsViewController.swift
│   │   │   ├── CAEditBlurViewController.swift
│   │   │   ├── CAEditBrushViewController.swift
│   │   │   ├── CAEditCommonViewController.swift
│   │   │   ├── CAEditFiltersViewController.swift
│   │   │   ├── CAEditFramesViewController.swift
│   │   │   ├── CAEditSaveViewController.swift
│   │   │   ├── CAEditStickersViewController.swift
│   │   │   ├── CAEditTextViewController.swift
│   │   │   ├── CAEditTransformViewController.swift
│   │   │   ├── Model/
│   │   │   ├── ViewModel/
│   │   │   └── Views/
│   │   ├── CustomStickerViewController/
│   │   └── TextViewController/
│   ├── Managers/
│   │   ├── AdjustManager.swift
│   │   ├── BlurManager.swift
│   │   ├── CollageLayoutManager.swift
│   │   ├── ColorManager.swift
│   │   ├── EffectManager.swift
│   │   ├── FiltersManager.swift
│   │   ├── FontManager.swift
│   │   ├── FramesManager.swift
│   │   ├── OpacityManager.swift
│   │   ├── StickerManager.swift
│   │   └── TextManager.swift
│   ├── HelperClasses/
│   │   ├── CustomUndoRedoManager.swift
│   │   ├── Extensions/
│   │   ├── GlobalHelperClass.swift
│   │   ├── Localization/
│   │   ├── Objects/
│   │   ├── RemoveBackground.swift
│   │   ├── SaveImageGallery/
│   │   ├── TextBoxHandlers.swift
│   │   ├── ThirdPartyViews/
│   │   └── View/
│   ├── Resources/
│   │   ├── Info.plist
│   │   ├── Fonts (40+ custom fonts)
│   │   ├── Images (Stickers, Frames, Icons)
│   │   └── JSON files
│   └── load.png
├── CAGlobal-Bridging-Header.h
├── CAGlobalPhotoSDK.xcodeproj/
├── CAGlobalPhotoSDK.xcworkspace/
├── fastlane/
│   ├── Appfile
│   ├── Fastfile
│   └── README.md
├── Gemfile
└── AuthKey_78UG2ZMVS2.p8 (App Store Connect API Key)
```

---

## Integration Guide

### Prerequisites
- Xcode (latest version recommended)
- iOS deployment target (check project settings)
- CocoaPods or Swift Package Manager (if dependencies are managed)

### Step 1: Add SDK to Your Project

#### Option A: Direct Integration
1. Copy the `CAGlobalPhotoSDK` folder to your project
2. Add the SDK files to your Xcode project
3. Ensure the bridging header is properly configured

#### Option B: Framework Integration
1. Build the SDK as a framework
2. Import the framework into your project
3. Link the framework in your target's "Link Binary With Libraries"

### Step 2: Configure Info.plist

Add the following permissions to your `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to edit photos</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save edited photos to your library</string>

<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos</string>
```

### Step 3: Initialize the Editor

```swift
import UIKit

class YourViewController: UIViewController {
    
    func openPhotoEditor(with image: UIImage) {
        let editViewController = CAEditViewController(nibName: "CAEditViewController", bundle: nil)
        
        // Configure the editor
        editViewController.imageOrignal = image
        editViewController.imageOrignalBackUp = image
        
        // Calculate aspect ratio
        let imageHeight = image.size.height
        let imageWidth = image.size.width
        var bestFitRatioValue: CGFloat?
        var isLandscape = true
        
        if imageHeight > imageWidth {
            isLandscape = false
            bestFitRatioValue = round(((imageHeight/imageWidth) * 2) * 10) / 10.0
        } else {
            isLandscape = true
            bestFitRatioValue = round(((imageWidth/imageHeight) * 2) * 10) / 10.0
        }
        
        editViewController.selectedRatioWith = bestFitRatioValue ?? 0.0
        editViewController.isLandscape = isLandscape
        
        // Set delegate for callbacks
        editViewController.customDelegate = self
        
        // Present the editor
        navigationController?.pushViewController(editViewController, animated: true)
    }
}

// MARK: - EditImageDelegate
extension YourViewController: EditImageDelegate {
    func printImage(image: UIImage) {
        // Handle the edited image
        // This is called when user completes editing
        GlobalHelper.sharedManager.finalEditImage = image
        GlobalHelper.sharedManager.isEditComplete = true
        
        // Process the edited image
        processEditedImage(image)
    }
    
    func processEditedImage(_ image: UIImage) {
        // Save to gallery, upload, or display
        // Example: Save to photo library
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
```

### Step 4: Access Edited Image

The edited image can be accessed through:

```swift
// Method 1: From GlobalHelper
let editedImage = GlobalHelper.sharedManager.finalEditImage

// Method 2: From delegate callback
// Implement EditImageDelegate.printImage(image:)
```

---

## Configuration

### API Endpoints

The SDK uses the following API endpoints for dynamic content:

**Stickers API:**
- Development: `http://qazip.smilecdn.site/api/stickers`
- Production: `http://zip.smilecdn.site/api/stickers`

**Frames API:**
- Development: `http://qazip.smilecdn.site/api/frames`
- Production: `http://zip.smilecdn.site/api/frames`

**Events API:**
- Production: `http://smile.smilecdn.site/api/`
- Development: `http://qa.smilecdn.site/api/`

**Configuration Location:**
- File: `CAGlobalPhotoSDK/ViewControllers/EditViewController/Model/ApiModel.swift`
- Update `EventsUrl.main` to switch between dev/production

### App Transport Security

The SDK allows arbitrary loads (configured in Info.plist):
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

⚠️ **Note**: For production, consider restricting to specific domains.

### Printer Configuration

Printer settings are configured in `CAEditViewController.swift`:
```swift
var printerDPI = 500
var printerWidth = 2.0447 // Print head width in inches
```

---

## API Reference

### GlobalHelper

Singleton class for shared state management.

```swift
@objcMembers public class GlobalHelper: NSObject {
    static let sharedManager = GlobalHelper()
    
    // Properties
    var finalEditImage: UIImage
    var isEditComplete: Bool
    var hadChanges: Bool
    var navigationController: UINavigationController
    var selectedRatioWith: CGFloat
    
    // Copilot tracking
    var copilotFrameIds: [String]
    var copilotStickerIds: [String]
    var copilotFontIds: [String]
    
    // Methods
    func clearImglyCopilot()
}
```

### CAEditViewController

Main photo editing view controller.

**Key Properties:**
```swift
@objc var imageOrignal: UIImage!          // Original image
@objc var imageOrignalBackUp: UIImage!    // Backup of original
@objc var selectedRatioWith: CGFloat      // Aspect ratio
@objc var isLandscape: Bool               // Orientation
public var currentAspectRatioValue: CGFloat
public var aspectRatioLocked: Bool
@objc var customDelegate: EditImageDelegate?
```

**Key Methods:**
```swift
// Image processing
func applyingAllFilters() -> UIImage?

// Transform operations
func saveTransformStateForUndo()
func resetTransform()
func applyTransform()

// Undo/Redo
func undoAction()
func redoAction()
```

### EditImageDelegate Protocol

```swift
@objc protocol EditImageDelegate: AnyObject {
    func printImage(image: UIImage)
}
```

### Managers

#### FiltersManager
```swift
class FiltersManager: NSObject {
    func getFilterData() -> [String]
}
```

#### StickerManager
```swift
class StickerManager: NSObject {
    func getStickerData() -> [String]
    func getShapesData() -> [UIImage]
    func getEmoticonData() -> [UIImage]
    func addSticker(...) -> AddSticker
}
```

#### TextManager
```swift
class TextManager: NSObject {
    func addText(...) -> AddTextView
    func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat
}
```

#### FramesManager
```swift
class FramesManager: NSObject {
    func getFramesData(isLandscape: Bool, selectedRatio: CGFloat) -> String
    func getEmoticonDataNew(isLandscape: Bool, selectedRatio: CGFloat) -> [FrameCategoryModel]
}
```

### BaseViewController

Provides common editing utilities:

```swift
// Image effects
func setEffectOn(image: UIImage, effect: ImageOrientation2) -> UIImage
func applyAutoEnhancement(to image: UIImage) -> UIImage?
func autoEnhance(image: UIImage, all: Bool, isRedEye: Bool) -> UIImage?

// Image adjustments
func increaseBrightness(for image: UIImage, byVal: CGFloat) -> UIImage
func increaseContrast(_ image: UIImage, byVal: CGFloat) -> UIImage
func increaseSaturation(_ image: UIImage, byVal: CGFloat) -> UIImage
func temperature(_ image: UIImage, byVal: CGFloat) -> UIImage
func increaseExposure(for image: UIImage, byVal: CGFloat) -> UIImage

// Image capture
func captureImageInView(inView: UIView) -> UIImage?
func captureImageToSave(inView: UIView, rect: CGRect) -> UIImage?
```

---

## Dependencies

### Third-Party Libraries

1. **GPUImage** (via Bridging Header)
   - Used for advanced image processing and filters
   - Location: `CAGlobalPhotoSDK/HelperClasses/ThirdPartyViews/GPUImage/`

2. **IHProgressHUD**
   - Progress indicator
   - Location: `CAGlobalPhotoSDK/HelperClasses/ThirdPartyViews/IHProgressHUD/`

### System Frameworks

- `UIKit`
- `Photos` (Photo library access)
- `CoreImage` (Image processing)
- `Accelerate` (Performance optimization)
- `AudioToolbox` (Haptic feedback)
- `SystemConfiguration` (Network connectivity)

### Fonts

40+ custom fonts are bundled with the SDK. See `Info.plist` for the complete list.

---

## Build & Deployment

### Building the SDK

1. Open `CAGlobalPhotoSDK.xcworkspace` (not .xcodeproj)
2. Select the appropriate scheme
3. Build for your target (Simulator or Device)

### Fastlane Integration

The project includes Fastlane for automated builds and TestFlight deployment.

**Configuration:**
- Fastfile: `fastlane/Fastfile`
- App Store Connect API Key: `AuthKey_78UG2ZMVS2.p8`
- Key ID: `78UG2ZMVS2`
- Issuer ID: `69a6de7a-6517-47e3-e053-5b8c7c11a4d1`

**Build Command:**
```bash
bundle exec fastlane ios beta
```

This will:
1. Build the app
2. Export for App Store
3. Upload to TestFlight

### Provisioning Profiles

- Profile Name: `CaglobalSDK_Appstore`
- Bundle ID: `com.caglobal.CAGlobalPhotoSDK`

### Build Settings

Key build settings to verify:
- **Code Signing**: Ensure proper provisioning profiles
- **Swift Version**: Check project Swift version compatibility
- **Deployment Target**: Verify minimum iOS version
- **Bitcode**: Check if enabled/disabled as needed

---

## Troubleshooting

### Common Issues

#### 1. **Bridging Header Not Found**
**Error**: `'GPUImage.h' file not found`

**Solution**:
- Ensure `CAGlobal-Bridging-Header.h` is properly configured in Build Settings
- Verify the path: `$(SRCROOT)/CAGlobal-Bridging-Header.h`

#### 2. **Fonts Not Loading**
**Error**: Custom fonts not appearing

**Solution**:
- Verify fonts are added to the project and included in the target
- Check `Info.plist` has all fonts listed in `UIAppFonts`
- Ensure font files are in the bundle

#### 3. **API Calls Failing**
**Error**: Stickers/Frames not loading from API

**Solution**:
- Check network connectivity
- Verify API endpoints in `ApiModel.swift`
- Check `NSAppTransportSecurity` settings
- Verify API is accessible and returning valid JSON

#### 4. **Memory Issues with Large Images**
**Error**: App crashes or becomes slow with large images

**Solution**:
- Implement image resizing before passing to editor
- Consider using lower resolution for preview
- Monitor memory usage with Instruments

#### 5. **Undo/Redo Not Working**
**Error**: Undo/Redo buttons not functioning

**Solution**:
- Check `CustomUndoRedoManager` initialization
- Verify state is being saved before each action
- Check if undo stack is being cleared unintentionally

#### 6. **Image Not Saving**
**Error**: Edited image not saving to gallery

**Solution**:
- Verify `NSPhotoLibraryAddUsageDescription` in Info.plist
- Check photo library permissions
- Ensure `SaveImageGallery` helper is properly implemented

### Debug Tips

1. **Enable Logging**: Add print statements in key methods
2. **Use Instruments**: Profile memory and performance
3. **Check Console**: Monitor for runtime warnings
4. **Test on Device**: Some features may behave differently on simulator

---

## Maintenance Notes

### Code Organization

- **Managers**: Business logic for each feature
- **ViewControllers**: UI and user interaction handling
- **Models**: Data structures and API models
- **Helpers**: Reusable utilities and extensions

### Known Limitations

1. **API Dependencies**: Stickers and frames require network connectivity
2. **Large Images**: Performance may degrade with very large images (>10MP)
3. **Memory Usage**: Multiple undo levels can consume significant memory
4. **Font Loading**: Large number of fonts increases app bundle size

### Future Enhancements

Consider the following improvements:

1. **Caching**: Implement caching for API-loaded stickers/frames
2. **Performance**: Optimize image processing for better performance
3. **Modularization**: Split into smaller, more focused modules
4. **Documentation**: Add inline code documentation
5. **Testing**: Add unit tests for managers and utilities
6. **Error Handling**: Improve error handling and user feedback

### Version Control

- **Git**: Ensure `.gitignore` excludes build artifacts
- **Dependencies**: Document all third-party dependencies
- **Secrets**: Never commit API keys or sensitive data
- **Branches**: Use feature branches for new development

### Code Quality

- **SwiftLint**: Consider adding SwiftLint for code consistency
- **Code Review**: Review all changes before merging
- **Refactoring**: Periodically refactor complex methods
- **Documentation**: Keep documentation up to date

### Security Considerations

1. **API Keys**: Store API keys securely (not in code)
2. **Network**: Use HTTPS for all API calls in production
3. **Permissions**: Request only necessary permissions
4. **Data**: Don't log sensitive user data

### Performance Optimization

1. **Image Processing**: Use background queues for heavy processing
2. **Memory**: Release unused resources promptly
3. **UI**: Keep main thread responsive
4. **Caching**: Cache processed images when possible

---

## Support & Contact

For issues, questions, or feature requests:

- **Developer**: Gurleen Singh
- **Created**: March 2023
- **Last Updated**: Check git history

---

## Appendix

### Filter List
- ZipLut_1, Sin, Lomo, AD1920, Lenin, SepiaHigh, Winter, Pola669, PolaSX, Food, Glam, Chest, Front, K1, K2, K6, KDynamic, Fridge, Orchid, X400, Fixie, BW, Quozi, Celsius, Texas

### Font List (Partial)
NotoSans, Montserrat, Avenir, Dense, Sofia, OpenSans, Raleway, HP Simplified, Oswald, Agbalumo, Alatsi, Aleo, Bangers, Baskerville, BebasNeue, Bodoni, Bradley Hand, BubblegumSans, Bungee, Calistoga, Caveat, Comfortaa, Copperplate, Flama, Futura, Galada, Georgia, GillSans, and more.

### Frame Categories
- Mother's Day: 20 frames
- Kindness: 18 frames
- Valentine: 18 frames
- New Year: 10 frames
- Holiday: 16 frames
- Winter: 9 frames
- Thanksgiving: 23 frames
- Solid: 30 frames

---

**Document Version**: 1.0  
**Last Updated**: [Current Date]  
**Maintained By**: Development Team
