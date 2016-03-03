/*
 * JLToastCenter.swift
 *
 *            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *                    Version 2, December 2004
 *
 * Copyright (C) 2013-2015 Su Yeol Jeon
 *
 * Everyone is permitted to copy and distribute verbatim or modified
 * copies of this license document, and changing it is allowed as long
 * as the name is changed.
 *
 *            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 *
 *  0. You just DO WHAT THE FUCK YOU WANT TO.
 *
 */

import UIKit

let MAX_CONCURRENT_TOASTS: Int = 10

protocol JLToastDelegate: class {
    func getTotalCount() -> Int
}

@objc public class JLToastCenter: NSObject, JLToastDelegate {

    private var _queue: NSOperationQueue!

    private struct Singletone {
        static let defaultCenter = JLToastCenter()
    }
    
    public class func defaultCenter() -> JLToastCenter {
        return Singletone.defaultCenter
    }
    
    override init() {
        super.init()
        self._queue = NSOperationQueue()
        self._queue.maxConcurrentOperationCount = MAX_CONCURRENT_TOASTS
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "deviceOrientationDidChange:",
            name: UIDeviceOrientationDidChangeNotification,
            object: nil
        )
    }

    // MARK: - Delegate

    public func getTotalCount() -> Int {
        return self._queue.operationCount
    }

    // MARK: -

    public func addToast(toast: JLToast) {
        toast.view.delegate = self
        if self._queue.operationCount == 0 {
            JLToast.topY = nil
        }
        self._queue.addOperation(toast)
    }
    
    func deviceOrientationDidChange(sender: AnyObject?) {
        if self._queue.operations.count > 0 && self._queue.operations.count <= self._queue.maxConcurrentOperationCount {
			for toast in self._queue.operations {
				let thisToast: JLToast = toast as! JLToast
				thisToast.view.updateView()
			}
		} else if self._queue.operations.count > self._queue.maxConcurrentOperationCount {
			for index in 0..<self._queue.maxConcurrentOperationCount {
				let thisToast: JLToast = self._queue.operations[index] as! JLToast
				thisToast.view.updateView()
			}
		}
    }
}
