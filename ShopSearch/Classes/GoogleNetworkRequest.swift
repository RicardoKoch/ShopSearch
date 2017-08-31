//
//  GoogleNetworkRequest.swift
//  Pods
//
//  Created by Ricardo Koch on 4/2/16.
//
//

import Foundation
import WebKit

@objc protocol GoogleNetworkRequestDelegate: class {
    @objc optional func googleRequestDidComplete(_ results:Data?)
    @objc optional func googleRequestDidFail()
}

let WebKitRequestKey = "SearchRequestKey".hashValue

class GoogleNetworkRequest: NSObject {
    
    static let google_domain = "https://www.google.com"

    static let search_format = "%@/search?hl=en&tbm=shop&tbs=vw:l&safe=off&q=%@"
    static let product_format = "%@/shopping/product/%@?hl=en"
	static let specs_format = "%@/shopping/product/%@/specs?hl=en"
    
    //SOURCE: https://support.google.com/merchants/answer/160081?hl=en
    static let categories_format = "%@/basepages/producttype/taxonomy-with-ids.en-US.txt"
    
    var session: Foundation.URLSession!
    var dataMap = [Int: Data]()
    var parserMap = [Int: GoogleNetworkRequestDelegate]()
	
	internal var loadWebView: WKWebView?
	
    override init() {

        super.init()
        
        let configuration = URLSessionConfiguration.default
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        self.session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
    }
    
    deinit {
        self.session?.invalidateAndCancel()
    }
    
    func searchRequest(_ query:String, parser:GoogleNetworkRequestDelegate) {
        
        var urlStr = String(format: GoogleNetworkRequest.search_format, GoogleNetworkRequest.google_domain, query)
        urlStr = urlStr.addingPercentEscapes(using: String.Encoding.utf8)!
        let url = URL(string: urlStr)

        guard let urlUnwrap = url else {
            parser.googleRequestDidFail?()
            return
        }
        
        NSLog("Execute Search \(urlUnwrap)", "")
        
        let dataTask = self.session.dataTask(with: urlUnwrap)
        self.parserMap[dataTask.taskIdentifier] = parser

        dataTask.resume()
    }
	
	func searchAdvRequest(_ query:String, parser: GoogleNetworkRequestDelegate) {
		
		var urlStr = String(format: GoogleNetworkRequest.search_format, GoogleNetworkRequest.google_domain, query)
		urlStr = urlStr.addingPercentEscapes(using: String.Encoding.utf8)!
		let url = URL(string: urlStr)
		
		guard let urlUnwrap = url else {
			parser.googleRequestDidFail?()
			return
		}
		
		NSLog("Execute Browser Search \(urlUnwrap)", "")
		
		self.parserMap[WebKitRequestKey]?.googleRequestDidFail?()
		self.loadWebView?.stopLoading()
		
		self.loadWebView = WKWebView()
		if #available(iOS 9.0, *) {
			self.loadWebView?.allowsLinkPreview = false
		}
		self.loadWebView?.uiDelegate = self
		self.loadWebView?.navigationDelegate = self
		var request = URLRequest(url: urlUnwrap)
		request.timeoutInterval = Double(InitializationTimeout)
		
		self.parserMap[WebKitRequestKey] = parser
		self.loadWebView?.load(request)
	}
	
    func productFetch(_ productId:String, parser:GoogleNetworkRequestDelegate) {
        
        var urlStr = String(format: GoogleNetworkRequest.product_format, GoogleNetworkRequest.google_domain, productId)
        urlStr = urlStr.addingPercentEscapes(using: String.Encoding.utf8)!
        let url = URL(string: urlStr)
        
        guard let urlUnwrap = url else {
            parser.googleRequestDidFail?()
            return
        }
        
        NSLog("Execute Product Fetch \(urlUnwrap)", "")
        
        let dataTask = self.session.dataTask(with: urlUnwrap)
        self.parserMap[dataTask.taskIdentifier] = parser
        dataTask.resume()
    }
	
	func specsFetch(_ productId:String, parser:GoogleNetworkRequestDelegate) {
		var urlStr = String(format: GoogleNetworkRequest.specs_format, GoogleNetworkRequest.google_domain, productId)
		urlStr = urlStr.addingPercentEscapes(using: String.Encoding.utf8)!
		let url = URL(string: urlStr)
		
		guard let urlUnwrap = url else {
			parser.googleRequestDidFail?()
			return
		}
		NSLog("Execute Product Specs Fetch \(urlUnwrap)", "")
		
		let dataTask = self.session.dataTask(with: urlUnwrap)
		self.parserMap[dataTask.taskIdentifier] = parser
		dataTask.resume()
	}
	
    func categoriesFetch(_ parser:GoogleNetworkRequestDelegate) {
		
        var urlStr = String(format: GoogleNetworkRequest.categories_format, GoogleNetworkRequest.google_domain)
        urlStr = urlStr.addingPercentEscapes(using: String.Encoding.utf8)!
        let url = URL(string: urlStr)
        
        guard let urlUnwrap = url else {
            parser.googleRequestDidFail?()
            return
        }
        NSLog("Execute Categories Fetch \(urlUnwrap)", "")
        
        let dataTask = self.session.dataTask(with: urlUnwrap)
        self.parserMap[dataTask.taskIdentifier] = parser
        
        dataTask.resume()
    }

    
}

extension GoogleNetworkRequest: URLSessionDelegate {
    
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveResponse response: URLResponse, completionHandler: (Foundation.URLSession.ResponseDisposition) -> Void) {
        //NSLog("didReceiveResponse", "")
        
        self.dataMap[dataTask.taskIdentifier] = Data()
        completionHandler(.allow)
    }
    
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data){
        //NSLog("didReceiveData", "")
        self.dataMap[dataTask.taskIdentifier]?.append(data)
    }
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        //NSLog("didCompleteWithError", "")
		
		if error == nil {
            let data = self.dataMap[task.taskIdentifier]
			
			//let str = String(data: data ?? Data(), encoding: String.Encoding.ascii)
			//NSLog("Response data:\n\(str ?? "")", "")
            self.parserMap[task.taskIdentifier]?.googleRequestDidComplete?(data)
        }
        else {
            self.parserMap[task.taskIdentifier]?.googleRequestDidFail?()
        }
        self.dataMap[task.taskIdentifier] = nil
        self.parserMap[task.taskIdentifier] = nil
    }
	
}

extension GoogleNetworkRequest: WKUIDelegate, WKNavigationDelegate {
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		
		let parser = parserMap[WebKitRequestKey]
		parserMap[WebKitRequestKey] = nil
		loadWebView = nil
		parser?.googleRequestDidFail?()
	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		decisionHandler(.allow)
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		
		webView.evaluateJavaScript("document.body.outerHTML") { (obj, error) in
			
			let parser = self.parserMap[WebKitRequestKey]
			
			if let content = obj as? String {
				
				//NSLog("Google WebView Request Content: \(content)", "")
				
				let data = content.data(using: String.Encoding.utf8)
				
				self.loadWebView = nil
				
				if let data = data {
					parser?.googleRequestDidComplete?(data)
				} else {
					parser?.googleRequestDidFail?()
				}
			} else {
				parser?.googleRequestDidFail?()
			}
			self.parserMap[WebKitRequestKey] = nil
		}
		
		//let content = webView.stringByEvaluatingJavaScript(from: "document.body.outerHTML") ?? ""
	}
	
	
}

