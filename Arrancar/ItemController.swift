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
    
    let folderPathsWereSetNotification = Notification.Name("folderPathsWereSet")
    
    var folderPaths: [URL] = [] {
        didSet {
            if folderPaths.count > 0 {
                NotificationCenter.default.post(name: folderPathsWereSetNotification, object: self, userInfo: ["folderPathCount": folderPaths.count])
            }
        }
    }
    var destinationFolder: URL?
    
    var filesToBeMoved: [URL] = []
    var foldersToBeChecked: [URL] = []
    
    let fileManager = FileManager()
    
    func move(files: [URL], toNewDirectory newDirectory: URL, completion: (Bool) -> Void) {
        
        for file in files {
            
            let newPath = newDirectory.appendingPathComponent(file.lastPathComponent)
            do {
                try ItemController.shared.fileManager.moveItem(at: file, to: newPath)
            } catch let error as NSError {
                print(error.localizedDescription)
                completion(false)
            }
        }
        prepareForNewArrancar()
        completion(true)
    }
    
    func prepareForNewArrancar() {
        self.filesToBeMoved = []
        self.folderPaths = []
        self.foldersToBeChecked = []
    }
    
    func getURLsForAllFilesIn(directory: URL, ofTypes types: [String]) {
        
        guard directory.hasDirectoryPath else { return }
        
        
        guard let contents = try? ItemController.shared.fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return }
        
        for item in contents {
            if item.hasDirectoryPath {
                
                ItemController.shared.foldersToBeChecked.append(item)
                getURLsForAllFilesIn(directory: item, ofTypes: types)
                
            } else if types.contains(item.pathExtension) {
                ItemController.shared.filesToBeMoved.append(item)
            }
        }
        
        if ItemController.shared.foldersToBeChecked.contains(directory) {
            guard let index = ItemController.shared.foldersToBeChecked.index(of: directory) else { return }
            ItemController.shared.foldersToBeChecked.remove(at: index)
        }
    }
}
