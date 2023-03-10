# Mastering-RxSwift

https://github.com/ReactiveX/RxSwift

# 01.KeyConcept
1. Observer는 Observable을 구독(```subscribe```)한다. 
```swift
let o1 = Observable<Int>.create { (observable) -> Disposable in
    observable.on(.next(0)) //이벤트 방출
    observable.onNext(1)//이벤트 방출
    
    observable.onCompleted() //종료
    return Disposables.create() //Disposable 생성
}
```
2. Observable은 이벤트를 방출(```OnNext()```), 완료(```Complete/ Error(Notification)```)한다.
```swift
    o1.subscribe {
    print("--start--")
    print($0)
    if let elem = $0.element {
        print(elem)
    }
    print("--end--")
}

```
3. RxSwift6부터 ```infalliable```이 추가되어 ```complete, error```는 방출하지 않는 컨셉도 있다.
```swift
//Error는 방출하지 않음
let inallible = Infallible<String>.create { observer in
//    observable.onNext()

    observer(.next("Hello"))
    observer(.completed)

    return Disposables.create()
}
```
4. Reactive 연산에 대한 메모리 관리는 ```disposable```로 하며, ```DisposableBag()```을 통해서 해당 객체가 메모리에 해제되는 순간 한 번에 진행할 수도 있다.
```swift

let subscription1 = Observable.from([1,2,3])
.subscribe(onNext: {elem in
    print("NEXT", elem)
}, onError: { error in
    print("ERROR", error)
}, onCompleted: {
    print("COMPLETED")
}, onDisposed: {
    //파라미터로 클로저를 전달하면 Observable과 관련된 리소스를 정리
    print("DISPOSED")
})
subscription1.dispose() //이것보다 DisposeBag이 권장사항
//
var bag = DisposeBag()

Observable.from([1,2,3]).subscribe{
    print($0)
}.disposed(by: bag)
//Observable이 completed, error가 되면 리소스가 해제됨
//두 번쨰 코드는 왜 DISPOSED가 호출되지 않았나? -> Observable과는 연관이 없음
//메모리 해제와 관련됨


/**
 disposeBag에 담고 disposeBag이 해제되는 시점에 모아둔 것을 해제
 */
bag = DisposeBag() // 이렇게하면 리소스가 해제됨 nil을 할당해도 좋다.


```
# 02.Subject
> Observable이자 Observer
## 02-01. PublishSubject
- Subject로 전달되는 이벤트를 Observer에 전달한다.
- Subject 구독 이전의 이벤트는 소멸된다는 특징을 가지고 있다.

```swift
let disposeBag = DisposBag()

let subject = PublishSubject<String>() //#1
subject.onNext("HELLO") //#2

/**
 #1에서 PublishSubject를 만든 후 
 #2에서 onNext("Hello") 이벤트를 방출한다.
 
 현재 subscriber는 없다.
 */

let o1 = subject.subscribe { print(">>1", $0) }.disposed(by: disposeBag)
//이전의 "HELLO"는 이미 소모됨 PublishSubject는 구독 이후의 동작을 처리한다.
subject.onNext("RxSwift")
// Rxswift는 o1에게 전달된다.

let o2 = subject.subscribe{ print(">>2", $0) }.disposed(by: disposeBag)
subject.onNext("SUBJECT")
//SUBJECT는 o1, o2에게 전달된다. 
```

## 02-02. BehaviorSubject
- ```PublishSubject```와 유사한 방식으로 동작한다.
- ```PublishSubject```와의 차이점은 생성자, 구독, 이벤트 전달 방식에서 차이가 있다.

```swift
let p = PublishSubject<Int>() // 빈 생성자로 생성한다.
p.subscribe{ print("publicshSubject >>", $0) }.disposed(by: disposeBag)
//subject로 이벤트 전달 전(next)까지 구독자로 이벤트 전달하지 않는다.

let b = BehaviorSubject<Int>(value: 0) //기본 값을 전달한다.
b.subscribe { print("behaviorSubject >>", $0)}.disposed(by: disposeBag)
//내부에 Next가 BehaviorSubject를 생성하자 마자 바로 생성되고 기본값을 전달한다.
```
```BehaviorSubject```는 버퍼가 한 개 있는 것과 같고, 그 버퍼를 기본 값으로 채우고 있는 것과 같은 모양을 하고 있다.

```swift
//  let b = BehaviorSubject<Int>(value: 0)

b.onNext(1)
/**
 onNext로 1을 전달한다고 했을 때, PublishSubject의 경우에는 onNext를 버리는 반면
 behaviorSubject는 버퍼에 담고 있는 것과 같이 행동한다.
 */


// 이전 이벤트를 저장하고 있다가 새로 구독한 녀석에게 던진다. 단 새로운 이벤트가 발생하면 이전 이벤트를 교체한다.
b.subscribe { print("behaviorSubject >>", $0)}.disposed(by: disposeBag) //next(1)
```

위와 같은 방식으로 기본 동작을 하며

```swift

b.onCompleted() //|| b.onError(MyError.error)
/**
 onCompleted, onError가 넘어오면 더 이상 broadCast를 하지 않는다. 
 */


//completed가 전달되면 이전 이벤트라도 무시한다.
b.subscribe { print("behaviorSubject >>", $0)}.disposed(by: disposeBag)

```


## 02-03. ReplaySubject
- 기본 동작은 ```BehaviorSubject```와 매우 유사하다. 
- 버퍼 사이즈를 조정할 수 있으며 기본 생성자 매개변수로 이를 받는다.```ReplaySubject<?>(bufferSize:)```
- ```BehaviorSubject```와 다른 점은 ```completed, error```에도 버퍼를 소모하고 해당 상태로 진행된다.
```swift

//2개 이상의 이벤트를 저장하고 새로운 구독자로 전달하고 싶다면 사용하면 된다.
//이전과 다르게 crate로 만든다.
let rs = ReplaySubject<Int>.create(bufferSize: 3)
(1...10).forEach { rs.onNext($0) }
rs.subscribe{ print("observer 1 >> ", $0)}.disposed(by: disposeBag) //next(8), next(9), next(10)

rs.onNext(11)

rs.subscribe{ print("observer 2 >> ", $0)}.disposed(by: disposeBag)  //next(9), next(10), next(11)

//rs.onCompleted()
rs.onError(MyError.error)

rs.subscribe{ print("observer 4 >> ", $0)}.disposed(by: disposeBag)  //next(9), next(10), next(11)
//버퍼에 있던 것들 소모하고 completed

```
## 02-04. AsyncSubject
- ```PublishSubject```, ```BehaviorSubject```는 이벤트 전달 즉시 구독자에게 전달하는 반면 ```AsyncSubject```는 ```completed```가 전달되면 completed 직전의 ```onNext()```만 전달한다. 
- ```onError```는 에러만 전달한다.

```swift

let subject = AsyncSubject<Int>()

subject.subscribe{ print($0) }.disposed(by: bag)

subject.onNext(1)
subject.onNext(2)
subject.onNext(3)

subject.onCompleted()
//마지막 onNext + onCompleted

// 혹은?

subject.onError(MyError.error)
//onError 만

```

## 02-05. Relay
- ```PublishRelay```, ```BehaviorRelay```, ```ReplayRelay```가 있다. 
- ```~Relay```는 ```onNext``` 이외는 없다.
- 구독자가 ```dispose```되기 전까지 유지된다.(즉, 종료되지 않는다.)
- ```onNext```와 같은 동작을 하는 ```accept```를 사용한다.


PublishRelay
```swift
let prelay = PublishRelay<Int>()
prelay.subscribe { print("1: \($0)") }.disposed(by: bag)
prelay.accept(1)
```

BehaviorRelay
```swift
let brelay = BehaviorRelay(value: 1)
brelay.accept(2)
brelay.subscribe { print("2: \($0)")}.disposed(by: bag) //2

brelay.accept(3) ////3
print(brelay.value) //읽기 전용
//brelay.value = 4 //error

```

ReplayRelay
```swift
let rrelay = ReplayRelay<Int>.create(bufferSize: 3)
(1...10).forEach { rrelay.accept($0) }

rrelay.subscribe{ print("3: \($0)")}
```

# 03.Operator

## 03-01. CreatingOperator
### 03-01-01. just()
- 하나의 요소를 받는다. 
```swift
let disposeBag = DisposeBag()
let element = "😀"

//하나만
Observable.just(element).subscribe { event in print(event) }.disposed(by: disposeBag)
Observable.just([1,2,3]).subscribe { event in print(event) }.disposed(by: disposeBag)
//받은 Element를 그대로 방출
```

### 03-01-02. of()
- 여러 요소를 받는다.
```swift
let disposeBag = DisposeBag()
let apple = "🍏"
let orange = "🍊"
let kiwi = "🥝"

//하나 이상
//더 많은 Element를 받으려면..
Observable.of(apple, orange, kiwi).subscribe { element in print(element) }.disposed(by: disposeBag)

Observable.of([1,2], [3,4], [5,6]).subscribe { element in print(element) }.disposed(by: disposeBag)

```
### 03-01-03. from()
- 배열을 요소로 받는다.
```swift
let disposeBag = DisposeBag()
let fruits = ["🍏", "🍎", "🍋", "🍓", "🍇"]

//그냥 배열
//배열의 요소를 하나씩 방출하려면?

Observable.from(fruits).subscribe { print($0) }.disposed(by: disposeBag)
```

