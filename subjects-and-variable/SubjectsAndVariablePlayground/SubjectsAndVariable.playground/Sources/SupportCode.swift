import Foundation

public func example(of description: String, action: () -> Void) {
  print("\nExample of: \(description)")
  action()
}

