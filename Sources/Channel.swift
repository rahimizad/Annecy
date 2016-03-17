// Channel.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Dispatch

public struct Channel {
    public enum Mode {
        case Stream
        case RandomAccess

        private var value: dispatch_io_type_t {
            switch self {
            case .Stream: return DISPATCH_IO_STREAM
            case .RandomAccess: return DISPATCH_IO_RANDOM
            }
        }
    }

    public enum CleanUpResult {
        case Success
        case Failure(error: ErrorType)

        public func success(f: Void -> Void) {
            switch self {
            case Success: f()
            default: break
            }
        }

        public func failure(f: ErrorType -> Void) {
            switch self {
            case Failure(let e): f(e)
            default: break
            }
        }
    }

    public typealias CleanUp = CleanUpResult -> Void

    public enum Result {
        case Success(done: Bool, data: Data)
        case Canceled(data: Data)
        case Failure(error: ErrorType)

        public func success(f: (done: Bool, data: Data) -> Void) {
            switch self {
            case Success(let done, let data): f(done: done, data: data)
            default: break
            }
        }

        public func failure(f: ErrorType -> Void) {
            switch self {
            case Failure(let e): f(e)
            default: break
            }
        }

        public func canceled(f: (data: Data) -> Void) {
            switch self {
            case Canceled(let data): f(data: data)
            default: break
            }
        }
    }

    public typealias Completion = Result -> Void

    let channel: dispatch_io_t

    public init(mode: Mode, fileDescriptor: FileDescriptor, queue: Queue = defaultQueue, cleanUp: CleanUp) {
        channel = dispatch_io_create(mode.value, fileDescriptor, queue.queue) { errorNumber in
            if errorNumber == 0 {
                cleanUp(.Success)
            } else {
                let error = Error.fromErrorNumber(errorNumber)
                cleanUp(.Failure(error: error))
            }
        }!
    }

    public func read(offset: Offset = 0, length: Int = Int.max, queue: Queue = defaultQueue, completion: Completion) {
        let mappedHandler = mapCompletion(completion)
        dispatch_io_read(channel, offset, length, queue.queue, mappedHandler)
    }

    public func write(offset: Offset = 0, length: Int = Int.max, queue: Queue = defaultQueue, data: Data, completion: Completion) {
        let data = dispatch_data_create(data.bytes, data.bytes.count, queue.queue, nil)
        let mappedHandler = mapCompletion(completion)
        dispatch_io_write(channel, offset, data, queue.queue, mappedHandler)
    }

    private func mapCompletion(completion: Completion) -> (done: Bool, data: dispatch_data_t!, errorNumber: Int32) -> Void {
        return { done, data, errorNumber in
            if errorNumber == ECANCELED {
                completion(.Canceled(data: bufferFromData(data)))
            } else if errorNumber != 0 {
                let error = Error.fromErrorNumber(errorNumber)
                completion(.Failure(error: error))
            } else {
                completion(.Success(done: done, data: bufferFromData(data)))
            }
        }
    }

    public func setLowWater(lowWater: Int) {
        dispatch_io_set_low_water(channel, lowWater)
    }

    public func setHighWater(highWater: Int) {
        dispatch_io_set_high_water(channel, highWater)
    }

    public var fileDescriptor: FileDescriptor {
        return dispatch_io_get_descriptor(channel)
    }

    public func close() {
        dispatch_io_close(channel, DISPATCH_IO_STOP)
    }
}
