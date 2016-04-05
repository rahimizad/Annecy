@_exported import C7
import Dispatch

public typealias FileDescriptor = Int32
public typealias Offset = Int64
public typealias Priority = Int32
public typealias Duration = UInt64

extension Duration {
    public static var forever: Duration {
        return DISPATCH_TIME_FOREVER
    }
}

public protocol DurationConvertible {
    var nanosecond: Duration { get }
    var microsecond: Duration { get }
    var millisecond: Duration { get }
    var second: Duration { get }
}

extension DurationConvertible {
    public var microsecond: Duration {
        return nanosecond * NSEC_PER_USEC
    }
    public var millisecond: Duration {
        return nanosecond * NSEC_PER_MSEC
    }
    public var second: Duration {
        return nanosecond * NSEC_PER_SEC
    }
}

extension DurationConvertible {
    public var nanoseconds: Duration {
        return nanosecond
    }
    public var microseconds: Duration {
        return microsecond
    }
    public var milliseconds: Duration {
        return millisecond
    }
    public var seconds: Duration {
        return second
    }
}

extension Int: DurationConvertible {
    public var nanosecond: Duration {
        return UInt64(self)
    }
}
