import Foundation
import AppKit

// Simple icon generator for Forgetze app
// This script creates basic icon images with the app name

func createIcon(size: Int, scale: Int = 1) -> NSImage {
    let finalSize = size * scale
    let image = NSImage(size: NSSize(width: finalSize, height: finalSize))
    
    image.lockFocus()
    
    // Background - light blue
    NSColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0).setFill()
    NSRect(x: 0, y: 0, width: finalSize, height: finalSize).fill()
    
    // Text
    let text = "Forgetze"
    let font = NSFont.boldSystemFont(ofSize: CGFloat(finalSize) * 0.15)
    let textAttributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white
    ]
    
    let textSize = text.size(withAttributes: textAttributes)
    let textRect = NSRect(
        x: (CGFloat(finalSize) - textSize.width) / 2,
        y: (CGFloat(finalSize) - textSize.height) / 2,
        width: textSize.width,
        height: textSize.height
    )
    
    text.draw(in: textRect, withAttributes: textAttributes)
    
    image.unlockFocus()
    return image
}

func saveIcon(size: Int, scale: Int = 1, filename: String) {
    let image = createIcon(size: size, scale: scale)
    
    if let tiffData = image.tiffRepresentation,
       let bitmapRep = NSBitmapImageRep(data: tiffData),
       let pngData = bitmapRep.representation(using: .png, properties: [:]) {
        
        let url = URL(fileURLWithPath: filename)
        try? pngData.write(to: url)
        print("Generated: \(filename)")
    }
}

// Generate all required icon sizes
let iconSizes = [
    (20, 1, "Icon-20.png"),
    (20, 2, "Icon-20@2x.png"),
    (20, 3, "Icon-20@3x.png"),
    (29, 1, "Icon-29.png"),
    (29, 2, "Icon-29@2x.png"),
    (29, 3, "Icon-29@3x.png"),
    (40, 1, "Icon-40.png"),
    (40, 2, "Icon-40@2x.png"),
    (40, 3, "Icon-40@3x.png"),
    (60, 2, "Icon-60@2x.png"),
    (60, 3, "Icon-60@3x.png"),
    (76, 1, "Icon-76.png"),
    (76, 2, "Icon-76@2x.png"),
    (84, 2, "Icon-83.5@2x.png"),
    (1024, 1, "Icon-1024.png")
]

print("Generating Forgetze app icons...")

for (size, scale, filename) in iconSizes {
    saveIcon(size: size, scale: scale, filename: filename)
}

print("Icon generation complete!")
