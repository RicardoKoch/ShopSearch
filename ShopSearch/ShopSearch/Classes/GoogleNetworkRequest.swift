//
//  GoogleNetworkRequest.swift
//  Pods
//
//  Created by Ricardo Koch on 4/2/16.
//
//

import Foundation

@objc protocol GoogleNetworkRequestDelegate: class {
    optional func googleRequestDidComplete(results:NSData?)
    optional func googleRequestDidFail()
}

class GoogleNetworkRequest: NSObject {
    
    static let google_domain = "https://www.google.com"
    
    static let search_format = "%@/search?hl=en&tbm=shop&tbs=vw:l&q=%@"
    static let product_format = "%@/shopping/product/%@?hl=en"
    
    //SOURCE: https://support.google.com/merchants/answer/160081?hl=en
    static let categories_format = "%@/basepages/producttype/taxonomy-with-ids.en-US.txt"
    
    var session: NSURLSession!
    var dataMap = [Int: NSMutableData]()
    var parserMap = [Int: GoogleNetworkRequestDelegate]()
    
    override init() {

        super.init()
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        self.session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        
    }
    
    deinit {
        self.session?.invalidateAndCancel()
    }
    
    func searchRequest(query:String, parser:GoogleNetworkRequestDelegate) {
        
        var urlStr = String(format: GoogleNetworkRequest.search_format, GoogleNetworkRequest.google_domain, query)
        urlStr = urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let url = NSURL(string: urlStr)

        guard let urlUnwrap = url else {
            parser.googleRequestDidFail?()
            return
        }
        
        NSLog("Execute Search \(urlUnwrap)", "")
        
        let dataTask = self.session.dataTaskWithURL(urlUnwrap)
        self.parserMap[dataTask.taskIdentifier] = parser

        dataTask.resume()
    }
    
    func productFetch(productId:String, parser:GoogleNetworkRequestDelegate) {
        
        var urlStr = String(format: GoogleNetworkRequest.product_format, GoogleNetworkRequest.google_domain, productId)
        urlStr = urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let url = NSURL(string: urlStr)
        
        guard let urlUnwrap = url else {
            parser.googleRequestDidFail?()
            return
        }
        
        NSLog("Execute Product Fetch \(urlUnwrap)", "")
        
        let dataTask = self.session.dataTaskWithURL(urlUnwrap)
        self.parserMap[dataTask.taskIdentifier] = parser
        
        dataTask.resume()
    }
    
    func categoriesFetch(parser:GoogleNetworkRequestDelegate) {
        
        var urlStr = String(format: GoogleNetworkRequest.categories_format, GoogleNetworkRequest.google_domain)
        urlStr = urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let url = NSURL(string: urlStr)
        
        guard let urlUnwrap = url else {
            parser.googleRequestDidFail?()
            return
        }
        NSLog("Execute Categories Fetch \(urlUnwrap)", "")
        
        let dataTask = self.session.dataTaskWithURL(urlUnwrap)
        self.parserMap[dataTask.taskIdentifier] = parser
        
        dataTask.resume()
    }

    
}

extension GoogleNetworkRequest: NSURLSessionDelegate {
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        //NSLog("didReceiveResponse", "")
        
        self.dataMap[dataTask.taskIdentifier] = NSMutableData()
        completionHandler(.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData){
        //NSLog("didReceiveData", "")
        self.dataMap[dataTask.taskIdentifier]?.appendData(data)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        //NSLog("didCompleteWithError", "")
        
        //let str = String(data: self.responseData, encoding: NSASCIIStringEncoding)
       //NSLog(str!, "")
        if error == nil {
            let data = self.dataMap[task.taskIdentifier]
            
            self.parserMap[task.taskIdentifier]?.googleRequestDidComplete?(data)
        }
        else {
            self.parserMap[task.taskIdentifier]?.googleRequestDidFail?()
        }
        self.dataMap[task.taskIdentifier] = nil
        self.parserMap[task.taskIdentifier] = nil
    }
    
    
    
}

