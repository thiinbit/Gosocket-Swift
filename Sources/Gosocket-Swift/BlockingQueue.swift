//
//  Queue.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation

// singly rather than doubly linked list implementation
// private, as users of Queue never use this directly
private final class QueueNode<T> {
    
    
    // not optional – every node has a value
    var value: T
    // but the last node doesn't have a next
    var next: QueueNode<T>? = nil
    
    init(value: T) {
        self.value = value
    }
}

// Ideally, Queue would be a struct with value semantics but
// I'll leave that for now
public final class BlockingQueue<T> {
    let semaphore = DispatchSemaphore(value: 0)
    
    // these are both optionals, to handle
    // an empty queue
    private var head: QueueNode<T>? = nil
    private var tail: QueueNode<T>? = nil
    
    public init() {
    }
}

extension BlockingQueue {
    
    public func append(newElement: T) {
        let oldTail = tail
        self.tail = QueueNode(value: newElement)
        if head == nil {
            head = tail
        } else {
            oldTail?.next = self.tail
        }
        self.semaphore.signal()
    }
    
    public func dequeue(timeout: DispatchTime) -> T? {
        let result = self.semaphore.wait(timeout: timeout)
        switch result {
        default:
            return dequeue()
        }
    }
    
    public func dequeue(wallTimeout: DispatchWallTime) -> T? {
        let result = self.semaphore.wait(wallTimeout: wallTimeout)
        switch result {
        default:
            return dequeue()
        }
    }
    
    private func dequeue() -> T? {
        if let head = self.head {
            self.head = head.next
            if head.next == nil {
                tail = nil
            }
            return head.value
        } else {
            return nil
        }
    }
}
