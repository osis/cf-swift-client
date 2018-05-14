import Foundation
import SwiftWebSocket
import ProtocolBuffers

public protocol CFLogger: NSObjectProtocol {
    func logsMessage(_ text: NSMutableAttributedString)
    func recentLogsFetched()
}

open class CFLogs: NSObject {
    public var appGuid: String
    var ws: WebSocket?
    public var delegate: CFLogger?
    
    public init(appGuid: String) {
        self.appGuid = appGuid
        super.init()
    }
    
    open func recent() {
        logMessage(LogMessageString.out("Fetching Recent Logs..."))
        CFApi.recentLogs(appGuid: self.appGuid) { (response: HTTPURLResponse?, data: Data?, error: Error?) in
           self.handleRecent(response, data: data, error: error)
        }
    }
    
    open func connect() {
        logMessage(LogMessageString.out("Connecting..."))
        tail()
    }
    
    open func reconnect() {
        logMessage(LogMessageString.out("Reconnecting..."))
        tail()
    }
    
    open func disconnect() {
        self.ws?.close()
    }
    
    open func tail() {
        do {
            let ws = try createSocket()
            
            ws.event.open = opened
            ws.event.close = closed
            ws.event.error = error
            ws.event.message = message
        } catch {
            print("--- Logs Connection Failed")
            logMessage(LogMessageString.out("Logs connection failed. Please try again"))
        }
    }
    
    func opened() {
        logMessage(LogMessageString.out("Connected"))
    }
    
    func closed(_ code: Int, reason: String, wasClean: Bool) {
        print("--- Logs Disconnected")
        logMessage(LogMessageString.out("Disconnected"))
    }
    
    func error(_ error: Error) {
        let errorString = String(describing: error)
        print("--- Logs \(errorString)")
        
        if (errorString.range(of: "401") != nil) {
            authRetry()
        } else {
            DispatchQueue.main.async(execute: {
                self.logMessage(LogMessageString.err(errorString))
            })
        }
    }
    
    func authRetry() {
        CFApi.performAuthRefreshRequest {
            self.tail()
        }
    }
    
    func message(_ bytes: Any) {
        let data = bytes as! Data
        var text: NSMutableAttributedString?
        
        do {
            let env = try Events.Envelope.parseFrom(data: data)
            
            if let logm = env.logMessage, logm.hasMessage {
                let message = String(data: logm.message, encoding: String.Encoding.ascii)!
                text = LogMessageString.message(logm.sourceType, sourceID: logm.sourceInstance, message: message, type: logm.messageType)
            }
        } catch {
            print("Message parsing failed")
            text = NSMutableAttributedString(string: String(data: data, encoding: String.Encoding.ascii)!)
        }
        
        if let msg = text {
            logMessage(msg)
        }
    }
    
    func createSocket() throws -> WebSocket {
        let request = try createSocketRequest()
        
        self.ws = WebSocket(request: request as URLRequest)
        self.ws!.binaryType = WebSocketBinaryType.nsData
        return self.ws!
    }
    
    func createSocketRequest() throws -> NSMutableURLRequest {
        let info = CFApi.session!.info
        let endpoint = info.dopplerLoggingEndpoint
        let url = URL(string: "\(endpoint)/apps/\(self.appGuid)/stream")
        let request = NSMutableURLRequest(url: url!)

        if let token = CFApi.session?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}

private extension CFLogs {
    func logMessage(_ message: NSMutableAttributedString) {
        self.delegate?.logsMessage(message)
    }
    
    func handleRecent(_ response: HTTPURLResponse?, data: Data?, error: Error?) {
        if let e = error {
            self.error(e)
            return
        }
        
        processResponseData(response, data: data)
    }
    
    func processResponseData(_ response: HTTPURLResponse?, data: Data?) {
        if let contentType = response?.allHeaderFields["Content-Type"] as! String? {
            let boundary = contentType.components(separatedBy: "boundary=").last!
            let chunks = self.chunkMessage(data!, boundary: boundary)
            
            for log in chunks {
                do {
                    let envelope = try Events.Envelope.parseFrom(data: log)
                    self.message(envelope.data())
                } catch {
                    print(error)
                }
            }
            delegate?.recentLogsFetched()
        }
    }
    
    func chunkMessage(_ data: Data, boundary: String) -> ArraySlice<Data> {
        let sepdata = String("--\(boundary)").data(using: String.Encoding.ascii, allowLossyConversion: false)!
        var chunks : [Data] = []
        
        // Find first occurrence of separator:
        var searchRange = NSMakeRange(0, data.count)
        var foundRange = data.range(of: sepdata, options: NSData.SearchOptions(), in: searchRange.toRange())

        while foundRange != nil {
            // Append chunk without \r\n\r\n & \r\n (if not empty):
            if foundRange!.lowerBound - 6 > searchRange.location + 4 {
                let newRange = NSMakeRange(searchRange.location+4, foundRange!.lowerBound-6 - searchRange.location)
                chunks.append(data.subdata(in: newRange.toRange()!))
            }
            // Search next occurrence of separator:
            searchRange.location = foundRange!.lowerBound + foundRange!.count
            searchRange.length = data.count - searchRange.location
            foundRange = data.range(of: sepdata, options: NSData.SearchOptions(), in: searchRange.toRange())
        }
        // Check for final chunk:
        if searchRange.length > 0 {
            chunks.append(data.subdata(in: searchRange.toRange()!))
        }
        return chunks.dropLast().suffix(100)
    }
}