### 03-01-04. range()
- 시작, 개수를 매개변수로 받아 시퀀스를 만든다.
- 항상 시작 값에서 1씩 증가한다.
```swift
let disposeBag = DisposeBag()

//정수를 지정된 수만큼 방출
Observable.range(start: 1, count: 10).subscribe { print($0) }.disposed(by: disposeBag)
/**
 시작값에서 1씩 증가하는 시퀀스가 생성
 만약 스탭을 바꾸거나 감소하는 연산을 하고 싶다면 generate를 써야한다.
 */
```

### 03-01-05. generate()
- 처음 값, 반복이 종료되는 조건, 반복자를 받아서 Observabled을 생성한다.
```swift
let disposeBag = DisposeBag()
let red = "🔴"
let blue = "🔵"



Observable.generate(initialState: 0, condition: { $0 <= 10}, iterate: { $0 + 2 } ).subscribe {print($0)}.disposed(by: disposeBag)
//0부터 시작하고, 10 이하일 경우 실행하며, 반복은 + 2를 한다. 
//next(0), next(2), next(4), next(6), next(8), next(10), completed

Observable.generate(initialState: 0, condition: { $0 >= -10}, iterate: { $0 - 2 } ).subscribe {print($0)}.disposed(by: disposeBag)
//0부터 시작하고, -10 이상일 경우 실행하며, 반복은 - 2를 한다. 
//next(0), next(-2), next(-4), next(-6), next(-8), next(-10), completed


Observable.generate(initialState: red, condition: { $0.count < 15 }, iterate: { $0.count.isMultiple(of: 2) ? $0 + red : $0 + blue }).subscribe{print($0)}.disposed(by: disposeBag)
// red로 시작하고 한 줄이 15개 이하이면 실행한다. 한 줄의 개수가 짝수 이면 그 줄에 빨간 아니면 파랑을 붙여서 새로운 Observable을 만든다.
```

### 03-01-06. repeatElement()
- 해당 요소를 반복한다. (제한이 없다.)

```swift
let disposeBag = DisposeBag()
let element = "❤️"

Observable.repeatElement(element).take(7).subscribe{print($0)}.disposed(by: disposeBag)
//여기에서는 take로 7개까지라고 한정했다.
```

### 03-01-07. deferred()
- 구독을 하기 전까지 ```Observable```을 생성하지 않으며, 구독을 하면 그 때 생성한다.  (생성을 지연한다.)
- 같은 ```Observable```이라도 ```subscribe```마다 다르게 동작한다.
- 구독 전까지 네트워크 요청을 하지 않는 식으로 활용할 수 있다.

```swift
let animals = ["🐶", "🐱", "🐹", "🐰", "🦊", "🐻", "🐯"]
let fruits = ["🍎", "🍐", "🍋", "🍇", "🍈", "🍓", "🍑"]
var flag = true

let factory: Observable<String> = Observable.deferred {
    flag.toggle()
    if flag {
        return Observable.from(animals)
    } else {
        return Observable.from(fruits)
    }
}

factory
    .subscribe{ print($0) }
    .disposed(by: disposeBag) //과일

factory
    .subscribe{ print($0)}
    .disposed(by: disposeBag) //동물

factory
    .subscribe{ print($0)}
    .disposed(by: disposeBag) //과일

```
### 03-01-08. create()
- ```Observable```을 생성할 때 사용한다.
- 주로 Observable이 동작하는 방식을 직접 정의하고자 할 때 사용한다.

```swift

//Observable이 동작하는 방식을 직접 정의하고 싶다면

let obs = Observable<String>.create{ (observer) -> Disposable in
    guard let url = URL(string: "https://www.apple.com") else {
        observer.onError(MyError.error)
        return Disposables.create()
    }
    
    guard let html = try? String(contentsOf: url, encoding: .utf8) else {
        observer.onError(MyError.error)
        return Disposables.create()
    }
    
    observer.onNext(html)
    observer.onCompleted()
    
    observer.onNext("After completed")
    return Disposables.create()
}


obs.subscribe{ print($0) }.disposed(by: disposeBag)
```

### 03-01-09. empty()
- 어떠한 요소도 방출하지 않는다.
- ```Completed```를 생성하여 전달한다.
```swift
let disposeBag = DisposeBag()

//어떠한 요소도 방출하지 않는다.
//Copmleted 를 생성하는 Observable 을 만든다.

Observable<Void>.empty()
    .subscribe{ print($0) }
    .disposed(by: disposeBag)


//옵저버가 아무런 동작 없이 종료해야할 경우 사용
```

### 03-01-10. error()
- 에러를 생성한다.
```swift
let disposeBag = DisposeBag()

enum ObservableError: Error {
    case error
}

Observable<Void>.error(ObservableError.error)
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

```

## 03-02. FilteringOperator

### 03-02-01. ignoreElements()
- 요소를 무시한다.
```swift
let disposeBag = DisposeBag()
let fruits = ["🍏", "🍎", "🍋", "🍓", "🍇"]



Observable.from(fruits).ignoreElements()
    .subscribe{ print($0) }
    .disposed(by: disposeBag) // completed

```

### 03-02-02. elementAt()
- 특정 인덱스의 요소만 추출한다.
```swift

let disposeBag = DisposeBag()
let fruits = ["🍏", "🍎", "🍋", "🍓", "🍇"]

Observable.from(fruits).element(at: 1)
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

```
### 03-02-03. filter()
- ```Predicate``` 조건에 부합하는 요소만 출력한다.
```swift
let disposeBag = DisposeBag()
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


Observable.from(numbers).filter{ $0.isMultiple(of: 2) }  //2의 배수만
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

```

### 03-02-04. skip(count:)
- 해당 개수 만큼 요소를 무시한다.
```swift

let disposeBag = DisposeBag()
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


Observable.from(numbers)
    .skip(3)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

```
### 03-02-05. skip(while:)
- ```Predicate```가 ```true```가 되면 무시하고 최초로 ```false```가 되는 이후로 방출한다.
```swift
let disposeBag = DisposeBag()
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

Observable.from(numbers)
        .skip { !$0.isMultiple(of: 2) }
        //skip의 predicate가 false가 되는 이후로 방출
        .subscribe{ print($0) }
        .disposed(by: disposeBag)
//1 이후로 방출
```

### 03-02-06. skip(until:)
- ```until```로 ```ObservableType```을 받는다.
- 매개변수로 전달 받은 ```ObservableType```이 방출된 이후 이벤트를 받는다.
- 따라서 until의 매개변수는 트리거가 된다.
```swift

let disposeBag = DisposeBag()
//until의 Observable이 trigger로 작동된다.
//Observable.just(1).skip(until: <#T##ObservableType#>)

let subject = PublishSubject<Int>()
let trigger = PublishSubject<Int>()
subject.skip(until: trigger).subscribe{ print($0) }.disposed(by: disposeBag)

subject.onNext(1)

trigger.onNext(0)  /// 이 이후의 이벤트만 받는다.
     
subject.onNext(2) //2는 방출된다.

//trigger가 방출된 이후 이벤트만 방출


```

### 03-02-07. skip(duration: scheduler:)
- 일정 시간 동안 방출을 무시한다.
- duration으로 받는 시간이 정확하지 않은 편이다.
```swift

let disposeBag = DisposeBag()

let o = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)

o.take(10)
    .skip(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print($0) }
    .disposed(by: disposeBag)
//Observable이 방출하는 이벤트를 3초 간 무시
//2부터 방출하는 이유?? -> 시간 오차가 발생 ms 단위의 오차가 발생 

```

### 03-02-08. take()
- 매개변수의 개수 만큼 요소를 받는다.
```swift

let disposeBag = DisposeBag()
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


Observable.from(numbers).take(5).subscribe{ print($0) }.disposed(by: disposeBag)
//에러가 발생하면 에러 이벤트도 전달
```

### 03-02-09. take(while:)
- 매개변수를 받는다.
- ```Predicate```가 ```true```일 경우 받는다.
- ```Predicate```가 ```false```가 되는 순간, 그 이후로는 받지 않는다.
- ```.exclusive```는 마지막 값 포함하지 않음, ```.inclusive```는 마지막 값 포함
```swift

let disposeBag = DisposeBag()
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


Observable.from(numbers).take(while: {!$0.isMultiple(of: 2)}, behavior: .exclusive)
        //조건을 충족하는 이벤트만 방출
        //behavior -> exclusive, inclusive
        .subscribe{ print($0) }
        .disposed(by: disposeBag)

//단 predicate가 false가 되면 중지(.exclusive)


Observable.from(numbers).take(while: {!$0.isMultiple(of: 2)}, behavior: .inclusive)
        //조건을 충족하는 이벤트만 방출
        //behavior -> exclusive, inclusive
        .subscribe{ print($0) }
        .disposed(by: disposeBag)

//단 predicate가 false가 되면 중지(.inclusive ==> 마지막 값 포함)
```

### 03-02-10. take(until: )
- ```ObservableType```을 매개변수로 받는다.
- 매개변수의 ```Observable```이 ```emit```되면 ```completed```가 된다.
- ```.inclusive```, ```.exclusive```를 받으며, 이는 트리거가 방출된 후 이벤트를 받느냐 마느냐를 결정한다.
```swift

let disposeBag = DisposeBag()


var subject = PublishSubject<Int>()
let trigger = PublishSubject<Int>()

/** take(until: (Int) -> Bool, behavior: TakeBehavior)*/
//predicate가 true가 되면 complete
//subject.take(until: { $0 > 5 }, behavior:.exclusive)
subject.take(until: { $0 > 5 }, behavior:.inclusive)
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

subject.onNext(1)
subject.onNext(2)
subject.onNext(4)
subject.onNext(6) //.exclusive -> completed //.inclusive -> 6, completed
subject.onNext(2)
```

