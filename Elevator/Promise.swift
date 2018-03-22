import Foundation

public class Promise {
    public typealias Callback = () -> Void
    
    private var successCallbacks: [Callback] = []
    private var errorCallback: Callback?
    private var errored = false
    
    @discardableResult
    public func then(_ callback: @escaping Callback) -> Promise {
        successCallbacks.append(callback)
        return self
    }
    
    public func onError(_ callback: @escaping Callback) {
        self.errorCallback = callback
    }
    
    internal enum Outcome {
        case success, error
    }
    
    internal func resolve(with outcome: Outcome) {
        switch outcome {
        case .success:
            for action in successCallbacks {
                if !errored { action() }
            }
        case .error:
            errored = true
            errorCallback?()
        }
    }
}
