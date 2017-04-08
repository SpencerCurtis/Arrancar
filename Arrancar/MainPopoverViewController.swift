//
//  MainPopoverViewController.swift
//  Arrancar
//
//  Created by Spencer Curtis on 4/7/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

class MainPopoverViewController: NSViewController {
    
    @IBOutlet weak var allVideoTypesCheckboxButton: NSButton!
    @IBOutlet weak var movFileTypeButton: NSButton!
    @IBOutlet weak var mp4FileTypeButton: NSButton!
    @IBOutlet weak var mkvFileTypeButton: NSButton!
    
    @IBOutlet weak var allImageTypesCheckboxButton: NSButton!
    @IBOutlet weak var jpgFileTypeButton: NSButton!
    @IBOutlet weak var pngFileTypeButton: NSButton!
    
    @IBOutlet weak var folderSelectedCountLabel: NSTextField!
    @IBOutlet weak var destinationFolderLabel: NSTextField!
    @IBOutlet weak var otherFileExtensionsTextField: NSTextField!
    @IBOutlet weak var arrancarButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var checkboxButtons: [NSButton] = []
    
    var allVideoTypesAreChecked = false
    var allImageTypesAreChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Arrancar"
        arrancarButton.isEnabled = false
        checkboxButtons = [movFileTypeButton, mp4FileTypeButton, mkvFileTypeButton, jpgFileTypeButton, pngFileTypeButton]
    }
    
    
    func toggleAllVideoCheckboxButtons() {
        
        let state = allVideoTypesCheckboxButton.state
        
        movFileTypeButton.state = state
        mp4FileTypeButton.state = state
        mkvFileTypeButton.state = state
        allVideoTypesAreChecked = state == 1 ? true : false
        print(allVideoTypesAreChecked)
    }
    func toggleAllImageCheckboxButtons() {
        
        let state = allImageTypesCheckboxButton.state
        
        jpgFileTypeButton.state = state
        pngFileTypeButton.state = state
        
        allImageTypesAreChecked = state == 1 ? true : false
        print(allImageTypesCheckboxButton)
    }
    
    
    @IBAction func allVideoTypesCheckboxButtonClicked(_ sender: Any) {
        toggleAllVideoCheckboxButtons()
    }
    
    @IBAction func allImageTypesCheckboxButtonClicked(_ sender: Any) {
        toggleAllImageCheckboxButtons()
    }
    
    @IBAction func folderSelectButtonClicked(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        openPanel.begin { (result) in
            
            guard result == NSFileHandlingPanelOKButton else { return }
            ItemController.shared.folderPaths = openPanel.urls
            
            let folderCount = openPanel.urls.filter({$0.hasDirectoryPath}).count
            
            self.folderSelectedCountLabel.stringValue = "\(folderCount) Folders Selected"
            if ItemController.shared.destinationFolder != nil && ItemController.shared.folderPaths.count > 0 {
                self.arrancarButton.isEnabled = true
            }
        }
    }
    
    @IBAction func destinationFolderButtonClicked(_ sender: Any) {
        
        let openPanel = NSOpenPanel()
        
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        openPanel.begin { (result) in
            
            guard let destination = openPanel.url, result == NSFileHandlingPanelOKButton else { return }
            ItemController.shared.destinationFolder = destination
            self.destinationFolderLabel.stringValue = "Files will be moved to \(destination.lastPathComponent)"
            if ItemController.shared.destinationFolder != nil && ItemController.shared.folderPaths.count > 0 {
                self.arrancarButton.isEnabled = true
            }
        }
    }
    
    @IBAction func arrancarButtonClicked(_ sender: Any) {
        guard let destinationFolder = ItemController.shared.destinationFolder else { return }
        self.progressIndicator.startAnimation(self)
        let selectedButtons = checkboxButtons.filter({$0.state == 1})
        
        var selectedTypes = selectedButtons.map({$0.title})
        selectedTypes += selectedTypes.map({$0.lowercased()})
        if otherFileExtensionsTextField.stringValue != "" {
            let otherFileTypes = otherFileExtensionsTextField.stringValue.components(separatedBy: .whitespaces)
            selectedTypes += otherFileTypes
        }
        
        for selectedFolder in ItemController.shared.folderPaths {
            ItemController.shared.getURLsForAllFilesIn(directory: selectedFolder, ofTypes: selectedTypes)
        }
        
        guard ItemController.shared.filesToBeMoved.count > 0 else { self.destinationFolderLabel.stringValue = "No files matching your criteria were found"; self.progressIndicator.stopAnimation(self); return }
        
        ItemController.shared.move(files: ItemController.shared.filesToBeMoved, toNewDirectory: destinationFolder) { (success) in
            if success {
                self.destinationFolderLabel.stringValue = "Files successfully moved to \(destinationFolder.lastPathComponent)"
            } else {
                self.destinationFolderLabel.stringValue = "Files could not be moved to \(destinationFolder.lastPathComponent)"
            }
            self.progressIndicator.stopAnimation(self)
            ItemController.shared.filesToBeMoved = []
        }
    }
}
