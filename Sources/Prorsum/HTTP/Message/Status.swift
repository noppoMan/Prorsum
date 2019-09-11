//The MIT License (MIT)
//
//Copyright (c) 2015 Zewo
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

extension Response.Status {
    public init(statusCode: Int, reasonPhrase: String? = nil) {
        if let reasonPhrase = reasonPhrase {
            self = .other(statusCode: statusCode, reasonPhrase: reasonPhrase)
        } else {
            switch statusCode {
            case Response.Status.`continue`.statusCode:                    self = .`continue`
            case Response.Status.switchingProtocols.statusCode:            self = .switchingProtocols
            case Response.Status.processing.statusCode:                    self = .processing
                
            case Response.Status.ok.statusCode:                            self = .ok
            case Response.Status.created.statusCode:                       self = .created
            case Response.Status.accepted.statusCode:                      self = .accepted
            case Response.Status.nonAuthoritativeInformation.statusCode:   self = .nonAuthoritativeInformation
            case Response.Status.noContent.statusCode:                     self = .noContent
            case Response.Status.resetContent.statusCode:                  self = .resetContent
            case Response.Status.partialContent.statusCode:                self = .partialContent
                
            case Response.Status.multipleChoices.statusCode:               self = .multipleChoices
            case Response.Status.movedPermanently.statusCode:              self = .movedPermanently
            case Response.Status.found.statusCode:                         self = .found
            case Response.Status.seeOther.statusCode:                      self = .seeOther
            case Response.Status.notModified.statusCode:                   self = .notModified
            case Response.Status.useProxy.statusCode:                      self = .useProxy
            case Response.Status.switchProxy.statusCode:                   self = .switchProxy
            case Response.Status.temporaryRedirect.statusCode:             self = .temporaryRedirect
            case Response.Status.permanentRedirect.statusCode:             self = .permanentRedirect
                
            case Response.Status.badRequest.statusCode:                    self = .badRequest
            case Response.Status.unauthorized.statusCode:                  self = .unauthorized
            case Response.Status.paymentRequired.statusCode:               self = .paymentRequired
            case Response.Status.forbidden.statusCode:                     self = .forbidden
            case Response.Status.notFound.statusCode:                      self = .notFound
            case Response.Status.methodNotAllowed.statusCode:              self = .methodNotAllowed
            case Response.Status.notAcceptable.statusCode:                 self = .notAcceptable
            case Response.Status.proxyAuthenticationRequired.statusCode:   self = .proxyAuthenticationRequired
            case Response.Status.requestTimeout.statusCode:                self = .requestTimeout
            case Response.Status.conflict.statusCode:                      self = .conflict
            case Response.Status.gone.statusCode:                          self = .gone
            case Response.Status.lengthRequired.statusCode:                self = .lengthRequired
            case Response.Status.preconditionFailed.statusCode:            self = .preconditionFailed
            case Response.Status.requestEntityTooLarge.statusCode:         self = .requestEntityTooLarge
            case Response.Status.requestURITooLong.statusCode:             self = .requestURITooLong
            case Response.Status.unsupportedMediaType.statusCode:          self = .unsupportedMediaType
            case Response.Status.requestedRangeNotSatisfiable.statusCode:  self = .requestedRangeNotSatisfiable
            case Response.Status.expectationFailed.statusCode:             self = .expectationFailed
            case Response.Status.imATeapot.statusCode:                     self = .imATeapot
            case Response.Status.authenticationTimeout.statusCode:         self = .authenticationTimeout
            case Response.Status.enhanceYourCalm.statusCode:               self = .enhanceYourCalm
            case Response.Status.unprocessableEntity.statusCode:           self = .unprocessableEntity
            case Response.Status.locked.statusCode:                        self = .locked
            case Response.Status.failedDependency.statusCode:              self = .failedDependency
            case Response.Status.preconditionRequired.statusCode:          self = .preconditionRequired
            case Response.Status.tooManyRequests.statusCode:               self = .tooManyRequests
            case Response.Status.requestHeaderFieldsTooLarge.statusCode:   self = .requestHeaderFieldsTooLarge
                
            case Response.Status.internalServerError.statusCode:           self = .internalServerError
            case Response.Status.notImplemented.statusCode:                self = .notImplemented
            case Response.Status.badGateway.statusCode:                    self = .badGateway
            case Response.Status.serviceUnavailable.statusCode:            self = .serviceUnavailable
            case Response.Status.gatewayTimeout.statusCode:                self = .gatewayTimeout
            case Response.Status.httpVersionNotSupported.statusCode:       self = .httpVersionNotSupported
            case Response.Status.variantAlsoNegotiates.statusCode:         self = .variantAlsoNegotiates
            case Response.Status.insufficientStorage.statusCode:           self = .insufficientStorage
            case Response.Status.loopDetected.statusCode:                  self = .loopDetected
            case Response.Status.notExtended.statusCode:                   self = .notExtended
            case Response.Status.networkAuthenticationRequired.statusCode: self = .networkAuthenticationRequired
                
            default: self = .other(statusCode: statusCode, reasonPhrase: "CUSTOM")
            }
        }
    }
}