### 03-02-11. takeLast(count:)
- 마지막에서 몇 개를 방출한다.
- 마지막에서 N개를 방출하는 식으로 동작하기 때문에 자연스레 방출이 지연된다.
- 방출되는 기점은 ```completed```가 되는 순간이다.
- error의 경우는 버퍼를 무시하고 에러만 보낸다. 

```swift

subject.takeLast(2)
        //원본 Observable이 방출하는 next이벤트를 count 만큼 마지막에서 방출 (끝에서)
        .subscribe{ print($0) }.disposed(by: disposeBag)
// 마지막에서 ~개를 방출하는 식이라 자연스럽게 방출이 지연된다.
(1 ... 10).forEach{ subject.onNext($0) }
//이렇게 해도 방출은 안된다 지연상태다.
subject.onNext(11)
//이러면 10, 11을 담고 기다린다.

//subject.onCompleted()
//completed가 되는 순간 마지막 이벤트를 방출한다.


enum MyError: Error {
    case error
}
subject.onError(MyError.error)
//에러는 이전 버퍼를 무시하고 에러만 보낸다.

```

### 03-02-12. take(for:)
- ```for```에 주어진 시간 만큼 요소를 방출한다.
- 역시 시간은 정확하지 않다.
```swift


let disposeBag = DisposeBag()

let o = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)

o.take(for: .seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

// take(for:) 여기에 준 시간 만큼 방출하고 끝낸다.
```
### 03-02-13. single()
- 원본 배열에서 첫 번째만 방출하거나 클로저로 받은 조건에 부합하는 첫 번째 하나만 방출한다.
- 구독자에게 요소 하나만 리턴하는 것을 보장한다. 
- 여러 요소 중 하나만을 방출하는 것을 보장하는 것이지 여러 ```next``` 중 하나만 방출하는 것을 보장하는 의미는 아니다.
```swift

let disposeBag = DisposeBag()
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
//원본에서 첫 번째만 방출하거나 조건에 부합하는 첫 번쨰만 방출
Observable.just(1)
    .single()
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

Observable.from(numbers)
    .single() //error(Sequence contains more than one element.)
    .subscribe{ print($0) }
    .disposed(by: disposeBag)
//하나 이상을 방출하려고 하면 에러

Observable.from(numbers)
    .single{ $0 == 3 }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

let subject = PublishSubject<Int>()
subject.single()
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

subject.onNext(100) //하나 보냈다고 바로 completed를 리턴하지 않는다. 즉, 대기한다.
Thread.sleep(forTimeInterval: 1)
subject.onNext(200) //구독자에게 하나 만을 방출하는 것을 보장한다.

```

### 03-02-14. distinctUntilChanged()
- 이전 값과 비교하여 같으면 방출하지 않는다.
- 바로 전과 비교하기 때문에 반드시 이전에 나온 것이 안나올 것이라는 보장은 하지 않는다.
- 클로저로 조건을 명시할 수도 있다.
- 튜플이나 객체의 경우 비교 대상을 클로저로 명시할 수 있다.
- keyPath로 지정할 수도 있다(객체의 경우)
 
```swift
let disposeBag = DisposeBag()
let numbers = [1, 1, 3, 2, 2, 3, 1, 5, 5, 7, 7, 7]
let tuples = [(1, "하나"), (1, "일"), (1, "one")]
let persons = [
    Person(name: "Sam", age: 12),
    Person(name: "Paul", age: 12),
    Person(name: "Tim", age: 56)
]

Observable.from(numbers)
    .distinctUntilChanged() //순서대로 비교하고 이전 이벤트와 같다면 방출하지 않는다.
    .subscribe{ print($0) }
    .disposed(by: disposeBag)
//단순히 동일한 이벤트가 연속적으로 방출되는지만 막는다.
//같은지는 $0 == $1와 같이 비교한다.
//만약 비교를 커스텀하고 싶다면 클로저나 keyPath를 받는다.

Observable.from(numbers)
    .distinctUntilChanged { !$0.isMultiple(of: 2) && !$1.isMultiple(of: 2) }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

Observable.from(tuples)
    .distinctUntilChanged { $0.0 }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

Observable.from(tuples)
    .distinctUntilChanged { $0.1 }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

Observable.from(persons)
        .distinctUntilChanged(at: \.age)
        .subscribe{ print($0) }
        .disposed(by: disposeBag)

```

### 03-02-12. debounce(_ dueTime: scheduler:)
- 일정 시간 이벤트를 무시한 후 이벤트를 받는다.

```swift

let disposeBag = DisposeBag()

let buttonTap = Observable<String>.create { observer in
   DispatchQueue.global().async {
      for i in 1...10 {
         observer.onNext("Tap \(i)")
         Thread.sleep(forTimeInterval: 0.3)
      }
      
      Thread.sleep(forTimeInterval: 1)
      
      for i in 11...20 {
         observer.onNext("Tap \(i)")
         Thread.sleep(forTimeInterval: 0.5)
      }
      observer.onCompleted()
   }
   return Disposables.create { }
}

buttonTap
    .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
   .subscribe { print($0) }
   .disposed(by: disposeBag)
```

### 03-02-13. throttle(_ dueTime:, latest:, scheduler:)
- 첫 이벤트를 받고 일정 시간 이벤트를 무시한다.
- ```latest```가 ```true```일 경우에는 해당 주기의 마지막 이벤트를 방출한다. ```false```라면 해당 주기의 마지막 이벤트를 무시한다.
```swift
let disposeBag = DisposeBag()

let buttonTap = Observable<String>.create { observer in
   DispatchQueue.global().async {
      for i in 1...10 {
         observer.onNext("Tap \(i)")
         Thread.sleep(forTimeInterval: 0.3)
      }
      
      Thread.sleep(forTimeInterval: 1)
      
      for i in 11...20 {
         observer.onNext("Tap \(i)")
         Thread.sleep(forTimeInterval: 0.5)
      }
      
      observer.onCompleted()
   }
   
   return Disposables.create { }
}

buttonTap
   .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
   .subscribe { print($0) }
   .disposed(by: disposeBag)

```

## 03-03. TransformingOperator
### 03-03-01. toArray()
- ```Completed``` 전까지 ```next```한 이벤트를 모아서 배열로 방출한다.
```swift
let disposeBag = DisposeBag()
let nums = [1,2,3,4,5,6,7,8,9,10]

let subject = PublishSubject<Int>()

subject
    .toArray()
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

subject.onNext(1)
subject.onNext(2)
subject.onCompleted()
//toArray는 completed전까지 방출한 요소를 모아서 배열로 방출한다. 
```

### 03-03-02. map()
- ```Observable```의 값을 변환하여 방출한다.
```swift
let disposeBag = DisposeBag()
let skills = ["Swift", "SwiftUI", "RxSwift"]

Observable.from(skills)
//    .map{ "Hello, \($0)"}
    .map{ $0.count } //-> 글자의 개수로 변환
    .subscribe{ print($0) }
    .disposed(by: disposeBag)
```

### 03-03-03. compactMap()
- ```nil```이면 무시한다.
- ```nil```이 아니면 언래핑해서 반환한다.


```swift
let disposeBag = DisposeBag()
let subject = PublishSubject<String?>()

subject
        //    .filter{ $0 != nil }
        //    .map { $0! }
        .compactMap{ $0 }
        .subscribe { print($0) }
        .disposed(by: disposeBag)

Observable<Int>.interval(.milliseconds(300), scheduler: MainScheduler.instance)
        .take(10)
        .map { _ in Bool.random() ? "⭐️" : nil }
        .subscribe(onNext: { subject.onNext($0) })
        .disposed(by: disposeBag)

/**
    compactMap은 변환을 한다. nil이면 무시, nil이 아니면 언래핑 해서 반환
 */
```

### 03-03-04. flatMap()
- ```InnerObserver```를 생성하고 지연 없이 방출한다.
- 기존 요소에서 ```Flattening```을 한다.

```swift
let disposeBag = DisposeBag()

let redCircle = "🔴"
let greenCircle = "🟢"
let blueCircle = "🔵"

let redHeart = "❤️"
let greenHeart = "💚"
let blueHeart = "💙"

Observable.from([redCircle, greenCircle, blueCircle])
    .flatMap { circle -> Observable<String> in
        switch circle {
            case redCircle:
                return Observable.repeatElement(redHeart).take(5)
            case greenCircle:
                return Observable.repeatElement(greenHeart).take(5)
            case blueCircle:
                return Observable.repeatElement(blueHeart).take(5)
            default:
                return Observable.just("")
        }
    }.subscribe{ print($0) }
    .disposed(by: disposeBag)

//InnerObservable을 지연없이 방출하기 때문에 순서가 제멋대로 (Interleaving이라고 한다. -> ConcatMap과 비교된다.)
//해당 예제는 3개의 빨, 녹, 파 원을 5개의 하트로 바꾼다.
//결과는 빨간하트 x 5, 녹색하트 x 5, 파란하트 x 5가 아닌 순서가 섞여서 나온다. 이는 Interleaving 때문이다.   
```

