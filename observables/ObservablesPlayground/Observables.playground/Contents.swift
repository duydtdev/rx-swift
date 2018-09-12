//: Playground - noun: a place where people can play

import UIKit
import RxSwift

example(of: "just, of, from") {
  let one = 1
  let two = 2
  let three = 3
  /// This is a singe element observable
  let observable: Observable<Int> = Observable<Int>.just(one)
  
  /// This is an observable of individual type instances from a array
  let observable2 = Observable.of(one, two, three)
  
  /// This is an observables array using of to create
  let observable3 = Observable.of([one, two, three])
  
  /// This is an observable of individual type instances from a array
  let observable4 = Observable.from([one, two, three])
}

example(of: "subscribe") {
  
  let one = 1
  let two = 2
  let three = 3
  /// This is an observable of individual type instances from a array
  let observable = Observable.of(one, two, three)
  
  /// Subscribes an element handler
  observable.subscribe(onNext: { element in
    print(element)
  })
  
  /// Subscribes an event handler to an observable sequence.
  observable.subscribe { event in
    print(event)
  }
}
  
example(of: "empty") {

let observable = Observable<Void>.empty()
observable
  .subscribe(
    onNext: { element in
      print(element)
  },
    /// When empty an observable, it will go to completed block
    onCompleted: {
      print("Completed")
  }
)
}

example(of: "never") {
  /// If never an observable, it will not emit anything
  let observable = Observable<Any>.never()
  observable
    .subscribe(
      onNext: { element in
        print(element)
    },
      onCompleted: {
        print("Completed")
    }
  )
}

example(of: "range") {
  
  let observable = Observable<Int>.range(start: 5, count: 10)
  observable
    .subscribe(onNext: { i in
      let n = Double(i)
      let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) /
        2.23606).rounded())
      print(fibonacci)
    })
}

example(of: "dispose") {
  
  let observable = Observable.of("A", "B", "C")
  let subscription = observable.subscribe { event in
    print(event)
  }
  /// When dispose, the observable can not emit anything
  subscription.dispose()
}

example(of: "DisposeBag") {
  
  let disposeBag = DisposeBag()
  
  Observable.of("A", "B", "C")
    .subscribe {
      print($0)
    }
    .addDisposableTo(disposeBag)
}

example(of: "create") {
  
  enum MyError: Error {
    case anError
  }
  let disposeBag = DisposeBag()
  
  Observable<String>.create { observer in
    /// Customize observable
    observer.onNext("1")
    observer.onNext("?")
    
    return Disposables.create()
    }
    .subscribe(
      onNext: { print($0) },
      onError: { print($0) },
      onCompleted: { print("Completed") },
      onDisposed: { print("Disposed") }
    )
    .addDisposableTo(disposeBag)
}
example(of: "deferred") {
  
  let disposeBag = DisposeBag()
  var flip = false
  
  let factory: Observable<Int> = Observable.deferred {
    
    flip = !flip
    
    if flip {
      return Observable.of(1, 2, 3)
    } else {
      return Observable.of(4, 5, 6)
    }
  }
  
  for _ in 0...1 {
    factory.subscribe(onNext: {
      print($0, terminator: "")
    })
      .addDisposableTo(disposeBag)
    print()
  }
}