extension Response.Status {
    public var statusCode: Int {
        switch self {
        case .`continue`:                    return 100
        case .switchingProtocols:            return 101
        case .processing:                    return 102
            
        case .ok:                            return 200
        case .created:                       return 201
        case .accepted:                      return 202
        case .nonAuthoritativeInformation:   return 203
        case .noContent:                     return 204
        case .resetContent:                  return 205
        case .partialContent:                return 206
            
        case .multipleChoices:               return 300
        case .movedPermanently:              return 301
        case .found:                         return 302
        case .seeOther:                      return 303
        case .notModified:                   return 304
        case .useProxy:                      return 305
        case .switchProxy:                   return 306
        case .temporaryRedirect:             return 307
        case .permanentRedirect:             return 308
            
            
        case .badRequest:                    return 400
        case .unauthorized:                  return 401
        case .paymentRequired:               return 402
        case .forbidden:                     return 403
        case .notFound:                      return 404
        case .methodNotAllowed:              return 405
        case .notAcceptable:                 return 406
        case .proxyAuthenticationRequired:   return 407
        case .requestTimeout:                return 408
        case .conflict:                      return 409
        case .gone:                          return 410
        case .lengthRequired:                return 411
        case .preconditionFailed:            return 412
        case .requestEntityTooLarge:         return 413
        case .requestURITooLong:             return 414
        case .unsupportedMediaType:          return 415
        case .requestedRangeNotSatisfiable:  return 416
        case .expectationFailed:             return 417
        case .imATeapot:                     return 418
        case .authenticationTimeout:         return 419
        case .enhanceYourCalm:               return 420
        case .unprocessableEntity:           return 422
        case .locked:                        return 423
        case .failedDependency:              return 424
        case .preconditionRequired:          return 428
        case .tooManyRequests:               return 429
        case .requestHeaderFieldsTooLarge:   return 431
            
        case .internalServerError:           return 500
        case .notImplemented:                return 501
        case .badGateway:                    return 502
        case .serviceUnavailable:            return 503
        case .gatewayTimeout:                return 504
        case .httpVersionNotSupported:       return 505
        case .variantAlsoNegotiates:         return 506
        case .insufficientStorage:           return 507
        case .loopDetected:                  return 508
        case .notExtended:                   return 510
        case .networkAuthenticationRequired: return 511
            
        case .other(let statusCode, _):        return statusCode
        }
    }
}