### 03-03-05. flatMapFirst()
- ```InnerObserver```를 생성하고 지연 없이 방출한다.
- 기존 요소에서 ```Flattening```을 한다.
- 가장 먼저 방출되는 요소만을 방출한다.
- '가장 먼저'에 대한 정의는 하나의 주기 중에서이다. 
  
```swift
//#exam1
let disposeBag = DisposeBag()

let redCircle = "🔴"
let greenCircle = "🟢"
let blueCircle = "🔵"

let redHeart = "❤️"
let greenHeart = "💚"
let blueHeart = "💙"

Observable.from([redCircle, greenCircle, blueCircle])
    .flatMapFirst { circle -> Observable<String> in
//    .flatMap { circle -> Observable<String> in
        switch circle {
        case redCircle:
            return Observable.repeatElement(redHeart)
                .take(5)
        case greenCircle:
            return Observable.repeatElement(greenHeart)
                .take(5)
        case blueCircle:
            return Observable.repeatElement(blueHeart)
                .take(5)
        default:
            return Observable.just("")
        }
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

// InnerObservable 중 가장 먼저 이벤트를 방출하는 것을 방출 
// 여기서는 빨간 하트 5개가 나온다.

//#exam2
//하나의 주기 안에서 가장 먼저 방출된 것을 방출한다.
sourceObservable
        .flatMapFirst { circle -> Observable<String> in
            print(circle)
            switch circle {
            case redCircle:
                return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                        .map { _ in redHeart}
                        .take(10)
            case greenCircle:
                return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                        .map { _ in greenHeart}
                        .take(10)
            case blueCircle:
                return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                        .map { _ in blueHeart}
                        .take(10)
            default:
                return Observable.just("")
            }
        }
        .subscribe { print($0) }
        .disposed(by: disposeBag)

sourceObservable.onNext(redCircle)

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    sourceObservable.onNext(greenCircle)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
    sourceObservable.onNext(blueCircle)
}

//결과로 모두 방출된다. 색은 섞이지 않는다.
```

### 03-03-06. flatMapLatest()
- ```InnerObserver```를 생성하고 지연 없이 방출한다.
- 기존 요소에서 ```Flattening```을 한다.
- 가장 마지막에 방출되는 요소만을 방출한다.
- 이전 작업 중 새로운 ```next```가 방출되면 기존의 ```InnerObserver```를 제거하고(멈추고) 새로운 것을 방출한다.
```swift

let disposeBag = DisposeBag()

let redCircle = "🔴"
let greenCircle = "🟢"
let blueCircle = "🔵"

let redHeart = "❤️"
let greenHeart = "💚"
let blueHeart = "💙"

let sourceObservable = PublishSubject<String>()
let trigger = PublishSubject<Void>()
//원본 -> InnerObservable을 만들어서 방출하는데 새로운 InnerObservable이 생기면 기존 이벤트 방출은 멈추고 최근 이벤트를 방출한다.
sourceObservable
//    .flatMap { circle -> Observable<String> in
    .flatMapLatest { circle -> Observable<String> in
        switch circle {
            case redCircle:
                return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                    .map { _ in redHeart}
                    .take(until: trigger)
            case greenCircle:
                return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                    .map { _ in greenHeart}
                    .take(until: trigger)
            case blueCircle:
                return Observable<Int>.interval(.milliseconds(200), scheduler: MainScheduler.instance)
                    .map { _ in blueHeart}
                    .take(until: trigger)
            default:
                return Observable.just("")
        }
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

sourceObservable.onNext(redCircle)

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    sourceObservable.onNext(greenCircle)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    sourceObservable.onNext(blueCircle)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    sourceObservable.onNext(redCircle)
} // -> 핵심은 InnerObservable을 재사용하는 식으로 만들어지는 것이 아니다. 항상 기존의 것을 제거한다. 

DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    trigger.onNext(())
}

//새로운 InnerObs 가 생성되면 기존 InnerObs가 삭제

```

### 03-03-07. concatMap()
- 기존 ```map```과 유사하게 동작한다.
- ```Interleaving```이 발생하지 않는다.
- 따라서 순서를 보장한다.
```swift
let disposeBag = DisposeBag()

let redCircle = "🔴"
let greenCircle = "🟢"
let blueCircle = "🔵"

let redHeart = "❤️"
let greenHeart = "💚"
let blueHeart = "💙"

Observable.from([redCircle, greenCircle, blueCircle])
//뒤섞이는 것을 Interleaving이라고 한다.
//concatMap은 순서를 보장한다. (원본 Observable, InnerObsevable의 순서가 같음)
//    .flatMap { circle -> Observable<String> in
    .concatMap { circle -> Observable<String> in
        switch circle {
        case redCircle:
            return Observable.repeatElement(redHeart)
                .take(5)
        case greenCircle:
            return Observable.repeatElement(greenHeart)
                .take(5)
        case blueCircle:
            return Observable.repeatElement(blueHeart)
                .take(5)
        default:
            return Observable.just("")
        }
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

//결과 빨강 하트 5, 녹 5 파 5
```

### 03-03-08. scan()
- ```reduce()```와 유사한 동작을 하나, 중간 단계를 ```emit```
```swift
/**
 기본 값으로 연산을 시작 -> 원본 Obs가 방출하는 값으로 연산을 시작하고 결과를 방출
-> Reduce랑 비슷해보임 (중간 단계도 구독자에 보낸다는 점이 다른 것 같음)
 */
let disposeBag = DisposeBag()

Observable.range(start: 1, count: 10)
        //    .scan(0, accumulator: { $0 + $1})
        .scan(0, accumulator: + )
        .subscribe{ print($0) }
        .disposed(by: disposeBag)
```

### 03-03-09. buffer(timespan:, count:, scheduler:)
- 일정 시간 혹은 개수 만큼 버퍼에 담아서 배열로 처리한다.
- 일정 시간, 혹은 개수를 넘으면 배열로 방출한다.
```swift
/**
 특정 주기동안 Obs가 방출하는 값을 수집하고 하나의 배열로 리턴
 */
let disposeBag = DisposeBag()

Observable<Int>.interval(.milliseconds(1000), scheduler: MainScheduler.instance)
    .buffer(timeSpan: .milliseconds(2000), count: 3, scheduler: MainScheduler.instance)
    .take(5)
    .subscribe{ print($0) }
    .disposed(by: disposeBag)
```

### 03-03-10. window(timer:, scheduler:)
- ```buffer```와 같이 작은 단위의 ```Observable```로 분해한다.
- 수집된 항목을 반환하는 ```Observable```을 반환한다.
```swift

let disposeBag = DisposeBag()
//buffer같이 작은 단위 Observable로 분해한다.
//window는 수집된 항목(Observable)을 반환하는 Observable을 반환한다.

Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .window(timeSpan: .seconds(5), count: 3, scheduler: MainScheduler.instance)
    .subscribe{
        print($0)
        if let observable = $0.element {
            observable.subscribe{print("  Inner  :", $0)}
        }
    }
    .disposed(by: disposeBag)
```

### 03-03-11. groupby()
- 결과로 ```Observable<GroupedObservable<Key, Element>>```를 반환한다.
- 일정한 기준으로 그룹화 한다.

```swift

let disposeBag = DisposeBag()
let words = ["Apple", "Banana", "Orange", "Book", "City", "Axe"]

Observable.from(words)
//    .groupBy { $0.count }
//    .subscribe{ print($0) }
//    .subscribe(onNext: {groupedObservable in
//        print("== \(groupedObservable.key)")
//        groupedObservable.subscribe{ print("  \($0)") }
//    })
    .groupBy{ $0.first ?? Character(" ") }
    .flatMap{ $0.toArray() }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)



Observable.range(start: 1, count: 10)
    .groupBy{ $0.isMultiple(of: 2) }
    .flatMap{ $0.toArray() }
    .subscribe{ print($0) }
    .disposed(by: disposeBag)

```

## 03-04. CombiningOperator
### 03-04-01. startWith(element: Element...)
- last in first out
- ```Observable```이 방출하기 전 기본/시작 값을 지정할 때 사용
```swift

let bag = DisposeBag()
let numbers = [1, 2, 3, 4, 5]

//Obs가 방출하기 전에 기본/시작값을 지정할 때 사용
//당연히 두 개 이상 연달아 사용 가능

Observable.from(numbers).startWith(-1).startWith(-2).startWith(-4, -9, -22)
    .subscribe{ print($0) }.disposed(by: bag)
// -4 -9 -22 -2 -1 1 2 3 4 5
// last in first out

//추가한 역순으로 시작
```


### 03-04-02. concat()
- 두 개의 ```Observable```을 연결할 때 사용한다.
- 방법은 ```typeMethd```, ```instanceMethod``` 두 개가 있다.
- 결합 순서는 연결된 순서대로 이며, 방출 순서도 같다.
- 순서대로 방출, ```completed```가 되면 다음 ```Observable이``` 시작된다.
```swift

let bag = DisposeBag()
let fruits = Observable.from(["🍏", "🍎", "🥝", "🍑", "🍋", "🍉"])
let animals = Observable.from(["🐶", "🐱", "🐹", "🐼", "🐯", "🐵"])


//두 개의 observable을 연결 할 때 사용
//typeMethod, instanceMethod로 구성됨

Observable.concat([fruits, animals])
    .subscribe{ print($0) }.disposed(by: bag)
//순서대로 연결한 새로운 Observable을 반환
//연결된 observable이 모든 요소를 방출하면 completed

fruits.concat(animals).subscribe{ print($0) }.disposed(by: bag)
//error가 전달되면 바로 종료


animals.concat(fruits).subscribe{ print($0) }.disposed(by: bag)
// 이전 observable(animal) 이 completed 되어야 다음 Observable(fruits)이 방출됨

```

