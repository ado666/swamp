//
//  WebSocketTransport.swift
//  swamp
//
//  Created by Yossi Abraham on 18/08/2016.
//  Copyright © 2016 Yossi Abraham. All rights reserved.
//

import Foundation
import Starscream

open class WebSocketSwampTransport: SwampTransport, WebSocketDelegate {
    
    public enum WampProtocol : String {
        case json = "wamp.2.json"
        case jsonBatched = "wamp.2.json.batched"
        #if MSGPACK_SUPPORT
        case msgpack = "wamp.2.msgpack"
        case msgpackBatched = "wamp.2.msgpack.batched"
        #endif
    }

    public enum WebsocketMode {
        case binary, text
    }

    open var delegate: SwampTransportDelegate?
    let socket: WebSocket
    let mode: WebsocketMode
    let serializer : SwampSerializer
    
    fileprivate var disconnectionReason: String?
    
    public init(wsEndpoint: URL, proto: WampProtocol, customSerializer: SwampSerializer? = nil) {
        
        socket = WebSocket(url: wsEndpoint, protocols: [proto.rawValue])
        
        let guessedSerializer: SwampSerializer!

        #if MSGPACK_SUPPORT
            switch (proto) {
            case .json, .jsonBatched:
                self.mode = .text
                guessedSerializer = JSONSwampSerializer()
            case .msgpack, .msgpackBatched:
                self.mode = .binary
                guessedSerializer = MsgpackSwampSerializer()
            }
        #else
            self.mode = .text
            guessedSerializer = JSONSwampSerializer()
        #endif
        
        if let customSerializer = customSerializer {
            self.serializer = customSerializer
        } else {
            self.serializer = guessedSerializer
        }
        socket.delegate = self

        // turn off system certificate validation so we can use our own self-signed certs
        socket.disableSSLCertValidation = true

        // set the ciphers we will allow (a required
        socket.enabledSSLCipherSuites = [TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256]
    }

    convenience public init(wsEndpoint: URL) {
        self.init(wsEndpoint: wsEndpoint, proto: .json)
    }
    
    // MARK: Transport
    open func connect() {
        self.socket.connect()
    }
    
    open func setConnectHeaders(headers: [String : String]) {
        self.socket.headers = headers
    }
    
    open func setCallbackQueue(_ queue: DispatchQueue) {
        self.socket.callbackQueue = queue
    }
    
    open func setCertificates(_ certificates: [Data]) {
        let sslCerts = certificates.flatMap { SSLCert(data: $0) }
        self.socket.security = SSLSecurity(certs: sslCerts, usePublicKeys: false)
        if let ssl = self.socket.security {
            print("ssl = \(ssl)")
        } else {
            print("no security")
        }
    }

    open func disconnect(_ reason: String) {
        self.disconnectionReason = reason
        self.socket.disconnect()
    }
    
    open func sendData(_ data: Data) {
        if self.mode == .text {
            self.socket.write(string: String(data: data, encoding: String.Encoding.utf8)!)
        } else {
            self.socket.write(data: data)
        }
    }
    
    // MARK: WebSocketDelegate
    
    open func websocketDidConnect(socket: WebSocket) {

        // TODO: Check which serializer is supported by the server, and choose self.mode and serializer
        delegate?.swampTransportDidConnectWithSerializer(serializer)
    }
    
    open func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        delegate?.swampTransportDidDisconnect(error, reason: self.disconnectionReason)
    }
    
    open func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        if let data = text.data(using: String.Encoding.utf8) {
            self.websocketDidReceiveData(socket: socket, data: data)
        }
    }
    
    open func websocketDidReceiveData(socket: WebSocket, data: Data) {
        delegate?.swampTransportReceivedData(data)
    }
}
