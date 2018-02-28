//
//  ZendeskTests.swift
//  ZendeskTests
//
//  Created by Tomislav Luketic on 24/02/2018.
//  Copyright © 2018 Tomislav Luketic. All rights reserved.
//

import XCTest
@testable import Zendesk

class ZendeskOfflineNetworkTests: XCTestCase {
    
    let client = NetworkClient(session: MockURLSession())
    let url = URL(fileURLWithPath: Bundle.main.path(forResource: "articles", ofType: "json")!)
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
       
        super.tearDown()
    }
    
    func testOfflineNetworkCall()
    {
        let expectation = XCTestExpectation(description: "Download mocked articles")
        
        client.get(url: url, callback: { (data, response, error) in
            
            let code = (response as! HTTPURLResponse).statusCode
            
            XCTAssert(code == 200)
            XCTAssertNotNil(data)
            
            expectation.fulfill()
            
        })
        
        wait(for: [expectation], timeout: 10.0)
    }
    
   
   
   
    
}