### 03-04-03. merge()
- 두 개 이상의 ```Observable```을 결합할 수 있다.
- 이후 모든 ```Observable```에서 방출하는 요소를 모은 ```Observable```을 생성하고 방출한다.
- merge 자체의 개수 제한은 없지만, ```merge(maxConcurrent:)```로 한 번에 병합하는 수를 조절할 수 있다.
- ```maxConcurrent```보다 많은 수의 ```Observable```을 병합하면 바로 병합되는 것이 아닌 큐에서 병합을 기다린다.
- 병합된 ```Observable```에서 ```completed``` 상태가 되면 큐에 있는 나머지가 병합된다.
- 완료는 병합된 요소가 모두 ```completed```가 되면 완료 상태가 되며, 그 중 하나라도 ```error```상태가 되면 구독자에게 ```error```를 알린다. 
```swift

let bag = DisposeBag()

enum MyError: Error {
   case error
}

let oddNumbers = BehaviorSubject(value: 1)
let evenNumbers = BehaviorSubject(value: 2)
let negativeNumbers = BehaviorSubject(value: -1)

//concat과 혼동할 수 있지만, 다른 동작을 갖는다.
//두 개 이상의 obs를 병합하고 모든 obs에서 방출하는 요소들을 방출하는 obs를 생성
//merge 수는 제한이 없음. 만약 제한해야 한다면 merge(maxConcurrent: )에 파라미터로 수를 보내면 된다.
let source = Observable.of(oddNumbers, evenNumbers, negativeNumbers)
source
    .merge(maxConcurrent: 2)
    .subscribe { print($0) }
    .disposed(by: bag)

oddNumbers.onNext(3)
evenNumbers.onNext(4)

evenNumbers.onNext(6)
oddNumbers.onNext(5)
/**
 next(1)
 next(2)
 next(3)
 next(4)
 next(6)
 next(5)

 대체 언제 종료되는가?
 */
//oddNumbers.onCompleted()
//이래도 evenNumbers는 이벤트를 받을 수 있다.
////oddNumbers.onError(MyError.error)
//#2 error라면? -> 그 즉시 구독자에 에러를 전달

////evenNumbers.onNext(8)
//next(8)
///evenNumbers.onCompleted()
//이렇게 다 종료해야 merge 역시 completed

//#3
negativeNumbers.onNext(-11)
//이러면 queue에 저장해 놓는다. 다른 Observable이 completed가 되면 병합 대상으로 올린다. 

```

### 03-04-04. combineLatest()
- 결과를 방출하는 ```Observable```을 방출한다.
- 타임라인에서 소스 타이밍 앞 뒤로 있는 다른 소스와 결합한다.
- 모든 소스에 이벤트가 방출되면 구독자에게 전파된다.
- 모든 소스가 ```completed```가 되면 구독자에 ```completed```가 전파된다.
- ```Error```는 바로 구독자에게 전파된다. 
```
 ex)

  ----1----2--------------------------3-----4-----------------5-----|→
                                
                                 ✚ 
                                
  ------A-----B--------------C---D----------------------------------|→
  
                                 
                                 =
                                 
  -------1A--2A--2B-----------2C--2D----3D----4D---------------5D---|→
 
```
```swift

Observable.combineLatest(greetings, languages) { lhs, rhs -> String in
    return "\(lhs) \(rhs)"
}
.subscribe{ print($0) }
.disposed(by: bag)

//combineLatest 결과를 방출하는 Observable을 방출


greetings.onNext("Hi, ")
//여기서 language에 이벤트가 없어서 구독자에게 방출 X -> 바로 받고 싶다면 BehaviorSubject || startWith 연산자로 넘기면 바로 받을 수도 있겠다
languages.onNext("Swift")
languages.onNext("RxSwift")

greetings.onNext("Hello!, ")

//greetings.onCompleted()
greetings.onError(MyError.error)  //소스 중 하나라도 error -> 구독자에게 Error
greetings.onNext("ByeBye! ")
languages.onNext("js")


// 둘 다(combine 대상 모두) completed가 되면 구독자에게 completed가 전달됨
languages.onCompleted()
```
### 03-04-05. zip()
- combineLatest와 유사한 듯 보이나 다르다.
- 각 이벤트에 인덱스에 맞춰서 조합된다. ```(Indexed Sequencing)```
- 결합할 짝이 없으면 구독자에게 전달되지 않는다.
- 소스 중 하나라도 ```Error```가 되면 구독자에 에러를 전달한다.
- 소스 모두 ```completed```가 되면 구독자에 전달된다.

``` 
ex)
 ---------1--------2-------------------3-----4---------5--|→
 
                            +
 
 -------------A-------B-----------C-D---------------------|→
 
                            =
 
 -------------1A-------2B--------------3C------4D---------|→
```
```swift
let numbers = PublishSubject<Int>()
let strings = PublishSubject<String>()


Observable.zip(strings, numbers) { "\($0) - \($1)" }.subscribe{ print($0) }.disposed(by: bag)
strings.onNext("A")
strings.onNext("B")

numbers.onNext(1)
//strings.onCompleted()
strings.onError(MyError.error)
numbers.onCompleted()
//항상 방출된 순서대로 짝을 이룬다.
//소스 중 하나라도 에러가 나면 구독자에 에러를 전파
```

### 03-04-06. withLatestFrom()
- ```triggerObservable.withLatestFrom(dataObservable)```의 형태
- 트리거가 ```next```를 전달하면 ```dataObserver```가 가장 최근의 ```next```를 구독자에게 전달한다.
- 전달 타이밍은 트리거의 ```next```이다.
- ```dataObserver```가 새로이 ```next```하지 않으면 트리거 ```next```시 같은 값이 전달될 수 있다.
- 트리거의 ```completed``` 여부에 따라 구독자에 ```completed```가 전달된다.
- 데이터의 ```error```는 구독자에게 바로 전달된다.

```swift
let trigger = PublishSubject<Void>()
let data = PublishSubject<String>()

trigger.withLatestFrom(data)
    .subscribe{ print($0) }
    .disposed(by: bag)

data.onNext("Hello")
data.onNext("RxSwift")

trigger.onNext(())
trigger.onNext(())
//trigger가 next 될 때마다 data의 최신 next를 구독자에 전달

//data.onCompleted() // 트리거가 completed여야 구독자에 completed를 전달
//data.onError(MyError.error) //에러면 구독자에 바로 전달
trigger.onNext(())
trigger.onCompleted()

```

### 03-04-07. sample()
- ```dataObservable.sample(triggerObservable)``` 형태이다.
- 트리거의 ```next``` 여부에 따라 ```dataObserver```에서 이벤트를 방출한다.
- ```withLatestFrom()```과 차이점은 중복된 내용을 ```dataObserver```에서 방출하지 않는다는 점이다.
- ```dataObserver```에서 ```completed``` 전달 후 트리거에서 ```next```를 하면 ```completed```가 구독자에게 전달된다.  
```swift
let trigger = PublishSubject<Void>()
let data = PublishSubject<String>()

data.sample(trigger)
    .subscribe{ print($0) }
    .disposed(by: bag)

trigger.onNext(()) //data가 방출되지 않아서 구독자에 방출되지 않음

data.onNext("HALO!")
trigger.onNext(())
trigger.onNext(()) //이전 데이터를 중복 방출하지 않음

//data.onCompleted() // sample은 completed를 onNext시 그대로 전달
//trigger.onNext(())

//data.onError(MyError.error) //트리거에서 next 없이도 에러 전달

trigger.onError(MyError.error) //바로 에러 전달
```

### 03-04-08. switchLatest()
- 가장 최근 이벤트를 방출한 ```Observable```의 이벤트를 구독자에게 방출한다.
- ```Observable```을 구독하는 ```Observable```에 가깝다.
- 소스를 구독 후, 소스가 이벤트를 방출하면 구독자에게 해당 이벤트를 방출한다.
- 구독 대상의의 ```completed```는 구독자로 전달되지 않는다.
- 구독 대상의 ```error```는 즉시 전달된다.
- ```switchLatest```의 ```completed```가 구독자게에 전달된다.
```swift

let a = PublishSubject<String>()
let b = PublishSubject<String>()


let source = PublishSubject<Observable<String>>()
source
    .switchLatest() // 파라미터 없음
    .subscribe { print($0) }
    .disposed(by: bag)

a.onNext("1")
b.onNext("B")

source.onNext(a) //여기까지 소스에서 방출하는 것이 없기에 아무것도 방출되지 않는다. onNext(a)로 하면 a가 감시 대상이 된다.

a.onNext("2")
b.onNext("B") //여기는 구독하지 않았기에 전달되지 않는다.

source.onNext(b) //b가 감시 대상이된다. a에 대한 구독은 종료한다.
b.onNext("b")


//a.onCompleted()//구독자로 전달되지 않는다.
//b.onCompleted()//구독자로 전달되지 않는다.

a.onError(MyError.error) //구독해제 했기에 전달되지 않는다.
b.onError(MyError.error) //전달한다.

source.onCompleted() // 소스에 completed 해야 전달
```
### 03-04-09. reduce()
- 일전의 ```scan()```과 유사한 동작을 한다.
- ```scan()```과 차이점은 중간 과정을 방출하냐 아니냐이다.
- ```scan()```은 중간 과정이 필요한 경우, ```reduce()```는 중간 과정이 필요 없는 경우이다.
- ```reduce()``` 연산 결과를 방출하고 ```completed``` 상태가 된다. 
```swift

let bag = DisposeBag()

enum MyError: Error {
   case error
}

let o = Observable.range(start: 1, count: 5)

print("== scan") //중간 결과가 필요한 경우에 사용
o.scan(0, accumulator: +)
   .subscribe { print($0) }
   .disposed(by: bag)

print("== reduce") //결과만 필요한 경우 사용
o.reduce(0, accumulator: +)
    .subscribe { print($0) }
    .disposed(by: bag)


//reduce는 결과만 방출하고 onCompleted가 된다.

```

