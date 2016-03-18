// Source.swift
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

public struct Source {
    public typealias Handle = UInt
    public typealias Mask = UInt
    public typealias Data = UInt

    public enum Mode {
        case DataAdd
        case DataOr
        case MachReceive
        case MachSend
        case MemoryPressure
        case Process
        case Read
        case Signal
        case Timer
        case VNode
        case Write

        var value: dispatch_source_type_t {
            switch self {
            case DataAdd:        return DISPATCH_SOURCE_TYPE_DATA_ADD
            case DataOr:         return DISPATCH_SOURCE_TYPE_DATA_OR
            case MachReceive:    return DISPATCH_SOURCE_TYPE_MACH_RECV
            case MachSend:       return DISPATCH_SOURCE_TYPE_MACH_SEND
            case MemoryPressure: return DISPATCH_SOURCE_TYPE_MEMORYPRESSURE
            case Process:        return DISPATCH_SOURCE_TYPE_PROC
            case Read:           return DISPATCH_SOURCE_TYPE_READ
            case Signal:         return DISPATCH_SOURCE_TYPE_SIGNAL
            case Timer:          return DISPATCH_SOURCE_TYPE_TIMER
            case VNode:          return DISPATCH_SOURCE_TYPE_VNODE
            case Write:          return DISPATCH_SOURCE_TYPE_WRITE
            }
        }
    }


    let source: dispatch_source_t

    public init(mode: Mode, handle: Handle, queue: Queue = defaultQueue) {
        source = dispatch_source_create(mode.value, handle, 0, queue.queue)
    }

    public func onEvent(closure: Void -> Void) {
        dispatch_source_set_event_handler(source, closure)
    }

    public func onCancel(closure: Void -> Void) {
        dispatch_source_set_cancel_handler(source, closure)
    }

    public func cancel() {
        dispatch_source_cancel(source)
    }

    public var canceled: Bool {
        return dispatch_source_testcancel(source) != 0
    }

    public func resume() {
        dispatch_resume(source)
    }

    public var handle: Handle {
        return dispatch_source_get_handle(source)
    }

    public var mask: Mask {
        return dispatch_source_get_mask(source)
    }

    public var data: Data {
        return dispatch_source_get_data(source)
    }

    public func merge(data: Data) {
        dispatch_source_merge_data(source, data)
    }
}
