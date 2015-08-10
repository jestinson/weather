//
//  Cache.swift
//  weather
//
//  Created by Stinson, Justin on 8/9/15.
//  Copyright © 2015 Justin Stinson. All rights reserved.
//

import Foundation

/**
    Container that holds a collection of generic values referenced by string keys. Data is held in
    memory and the size of the collection is bounded. The API is similar to a native Dictionary.

    Internally when an item is added an NSDate is stored for record keeping. When the cache reaches
    the maximum size the oldest item is removed. When an item is accessed its corresponding date is
    bumped to the current time to keep the item from being removed next time the maximum is reached.
    This means that items added and never accessed with be removed before items frequently accessed
    even if they are the oldest.

    This class is implemented using a standard Dictionary which provides best case O(1) and worst
    case O(n) access times. Since a cache accesses always require two traversals of the data
    structure (one to get the item, and a second to update the item with a new date) the expected
    performance is 2 * O(1) to 2 * O(n) or simply O(1) to O(n). Cache insertions become 2 * O(1)
    to 2 * O(n^2) or O(1) to O(n^2).
    See: http://www.raywenderlich.com/79850/collection-data-structures-swift
*/
struct Cache<ValueType> {

    /// The maximum number of items the cache can hold. After this number is reached the
    /// oldest item will be removed.
    let maxNumItems: Int

    /// The number of items in the cache
    var count: Int {
        get {
            return cache.count
        }
    }

    private var cache = [String: (ValueType, NSDate)]()

    /// Designated initializer
    /// - Parameter: maximumNumberOfItems The largest number of items the cache should allow
    ///              (values less than 1 are changed to 1)
    init(maximumNumberOfItems: Int) {
        self.maxNumItems = maximumNumberOfItems > 0 ? maximumNumberOfItems : 1
    }

    /// Subscript to get/set values in the cache by key
    subscript(key: String) -> ValueType? {
        mutating get {
            guard let value = self.cache[key] else {
                // No value for the key
                return nil
            }

            // Replace the existing value with one that has an updated date
            self.cache[key] = (value.0, NSDate())

            // Return the value
            return value.0
        }

        mutating set {
            guard let newValue = newValue else {
                // Can't add nil
                return
            }

            // Add the new item and remove one if needed
            self.cache[key] = (newValue, NSDate())
            self.removeOldestIconFromCacheIfNeeded()
        }
    }

    /// Remove all elements.
    mutating func removeAll() {
        self.cache.removeAll(keepCapacity: true)
    }

    /// Removes the oldest icon from the cache
    /// - Returns: Boolean indicating if a value was removed from the cache or not
    private mutating func removeOldestIconFromCacheIfNeeded() -> Bool {
        let cacheSize = self.cache.count
        if cacheSize < 1 || cacheSize <= self.maxNumItems {
            // Cache is empty or not yet at max size, no removal needed
            return false
        }

        // Find the oldest item and remove it from the cache
        var oldestItem = self.cache.first!
        for item in self.cache {
            if item.1.1.compare(oldestItem.1.1) == .OrderedAscending {
                oldestItem = item
            }
        }
        self.cache.removeValueForKey(oldestItem.0)
        return true
    }

}