## 03-05. ConditionalOperator
### 03-05-01. amb()
- 가장 먼저 방출을 한 ```Observerable```를 구독한다.
- 이를 응용하면 여러 서버에 동일 요청을 보내고 가장 빠른 응답을 가지고 로직을 수행하는 등의 작업을 수행할 수 있다.
```
ex)
---------20----40-------60-----------|→
 
 ------1--2-----3---------------------|→
 
 ----------0------0--------0--------0-|→
 
 [amb]
 ------1--2-----3---------------------|→
```
```swift
let a = PublishSubject<String>()
let b = PublishSubject<String>()
let c = PublishSubject<String>()


a.amb(b)
    .subscribe{ print($0) }
    .disposed(by: bag)

a.onNext("A")
b.onNext("B")  //이러면 A subject를 구독
b.onCompleted() //어떠한 B의 이벤트 모두 무시
a.onCompleted()

//
//Observable.amb([a,b,c])
//    .subscribe{ print($0) }
//    .disposed(by: bag)
//
//
//a.onNext("A")
//b.onNext("B")
//c.onNext("C")
```

## 03-06. TimeBasedOperation

### 03-06-01. interval()
- ```Observable``` 내부에 타이머를 만든다.
- 구독 숫자 만큼 타이머를 만든다.
- ```interval```의 ```period``` 주기로 반복한다.

```swift
let i = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
let subscription1 = i.subscribe{ print("1 >>> \($0)") }

//Observable 내부에 타이머가 있는데 생성 시점은 subscribe 때이다. 따라서 subscriber 수 만큼 타이머가 생긴다.
DispatchQueue.main.asyncAfter(deadline: .now() + 5){
    subscription1.dispose()
}

var subscription2: Disposable?
DispatchQueue.main.asyncAfter(deadline: .now() + 2){
    subscription2 = i.subscribe{ print("2 >>> \($0)")}
}

DispatchQueue.main.asyncAfter(deadline: .now() + 7){
    subscription2?.dispose()
}
```

### 03-06-02. timer()
- ```dueTime```로 첫 방출 이벤트의 시간을 조절할 수 있다.
- ```period```로 반복 주기 간 시간을 정할 수 있다.
```swift
let bag = DisposeBag()
//첫 번째 요소의 전달 시간
Observable<Int>.timer(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe{ print($0) }
    .disposed(by: bag)

//두 번 째 파라미터(period)가 반복 주기가 된다.
let obs = Observable<Int>.timer(.seconds(1), period: .milliseconds(500), scheduler: MainScheduler.instance)
    .subscribe{ print($0) }

DispatchQueue.main.asyncAfter(deadline: .now() + 5){
    obs.dispose()
}
```

### 03-06-03. timeout()
- ```Observable```에 timeout을 지정할 수 있다.
- timeout이 지나면 ```Error(RxError.timeout)``` 이벤트를 전달한다. 
- ```other```에 다른 ```Observable```을 전달할 경우, 원래 이벤트 ```Error```시 ```other```로 교체된다.
```swift
let bag = DisposeBag()

let subject = PublishSubject<Int>()

//timeout 내에 next를 전달하지 않으면 RxError.timeout으로 에러를 전파
//subject.timeout(.seconds(3), scheduler: MainScheduler.instance)
//    .subscribe{ print($0) }
//    .disposed(by: bag)
//
//Observable<Int>.timer(.seconds(1), period: .seconds(1),scheduler: MainScheduler.instance)
//    .subscribe(onNext: { subject.onNext($0) })
//    .disposed(by: bag)

//other에는 Observable을 전달하며, subject에서 타임아웃이 발생하면 Observable이 other로 변경된다. 
subject.timeout(.seconds(3), other: Observable.just(0), scheduler: MainScheduler.instance)
    .subscribe{ print($0) }
.disposed(by: bag)

Observable<Int>.timer(.seconds(2 /*5*/), period: .seconds(5 /*2*/),scheduler: MainScheduler.instance)
    .subscribe(onNext: { subject.onNext($0) })
    .disposed(by: bag)
```

### 03-06-04. delay()
- ```next``` 이벤트의 전파를 ```dueTime``` 만큼 미룬다.
- ```error```는 즉시 전달한다.
- 구독 자체를 미루는 개념은 아니다.
```swift
let bag = DisposeBag()

func currentTimeString() -> String {
   let f = DateFormatter()
   f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
   return f.string(from: Date())
}
//next이벤트가 구독자로 전달되는 시점을 지정한 시간만큼 지연시킨다.
//에러 이벤트는 즉시 전달
Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .debug()
    .delay(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe{ print($0) }
    .disposed(by: bag)
//구독 시점을 연기 시키는 것이 아니라 구독자에게 전달하는 시점을 딜레이 한다. 
```
### 03-06-05. delaySubscription()
- 구독 자체를 ```dueTime``` 만큼 늦춘다.
```swift
let bag = DisposeBag()

func currentTimeString() -> String {
   let f = DateFormatter()
   f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
   return f.string(from: Date())
}

Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(10)
    .debug()
    .delaySubscription(.seconds(7), scheduler: MainScheduler.instance)
    .subscribe{ print($0) }
    .disposed(by: bag)

//구독 자체를 딜레이 시켜서 next 자체를 늦추게 된다. 
```

# 04.SharingSubscribe
```Observable```을 구독하면 그 때마다 연산을 시작한다. 만약 일전에 누군가 구독을 통해서 얻은 내용을 공유할 수 있다면 좋을 것이다.

## 04-01. multicast
- 일전의 방식은 ```UniCast```에 가깝다.
- ```multiCast```는 여러 구독자가 하나의 ```subject```를 구독한다.
- ```subject```가 ```Observable```을 구독하고 그 ```subject```를 다시 구독하는 형태이다.
- ```ConnectableObservable<Subject, Element>``` 타입을 리턴한다.
- ```ConnectableObservable```은 구독한다고 바로 이벤트가 방출되는 것이 아니라 ```connect()```메소드를 실행하면 그 때 ```broadCast```가 시작된다.
- ```connect()```의 리턴 값은 ```disposable```이다.
- 하나의 시퀀스를 공유하기 때문에 해당 시퀀스가 끝나면 구독자들 모두 종료가 된다.
```swift
//Unicast와 같다. 여러 구독자가 하나의 Observable을 구독하는 방법 ==> 1. Multicast
/**
 Subject가 Observable을 구독하고 그 subject를 구독하는 방식 (ConnectableObservable<Subject, Element> 형태)
 
 ConnectableObservable은 subscribe를 해도 시퀀스가 실행되지 않음
 connect()를 해야, 시퀀스 실행
 
 --> 모든 구독자 구독 후 Subject 실행
 */


let bag = DisposeBag()
let subject = PublishSubject<Int>()

let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).take(5)

    .multicast(subject) //이러면 source에는 ConnectablerObsevable이 저장

source
    .subscribe { print("🔵", $0) }
    .disposed(by: bag)

source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("🔴", $0) }
    .disposed(by: bag)

source.connect() //이러면 Observable 방출 시작
    .disposed(by: bag)//.connect() -> Disposable을 리턴
/**
 🔴는 2부터 출력, 원래는 3초 뒤 0부터 실행됐음
 */
```

## 04-02. publish()
- ```multicast()```를 이용하는 것은 같다.
- ```publishSubject<?>```를 만드는 과정과 ```multicast()```에 subject를 매개변수로 넘겨주는 과정이 합쳐져 있다.
- 근본적으로 ```publishSubject```를 사용하기 때문에 지나간 이벤트를 받을 수 없다.
```swift
let bag = DisposeBag()
let subject = PublishSubject<Int>()
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).take(5)//.multicast(subject)
    .publish() //publishSubject를 생성하고 multicast로 전달하는 동작이 통합됨
    
source
    .subscribe { print("🔵", $0) }
    .disposed(by: bag)

source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("🔴", $0) }
    .disposed(by: bag)

source.connect()
```
## 04-02.relay() / replayAll()
- ```multicast()```를 이용하는 것은 같다.
- ```relaySubject<?>```를 만드는 과정과 ```multicast()```에 subject를 매개변수로 넘겨주는 과정이 합쳐져 있다.
- 근본적으로 ```relaySubject```를 사용하기 때문에 버퍼를 지정해서 지나간 이벤트를 구독자에게 한 번에 플러시 할 수 있다.
- ```replayAll()```은 버퍼 제한이 없지만 메모리 상 문제가 될 수 있다.
```swift
let bag = DisposeBag()
let subject = ReplaySubject<Int>.create(bufferSize: 5) //소실되는 이벤트를 Replay로 저장
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).take(5)//.multicast(subject)
        .replay(5)//혹은 이렇게 replay연산자 혹은 replayAll로 버퍼 지정 없이 사용할 수 있다.

source
        .subscribe { print("🔵", $0) }
        .disposed(by: bag)

source
        .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
        .subscribe { print("🔴", $0) }
        .disposed(by: bag)

source.connect()
//두 번째 구독자는 모든 이벤트를 받을 수 없다.
/**
 만약 두 번째 구독자에게 모두 전달하고 싶다면???
 ReplaySubject로 버퍼링할 수 있다.
 */
```

