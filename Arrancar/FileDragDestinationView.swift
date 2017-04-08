//
//  FileDragDestinationView.swift
//  Arrancar
//
//  Created by Spencer Curtis on 4/8/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

class FileDragDestinationView: NSView {

    var acceptableTypes: Set<String> { return [NSURLPboardType] }
    let filteringOptions = [NSPasteboardURLReadingFileURLsOnlyKey: 1]
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect:bounds)
            path.lineWidth = 5
            path.stroke()
        }
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
    
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard()
    
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
            
            ItemController.shared.folderPaths  += urls.filter({$0.hasDirectoryPath})
            return true
        }
        return false
        
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    func setup() {
        register(forDraggedTypes: Array(acceptableTypes))
    }
    
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL],urls.filter({$0.hasDirectoryPath}).count > 0 {
            canAccept = true
        }
        
        return canAccept
        
    }
}
