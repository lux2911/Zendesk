//
//  NetworkClient.swift
//  Zendesk
//
//  Created by Tomislav Luketic on 27/02/2018.
//  Copyright © 2018 Tomislav Luketic. All rights reserved.
//


// Implementation of HttpClient using protocols that allow us to use dependancy injection when testing

import UIKit

protocol URLSessionDataTaskProtocol { func resume() }

protocol URLSessionProtocol { typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    func dataTask(with request: NSURLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

class NetworkClient {
    typealias completeClosure = ( _ data: Data?,_ response : URLResponse? , _ error: Error?)->Void
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func get( url: URL, callback: @escaping completeClosure ) {
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            callback(data,response, error)
        }
        task.resume()
    }
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: NSURLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
         return dataTask(with: request as URLRequest, completionHandler: completionHandler) as URLSessionDataTaskProtocol
       
    }
}
extension URLSessionDataTask: URLSessionDataTaskProtocol {}

class MockURLSessionDataTask : URLSessionDataTaskProtocol {
    func resume() { }
}

class MockURLSession: URLSessionProtocol {
    
    var nextDataTask = MockURLSessionDataTask()
    
    func successHttpURLResponse(request: NSURLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(with request: NSURLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        
            let data = try! Data(contentsOf: request.url!, options: .mappedIfSafe)
        
            completionHandler(data, successHttpURLResponse(request: request), nil)
        
            return nextDataTask
        
    }
}