## 04-03. refCount()
- ```ConnectableObservableType``` 프로토콜에 구현됐으며, ```Observable```을 리턴한다.
- 내부에 ```ConnectableObservable```을 유지하면서 새로운 구독자가 생기면 ```connect()```를 실행한다.
- 구독자가 구독을 종료하고 더 이상 구독자가 존재하지 않으면 시퀀스를 종료한다.
- 종료 이후 구독자가 새로이 붙으면 새롭게 시퀀스를 시작한다.
```swift
let bag = DisposeBag()
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).debug().publish()
    //.replay(4)
    .refCount() //refCountObservable을 리턴 (내부에서 connect)

let observer1 = source
    .subscribe { print("🔵", $0) }

//source.connect() //refCount를 사용하면 필요 없다.

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    observer1.dispose()
}

//DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//    let observer3 = source.subscribe{ print("🟣", $0) }
//    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//        observer3.dispose()
//    }
//}


DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
    let observer2 = source.subscribe { print("🔴", $0) }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        observer2.dispose()
    }
}
```

## 04-04. share(replay:, scope:)
- 매개 변수 ```replay```는 내부적으로 ```publishSubject```를 사용할지 ```relaySubject```를 사용할지를 결정한다.
- 매개변수 ```scope```는 생명 주기를 결절한다. ```.forever```와 ```.whileConnected```가 있다.
- ```.forever```는 구독자가 없어지더라도 버퍼를 유지한다. 즉 구독자가 사라졌다. 새롭게 붙으면 이전에 버퍼 수 만큼 이벤트를 flush 받는다.
- ```.forever```는 버퍼를 공유하기는 하지만 시퀀스를 공유하는 것은 아니다.
- ```.whileConnected```는 구독자가 없어지 버퍼가 사라지고 새롭게 구독자가 붙으면 새롭게 시퀀스를 시작한다.

```swift
let bag = DisposeBag()
let source = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).debug()
//    .share() //publishSubject
//    .share(replay: 5) //replaySubject
    .share(replay: 5, scope: .forever) //모든 구독자가 하나의 subject 공유 --> 이전 버퍼가 남아 있음 시퀀스 공유는 아님

let observer1 = source
    .subscribe { print("🔵", $0) }

let observer2 = source
    .delaySubscription(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe { print("🔴", $0) }

DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    observer1.dispose()
    observer2.dispose()
}

DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
    let observer3 = source.subscribe { print("⚫️", $0) }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        observer3.dispose()
    }
}
```


# 05. Scheduler
- swift는 쓰레드 처리를 위해서 ```GCD(Grand Central Dispatch)```를 사용한다.
- rxSwift는 비슷한 동작을 위해서 ```scheduler```를 사용한다.
- 스케쥴러는 특정 코드가 실행하는 컨텍스트를 추상화한 것에 가깝다.
- 쓰레드와 스케쥴러는 1:1로 매칭되는 것이 아니다. 쓰레드 하나에 스케쥴러가 여러 개가 될 수도, 하나의 스케쥴러가 여러 쓰레드에 걸쳐 있을 수도 있다.
- 스케쥴러는 방식에 따라 ```SerialScheduler``` / ```ConcurrentScheduler```로 나뉜다. 
- ```SerialScheduler```는  (CurrentThreadScheduler / MainScheduler / SerialDispatchQueueScheduler) 가 있다.
- ```ConcurrentScheduler```는 (ConcurrentDispatchQueueScheduler / OperationQueueScheduler )가 있다.
- 이 외에도 ```TestScheduler```/ ```CustomScheduler```가 있다.

> subscribe(on:) : Observable이 실행되는 스케쥴러를 정한다. 위치는 크게 구애받지 않는다.
> 
> observe(on:) : 이 후의 동작이 실행되는 스케쥴러를 지정할 수 있다. 위치 선정이 중요하다. 

```swift
let backgroundScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9) //Observable의 정의
    .subscribe(on:MainScheduler.instance)
    .filter { num -> Bool in
        print(Thread.isMainThread ? "Main Thread" : "Background Thread", ">> filter")
        return num.isMultiple(of: 2)
    }
    .observe(on: backgroundScheduler) //이렇게 하면 이후 체이닝은 다 백그라운드로 동작한다.
    .map { num -> Int in
//        DispatchQueue.global().async {
//            print(Thread.isMainThread ? "Main Thread" : "Background Thread", ">> map")
//            return num * 2
//        }
// 이러면 map을 백그라운드가 아닌 연산을 백그라운드로 실행시킨다.
// RX에서 스케쥴러 지정은 observeOn, subscribeOn으로 한다.
        print(Thread.isMainThread ? "Main Thread" : "Background Thread", ">> map")
        return num * 2
    }
    .observe(on: MainScheduler.instance)
    
//    .subscribe(on:MainScheduler.instance) //이래도 여전히 백그라운드 subscribe의 스케쥴러를 정하는 것이 아니다. Observable 생성 시 어떤 스케쥴러를 사용할 지 정하는 것 + observe(on:)과 달리 호출 시점에 구애받지 않는다.
    .subscribe {//Observable이 생성되는 시점은 구독이 되는 시점이다.
        print(Thread.isMainThread ? "Main Thread" : "Background Thread >> subscribe", $0)
    } .disposed(by: bag)
/**
 Scheduler를 따로 정하지 않았다. -> CurrentScheduler이다.
 */
/**
 subscribe(on:)은 Observable이 시작하는 스케쥴러를
 observe(on:)은 이어지는 연산자가 시작되는 스케쥴러를 정한다.
 */
```

# 06. ErrorHandling
에러 핸들링에는 두 가지 방식이 있다.
- 에러 이벤트가 전달되면 새로운 ```Observable```을 전달한다. (기본 값 혹은 다른 Observable)
- 에러가 발생하면 기존 ```Observable```을 다시 구독해서 재시도 한다.

## 06-01. catch()
- 원 ```Observable```이 ```Error```가 되면 대체할 ```Observable```을 ```catch```의 클로저에서 리턴하게 한다.
- 원 ```Observable```에서 ```error```가 발생하면 더 이상 이벤트를 전달할 수 없으며, ```recovery observable```에서 이벤트를 전달하면 받을 수 있다.

```swift
let bag = DisposeBag()

enum MyError: Error {
    case error
}

let subject = PublishSubject<Int>()
let recovery = PublishSubject<Int>()

subject
    .catch{ _ in recovery}
    .subscribe { print($0) }
    .disposed(by: bag)

subject.onError(MyError.error)
subject.onNext(123)//당연히 더 이상 전달되지 않는다. - catch를 붙이고 -> 에러가 전달되지 않는다.
subject.onNext(44) //더 이상 값을 전달하지 못한다.

recovery.onNext(22) //recovery의 이벤트가 전달된다.
recovery.onCompleted()//recovery의 구독 종료
```
## 06-02. catchAndReturn()
- ```catchAndReturn()```의 파라미터에 기본값을 할당할 수 있다.
- ```error```가 발생하면 기본 값을 방출하고 ```completed```가 된다.

```swift
let bag = DisposeBag()

enum MyError: Error {
    case error
}

let subject = PublishSubject<Int>()

subject
    .catchAndReturn(4)
    .subscribe { print($0) }
    .disposed(by: bag)

subject.onError(MyError.error) //catchAndReturn의 파라미터 값 전달
```

## 06-03. retry()
- 기존 구독에서 에러가 발생하면 기존 구독을 해지하고(```error```) 새롭게 다시 해당 ```Observable```을 구독한다.
- 파라미터를 넘기지 않으면 해당 구독이 성공할 때까지 시도한다.
- 파라미터를 넘기면 숫자 만큼 재시도를 한다. ```(! 초기 시도도 재시도 횟수를 사용한다. == 재시도 횟수 + 1을 파라미터로 넘겨야 한다.)```
- 재시도에 성공하면 종료한다.
- 재시도 간격을 조절할 수 없다.

```swift
let bag = DisposeBag()

enum MyError: Error {
    case error
}

var attempts = 1

let source = Observable<Int>.create { observer in
    let currentAttempts = attempts
    print("#\(currentAttempts) START")
    
    if attempts < 3 {
        observer.onError(MyError.error)
        attempts += 1
    }
    
    observer.onNext(1)
    observer.onNext(2)
    observer.onCompleted()
    
    return Disposables.create {
        print("#\(currentAttempts) END")
    }
}

source
//    .retry() //Observable이 정상적으로 완료될 때까지 재시도
    .retry(2) // 첫 시도도 retry에 포함된다.
    .subscribe { print($0) }
    .disposed(by: bag)

//재시도 횟수 내에 성공하면 종료한다.
//재시도 사이 sleep은 따로 지정할 수 없다.
```

## 06-04 retry(when:)
- ```retry```를 시도하는 시점을 선택할 수 있다.
- 파리미터에 ```trigger```가 되는 ```Observable```을 넘기고 ```trigger```에 이벤트를 방출하면 재시도한다.
- 재시도하는 버튼을 만들고 누르면 재시도하는 로직 등을 구현할 수 있다. 

