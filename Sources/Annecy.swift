@_exported import C7
import Dispatch

public typealias FileDescriptor = Int32
public typealias Offset = Int64
public typealias Priority = Int32
public typealias Duration = UInt64

public let forever = DISPATCH_TIME_FOREVER

public let nanosecond = 1
public let nanoseconds = nanosecond

public let microsecond = NSEC_PER_USEC
public let microseconds = microsecond

public let millisecond = NSEC_PER_MSEC
public let milliseconds = millisecond

public let second = NSEC_PER_SEC
public let seconds = second