//
//  MainPopoverViewController.swift
//  Arrancar
//
//  Created by Spencer Curtis on 4/7/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, ArrancarPreparationDelegate {
    
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
    @IBOutlet weak var ignoreStringTextField: NSTextField!
    @IBOutlet weak var copyToDestinationButton: NSButton!
    @IBOutlet weak var moveToDestinationButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var singleFiletypeCheckboxButtons: [NSButton] = []
    var singleVideoTypeCheckboxButtons: [NSButton] = []
    var singleImageTypeCheckboxButtons: [NSButton] = []
    
    var allVideoTypesAreChecked = false
    var allImageTypesAreChecked = false
    
    var defaultFolderSelectedCountLabelText = "0 Folders Selected"
    var defaultDestinationFolderLabelText = "Select a destination folder above"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Arrancar"
        
        toggleDestinationOperationButtonsEnabledState()
        
        singleFiletypeCheckboxButtons = [movFileTypeButton, mp4FileTypeButton, mkvFileTypeButton, jpgFileTypeButton, pngFileTypeButton]
        singleVideoTypeCheckboxButtons = [movFileTypeButton, mp4FileTypeButton, mkvFileTypeButton]
        singleImageTypeCheckboxButtons = [jpgFileTypeButton, pngFileTypeButton]
        
        singleVideoTypeCheckboxButtons.forEach({$0.action = #selector(checkIfAllVideoCheckboxButtonsAreChecked(sender:))})
        singleImageTypeCheckboxButtons.forEach({$0.action = #selector(checkIfAllImageCheckboxButtonsAreChecked(sender:))})

        
        setupFileDragDestinationView()
        setupDragTargetFoldersView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFolderSelectedCountLabelWith(notification:)), name: ItemController.shared.folderPathsWereSetNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDestinationFolderLabelWith(notification:)), name: ItemController.shared.destinationFolderWasSetNotification, object: nil)
        ItemController.shared.delegate = self
    }
    
    func setupDragTargetFoldersView() {
        let height = self.view.frame.size.height / 2
        let width = self.view.frame.size.width
        let frame = CGRect(x: 0, y: height, width: width, height: height)

        let dragTargetFoldersView = FolderDragView(frame: frame)
        dragTargetFoldersView.setupWith(folderType: .target)
        dragTargetFoldersView.wantsLayer = true
        dragTargetFoldersView.layerUsesCoreImageFilters = true
        
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return }
        blurFilter.setDefaults()
        blurFilter.setValue(3.5, forKey: kCIInputRadiusKey)
        dragTargetFoldersView.blurFilter = blurFilter
        
        self.view.addSubview(dragTargetFoldersView)
    }
    
    func setupFileDragDestinationView() {
        let height = self.view.frame.size.height / 2
        let width = self.view.frame.size.width
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let fileDragDestinationView = FolderDragView(frame: frame)
        fileDragDestinationView.setupWith(folderType: .destination)
        fileDragDestinationView.wantsLayer = true
        fileDragDestinationView.layerUsesCoreImageFilters = true
        
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return }
        blurFilter.setDefaults()
        blurFilter.setValue(3.5, forKey: kCIInputRadiusKey)
        fileDragDestinationView.blurFilter = blurFilter

        self.view.addSubview(fileDragDestinationView)
    }
    
    @objc func updateDestinationFolderLabelWith(notification: Notification) {
        let destinationFolderKey = ItemController.shared.destinationFolderKey
        guard let destinationFolderURL = notification.userInfo?[destinationFolderKey] as? URL else { return }
        
        destinationFolderLabel.stringValue = "Your destination folder is: \(destinationFolderURL.lastPathComponent)"
        toggleDestinationOperationButtonsEnabledState()
    }
    
    @objc func updateFolderSelectedCountLabelWith(notification: Notification) {
        let folderPathCountKey = ItemController.shared.folderPathCountKey
        guard let folderCount = notification.userInfo?[folderPathCountKey] as? Int else { return }
        
        var labelText = "\(folderCount) "
        labelText += folderCount > 1 ? "Folders selected" : "Folder Selected"
        
        folderSelectedCountLabel.stringValue = labelText
        toggleDestinationOperationButtonsEnabledState()
    }
    
    func toggleAllVideoCheckboxButtons() {
        
        let state = allVideoTypesCheckboxButton.state
        
        movFileTypeButton.state = state
        mp4FileTypeButton.state = state
        mkvFileTypeButton.state = state
        allVideoTypesAreChecked = state.rawValue == 1 ? true : false
    }
    func toggleAllImageCheckboxButtons() {
        
        let state = allImageTypesCheckboxButton.state
        
        jpgFileTypeButton.state = state
        pngFileTypeButton.state = state
        
        allImageTypesAreChecked = state.rawValue == 1 ? true : false
    }
    
    @objc func checkIfAllVideoCheckboxButtonsAreChecked(sender: NSButton) {
        
        
        if singleVideoTypeCheckboxButtons.filter({$0.state.rawValue == 0}).count != singleVideoTypeCheckboxButtons.count {
            allVideoTypesCheckboxButton.state = convertToNSControlStateValue(0)
        }
        
        
        if singleVideoTypeCheckboxButtons.filter({$0.state.rawValue == 1}).count == singleVideoTypeCheckboxButtons.count {
            allVideoTypesCheckboxButton.state = convertToNSControlStateValue(1)
        }

    }
    
    @objc func checkIfAllImageCheckboxButtonsAreChecked(sender: NSButton) {
        
        
        if singleImageTypeCheckboxButtons.filter({$0.state.rawValue == 0}).count != singleImageTypeCheckboxButtons.count {
            allImageTypesCheckboxButton.state = convertToNSControlStateValue(0)
        }
        
        
        if singleImageTypeCheckboxButtons.filter({$0.state.rawValue == 1}).count == singleImageTypeCheckboxButtons.count {
            allImageTypesCheckboxButton.state = convertToNSControlStateValue(1)
        }
    
    }
    
    func toggleDestinationOperationButtonsEnabledState() {
        if ItemController.shared.destinationFolder != nil && ItemController.shared.folderPaths.count > 0 {
            self.moveToDestinationButton.isEnabled = true
            self.copyToDestinationButton.isEnabled = true
        } else if ItemController.shared.destinationFolder == nil && ItemController.shared.folderPaths.count == 0 {
            self.moveToDestinationButton.isEnabled = false
            self.copyToDestinationButton.isEnabled = false
        }
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
            
            guard result.rawValue == NSFileHandlingPanelOKButton else { return }
            ItemController.shared.folderPaths = openPanel.urls
            
            let folderCount = openPanel.urls.filter({$0.hasDirectoryPath}).count
            
            var labelText = "\(folderCount) "
            labelText += folderCount > 1 ? "Folders selected" : "Folder Selected"
            
            self.folderSelectedCountLabel.stringValue = labelText
            self.toggleDestinationOperationButtonsEnabledState()
        }
    }
    
    @IBAction func destinationFolderButtonClicked(_ sender: Any) {
        
        let openPanel = NSOpenPanel()
        
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        openPanel.begin { (result) in
            
            guard let destination = openPanel.url, result.rawValue == NSFileHandlingPanelOKButton else { return }
            ItemController.shared.destinationFolder = destination
            self.destinationFolderLabel.stringValue = "Your destination folder is: \(destination.lastPathComponent)"
//            self.toggleDestinationOperationButtonsEnabledState()
        }
    }
    
    func prepareForSelectedFileModification() {
        self.progressIndicator.startAnimation(self)
        let selectedButtons = singleFiletypeCheckboxButtons.filter({$0.state.rawValue == 1})
        
        var selectedTypes = selectedButtons.map({$0.title})
        selectedTypes += selectedTypes.map({$0.lowercased()})
        if otherFileExtensionsTextField.stringValue != "" {
            let otherFileTypes = otherFileExtensionsTextField.stringValue.components(separatedBy: .whitespaces)
            selectedTypes += otherFileTypes
        }
        
        let wordsToIgnore = ignoreStringTextField.stringValue.components(separatedBy: " ")
        
        for selectedFolder in ItemController.shared.folderPaths {
            ItemController.shared.getURLsForAllFilesIn(directory: selectedFolder, ofTypes: selectedTypes, ignoringFilesWithWords: wordsToIgnore)
        }
    }
    
    func prepareViewsForNewArrancar() {
        toggleDestinationOperationButtonsEnabledState()
        self.folderSelectedCountLabel.stringValue = defaultFolderSelectedCountLabelText
    }
    
    
    @IBAction func moveToDestinationButtonClicked(_ sender: Any) {
        
        prepareForSelectedFileModification()
        
        guard let destinationFolder = ItemController.shared.destinationFolder else { return }

        guard ItemController.shared.filesToBeModified.count > 0 else { self.destinationFolderLabel.stringValue = "No files matching your criteria were found"; self.progressIndicator.stopAnimation(self); return }
        
        ItemController.shared.modifyFilesToBeModified(toNewDirectory: destinationFolder, withModificationType: .move) { (success) in
            if success {
                self.destinationFolderLabel.stringValue = "Files successfully moved to \(destinationFolder.lastPathComponent)"
            } else {
                self.destinationFolderLabel.stringValue = "Files could not be moved to \(destinationFolder.lastPathComponent)"
            }
            self.progressIndicator.stopAnimation(self)
            NSWorkspace.shared.activateFileViewerSelecting([destinationFolder])
        }
    }
    
    @IBAction func copyToDestinationButtonClicked(_ sender: Any) {
        prepareForSelectedFileModification()
        
        guard let destinationFolder = ItemController.shared.destinationFolder else { return }
        
        guard ItemController.shared.filesToBeModified.count > 0 else { self.destinationFolderLabel.stringValue = "No files matching your criteria were found"; self.progressIndicator.stopAnimation(self); return }
        
        ItemController.shared.modifyFilesToBeModified(toNewDirectory: destinationFolder, withModificationType: .copy) { (success) in
            if success {
                self.destinationFolderLabel.stringValue = "Files successfully copied to \(destinationFolder.lastPathComponent)"
            } else {
                self.destinationFolderLabel.stringValue = "Files could not be copied to \(destinationFolder.lastPathComponent)"
            }
            self.progressIndicator.stopAnimation(self)
            NSWorkspace.shared.activateFileViewerSelecting([destinationFolder])
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
	return NSControl.StateValue(rawValue: input)
}
