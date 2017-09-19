import XCTest
@testable import Tsim

class TsimTests: XCTestCase {

    public enum Cases: CustomStringConvertible, Equatable {
        
        public static func ==(lhs: Cases, rhs: Cases) -> Bool {
            return lhs.description == rhs.description
        }

        public var description: String {
            switch self {
            case .post(let s): return "POST(\(s))"
            case .get(let s): return "GET(\(s))"
            case .patch(let s): return "PATCH(\(s))"
            case .delete(let s): return "DELETE(\(s))"
            }
        }
        
        case post(String)
        case get(String)
        case patch(String)
        case delete(String)
    }

    public class Master: Actor<Cases> {
        
        public var message: Cases? = nil
        public var sender: Actor<Cases>? = nil
        
        func setData(sender: Actor<Cases>?, message: Cases) {
            self.sender = sender
            self.message = message
        }
        
        override public func receive(sender: Actor<Cases>?, message: Cases) {
            setData(sender: sender, message: message)
        }
    }

    public class Worker: Actor<Cases> {
        
        public var message: Cases? = nil
        public var sender: Actor<Cases>? = nil
        
        func setData(sender: Actor<Cases>?, message: Cases) {
            self.sender = sender
            self.message = message
        }
    
        override public func receive(sender: Actor<Cases>?, message: Cases) {
            guard let s = sender else {
                return
            }
            
            setData(sender: sender, message: message)

            switch message {
            case .post(_)           : break
            case .get(let str)      : tell(actor: s, message: .get("[ECHO] " + str))
            case .patch(let str)    : tell(actor: s, message: .patch("[ECHO] " + str))
            case .delete(let str)   : tell(actor: s, message: .delete("[ECHO] - " + str))
            }
        }
    }

    func testAsk() {
        let system = System<Cases>()
        let master = system.createActor(of: Master.self)
        let worker1 = system.createActor(of: Worker.self)
    
        let response = master.ask(actor: worker1, message: .get("Hello?"))
        XCTAssertNotNil(response)
        XCTAssertEqual(response!.description, "GET([ECHO] Hello?)")
    }
    
    func testTell() {
        let system = System<Cases>()
        let master = system.createActor(of: Master.self)
        let worker1 = system.createActor(of: Worker.self)
        
        master.tell(actor: worker1, message: .post("hello"))
        
        sleep(1)

        guard let w = worker1 as? Worker else {
            XCTFail()
            return
        }
        XCTAssertNotNil(w.message)
        XCTAssertNotNil(w.sender)
        XCTAssertEqual(w.message!, Cases.post("hello"))
        XCTAssertEqual(w.sender!, master)
    }

    static var allTests = [
        ("testAsk", testAsk),
        ("testTell", testTell)
    ]
}
