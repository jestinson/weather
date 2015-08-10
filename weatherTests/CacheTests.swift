//
//  CacheTests.swift
//  weatherTests
//
//  Created by Stinson, Justin on 8/9/15.
//  Copyright © 2015 Justin Stinson. All rights reserved.
//

import XCTest
@testable import weather

class CacheTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCacheNormalUsage() {
        var cache = Cache<Int>(maximumNumberOfItems: 3)
        XCTAssertEqual(cache.maxNumItems, 3)
        XCTAssertEqual(cache.count, 0)

        cache["a"] = 1
        XCTAssertEqual(cache.count, 1)
        XCTAssertEqual(cache["a"]!, 1)

        cache["b"] = 2
        XCTAssertEqual(cache.count, 2)
        XCTAssertEqual(cache["b"]!, 2)

        cache["c"] = 3
        XCTAssertEqual(cache.count, 3)
        XCTAssertEqual(cache["c"]!, 3)

        cache["d"] = 4
        XCTAssertEqual(cache.count, 3)
        XCTAssertEqual(cache["d"]!, 4)

        cache["e"] = 5
        XCTAssertEqual(cache.count, 3)
        XCTAssertEqual(cache["e"]!, 5)

        XCTAssertEqual(cache["d"]!, 4)
        XCTAssertEqual(cache["c"]!, 3)
        XCTAssertNil(cache["b"])
        XCTAssertNil(cache["a"])

        cache["f"] = 6
        XCTAssertEqual(cache.count, 3)
        XCTAssertEqual(cache["d"]!, 4)
        XCTAssertEqual(cache["c"]!, 3)
        XCTAssertEqual(cache["f"]!, 6)

        cache.removeAll()
        XCTAssertEqual(cache.count, 0)
        XCTAssertEqual(cache.maxNumItems, 3)
    }

    func testCacheNegativeMaxSize() {
        var negativeCache = Cache<Double>(maximumNumberOfItems: -2)
        XCTAssertEqual(negativeCache.maxNumItems, 1)
        XCTAssertEqual(negativeCache.count, 0)

        negativeCache["a"] = 1.0
        XCTAssertEqual(negativeCache.count, 1)

        negativeCache["b"] = 1.1
        XCTAssertEqual(negativeCache.count, 1)

        negativeCache.removeAll()
        XCTAssertEqual(negativeCache.count, 0)
        XCTAssertEqual(negativeCache.maxNumItems, 1)
    }

    func testCacheValueChange() {
        var cache = Cache<String>(maximumNumberOfItems: 10)
        XCTAssertEqual(cache.maxNumItems, 10)
        XCTAssertEqual(cache.count, 0)

        cache["A"] = "a"
        XCTAssertEqual(cache.count, 1)
        XCTAssertEqual(cache["A"]!, "a")

        cache["B"] = "b"
        XCTAssertEqual(cache.count, 2)
        XCTAssertEqual(cache["B"]!, "b")

        cache["B"] = "A"
        XCTAssertEqual(cache.count, 2)
        XCTAssertEqual(cache["B"]!, "A")

        cache.removeAll()
        XCTAssertEqual(cache.count, 0)
        XCTAssertEqual(cache.maxNumItems, 10)
    }
    
}
