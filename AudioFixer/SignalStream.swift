//
//  JSignal.swift
//  TestingSignals
//
//  Created by José Mota on 05/04/2019.
//  Copyright © 2019 Mota. All rights reserved.
//

import Foundation

class SignalStream<T> {
    
    enum Strategy {
        case cold
        case warm(upTo: Int)
        case hot
    }
    
    fileprivate var arrayQueue: DispatchQueue!
    fileprivate var values: TopArray<T> = TopArray.init(upTo: 0)
    
    let description: String
    let strategy: Strategy
    init(description: String, strategy: Strategy = .hot) {
        self.description = description
        self.strategy = strategy
        self.arrayQueue = DispatchQueue.init(label: "Signal_\(description)")
        
        switch strategy {
        case .cold:
            values = TopArray.init(upTo: Int.max)
            break
        case .warm(let max):
            values = TopArray.init(upTo: max)
            break
        case .hot:
            values = TopArray.init(upTo: 0)
            break
        }
    }
    
    private var subscriptions: [SignalSubscription<T>] = [] {
        didSet {
            NSLog("Signal \(description) counter: %d", subscriptions.count)
        }
    }
    
    @discardableResult
    func subscribe(on observer: AnyObject, queue: DispatchQueue = OperationQueue.current?.underlyingQueue ?? .main, handler: @escaping (T)->Void) -> SignalSubscription<T> {
        
        clean()
        let subscription = SignalSubscription.init(observer: observer, handler: handler, dispatchQueue: queue)
        arrayQueue.async { [weak self] in
            self?.subscriptions.append(subscription)
            for value in self?.values.values.filter({ subscription.filter($0) }) ?? [] {
                subscription.fire(value)
            }
        }
        return subscription
    }
    
    fileprivate func clean() {
        
        arrayQueue.async { [weak self] in
            let subs = self?.subscriptions.filter({ $0.observer != nil })
            if subs?.count != self?.subscriptions.count {
                self?.subscriptions = subs ?? []
            }
        }
    }
    
    func fire(_ value: T) {
        
        clean()
        arrayQueue.async { [weak self] in
            self?.subscriptions.filter({$0.filter(value)}).forEach({
                $0.fire(value)
            })
            self?.values.append(value)
        }
    }
    
    class SignalSubscription<T> {
        fileprivate weak var observer: AnyObject?
        private var handler: (T)->Void
        private let dispatchQueue: DispatchQueue
        fileprivate var filter: (T)->Bool = { _ in return true }
        
        fileprivate var mapSubscription: SignalSubscription<Any>?
        fileprivate var transform: ((T)->Any)?
        
        fileprivate init(observer: AnyObject?, handler: @escaping (T)->Void, dispatchQueue: DispatchQueue) {
            self.observer = observer
            self.handler = handler
            self.dispatchQueue = dispatchQueue
        }
        
        fileprivate func fire(_ value: T) {
            dispatchQueue.async { [weak self] in
                self?.handler(value)
                if let transformedValue = self?.transform?(value), let mapSubscription = self?.mapSubscription {
                    mapSubscription.fire(transformedValue)
                }
            }
        }
        
        @discardableResult
        func filter(_ filter: @escaping (T)->Bool) -> SignalSubscription {
            self.filter = filter
            return self
        }
        
        @discardableResult
        func map<U: Any>(_ transform: @escaping (T)->U, handler: @escaping (U)->Void) -> SignalSubscription<U> {
            
            let subscription = SignalSubscription<U>(observer: observer, handler: handler, dispatchQueue: dispatchQueue)
            self.transform = transform
            self.mapSubscription = subscription as? SignalSubscription<Any>
            return subscription
        }
    }
    
    fileprivate struct TopArray<T> {
        
        let max: Int
        init(upTo: Int) {
            max = upTo
        }
        
        private var storage: [T] = []
        
        mutating func append(_ element: T) {
            storage.append(element)
            
            if storage.count > max {
                storage.removeFirst()
            }
        }
        
        var values: [T] {
            return storage
        }
    }
}