extension Response.Status {
    public var reasonPhrase: String {
        switch self {
        case .`continue`:                    return "Continue"
        case .switchingProtocols:            return "Switching Protocols"
        case .processing:                    return "Processing"
            
        case .ok:                            return "OK"
        case .created:                       return "Created"
        case .accepted:                      return "Accepted"
        case .nonAuthoritativeInformation:   return "Non Authoritative Information"
        case .noContent:                     return "No Content"
        case .resetContent:                  return "Reset Content"
        case .partialContent:                return "Partial Content"
            
        case .multipleChoices:               return "Multiple Choices"
        case .movedPermanently:              return "Moved Permanently"
        case .found:                         return "Found"
        case .seeOther:                      return "See Other"
        case .notModified:                   return "Not Modified"
        case .useProxy:                      return "Use Proxy"
        case .switchProxy:                   return "Switch Proxy"
        case .temporaryRedirect:             return "Temporary Redirect"
        case .permanentRedirect:             return "Permanent Redirect"
            
        case .badRequest:                    return "Bad Request"
        case .unauthorized:                  return "Unauthorized"
        case .paymentRequired:               return "Payment Required"
        case .forbidden:                     return "Forbidden"
        case .notFound:                      return "Not Found"
        case .methodNotAllowed:              return "Method Not Allowed"
        case .notAcceptable:                 return "Not Acceptable"
        case .proxyAuthenticationRequired:   return "Proxy Authentication Required"
        case .requestTimeout:                return "Request Timeout"
        case .conflict:                      return "Conflict"
        case .gone:                          return "Gone"
        case .lengthRequired:                return "Length Required"
        case .preconditionFailed:            return "Precondition Failed"
        case .requestEntityTooLarge:         return "Request Entity Too Large"
        case .requestURITooLong:             return "Request URI Too Long"
        case .unsupportedMediaType:          return "Unsupported Media Type"
        case .requestedRangeNotSatisfiable:  return "Requested Range Not Satisfiable"
        case .expectationFailed:             return "Expectation Failed"
        case .imATeapot:                     return "I'm A Teapot"
        case .authenticationTimeout:         return "Authentication Timeout"
        case .enhanceYourCalm:               return "Enhance Your Calm"
        case .unprocessableEntity:           return "Unprocessable Entity"
        case .locked:                        return "Locked"
        case .failedDependency:              return "Failed Dependency"
        case .preconditionRequired:          return "Precondition Required"
        case .tooManyRequests:               return "Too Many Requests"
        case .requestHeaderFieldsTooLarge:   return "Request Header Fields Too Large"
            
        case .internalServerError:           return "Internal Server Error"
        case .notImplemented:                return "Not Implemented"
        case .badGateway:                    return "Bad Gateway"
        case .serviceUnavailable:            return "Service Unavailable"
        case .gatewayTimeout:                return "Gateway Timeout"
        case .httpVersionNotSupported:       return "HTTP Version Not Supported"
        case .variantAlsoNegotiates:         return "Variant Also Negotiates"
        case .insufficientStorage:           return "Insufficient Storage"
        case .loopDetected:                  return "Loop Detected"
        case .notExtended:                   return "Not Extended"
        case .networkAuthenticationRequired: return "Network Authentication Required"
            
        case .other(_, let reasonPhrase):      return reasonPhrase
        }
    }
}

extension Response.Status {
    public var isInformational: Bool {
        return 100 ..< 200 ~= statusCode
    }
    
    public var isSuccessful: Bool {
        return 200 ..< 300 ~= statusCode
    }
    
    public var isRedirection: Bool {
        return 300 ..< 400 ~= statusCode
    }
    
    public var isError: Bool {
        return 400 ..< 600 ~= statusCode
    }
    
    public var isClientError: Bool {
        return 400 ..< 500 ~= statusCode
    }
    
    public var isServerError: Bool {
        return 500 ..< 600 ~= statusCode
    }
}

extension Response.Status : Hashable {
    
    public var hashValue: Int {
        return statusCode
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.statusCode)
    }
}

public func ==(lhs: Response.Status, rhs: Response.Status) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