```swift
let bag = DisposeBag()

enum MyError: Error {
    case error
}

var attempts = 1

let source = Observable<Int>.create { observer in
    let currentAttempts = attempts
    print("START #\(currentAttempts)")
    
    if attempts < 3 {
        observer.onError(MyError.error)
        attempts += 1
    }
    
    observer.onNext(1)
    observer.onNext(2)
    observer.onCompleted()
    
    return Disposables.create {
        print("END #\(currentAttempts)")
    }
}

let trigger = PublishSubject<Void>()

source
    .retry{ _ in trigger}
    .subscribe { print($0) }
    .disposed(by: bag)

//트리거가 next를 방출할 때까지 기다린다.
trigger.onNext(())
trigger.onNext(())
trigger.onNext(())
```
# 07.RxCoCoa
## 07-01. rx
- RxCocoa는 기본적으로 기존의 CocoaTouch를 래핑해 놓은 상태이다.
- ```Reactive``` 클래스를 확장하여  ``` 필요한 CocoaTouchClass를 채용한다.
- 리턴하는 형태는 읽기 전용인(Observer) ```Binder<?>```, 읽기, 쓰기가 가능한 (Observable) ```ControlProperty```, 이벤트를 래핑하고 해당 이벤트 발생 시 next를 전달하는 형태인 ```ControlEvent<Void>```가 있다.
- ```ControlProperty```는 ```Observable```에서 이벤트를 받아서 버퍼가 1개인 ```share()```와 같이 동작한다.
- ```controlEvent```는 버퍼가 없는 ```share()```와 같이 동작한다.
- 주로 이러한 rxCocoa에 접근하려면 ```oulet```에 ```rx```를 통해서 접근한다.
- 


## 07-02. bind()
- ```Observable```을 소모하는 연산자이다.
- 주로 UI를 업데이트할 때 사용한다.
- MainThread에서 동작되는 것을 보장한다.

```swift
class BindingRxCocoaViewController: UIViewController {
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var valueField: UITextField!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueLabel.text = ""
        valueField.becomeFirstResponder()
        
        
        //ControlProperty
        //방법 1 //MainThread에서 UI 업데이트를 보장하기 위해서 DispatchQueue를 사용했다.
        valueField.rx.text
            .subscribe(onNext: { [weak self] str in
                DispatchQueue.main.async { //#1 메인쓰레드 방법 1
                    self?.valueLabel.text = str
                }
            }).disposed(by: disposeBag)
        
        
        //방법2 //observe(on:) 사용을 통해서 subscribe를 MainScehduler에서 동작하도록 한다.
        valueField.rx.text
            .observe(on: MainScheduler.instance) //#2 메인쓰레드 방법 2
            .subscribe(onNext: { [weak self] str in
                self?.valueLabel.text = str
            }).disposed(by: disposeBag)

        //방법3 //bind(to:)
        valueField.rx.text.bind(to: valueLabel.rx.text).disposed(by: disposeBag)
        //이러면 알아서 MainThread에서 바인딩한다. (스케쥴러를 따로 지정하지 않는다면)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        valueField.resignFirstResponder()
    }
}
```
### !주의 -> rxCocoa를 사용하면서 가끔 컴파일러 단에서 타입 추론에 실패하는 경우가 발생한다.
```swift
 let observer = Observable.combineLatest([redSlider.rx.value, greenSlider.rx.value, blueSlider.rx.value])
        .map { UIColor(red: CGFloat($0[0]) / 255, green: CGFloat($0[1]) / 255, blue: CGFloat($0[2]) / 255, alpha: 1.0) }
                .bind(to: colorView.rx.backgroundColor).disposed(by:bag)
```
### 의 경우 해당 현상이 발생했으며, 
```swift
 let observer = Observable.combineLatest([redSlider.rx.value, greenSlider.rx.value, blueSlider.rx.value])
        //The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions
        // 타입 추론이 어렵다는 것이 결론, 따라서 위 아래처럼 쪼개면 된다고 한다. 
        observer.map { UIColor(red: CGFloat($0[0]) / 255, green: CGFloat($0[1]) / 255, blue: CGFloat($0[2]) / 255, alpha: 1.0) }
                .bind(to: colorView.rx.backgroundColor).disposed(by:bag)
```
### 와 같이 나누면 이를 해결할 수 있다.

## 07-03. drive()
- ```bind```와 마찬가지로 ```Observable sequence```를 소비한다. 
- 에러를 전달하지 않는다.
- sideEffect를 ```share```한다. (# ```sideEffect```는 ```Observable``` 밖으로 데이터를 내보내는 행위를 일컫는다.)
- Main Thread에서 사용을 보장한다.
- ```Observable```의 ```sequence```를 ```share```한다. (하나의 ````Observable````에 ```bind(to:)``` 를 3 번하면 3 번 시퀀스가 돌지만 ```driver```을 사용해서 공유하는 방법으로 줄일 수 있다.)
### bind(to:)를 사용한 에러 핸들링 및 mainThread 지정 예
```swift
let result = inputField.rx.text
    .flatMapLatest {
        validateText($0)
            .observe(on: MainScheduler.instance) //background에서 돌 수도 있다.
            .catchAndReturn(false)
    }
    .share()
    .map { $0 ? "Ok" : "Error" }
    .bind(to: resultLabel.rx.text) //driver를 사용하면 dribe로 대체
    .disposed(by: bag)
```
### driver의 onErrorJustReturn으로 에러 처리 및 mainThread 기본 사용을 이용한 코드
```swift

let result = inputField.rx.text.asDriver()
        .flatMapLatest{
            validateText($0)
                    .asDriver(onErrorJustReturn: false) //driver로 변환
        }
        .map { $0 ? UIColor.blue : UIColor.red }
        .drive(resultLabel.rx.backgroundColor)
        .disposed(by: bag)
```

## 07-04. CustomBinder
- ```Reactive```를 확장하고 원하는 UI 프로토콜을 채용한다.
- 사용할 변수를 할당한다. 리턴 타입은  ```Binder<?>```가 된다. (받을 타입을 제네릭으로 설정하면 된다.)
- ```Binder``` 구조체를 반환한다. 생성자는 ```Binder(<#T##target: Target##Target#>, binding: <#T##(Target, Value) -> Void#>)```이다.
- 주로 첫 번째 파라미터는 ```base.self```를  두 번째 파라미터 파인딩 타겟과 ```Observable```에서 받을 ```value```를 가진 클로저를 선언한다.
```swift
//ex)
extension Reactive where Base: UILabel {
    var segmentedValue: Binder<Int> {
        return Binder(self.base) { label, index in
            switch (index){
                case 0:
                    label.text = "Red"
                    label.textColor = UIColor.red
                case 1:
                    label.text = "Green"
                    label.textColor = UIColor.green
                case 2:
                    label.text = "Blue"
                    label.textColor = UIColor.blue
                default:
                    label.text = "Unknown"
                    label.textColor = UIColor.black
            }
            
        }
    }
}


//usage)
colorPicker.rx.selectedSegmentIndex.bind(to: valueLabel.rx.segmentedValue).disposed(by: bag)
```

## 07-05. CustomControlProperty
- ```Reactive```를 확장하고 원하는 UI 프로토콜을 채용한다.
- 사용할 변수를 할당한다. 리턴 타입은  ```ControlProperty<T?> ```가 된다. (리턴할 타입에 옵셔널을 붙인다.)
- ```base.rx.controlProperty``` 메소드를 리턴한다.
- ```(editingEvents: UIControl.Event, getter: @escaping (Base) -> T, setter: @escaping (Base, T) -> Void)``` 가 해당 메소드의 파라미터이다. 이벤트 타입, getter, setter를 리턴한다.
  
```swift
//예시
extension Reactive where Base: UISlider {
    var color: ControlProperty<UIColor?> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: { (slider) in
            UIColor(white: CGFloat(slider.value), alpha: 1.0)
        }, setter: { slider, color in
            var white = CGFloat(1)
            color?.getWhite(&white, alpha: nil)
            slider.value = Float(white)
        })
    }
}

//사용 예
whiteSlider.rx.color.bind(to: view.rx.backgroundColor).disposed(by: bag)

//추가로 bind(to:)에 두 개이상의 옵저버를 전달할 수도 있다.
resetButton.rx.tap
        .map { _ in UIColor(white:0.5, alpha: 1.0) }
        .bind(to: whiteSlider.rx.color.asObserver(), view.rx.backgroundColor.asObserver()) //2개 이상 옵저버를 전달할 수 있다.
        .disposed(by: bag)
```

## 07-06. CustomControlEvent
- ```Reactive```를 확장하고 원하는 UI 프로토콜을 채용한다.
- ```ControlEvent<Void>``` 타입의 ```getter```를 선언하고  ```ControlEvent<()>```를 리턴하는 ```controlEvent(_ controlEvents: UIControl.Event) ```을 리턴한다.
- 파라미터는 반응할 이벤트이다.

### Reactive에 커스텀 이벤트 선언
```swift
extension Reactive where Base: UITextField {
    var editingChanged: ControlEvent<Void> {
        return controlEvent(.editingChanged)
    }
}
```
### 커스텀 이벤트 사용
```swift
 inputField.rx.editingChanged
            .map{ [weak self] in
                self?.inputField.text?.count
            }.bind(to: countLabel.rx.textCount)
            .disposed(by: bag)
        
```
## 07-07. DelegateProxy


