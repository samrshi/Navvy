//
//  Publisher+weaklyAssign.swift
//  Navvy
//
//  Created by Samuel Shi on 12/17/21.
//

import Combine

extension Publisher where Failure == Never {
    func weaklyAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root) -> AnyCancellable {
        sink { [weak root] in
            root?[keyPath: keyPath] = $0
        }
    }
    
    func weaklyAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output?>, on root: Root) -> AnyCancellable {
        sink { [weak root] in
            root?[keyPath: keyPath] = $0
        }
    }
}
