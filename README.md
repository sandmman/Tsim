# Tsim

> A simple port of the Scala Akka model in Swift

### Usage

```swift

public enum Method {
    case post(String)
    case get(String)
}

public class Master: Actor<Methods> {
    
    override public func receive(sender: Actor<Method>?, message: Cases) {
        print("Master: \(message)")
    }
}

public class Worker: Actor<Method> {
    
    override public func receive(sender: Actor<Method>?, message: Cases) {
        switch message {
        case .post(_)           : break
        case .get(let str)      : tell(actor: sender!, message: .get("[ECHO] " + str))
        }
    }
}

let system = System<Method>()
let master = system.create(constructor: Master.self)
let worker = system.create(constructor: Worker.self)

// .get([ECHO] Hello?)
let response = master.ask(actor: worker, message: .get("Hello?"))
```
