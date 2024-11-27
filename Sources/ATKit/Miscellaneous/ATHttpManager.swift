//
//  ATHttpManager.swift
//  ATKit
//
//

import Foundation

#if canImport(Alamofire)
import Alamofire
#endif


public class ATHttpManager {
    
    public var isDebug: Bool = false
    
    private let defaultMultipartEndOfPart :String = "--"
    
    public init() {
        
    }
    
    public func send(httpRequest pHttpRequest :HttpRequest) -> HttpResponse {
        var aReturnVal :HttpResponse = HttpResponse()
        
        self.log(httpRequest: pHttpRequest)
        
        #if canImport(Alamofire)
            aReturnVal = self.responseWithAlamofire(httpRequest: pHttpRequest)
        #else
            aReturnVal = self.responseWithUrlSession(httpRequest: pHttpRequest)
        #endif
        
        self.log(httpResponse: aReturnVal)
        
        return aReturnVal
    }
    
    
    private func responseWithUrlSession(httpRequest pHttpRequest :HttpRequest) -> HttpResponse {
        let aReturnVal = HttpResponse()
        aReturnVal.title = pHttpRequest.title
        
        var aUrlRequest = URLRequest(url: pHttpRequest.url!)
        aUrlRequest.httpMethod = pHttpRequest.method?.toString ?? Method.post.toString
        if let anHttpHeaderArray = pHttpRequest.headers
        , anHttpHeaderArray.count > 0 {
            for anHttpHeader in anHttpHeaderArray {
                if let aHeaderName = anHttpHeader.name
                , let aHeaderValue = anHttpHeader.value {
                    aUrlRequest.addValue(aHeaderValue, forHTTPHeaderField: aHeaderName)
                }
            }
        }
        if let anHttpRequestBody = pHttpRequest.body {
            switch anHttpRequestBody {
            case .empty:
                aUrlRequest.httpBody = nil
            case .data(let pData):
                aUrlRequest.httpBody = pData
            case .json(let pDict):
                if pHttpRequest.headers?.contains(where: { $0.name == "Content-Type" }) != true {
                    aUrlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                aUrlRequest.httpBody = try? JSONSerialization.data(withJSONObject: pDict, options: .prettyPrinted)
            case .multipart(let pParameterArray, let pEndOfPartString):
                let aBoundary = UUID().uuidString.replacingOccurrences(of: "-", with: "")
                aUrlRequest.addValue(String(format: "multipart/form-data; boundary=%@", aBoundary), forHTTPHeaderField: "Content-Type")
                var aBodyData = Data()
                for aParameter in pParameterArray {
                    if let aParameterName = aParameter.name
                    , let aParameterValue = aParameter.value {
                        aBodyData.append(String(format: "\r\n--%@\r\n", aBoundary).data(using: String.Encoding.utf8)!)
                        if let aParameterFileName = aParameter.fileName {
                            aBodyData.append(String(format: "Content-Type: %@\r\n", aParameter.mimeType).data(using: String.Encoding.utf8)!)
                            aBodyData.append(String(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", aParameterName, aParameterFileName).data(using: String.Encoding.utf8)!)
                        } else {
                            aBodyData.append(String(format: "Content-Disposition: form-data; name=\"%@\"\r\n", aParameterName).data(using: String.Encoding.utf8)!)
                        }
                        aBodyData.append(String(format: "Content-Length: %lu\r\n", aParameterValue.count).data(using: String.Encoding.utf8)!)
                        aBodyData.append("\r\n".data(using: String.Encoding.utf8)!)
                        aBodyData.append(aParameterValue)
                        aBodyData.append(String(format: "\r\n--%@%@", aBoundary, pEndOfPartString).data(using: String.Encoding.utf8)!)
                    }
                    aUrlRequest.httpBody = aBodyData
                }
            }
        }
        
        let aDispatchSemaphore = DispatchSemaphore(value: 0)
        let aDataTask = URLSession.shared.dataTask(with: aUrlRequest, completionHandler: { (pData, pUrlResponse, pError) in
            aReturnVal.code = (pUrlResponse as? HTTPURLResponse)?.statusCode
            var aHeaderArray: Array<Header>?
            if let aHeaderDictArray = (pUrlResponse as? HTTPURLResponse)?.allHeaderFields as? [String:String] {
                aHeaderArray = aHeaderDictArray.compactMap { (pKey, pValue) in
                    Header(name: pKey, value: pValue)
                }
            }
            aReturnVal.headers = aHeaderArray
            if let aData = pData {
                aReturnVal.body = .data(aData)
            } else {
                aReturnVal.body = .empty
            }
            aReturnVal.error = pError
            aDispatchSemaphore.signal()
        })
        aDataTask.resume()
        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        
        return aReturnVal
    }
    
    
    #if canImport(Alamofire)
    private func responseWithAlamofire(httpRequest pHttpRequest :HttpRequest) -> HttpResponse {
        let aReturnVal = HttpResponse()
        aReturnVal.title = pHttpRequest.title
        
        // Create request
        let aRequestUrl = pHttpRequest.url!
        var aRequestMethod = HTTPMethod.get
        if pHttpRequest.method == "POST" {
            aRequestMethod = HTTPMethod.post
        } else if pHttpRequest.method == "PUT" {
            aRequestMethod = HTTPMethod.put
        } else if pHttpRequest.method == "DELETE" {
            aRequestMethod = HTTPMethod.delete
        }
        var aRequestHeaders = HTTPHeaders()
        if pHttpRequest.headers != nil {
            for (aKey,aValue) in pHttpRequest.headers! {
                aRequestHeaders.add(name: aKey, value: aValue)
            }
        }
        let aRequestBody = pHttpRequest.body
        
        // Execute request
        let aSession = Alamofire.Session()
        var aRequest :DataRequest? = nil
        switch aRequestBody {
        case .json(let pDict):
            aRequest = aSession.request(aRequestUrl, method: aRequestMethod, parameters: pDict, encoding: JSONEncoding(), headers: aRequestHeaders, interceptor: nil, requestModifier: nil)
        case .multipart(let pParameterArray):
            aRequest = aSession.upload(multipartFormData: { pMultipartFormData in
                for aParameter in pParameterArray {
                    if let aName = aParameter.name
                    , let aValue = aParameter.value {
                        if let aFileName = aParameter.fileName {
                            pMultipartFormData.append(aValue, withName: aName, fileName: aFileName, mimeType: aParameter.mimeType)
                        } else {
                            pMultipartFormData.append(aValue, withName: aName)
                        }
                    }
                }
            }, to: aRequestUrl, method: aRequestMethod, headers: aRequestHeaders)
        case nil:
            aRequest = aSession.request(aRequestUrl, method: aRequestMethod, parameters: nil, encoding: JSONEncoding(), headers: aRequestHeaders, interceptor: nil, requestModifier: nil)
        }
        
        let aDispatchSemaphore = DispatchSemaphore(value: 0)
        aRequest?.response { pResult in
            aReturnVal.code = pResult.response?.statusCode
            aReturnVal.headers = pResult.response?.allHeaderFields as? [String:String]
            aReturnVal.body = pResult.data
            aReturnVal.error = pResult.error
            aDispatchSemaphore.signal()
        }
        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        
        return aReturnVal
    }
    #endif
    
    
    private func log(httpRequest pHttpRequest :HttpRequest) {
        if self.isDebug {
            var aLog :String = String(format: "\n----- BEGIN \"%@\"", pHttpRequest.title ?? "<null>")
            aLog += String(format: "\n\nRequest URL (%@):\n%@", pHttpRequest.title ?? "<null>", pHttpRequest.url?.absoluteString ?? "<null>")
            aLog += String(format: "\n\nRequest Method (%@):\n%@", pHttpRequest.title ?? "<null>", pHttpRequest.method?.toString ?? "<null>")
            aLog += String(format: "\n\nRequest Headers (%@):\n%@", pHttpRequest.title ?? "<null>", pHttpRequest.headers?.description ?? "<null>")
            aLog += String(format: "\n\nRequest Body (%@):\n%@", pHttpRequest.title ?? "<null>", pHttpRequest.body?.description ?? "<null>")
            Swift.print(aLog)
        }
    }
    
    
    private func log(httpResponse pHttpResponse :HttpResponse) {
        if self.isDebug {
            var aLog :String = String(format: "\n\nResponse Error (%@):\n%@", pHttpResponse.title ?? "<null>", pHttpResponse.error?.localizedDescription ?? "<null>")
            aLog += String(format: "\n\nResponse Code (%@):\n%d", pHttpResponse.title ?? "<null>", pHttpResponse.code ?? "<null>")
            aLog += String(format: "\n\nResponse Headers (%@):\n%@", pHttpResponse.title ?? "<null>", pHttpResponse.headers?.description ?? "<null>")
            aLog += String(format: "\n\nResponse Body (%@):\n%@", pHttpResponse.title ?? "<null>", pHttpResponse.body?.description ?? "<null>")
            aLog += String(format: "\n\n----- END \"%@\"", pHttpResponse.title ?? "<null>")
            Swift.print(aLog)
        }
    }
    
}


public extension ATHttpManager {
    
    enum Method {
        case get
        case post
        case put
        case patch
        case delete
        
        var toString: String {
            var aReturnVal: String
            switch self {
            case .get:
                aReturnVal = "GET"
            case .post:
                aReturnVal = "POST"
            case .put:
                aReturnVal = "PUT"
            case .patch:
                aReturnVal = "PATCH"
            case .delete:
                aReturnVal = "DELETE"
            }
            return aReturnVal
        }
    }
    
}


public extension ATHttpManager {
    
    struct Header {
        public var name :String?
        public var value :String?
        
        public init() {
            
        }
        
        public init(name pName: String, value pValue: String) {
            self.name = pName
            self.value = pValue
        }
    }
    
}


public extension ATHttpManager {
    
    enum Body {
        case empty
        case data(Data)
        case json(Dictionary<String,Any>)
        case multipart(Array<Parameter>, String = "--")
        
        var description: String {
            var aReturnVal: String = ""
            switch self {
            case .empty:
                aReturnVal = "<null>"
            case .data(let pData):
                if let aBody = String(data: pData, encoding: String.Encoding.utf8) {
                    aReturnVal = aBody
                }
            case .json(let pDict):
                if let aData = try? JSONSerialization.data(withJSONObject: pDict, options: [])
                , let aBody = String(data: aData, encoding: String.Encoding.utf8) {
                    aReturnVal = aBody
                }
            case .multipart(let pParameterArray, _):
                var aStringArray: Array<String> = Array<String>()
                for aParameter in pParameterArray {
                    aStringArray.append(aParameter.description)
                }
                aReturnVal = aStringArray.joined(separator: "\n")
            }
            return aReturnVal
        }
        
        public var toData: Data? {
            var aReturnVal :Data?
            switch self {
            case .empty:
                aReturnVal = nil
            case .data(let pData):
                aReturnVal = pData
            case .multipart:
                aReturnVal = nil
            case .json:
                aReturnVal = nil
            }
            return aReturnVal
        }
        
        public var toDictionary: Dictionary<String,Any>? {
            var aReturnVal :Dictionary<String,Any>?
            switch self {
            case .empty:
                aReturnVal = nil
            case .data:
                aReturnVal = nil
            case .multipart:
                aReturnVal = nil
            case .json(let pDictionary):
                aReturnVal = pDictionary
            }
            return aReturnVal
        }
    }
    
}


public extension ATHttpManager {
    
    struct Parameter {
        var name :String?
        var value :Data?
        var fileName :String?
        
        public init(name pName :String, value pValue :Data?, fileName pFileName :String?) {
            self.name = pName
            self.value = pValue
            self.fileName = pFileName
        }
        
        var mimeType :String {
            var aReturnVal = "application/octet-stream"
            if let anExtension = self.fileName?.components(separatedBy: ".").last {
                if anExtension == "xls"
                || anExtension == "xlsx" {
                    aReturnVal = "application/vnd.ms-excel"
                } else if anExtension == "doc"
                || anExtension == "docx" {
                    aReturnVal = "application/msword"
                } else if anExtension == "jpg"
                || anExtension == "jpeg" {
                    aReturnVal = "image/jpeg"
                } else if anExtension == "png" {
                    aReturnVal = "image/png"
                } else if anExtension == "pdf" {
                    aReturnVal = "image/pdf"
                }
            }
            return aReturnVal
        }
        
        var description: String {
            var aReturnVal = ""
            var aValue = ""
            if let aData = self.value
            , let aString = String(data: aData, encoding: .utf8) {
                aValue = aString
            } else {
                var aSize = "0 kb"
                if let aCount = self.value?.count {
                    if aCount <= 1024 {
                        aSize = String(format: "%d bytes", aCount)
                    } else if aCount > 1024 && aCount <= (1024 * 1024) {
                        aSize = String(format: "%d kb", aCount / 1024)
                    } else {
                        aSize = String(format: "%d mb", aCount / (1024 * 1024))
                    }
                }
                aValue = String(format: "<%@(%@)>", (self.fileName != nil ? (self.fileName! + " ") : ""), aSize)
            }
            aReturnVal = String(format: "%@ = %@", self.name ?? "", aValue)
            return aReturnVal
        }
    }
    
}


public extension ATHttpManager {
    
    class HttpRequest {
        public var url :URL?
        public var method :Method?
        public var headers :Array<Header>?
        public var body :Body?
        public var title :String?
        
        public init() {
            
        }
        
        public init(title pTitle :String, url pUrl :URL, method pMethod :Method, headers pHeaderArray :Array<Header>?, body pBody :Body?) {
            self.title = pTitle
            self.url = pUrl
            self.method = pMethod
            self.headers = pHeaderArray
            self.body = pBody
        }
    }
    
}


public extension ATHttpManager {
    
    class HttpResponse {
        public var error :Error?
        public var code :Int?
        public var headers :Array<Header>?
        public var body :Body?
        public var title :String?
    }
    
}


public extension Array where Element == ATHttpManager.Header {
    var description: String {
        var aReturnVal = ""
        let aStringArray: Array<String> = self.map() { ($0.name ?? "") + " : " + ($0.value ?? "") }
        aReturnVal = aStringArray.joined(separator: "\n")
        return aReturnVal
    }
    
    var toDictionary: Dictionary<String,String> {
        var aReturnVal = Dictionary<String,String>()
        for aHeader in self {
            if let aKey = aHeader.name, aKey.isEmpty == false
            , let aValue = aHeader.value, aValue.isEmpty == false {
                aReturnVal[aKey] = aValue
            }
        }
        return aReturnVal
    }
}
