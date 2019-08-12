//
//  NetworkLayer.swift
//  ImageCachingLibrary
//
//  Created by Aman Thakur on 8/5/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import UIKit

public class NetworkLayer: NSObject {
    
    public enum Result<T,U> {
        case Success(T), Failure(U)
    }
    
    public enum NetworkError: Error {
        case NetworkUnavailable
        case NoDataReceived
        case TimedOut
        case NotFound
        case AccessDenied
        case InvalidProxy
        case InvalidConfiguration
        case NotSpecifiedError(statusCode: Int, errorMsg: String)
        
        public var errorDescription: String {
            switch self {
            case .NoDataReceived:
                return "NoDataFromServerError".localized()
            case .TimedOut:
                return "NoResponseError".localized()
            case .NotFound:
                return "NotFoundError".localized()
            case .AccessDenied:
                return "AccessDeniedError".localized()
            case .InvalidProxy:
                return "InvalidProxy".localized()
            case .InvalidConfiguration:
                return "ConfigurationSettings".localized()
            case .NetworkUnavailable:
                return "NoConnection".localized()
            case .NotSpecifiedError(let statusCode, let errorMsg):
                return errorMsg + (statusCode > 0 ? " Status code - \(statusCode)" : "")
            }
        }
    }
    
    public typealias CompletionBlock = ((NetworkResult) -> Void)?
    public typealias NetworkResult = Result<Data,NetworkError>
    private var networkAvailability: NetworkAvailability!
    private var session: URLSession?
    private var sessionTasks: [URLSessionTask] = []
    private var requestCounter = 0
    
    deinit {
        #if DEBUG
        print("Network layer deinit")
        #endif
    }
    
    public override init() {
        super.init()
        networkAvailability = NetworkAvailability()
    }
    
    
    //MARK: - Session Creation
    
    /// Creates a task that retrieves the contents of a URL based on the specified URL request object, and calls a handler upon completion.
    ///
    /// - Parameters:
    ///   - request: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on.
    ///   - progressBlock: Asynchronous block for progress update.(Optional)
    ///   - completion: The completion handler to call when the load request is complete with Result enum.
    /// - Returns: The new session data task.(Optional)
    @discardableResult
    public func requestWithCompletionBlock(request : URLRequest, completion : CompletionBlock)->URLSessionDataTask? {
        
        if networkAvailability.isAvailable == .Unavailable{
            completion?(.Failure(.NetworkUnavailable))
            return nil
        }
        
        #if DEBUG
        print("Headers -- "+(request.allHTTPHeaderFields?.description ?? ""))
        print("URL -- " + (request.url?.absoluteString ?? ""))
        #endif
        
        increaseRequestCounter()
        if session == nil{
            let sessionConfig = URLSessionConfiguration.default
            session = URLSession.init(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        }
        
        let task = session?.dataTask(with: request,
                                     completionHandler: { [weak self] (receivedData, response, error) in
                                        DispatchQueue.main.async {
                                            self?.processResponse(response: response, receivedData: receivedData, 
                                                                  error: error, completion: completion)
                                        }
        })
        
        task?.resume()
        
        return task
    }
    
    //MARK: - Process Response
    
    fileprivate func processResponse(response : URLResponse?, receivedData : Data?, error : Error?, completion : CompletionBlock ){
        
        self.decreaseRequestCounter()
        #if DEBUG
        if let receivedData = receivedData, let responseString = String(data: receivedData, encoding: String.Encoding.utf8){
            print("response - \(responseString)")
        }
        if let error = error{
            print("error - \(error.localizedDescription )")
        }
        #endif
        switch response as? HTTPURLResponse{
        case .some(let response) :
            switch response.statusCode{
            case 404:
                completion?(.Failure(.NotFound))
            case 407:
                completion?(.Failure(.AccessDenied))
            case 200:
                switch receivedData{
                case .some(let data) :
                    completion?(.Success(data))
                case .none:
                    completion?(.Failure(.NoDataReceived))
                }
            default:
                completion?(.Failure(.NotSpecifiedError(statusCode: response.statusCode, errorMsg: error?.localizedDescription ?? "GenericServerErrorMessage".localized())))
                
            }
        case .none:
            completion?(.Failure(.NotSpecifiedError(statusCode: 0, errorMsg: error?.localizedDescription ?? "GenericServerErrorMessage".localized())))
            
        }
    }
    
    //MARK: - Helpers
    
    /// Cancels all running tasks
    private func cancelAllRunningTasks(){
        sessionTasks.forEach { (task) in
            if task.state == .running{
                task.cancel()
            }
        }
        sessionTasks.removeAll()
    }
    
    ///Cancel particular task
    ///
    /// Parameters:-
    ///     sessionTask - URLSessionTask provided by user to cancel
    private func cancelRunningTasks(sessionTask: URLSessionTask){
        for (index, task) in sessionTasks.enumerated(){
            if task.state == .running,
                task == sessionTask{
                task.cancel()
                sessionTasks.remove(at: index)
            }
        }
    }
    
    private func increaseRequestCounter(){
        requestCounter += 1
        #if DEBUG
        print("Started Request No. \(requestCounter)")
        #endif
    }
    
    private func decreaseRequestCounter(){
        requestCounter -= 1
    }
}
