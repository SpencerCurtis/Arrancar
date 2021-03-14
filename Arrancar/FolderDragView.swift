//
//  FileDragDestinationView.swift
//  Arrancar
//
//  Created by Spencer Curtis on 4/8/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

class FolderDragView: NSView {

    var acceptableTypes: Set<String> { return [NSPasteboard.PasteboardType(kUTTypeURL as String).rawValue] }
    let filteringOptions = [convertFromNSPasteboardReadingOptionKey(NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly): 1]
    
    enum DraggedFolderType: String {
        case target = "Add to folder(s) containing files to be modified"
        case destination = "Add as destination folder"
        case none = "none"
    }
    
    var blurFilter: CIFilter?
    var folderType: DraggedFolderType?
    var folderTypeLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")

        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.alignment = .center
        
        return label

    }()
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
            guard let layer = self.layer, let backgroundFilters = layer.backgroundFilters, backgroundFilters.count > 0 else { return }
            self.layer?.backgroundFilters?.remove(at: 0)
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
            path.lineWidth = 8
            path.stroke()
            displayFolderTypeLabel()
        }
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
    
        isReceivingDrag = false
        hideFolderTypeLabel()
        let pasteBoard = draggingInfo.draggingPasteboard
    
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:convertToOptionalNSPasteboardReadingOptionKeyDictionary(filteringOptions)) as? [URL], urls.count > 0 {
            
            if folderType == .target {
            
            ItemController.shared.folderPaths  += urls.filter({$0.hasDirectoryPath})
            } else if folderType == .destination {
            ItemController.shared.destinationFolder = urls.filter({$0.hasDirectoryPath}).first
            }
            return true
        }
        return false
        
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        
        if allow {
            guard let blurFilter = blurFilter else { return NSDragOperation() }
            self.layer?.backgroundFilters?.insert(blurFilter, at: 0)
        }
        return allow ? .copy : NSDragOperation()
        
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
        hideFolderTypeLabel()
        guard let layer = self.layer, let backgroundFilters = layer.backgroundFilters, backgroundFilters.count > 0 else { return }

        self.layer?.backgroundFilters?.remove(at: 0)
    }
    
    func setupWith(folderType: DraggedFolderType) {
        registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray(Array(acceptableTypes)))
        self.folderType = folderType
        let centerYConstraint = NSLayoutConstraint(item: folderTypeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 4)
        let leadingConstraint = NSLayoutConstraint(item: folderTypeLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 4)
        let trailingConstraint = NSLayoutConstraint(item: folderTypeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 4)
        
        folderTypeLabel.alphaValue = 0
        folderTypeLabel.stringValue = folderType.rawValue
        self.addSubview(folderTypeLabel)
        self.addConstraints([centerYConstraint, leadingConstraint, trailingConstraint])
        
        guard let labelFont = folderTypeLabel.font else { return }
        
        let newFont = NSFont(name: labelFont.fontName, size: 30)
        folderTypeLabel.font = newFont
        
    }
    
    func displayFolderTypeLabel() {
        folderTypeLabel.alphaValue = 1
    }
    
    
    func hideFolderTypeLabel() {
        folderTypeLabel.alphaValue = 0
    }
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        
        let pasteBoard = draggingInfo.draggingPasteboard
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:convertToOptionalNSPasteboardReadingOptionKeyDictionary(filteringOptions)) as? [URL],urls.filter({$0.hasDirectoryPath}).count > 0 {
            if folderType == .target {
                canAccept = true
            } else if folderType == .destination && urls.count == 1 {
                canAccept = true
            }
        }
        
        return canAccept
        
    }
}

extension NSView {
    
    var backgroundColor: NSColor? {
        
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSPasteboardReadingOptionKey(_ input: NSPasteboard.ReadingOptionKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSPasteboardReadingOptionKeyDictionary(_ input: [String: Any]?) -> [NSPasteboard.ReadingOptionKey: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSPasteboard.ReadingOptionKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardTypeArray(_ input: [String]) -> [NSPasteboard.PasteboardType] {
	return input.map { key in NSPasteboard.PasteboardType(key) }
}
