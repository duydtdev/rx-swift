//: Playground - noun: a place where people can play

import UIKit
import RxSwift

example(of: "PublishSubject") {
  let disposeBag = DisposeBag()
  let subject = PublishSubject<String>()
  subject.onNext("Ignored...")
  
  subject
    .subscribe(onNext: { text in
      print(text)
    })
    .addDisposableTo(disposeBag)
  subject.onNext("Printed!")
}

example(of: "BehaviorSubject") {
  let disposeBag = DisposeBag()
  let subject = BehaviorSubject<String>(value: "Initial value")
  
  subject.onNext("Not printed!")
  subject.onNext("Not printed!")
  subject.onNext("Printed!")
  
  subject
    .subscribe(onNext: { text in
      print(text)
    })
    .addDisposableTo(disposeBag)
  
  subject.onNext("Printed one!")
  subject.onNext("Printed two!")
}

example(of: "ReplaySubjects") {
  let disposeBag = DisposeBag()
  let subject = ReplaySubject<String>.create(bufferSize: 3)
  subject.onNext("Not printed!")
  subject.onNext("Printed!")
  subject.onNext("Printed!")
  subject.onNext("Printed!")
  
  subject
    .subscribe(onNext: { text in
      print(text)
    })
    .addDisposableTo(disposeBag)
  
  subject.onNext("Printed end!")
}

example(of: "Variables") {
  let disposeBag = DisposeBag()
  let variable = Variable("Current String")
  
  /// Getting the value
  print(variable.value)
  
  /// Setting the value
  variable.value = "Second String"
  
  /// Observing the value
  variable.asObservable()
    .subscribe(onNext: { text in
      print(text)
    })
    .addDisposableTo(disposeBag)
  
  variable.value = "Third String"
}
