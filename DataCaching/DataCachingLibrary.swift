//
//  ImageCachingLibrary.swift
//  ImageCachingLibrary
//
//  Created by Aman Thakur on 8/5/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import UIKit

public typealias Completion = ((Result<(Data,String),Error>) -> Void)?

public class DataCachingLibrary: NSObject, URLSessionTaskDelegate {
    
    private weak var newtworkLayer: NetworkLayer!
    
    /// To perform caching of all the data recieved from server
    private var cache = NSCache<NSString,NSData>()
    
    /// To keep track of all the operation to download the data with "key" as url
    private var tasksDictionary: [String:[CustomURLSessionDataTask]] = [:]
    
    deinit {
        #if DEBUG
        print("Image Caching deinit")
        #endif
    }
    
    //MARK:- Init with data
    
    /// Intialise data for the class
    ///
    /// - Parameters:
    ///   - networlLayer: An object of networkLayer class to perform web server interactions.
    public init(networkLayer: NetworkLayer) {
        self.newtworkLayer = networkLayer
    }
    
    //MARK:- Server methods
    
    /// Get the data from server for specific url string.
    
    ///
    /// - Parameters:
    ///   - urlString: Url as string to get the data from
    ///   - completion: The completion handler to call when the load request is complete with Result enum.
    /// - Returns: The session data task.(Optional)(Discardable)
    @discardableResult
    public func getDataFromServerForURL(urlString: String, completion: Completion) -> CustomURLSessionDataTask?{
        
        /// Checks whether cache has data in it or not
        if let value = cache.object(forKey: urlString as NSString){
            completion?(.success((value as Data,urlString)))
            return nil
        }
        
        /// Add session data task to dictionary with task already present for same download
        if var taskArray = tasksDictionary[urlString], taskArray.count > 0{
            let newTask = CustomURLSessionDataTask(task: taskArray[0].task, urlString: urlString, completion: completion, delegate: self)
            taskArray.append(newTask)
            tasksDictionary[urlString] = taskArray
            return newTask
        }else{
            guard let url = URL(string: urlString) else {return  nil}
            var urlRequest = URLRequest(url: url)
            urlRequest.timeoutInterval = 120.0
            
            let task = newtworkLayer.requestWithCompletionBlock(request: urlRequest, completion: { [weak self] (result) in
                if let taskArr = self?.tasksDictionary[urlString]{
                    for task in taskArr{
                        switch(result)
                        {
                        case .Failure(let error):
                            task.completion?(.failure(error))
                        case .Success(let data):
                            self?.cache.setObject(data as NSData, forKey: urlString as NSString)
                            task.completion?(.success((data,urlString)))
                        }
                    }
                    self?.tasksDictionary.removeValue(forKey: urlString)
                }
            })
            
            let newTask = CustomURLSessionDataTask.init(task: task, urlString: urlString, completion: completion, delegate: self)
            var taskArr: [CustomURLSessionDataTask] = []
            taskArr.append(newTask)
            tasksDictionary[urlString] = taskArr
            return newTask
        }
    }
}

/// Cancel request from task array for particular url
extension DataCachingLibrary: RequestCancellationProtocol{
    public func cancelAllTasks() {
        
    }
    
    public func requestCancelledFor(urlSessionTask: CustomURLSessionDataTask) {
        if var taskArr = tasksDictionary[urlSessionTask.urlString]{
            if let index = taskArr.firstIndex(where: { (task) -> Bool in
                return task === urlSessionTask
            }){
                taskArr.remove(at: index)
                tasksDictionary[urlSessionTask.urlString] = taskArr
            }
        }
    }
}
