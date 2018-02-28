//
//  ZendeskOnlineTest.swift
//  ZendeskTests
//
//  Created by Tomislav Luketic on 27/02/2018.
//  Copyright © 2018 Tomislav Luketic. All rights reserved.
//

import XCTest
@testable import Zendesk

class ZendeskOnlineNetworkTests: XCTestCase {
    
    let client = NetworkClient(session: URLSession(configuration: .default))
    let url = URL(string: "https://support.zendesk.com/api/v2/help_center/en-us/sections/200623776/articles.json")
   
    
    override func setUp() {
        super.setUp()
               
    }
    
    override func tearDown() {
       
        
        super.tearDown()
    }
    
    
    func testOnlineNetworkCall()
    {
        let expectation = XCTestExpectation(description: "Download articles")
        
        client.get(url: url!, callback: { (data, response, error) in
            
            let code = (response as! HTTPURLResponse).statusCode
            
            XCTAssert(code == 200)
            XCTAssertNotNil(data)
            
            expectation.fulfill();
            
            
        })
        
        wait(for: [expectation], timeout: 10.0)
        
    }
    
    func testDataDeserialization()
    {
        let expectation = XCTestExpectation(description: "Download articles")
        
        client.get(url: url!, callback: { (data, response, error) in
                      
            XCTAssertNotNil(data)
            
            let resp = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            
            XCTAssertNotNil(resp)
            
            XCTAssertNotNil(resp["articles"])
            
            XCTAssertNotNil(resp["count"])
            
            let articles = resp["articles"] as? [[String: Any]]
            
            if articles!.count > 0
            {
                XCTAssertNotNil(articles![0]["title"])
                XCTAssertNotNil(articles![0]["updated_at"])
                XCTAssertNotNil(articles![0]["body"])
            }
            
            expectation.fulfill();
            
            
        })
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    
    
}
