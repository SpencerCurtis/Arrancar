//
//  MainPopoverViewController.swift
//  Arrancar
//
//  Created by Spencer Curtis on 4/7/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

class MainPopoverViewController: NSViewController {
    
    var folderPaths: [URL] = []
    var destinationFolder: URL?
    
    var filesToBeMoved: [URL] = []
    var foldersToBeChecked: [URL] = []
    
    let fileManager = FileManager()
    
    @IBOutlet weak var allMovieTypesCheckboxButton: NSButton!
    @IBOutlet weak var movFileTypeButton: NSButton!
    @IBOutlet weak var mp4FileTypeButton: NSButton!
    @IBOutlet weak var mkvFileTypeButton: NSButton!
    
    @IBOutlet weak var allImageTypesCheckboxButton: NSButton!
    @IBOutlet weak var jpgFileTypeButton: NSButton!
    @IBOutlet weak var pngFileTypeButton: NSButton!
    
    @IBOutlet weak var folderSelectedCountLabel: NSTextField!
    @IBOutlet weak var destinationFolderLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    func move(files: [URL], toNewDirectory newDirectory: URL) {
        
        for file in files {
            
            let newPath = newDirectory.appendingPathComponent(file.lastPathComponent)
            do {
                try fileManager.moveItem(at: file, to: newPath)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func getURLsForAllFilesIn(directory: URL, ofTypes types: [String]) {
        
        guard directory.hasDirectoryPath else { return }
        
        
        guard let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return }
        
        for item in contents {
            if item.hasDirectoryPath {
                
                self.foldersToBeChecked.append(item)
                getURLsForAllFilesIn(directory: item, ofTypes: types)
                
            } else if types.contains(item.pathExtension) {
                self.filesToBeMoved.append(item)
            }
        }
        
        if self.foldersToBeChecked.contains(directory) {
            guard let index = self.foldersToBeChecked.index(of: directory) else { return }
            self.foldersToBeChecked.remove(at: index)
        }
    }
    
    @IBAction func folderSelectButtonClicked(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        openPanel.begin { (result) in
            
            guard result == NSFileHandlingPanelOKButton else { return }
            self.folderPaths = openPanel.urls
            
        }
    }
    
    @IBAction func destinationFolderButtonClicked(_ sender: Any) {
        
        let openPanel = NSOpenPanel()
        
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        openPanel.begin { (result) in
            
            guard let destination = openPanel.url, result == NSFileHandlingPanelOKButton else { return }
            self.destinationFolder = destination
            
        }
    }
    
    @IBAction func arrancarButtonClicked(_ sender: Any) {
        guard let destinationFolder = self.destinationFolder else { return }
        
        for selectedFolder in self.folderPaths {
            getURLsForAllFilesIn(directory: selectedFolder, ofTypes: ["jpg"])
        }
    
        self.move(files: self.filesToBeMoved, toNewDirectory: destinationFolder)
    }
}
