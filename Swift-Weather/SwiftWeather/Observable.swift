//
//  Created by Mehmet Özdede on 10/05/2025.
//  Copyright © 2025 Mehmet Özdede. All rights reserved.
//

import Foundation

class Observable<T> {
  typealias Observer = (T) -> Void
  var observer: Observer?

  func observe(_ observer: Observer?) {
    self.observer = observer
    observer?(value)
  }

  var value: T {
    didSet {
      observer?(value)
    }
  }

  init(_ value: T) {
    self.value = value
  }
}
