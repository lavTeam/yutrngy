//
//  CacheManager.swift
//  WeKnow
//
//  Created by Aleksey Larichev on 02.07.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//
import Foundation

public enum Result<T> {
    case success(T)
    case failure(NSError)
}

class CacheManager {
    static let shared = CacheManager()
    private let fileManager = FileManager.default
        private lazy var mainDirectoryUrl: URL = {
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsUrl
    }()
    
    func getFileWith(stringUrl: String, completionHandler: @escaping (Result<URL>) -> Void ) {
        let file = directoryFor(stringUrl: stringUrl)

        //return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: file.path)  else {
            completionHandler(Result.success(file))
            return
        }
        DispatchQueue.global().async {
            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
                videoData.write(to: file, atomically: true)
                DispatchQueue.main.async {
                    completionHandler(Result.success(file))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(Result.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Can't download video"])))
                }
            }
        }
    }
    
    private func directoryFor(stringUrl: String) -> URL {
        let fileURL = URL(string: stringUrl)!.lastPathComponent
        let file = self.mainDirectoryUrl.appendingPathComponent(fileURL)
        return file
    }
}
