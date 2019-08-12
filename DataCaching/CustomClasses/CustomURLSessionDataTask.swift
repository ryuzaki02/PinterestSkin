//
//  URLSessionDataTask+Custom.swift
//  PinterestSkin
//
//  Created by Aman Thakur on 8/8/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import Foundation

public protocol RequestCancellationProtocol: class{
    /// To cancel request for particular task
    ///
    /// - Parameters:
    ///   - urlSessionTask: Object of urlSessionTask to perform cancel action.
    func requestCancelledFor(urlSessionTask: CustomURLSessionDataTask)
    
    /// To cancel all current tasks
    ///
    func cancelAllTasks()
}

public class CustomURLSessionDataTask{
    
    var task: URLSessionDataTask?
    var urlString = ""
    var completion: Completion!
    weak var delegate: RequestCancellationProtocol?
    
    deinit {
        #if DEBUG
        print("Task deinit")
        #endif
    }
    
    //MARK:- Init data
    
    /// Initialise data for class
    ///
    /// - Parameters:
    ///   - task: UrlSessionTask recieves from session.(Optional)
    ///   - completion: Completion handler to handle data/error from server.
    ///   - delegate: To perform desired actions from the controller
    init(task: URLSessionDataTask?, urlString: String, completion: Completion, delegate: RequestCancellationProtocol) {
        self.task = task
        self.urlString = urlString
        self.completion = completion
        self.delegate = delegate
    }
    
    //MARK:- Cancel Request
    public func cancelRequest(){
        delegate?.requestCancelledFor(urlSessionTask: self)
    }
    
}
