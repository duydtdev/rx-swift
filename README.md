# RxSwift

## Descriptions
> This repository to contain all knowledges and exampples about ``RxSwift``.

## Concepts
`RxSwift` is a library for composing asynchronous and event-based code by using observable sequences and functional style operators, allowing for parameterized execution via schedulers.

`RxSwift` in its essence, simplifies developing asynchronous programs by allowing your code to react to new data and process it in sequential, isolated manner.
## Installing
#### 1. RxSwift via CocoaPods
You can install RxSwift via CocoaPods like any other pod library. A typical Podfile would look something like this:
```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
end
```
And then run podfile to install RxSwift libary to your project
```bash 
$ pod install
```
#### 2. RxSwift via Carthage
In your project, create a new file named Cartfile and add the following line to it:
```ruby
github "ReactiveX/RxSwift" ~> 4.0
```
Next, within the folder of your project execute:
```bash
$ carthage update
```
#### 3. Create a playground with Cocoapods
Step 1:  Go to your directory and run below command with sudo permission:
```bash
gem install cocoapods-playgrounds
```
Step 2: Create a example via below command:
```bash
pod playgrounds YourExample
```
Step 3: Declare all libraries in podfile and then run `pod install` to download
>(Because on Xcode 9 don't support create a playground in existing project, so we must do Setep 4 & 5)

Step 4: In the Xcode choose New -> Playground to create a playground
Step 5: In your project, right click and choose `Add file to..` to add playground to your project

## Contents
#### 1. Observables
Observables are the heart of Rx
##### Lifecycle of an observable
* In the previous marble diagram, the observable emitted three elements. When an observable emits an element, it does so in what’s known as a next event.
* Observable emits three tap events, and then it ends. This is called a `completed` event
* The observable emitted an `error` event containing the error. If an observable emits an `error` event, it is also terminated and can no longer emit anything else
* An observable emits `next` events that contain elements

##### Creating observables
* `just` is aptly named, since all it does is create an observable sequence containing `just` a single element
* The `from` operator creates an observable of individual type instances from a regular array of elements
* You can use `of` to create an observables array or a create an observable of individual type

Below example to discern `just`, `of` and `from`
```swift
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
```
##### Subscribing to observables
* Subscribing to an RxSwift observable is fairly similar; you call observing an observable `subscribing` to it. So instead of `addObserver()`, you use `subscribe()`. Unlike `NotificationCenter`, where developers typically use only its `.default` singleton instance, each observable in Rx is different.
* More importantly, an `observable` won’t send events until it has a subscriber.

An example for subsribing to observables
```swift
  let one = 1
  let two = 2
  let three = 3
  /// This is an observable of individual type instances from a array
  let observable = Observable.of(one, two, three)
  
  /// Subscribes an element handler
  observable.subscribe(onNext: { element in
    print(element) // Result will be: 1,2,3
  })
  
  /// Subscribes an event handler to an observable sequence.
  observable.subscribe { event in
    print(event) // Result will be: next(1) next(2) next(3) completed
  }
```
* The `empty` operator creates an empty observable sequence with zero elements. It will only emit a `.completed` event.

```swift 
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
```
* The `never` operator creates an observable that doesn’t emit anything and never terminates

```swift
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
```
##### Disposing and terminating
* To explicitly cancel a subscription, call `dispose()` on it. After you cancel the subscription, or `dispose` of it, the observable in the current example will stop emitting events

```swift
let observable = Observable.of("A", "B", "C")
  let subscription = observable.subscribe { event in
    print(event)
  }
  /// When dispose, the observable can not emit anything
  subscription.dispose()
```

* Managing each subscription individually would be tedious, so RxSwift includes a `DisposeBag` type. A dispose bag holds disposables typically added using the `.addDisposableTo()` method and will call `dispose()` on each one when the dispose bag is about to be deallocated

```swift
let disposeBag = DisposeBag()
  
  Observable.of("A", "B", "C")
    .subscribe {
      print($0)
    }
    .addDisposableTo(disposeBag)
```

* The `create` operator takes a single parameter named `subscribe`. Its job is to provide the implementation of calling subscribe on the observable.
* Using `create` to customize an observable

```swift
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
```

##### Creating observable factories
* `deferred` defers reading of the value until a subscription
* `deferred` has one trait which you need to remember about. deferred creates the Observable from his closure each time it has a new observer. It means subscribing 2 times will create 2 Observable objects. It can affect the performance, however it’s not likely to happen
* `deferred` will help when subscribe a long calculate function (it will block if we use `create` or `just` )

```swift
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
```

#### 2. Subjects
##### What are subjects?
* `Subjects` act as both an `observable` and an `observer`
* The `subject` received `.next` events, and each time it received an event, it turned around and emitted it to its subscriber.
* There are four subject types in RxSwift:
    * `PublishSubject`: Starts empty and only emits new elements to subscribers.
    * `BehaviorSubject`: Starts with an initial value and replays it or the latest element to new subscribers.
    * `ReplaySubject`: Initialized with a buffer size and will maintain a buffer of elements up to that size and replay it to new subscribers.
    * `Variable`: Wraps a BehaviorSubject, preserves its current value as state, and replays only the latest/initial value to new subscribers.

##### Working with PublishSubjects
* Publish subjects will `ignore` all elements that were emitted before subscribe have happened.

```swift
  let disposeBag = DisposeBag()
  let subject = PublishSubject<String>()
  subject.onNext("Ignored...")
  
  subject
    .subscribe(onNext: { text in
      print(text)
    })
    .addDisposableTo(disposeBag)
  subject.onNext("Printed!")
```

In the result just show `Printed!`

> We use it when we’re just interested in future values.

##### Working with BehaviorSubjects
* Behavior subjects will repeat only the one last value. Moreover it’s initiated with a starting value, unlike the other subjects.

```swift
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
```

Looking in the result

```
Printed!
Printed one!
Printed two!
```

> We use it when you just need to know the last value, for example the array of elements for table view.

##### Working with ReplaySubjects
* Replay subject will repeat last N number of values, even the ones before the subscription happened. The N is the buffer

```swift
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
```

The result will be

```
Printed!
Printed!
Printed!
Printed end!
```

>We use it when we’re interested in all values of the subjects lifetime.

##### Working with Variables
* Variable wraps a BehaviorSubject and stores its current value as state

```swift
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
```

Let's see the result

```
Current String
Second String
Third String
```

#### 3. Filtering Operators
##### Ignoring operators
* `ignoreElements` will ignore .next event elements. It will, however, allow through stop events, i.e., `.completed` or `.error` events. It is useful when you only want to be notified when an observable has terminated, via a `.completed` or `.error` event

```swift
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
```
The result will be: 
```
You're out!
```

* `elementAt` takes the index of the element you want to receive, and it ignores everything else.

```swift
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
```

Result:
```
X2
```

* `filter` emit only those items that pass a predicate test

```swift
  let disposeBag = DisposeBag()
  
  Observable.of(1, 2, 3, 4, 5, 6)
    .filter { integer in
      integer % 2 == 0
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
```

Result:

```
2
4
6
```

##### Skipping operators
* The `skip` operator allows you to ignore from the 1st to the number you pass as its parameter.

```swift
  let disposeBag = DisposeBag()
  
  Observable.of("A", "B", "C", "D", "E", "F")
    .skip(1)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
```

The result will be:

```
B
C
D
E
F
```

* `skipWhile` discard items until a specified condition becomes false

```swift
  let disposeBag = DisposeBag()

  Observable.of(2, 4, 3, 2, 4)
    .skipWhile { integer in
      integer % 2 == 0
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
```

Result of `skipWhile`

```
3
2
4
```

* `skipUntil` discard items until a second Observable emits an item

```swift
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
```

The result:

```
C
```

##### Taking operators
* `take` emit only the first n items

```swift
  let disposeBag = DisposeBag()
  
  Observable.of(1, 2, 3, 4, 5, 6)
    .take(3)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
```

Result:

```
1
2
3
```

* `takeWhileWithIndex` mirror items until a specified condition becomes false

```swift
  let disposeBag = DisposeBag()
  
  Observable.of(2, 2, 4, 4, 6, 6)
    .takeWhileWithIndex { integer, index in
      integer % 2 == 0 && index < 3
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
```

Result:

```
2
2
4
```

* `takeUntil` discard any items after a second Observable emits an item or terminates

```swift
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
```

The result:
```
1
2

```

##### Distinct operators
* `distinctUntilChanged` prevents duplicates that are right next to each other

```swift
  let disposeBag = DisposeBag()
  
  Observable.of("A", "A", "B", "B", "A")
    .distinctUntilChanged()
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
```

The result will be:

```
A
B
A
```

#### 4. Transforming Operators
##### Transforming elements
* `toArray` convert an Observable into an array

```swift
  let disposeBag = DisposeBag()
  Observable.of("A", "B", "C")
    .toArray()
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
```

The result will be ```["A", "B", "C"]```

* `map` transform the items by an Observablapplying a function to each item

```swift
  let disposeBag = DisposeBag()
  
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut
  
  Observable<NSNumber>.of(123, 4, 56)
    .map {
      formatter.string(from: $0) ?? ""
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
```

Result:

```
one hundred twenty-three
four
fifty-six
```

* `mapWithIndex` transform the items by an Observablapplying a function to each item include index of elements on an Observable

```swift
  let disposeBag = DisposeBag()
  Observable.of(1, 2, 3, 4, 5, 6)
    .mapWithIndex { integer, index in
      index > 2 ? integer * 2 : integer
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
```

Result:
```
1
2
3
8
10
12
```

##### Transforming inner observables
* `flatMap` transform the items into Observables and merge them into a single one

Example:
Creating a struct for Student
```swift
  struct Student {
  var score: Variable<Int>
}
```

```swift
  let disposeBag = DisposeBag()
  
  let ryan = Student(score: Variable(80))
  let charlotte = Student(score: Variable(90))
  
  let student = PublishSubject<Student>()
  
  student.asObservable()
    .flatMap {
      $0.score.asObservable()
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
  
  student.onNext(ryan)
  ryan.score.value = 85
  
  student.onNext(charlotte)
  ryan.score.value = 95
  
  charlotte.score.value = 100
```

Result:
```
80
85
90
95
100
```

* `flatMapLatest` works just like `flatMap` to reach into an observable element to access its observable property. `flatMapLatest` different is that it will automatically switch to the latest observable and unsubscribe from the the previous one.

```swift
  let disposeBag = DisposeBag()
  
  let ryan = Student(score: Variable(80))
  let charlotte = Student(score: Variable(90))
  
  let student = PublishSubject<Student>()
  
  student.asObservable()
    .flatMapLatest {
      $0.score.asObservable()
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
  
  student.onNext(ryan)
  
  ryan.score.value = 85
  
  student.onNext(charlotte)
  
  ryan.score.value = 95
  
  charlotte.score.value = 100
```

Result:
```
80
85
90
100
```
#### 5. Combining Operators
##### Prefixing and concatenating
* `startWith` emit a specified sequence of items before others from source

```swift
  let numbers = Observable.of(2, 3, 4)
  let observable = numbers.startWith(1)
  observable.subscribe(onNext: { value in
    print(value)
  })
  ```
  Result ``` 1 2 3 4```
 
* `concat` emit the emissions from two or more Observables without interleaving them

```swift
  let first = Observable.of(1, 2, 3)
  let second = Observable.of(4, 5, 6)
  let observable = Observable.concat([first, second])
  observable.subscribe(onNext: { value in
    print(value)
  })
```
Result ``` 1 2 3 4 5 6```
##### Merging
* `merge` combine multiple Observables into one by merging their emissions
![alt text](https://raw.githubusercontent.com/duydtdev/rx-swift/master/combining-operators/images/merge.png)

##### Combining elements

* `combineLatest` combine the latest item emitted by each Observable
![alt text](https://raw.githubusercontent.com/duydtdev/rx-swift/master/combining-operators/images/combineLatest.png)
* `zip` combine the emissions of multiple Observables together
Triggers
![alt text](https://raw.githubusercontent.com/duydtdev/rx-swift/master/combining-operators/images/zip.png)
* `withLatestFrom` takes an Observable as an input and transforms the trigger into the latest event from the input Observable.

##### Switches
* `amb` given two or more source Observables, emit all of the items from only the first of these Observables to emit an item or notification

```swift
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()
  let observable = left.amb(right)
  let disposable = observable.subscribe(onNext: { value in
    print(value)
  })
  
  left.onNext("Lisbon")
  right.onNext("Copenhagen")
  left.onNext("London")
  left.onNext("Madrid")
  right.onNext("Vienna")
  
  disposable.dispose()
```

Result

```
Lisbon
London
Madrid
```

##### Combining elements within a sequence

* `reduce` apply a function to each item emitted by an Observable, sequentially, and emit the final value

```swift
  let source = Observable.of(1, 3, 5, 7, 9)

  let observable = source.reduce(0, accumulator: { summary, newValue in
    return summary + newValue
  })
  
  observable.subscribe(onNext: { value in
    print(value)
  })
```

Result: ```25```

* `scan` apply a function to each item emitted by an Observable, sequentially, and emit each successive value

```swift
  let source = Observable.of(1, 3, 5, 7, 9)
  
  let observable = source.scan(0, accumulator: +)
  observable.subscribe(onNext: { value in
    print(value)
  })
```

Result: 

```
1
4
9
16
25
```

## Meta
Author: Duy Doan

Distributed under the MIT license. See ``LICENSE`` for more information.