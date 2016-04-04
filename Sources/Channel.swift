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

public class Channel {
    public typealias CleanUp = ErrorType? -> Void
    public typealias Completion = (done: Bool, data: DispatchData?, error: ErrorType?) -> Void

    let channel: dispatch_io_t

    init(channel: dispatch_io_t) {
        self.channel = channel
    }
    
    private func mapCompletion(completion: Completion) -> (done: Bool, data: dispatch_data_t!, errorNumber: Int32) -> Void {
        return { done, dispatchData, errorNumber in
            let data: DispatchData?
            let error: ErrorType?

            if dispatchData == nil {
                data = nil
            } else {
                data = DispatchData(dispatchData: dispatchData)
            }

            if errorNumber == 0 {
                error = nil
            } else {
                error = Error.fromErrorNumber(errorNumber)
            }

            completion(done: done, data: data, error: error)
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

    public func barrier(closure: Void -> Void) {
        dispatch_io_barrier(channel, closure)
    }

    public func close(stop: Bool = false) {
        dispatch_io_close(channel, stop ? DISPATCH_IO_STOP : 0)
    }
}

public final class StreamChanell: Channel {
    public init(fileDescriptor: FileDescriptor, queue: Queue = defaultQueue, cleanUp: CleanUp? = nil) {
        let channel = dispatch_io_create(DISPATCH_IO_STREAM, fileDescriptor, queue.queue) { errorNumber in
            if errorNumber == 0 {
                cleanUp?(nil)
            } else {
                cleanUp?(Error.fromErrorNumber(errorNumber))
            }
        }!
        super.init(channel: channel)
    }

    public func read(length length: Int = Int.max, queue: Queue = defaultQueue, completion: Completion) {
        let mappedHandler = mapCompletion(completion)
        dispatch_io_read(channel, 0, length, queue.queue, mappedHandler)
    }

    public func write(queue queue: Queue = defaultQueue, data: DispatchData, completion: Completion) {
        let mappedHandler = mapCompletion(completion)
        dispatch_io_write(channel, 0, data.dispatchData, queue.queue, mappedHandler)
    }
}

public final class RandomAccessChanell: Channel {
    public init(fileDescriptor: FileDescriptor, queue: Queue = defaultQueue, cleanUp: CleanUp? = nil) {
        let channel = dispatch_io_create(DISPATCH_IO_RANDOM, fileDescriptor, queue.queue) { errorNumber in
            if errorNumber == 0 {
                cleanUp?(nil)
            } else {
                cleanUp?(Error.fromErrorNumber(errorNumber))
            }
            }!
        super.init(channel: channel)
    }

    public func read(offset offset: Offset = 0, length: Int = Int.max, queue: Queue = defaultQueue, completion: Completion) {
        let mappedHandler = mapCompletion(completion)
        dispatch_io_read(channel, offset, length, queue.queue, mappedHandler)
    }

    public func write(offset offset: Offset = 0, queue: Queue = defaultQueue, data: DispatchData, completion: Completion) {
        let mappedHandler = mapCompletion(completion)
        dispatch_io_write(channel, offset, data.dispatchData, queue.queue, mappedHandler)
    }
}
