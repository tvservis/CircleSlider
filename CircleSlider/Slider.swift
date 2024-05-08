//
//  Slider.swift
//  CircleSlider
//
//  Created by Václav Kamenický on 08.05.2024.
//

import Cocoa

class Slider: NSView {
    
    // Properties pro nastavení slideru
       var minValue: CGFloat = 0
       var maxValue: CGFloat = 100
        var currentValue: CGFloat = 80 // Počáteční hodnota pro 8 hodin
       
       var handleColor: NSColor = .white
       var handleRadius: CGFloat = 20
       
       // Proměnná pro sledování, zda byla ručička uchopena myší
       var isDraggingHandle = false
       
       // Funkce pro zjištění, zda se kurzor myši nachází uvnitř ručičky
       func isMouseInsideHandle(point: NSPoint) -> Bool {
           let centerX = bounds.midX
           let centerY = bounds.midY
           let angle = atan2(point.y - centerY, point.x - centerX)
           let radius: CGFloat = min(bounds.width, bounds.height) / 2 - 30
           let handleX = centerX + cos(angle) * radius
           let handleY = centerY + sin(angle) * radius
           let handleRect = NSRect(x: handleX - handleRadius, y: handleY - handleRadius, width: handleRadius * 2, height: handleRadius * 2)
           return handleRect.contains(point)
       }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Vykreslení kruhového slideru
        let centerX = bounds.midX
        let centerY = bounds.midY
        let innerRadius: CGFloat = 80
        let radius = min(bounds.width, bounds.height) / 2 - handleRadius
        
        // Definice gradientu mezi modrou a červenou barvou
           let gradient = NSGradient(colors: [NSColor.blue, NSColor.red])
           
        // Vykreslení kruhu s gradientem
           let circlePath = NSBezierPath(ovalIn: NSRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2))
           gradient?.draw(in: circlePath, angle: 0)
        
        // Vykreslení výseče
            let startAngle: CGFloat = 315
            let endAngle: CGFloat = 225
            let section = NSBezierPath()
            section.appendArc(withCenter: CGPoint(x: centerX, y: centerY - 1), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            section.line(to: CGPoint(x: centerX, y: centerY))
            section.close()
            NSColor.windowBackgroundColor.setFill() // Barva výseče
            section.fill()
        
        // Vykreslení středu
           NSColor.windowBackgroundColor.setFill()
           let innerCirclePath = NSBezierPath(ovalIn: NSRect(x: centerX - innerRadius, y: centerY - innerRadius, width: innerRadius * 2, height: innerRadius * 2))
           innerCirclePath.fill()
        
        // Text zobrazující polohu ručičky ve stupních
           let text = "\(Int((currentValue) - 84) * (-1)/2) ºC"
           let attributes: [NSAttributedString.Key: Any] = [
               .font: NSFont.systemFont(ofSize: 20),
               .foregroundColor: NSColor.black
           ]
           let textSize = text.size(withAttributes: attributes)
           let textRect = NSRect(x: centerX - textSize.width / 2, y: centerY - textSize.height / 2, width: textSize.width, height: textSize.height)
           text.draw(in: textRect, withAttributes: attributes)
        
        // Vykreslení ručičky pouze pokud currentValue je v požadovaném rozmezí
        
        if currentValue >= 16 && currentValue <= 84 {
            let newRadius = min(bounds.width, bounds.height) / 2 - handleRadius - 20
            let angle = CGFloat.pi * 2 * (currentValue - minValue) / (maxValue - minValue) - CGFloat.pi / 2
            let handleX = centerX  + cos(angle) * newRadius
            let handleY = centerY  + sin(angle) * newRadius
            let handleRect = NSRect(x: handleX - handleRadius, y: handleY - handleRadius, width: handleRadius * 2, height: handleRadius * 2)
            handleColor.setFill()
            NSBezierPath(ovalIn: handleRect).fill()
        }
    }
    
    // Funkce pro zachycení začátku události tažení myši
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        if isMouseInsideHandle(point: location) {
            isDraggingHandle = true
        }
    }
    
    // Funkce pro zachycení přesunu myši
    override func mouseDragged(with event: NSEvent) {
        guard isDraggingHandle else { return }
        
        let location = convert(event.locationInWindow, from: nil)
        updateHandlePosition(point: location)
    }
    
    // Funkce pro zachycení konce události tažení myši
    override func mouseUp(with event: NSEvent) {
        isDraggingHandle = false
    }
    
    // Funkce pro aktualizaci polohy ručičky na základě aktuální polohy myši
 func updateHandlePosition(point: NSPoint) {
     let centerX = bounds.midX
     let centerY = bounds.midY
     let angle = atan2(point.y - centerY, point.x - centerX)
     let _: CGFloat = min(bounds.width, bounds.height) / 2 - 10
     
     // Převedení úhlu na rozsah 0 až 2π
     var normalizedAngle = angle + CGFloat.pi / 2
     if normalizedAngle < 0 {
         normalizedAngle += CGFloat.pi * 2
     }
     
     // Převedení úhlu na hodnotu v rozmezí minValue až maxValue
     var value = (normalizedAngle / (CGFloat.pi * 2)) * (maxValue - minValue) + minValue
     
     // Omezení na limity 20 a 80
     if value > 84 {
         value = 84
     } else if value < 16 {
         value = 16
     }
     
     currentValue = value
     needsDisplay = true
 }
    
}
