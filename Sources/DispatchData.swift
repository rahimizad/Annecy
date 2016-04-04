// DispatchData.swift
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

public final class DispatchData: DataConvertible {
    var dispatchData: dispatch_data_t

    init(dispatchData: dispatch_data_t) {
        self.dispatchData = dispatchData
    }

    public init() {
        self.dispatchData = dispatch_data_empty
    }

    public init(data: Data) {
        self.dispatchData = dispatch_data_create(data.bytes, data.bytes.count, backgroundQueue.queue, nil)
    }

    public var data: Data {
        var buffer: UnsafePointer<Void> = nil
        var length: Int = 0
        let _ = dispatch_data_create_map(dispatchData, &buffer, &length)
        var dataBuffer = C7.Data([Byte](count: length, repeatedValue: 0))
        memcpy(&dataBuffer.bytes, buffer, length)
        return dataBuffer
    }

    public typealias Applier = (region: DispatchData, offset: Int, buffer: UnsafePointer<Void>, size: Int) -> Bool

    public func apply(closure: Applier) {
        dispatch_data_apply(dispatchData) { (region, offset, buffer, size) -> Bool in
            closure(region: DispatchData(dispatchData: region), offset: offset, buffer: buffer, size: size)
        }
    }
}

func +=(inout lhs: DispatchData, rhs: DispatchData) {
    lhs.dispatchData = dispatch_data_create_concat(lhs.dispatchData, rhs.dispatchData)
}

func +(lhs: DispatchData, rhs: DispatchData) -> DispatchData {
    return DispatchData(dispatchData: dispatch_data_create_concat(lhs.dispatchData, rhs.dispatchData))
}


