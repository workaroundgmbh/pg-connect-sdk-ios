//
//  AppLogger.swift
//  ConnectSDK Example
//
//  Copyright © 2019 Workaround GmbH. All rights reserved.
//

import ConnectSDK
import os.log
import UIKit

extension OSLog {
    static let appSubsystem = Bundle.main.bundleIdentifier!
}

let logger = AppLogger()

class AppLogger: NSObject, PGLoggingDelegate {
    let log = OSLog(subsystem: OSLog.appSubsystem, category: "ConnectSDK")
    private let logDirectory = "Logs"
    private let logFile = "logs"
    private let logFileExtention = ".txt"
    private var currentTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ssZ"
        return dateFormatter.string(from: Date())
    }
    
    // Log file will be stored inside this directory
    var logDirectoryPath: URL? {
        guard let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        let directory = NSURL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(logDirectory)
        return directory
    }
    // Log file url
    var logFileUrl: URL? {
        guard let logDirectoryPath = logDirectoryPath else {
            return nil
        }
        let logFilePath = logDirectoryPath.appendingPathComponent("\(logFile)\(logFileExtention)")
        return logFilePath
    }
    
    // called in App delegate
    class func register() {
        PGLogging.delegate = logger
    }
    
    // MARK: - PGLoggingDelegate methods
    
    func pgLog(_ asynchronous: Bool, flag: PGLogFlag, context: Int, file: String, function: String, line: UInt, tag: Any?, message: String) {
        //Save received logs to file
        let logString = "\(currentTime) \(function) line: \(line): \(message)"
        writeLogToFile(logText: "\(logString)\n\n")
        
        //Print received logs
        switch flag {
        case .warning: os_log(.error, log: log, "%{public}@", message)
        case .error: os_log(.fault, log: log, "%{public}@", message)
        case .info: os_log(.info, log: log, "%{public}@", message)
        case .debug: os_log(.debug, log: log, "%{public}@", message)
        case .verbose: os_log(.debug, log: log, "%{public}@", message)
        default: os_log(.debug, log: log, "%{public}@", message)
        }
    }
    
    // MARK: - Convenience methods for saving logs to a file and receiving logs from the file.
    
    /// Convenience method used to write text at the end of a file.
    /// - Parameter logText: text to log
    func writeLogToFile(logText: String) {
        guard let logDirectoryPath = logDirectoryPath, let logFilePath = logFileUrl, let logData = logText.data(using: .utf8) else {
            return
        }
                
        do {
            // If log file does not exist, one will be created and logs added.
            if !FileManager.default.fileExists(atPath: logDirectoryPath.path) {
                try FileManager.default.createDirectory(atPath: logDirectoryPath.path, withIntermediateDirectories: true)
                try logData.write(to: logFilePath, options: .atomicWrite)
                return
            }
            
            // If log file does exist, log text will be added at the end of it.
            let fileHandle = try FileHandle(forWritingTo: logFilePath)
            fileHandle.seekToEndOfFile()
            fileHandle.write(logData)
            fileHandle.closeFile()
        } catch {
            os_log(.error, log: log, "%{public}@", error.localizedDescription)
        }
    }
    
    /// Convenience method used to fetch all the logs from the log file.
    /// - Returns: logs in String format
    func fetchLogs() -> String? {
        guard let logFileUrl = logFileUrl else {
            return nil
        }
        return try? String(contentsOf: logFileUrl, encoding: .utf8)
    }
    
    /// Convenience method used to delete text from the log file.
    func deleteLogs() {
        do {
            guard let logFileUrl = logFileUrl else {
                return
            }
            let data = "".data(using: .utf8)
            try data?.write(to: logFileUrl, options: .atomicWrite)
        } catch {
            os_log(.error, log: log, "%{public}@", error.localizedDescription)
        }
    }
}
