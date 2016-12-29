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

import Foundation

public enum URLError : Error {
    case invalidURL
}

extension URL {
    public var queryItems: [URLQueryItem] {
        #if os(Linux)
            //URLComponents.queryItems crashes on Linux.
            //FIXME: remove that when Foundation will be fixed
            //https://bugs.swift.org/browse/SR-384
            guard let queryPairs = query?.components(separatedBy: "&") else { return [] }
            let items = queryPairs.map { (s) -> URLQueryItem in
                let pair = s.components(separatedBy: "=")
                
                let name = pair[0]
                let value: String? = pair.count > 1 ? pair[1] : nil
                
                return URLQueryItem(name: name, value: value?.removingPercentEncoding)
            }
            
            return items
            
            
        #else
            return URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #endif
    }
}
