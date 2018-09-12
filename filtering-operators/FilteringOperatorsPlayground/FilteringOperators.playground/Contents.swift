//: Playground - noun: a place where people can play

import UIKit
import RxSwift

example(of: "ignoreElements") {

  let strikes = PublishSubject<String>()
  
  let disposeBag = DisposeBag()
  
  strikes
    .ignoreElements()
    .subscribe { _ in
      print("You're out!")
    }
    .addDisposableTo(disposeBag)
  
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onCompleted()
}

example(of: "elementAt") {
  
  let strikes = PublishSubject<String>()
  
  let disposeBag = DisposeBag()
  strikes
    .elementAt(2)
    .subscribe(onNext: { elements in
      print(elements)
    })
    .addDisposableTo(disposeBag)
  
  strikes.onNext("X0")
  strikes.onNext("X1")
  strikes.onNext("X2")
}

example(of: "filter") {
  
  let disposeBag = DisposeBag()
  
  Observable.of(1, 2, 3, 4, 5, 6)
    .filter { integer in
      integer % 2 == 0
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "skip") {
  
  let disposeBag = DisposeBag()
  
  Observable.of("A", "B", "C", "D", "E", "F")
    .skip(1)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "skipWhile") {
  
  let disposeBag = DisposeBag()

  Observable.of(2, 4, 3, 2, 4)
    .skipWhile { integer in
      integer % 2 == 0
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "skipUntil") {
  
  let disposeBag = DisposeBag()
  
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()

  subject
    .skipUntil(trigger)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
  
  subject.onNext("A")
  subject.onNext("B")
  
  trigger.onNext("X")
  subject.onNext("C")
}

example(of: "take") {
  
  let disposeBag = DisposeBag()
  
  Observable.of(1, 2, 3, 4, 5, 6)
    .take(3)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "takeWhileWithIndex") {
  
  let disposeBag = DisposeBag()
  
  Observable.of(2, 2, 4, 4, 6, 6)
    .takeWhileWithIndex { integer, index in
      integer % 2 == 0 && index < 3
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "takeUntil") {
  
  let disposeBag = DisposeBag()
  
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()
  
  subject
    .takeUntil(trigger)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
  
  subject.onNext("1")
  subject.onNext("2")
  
  trigger.onNext("X")
  subject.onNext("3")
}

example(of: "distinctUntilChanged") {
  
  let disposeBag = DisposeBag()
  
  Observable.of("A", "A", "B", "B", "A")
    .distinctUntilChanged()
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}
