//
//  ItemController.swift
//  Arrancar
//
//  Created by Spencer Curtis on 4/8/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Foundation

class ItemController {
    
    static let shared = ItemController()
    
    weak var delegate: ArrancarPreparationDelegate?
    
    enum FileModificationType {
        case move
        case copy
    }
    
    let folderPathsWereSetNotification = Notification.Name("folderPathsWereSet")
    let destinationFolderWasSetNotification = Notification.Name("destinationFolderWasSet")
    
    let folderPathCountKey = "folderPathCount"
    var folderPaths: [URL] = [] {
        didSet {
            if folderPaths.count > 0 {
                NotificationCenter.default.post(name: folderPathsWereSetNotification, object: self, userInfo: ["folderPathCount": folderPaths.count])
            }
        }
    }
    
    let destinationFolderKey = "destinationFolder"
    var destinationFolder: URL? {
        didSet {
            if let destinationFolder = destinationFolder {
                NotificationCenter.default.post(name: destinationFolderWasSetNotification, object: self, userInfo: ["destinationFolder": destinationFolder])
            }
        }
    }
    
    var filesToBeModified: [URL] = []
    var foldersToBeChecked: [URL] = []
    
    let fileManager = FileManager()
    
    func modifyFilesToBeModified(toNewDirectory newDirectory: URL, withModificationType modificationType: FileModificationType, completion: (Bool) -> Void) {
        for fileURL in self.filesToBeModified {
            
            do {
                if modificationType == .copy {
                    let pathComponents = fileURL.lastPathComponent.components(separatedBy: ".")
                    guard let fileName = pathComponents.first, let pathExtension = pathComponents.last else { return }
                    let lastFileComponent = "\(fileName) copy"
                    let newPath = newDirectory.appendingPathComponent(lastFileComponent).appendingPathExtension(pathExtension)
                    try fileManager.copyItem(at: fileURL, to: newPath)
                } else {
                    let newPath = newDirectory.appendingPathComponent(fileURL.lastPathComponent)
                    try fileManager.moveItem(at: fileURL, to: newPath)
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
                completion(false)
            }
        }
        prepareForNewArrancar()
        completion(true)
    }

    func prepareForNewArrancar() {
        self.filesToBeModified = []
        self.folderPaths = []
        self.foldersToBeChecked = []
        self.destinationFolder = nil
        delegate?.prepareViewsForNewArrancar()
    }
    
    func getURLsForAllFilesIn(directory: URL, ofTypes types: [String], ignoringFilesWithWords words: [String]) {
        
        guard directory.hasDirectoryPath else { return }
        
        
        guard let contents = try? ItemController.shared.fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return }
        
        for item in contents {
            
            var hasWordToIgnore = false
            
            for wordToIgnore in words {
                if item.absoluteString.contains(wordToIgnore) { hasWordToIgnore = true }
            }
            
            guard !hasWordToIgnore else { break }
            
            if item.hasDirectoryPath {
                
                self.foldersToBeChecked.append(item)
                getURLsForAllFilesIn(directory: directory, ofTypes: types, ignoringFilesWithWords: words)
                
            } else if types.contains(item.pathExtension) {
                self.filesToBeModified.append(item)
            }
        }
        
        if ItemController.shared.foldersToBeChecked.contains(directory) {
            guard let index = ItemController.shared.foldersToBeChecked.index(of: directory) else { return }
            self.foldersToBeChecked.remove(at: index)
        }
    }
}

protocol ArrancarPreparationDelegate: class {
    func prepareViewsForNewArrancar()
}
