//
//  ApplicationStoreCase.swift
//  QiitaWithFluxSample
//
//  Created by marty-suzuki on 2017/04/19.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import XCTest
import RxSwift

class ApplicationStoreCase: XCTestCase {
    var applicationStore: ApplicationStore!
    var applicationDispatcher: AnyObserverDispatcher<ApplicationDispatcher>!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        #if TEST
            let dispatcher = ApplicationDispatcher()
            applicationDispatcher = AnyObserverDispatcher(dispatcher)
            applicationStore = ApplicationStore(dispatcher: AnyObservableDispatcher(dispatcher))
        #endif
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetNonNilAccessToken() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let nonNilAccessTokenExpectation = expectation(description: "accessToken is non-nil")
        
        let disposeBag = DisposeBag()
        applicationStore.accessToken.asObservable().skip(1)
            .subscribe(onNext: {
                XCTAssertEqual($0, "accessToken")
                nonNilAccessTokenExpectation.fulfill()
            })
            .addDisposableTo(disposeBag)
        applicationDispatcher.accessToken.onNext("accessToken")
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testSetNilAccessToken() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let nilAccessTokenExpectation = expectation(description: "accessToken is nil")
        
        let disposeBag = DisposeBag()
        applicationStore.accessToken.asObservable().skip(1)
            .subscribe(onNext: {
                XCTAssertNil($0)
                nilAccessTokenExpectation.fulfill()
            })
            .addDisposableTo(disposeBag)
        applicationDispatcher.accessToken.onNext(nil)
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testError() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let errorExpectation = expectation(description: "error is NSCocoaErrorDomain")
        
        let disposeBag = DisposeBag()
        applicationStore.accessTokenError
            .subscribe(onNext: {
                XCTAssertEqual(($0 as NSError).domain, NSCocoaErrorDomain)
                errorExpectation.fulfill()
            })
            .addDisposableTo(disposeBag)
        applicationDispatcher.accessTokenError.onNext(NSError(domain: NSCocoaErrorDomain, code: -9999, userInfo: nil))
        waitForExpectations(timeout: 0.1, handler: nil)
    }
}
