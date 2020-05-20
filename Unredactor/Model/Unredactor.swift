//
//  Unredactor.swift
//  Unredactor
//
//  Created by tyler on 7/17/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation
import UIKit
import JavaScriptCore
import Alamofire

// I'm going to make this a singleton because there should only be one unredactor and it doesn't carry info between things, it only performs functions
class Unredactor {
    static var maskToken: String = "unk"
    
    func unredact(_ redactedText: ClassifiedText, completion: @escaping (ClassifiedText, String?) -> Void) {
        // Implement by accessing the website API
        
        // Get array of words that are unredacted back:
        var unredactedWords: [String] = [] // Placeholder for now
        
        // Create a copy of redactedText
        let unredactedText: ClassifiedText = redactedText.copy() as! ClassifiedText
        
        let redactedWords = unredactedText.words.filter { $0.redactionState != .notRedacted }
        
        // Placeholder definition of unredactedWords - get from API
        
        getUnredactedWords(fromText: unredactedText.urlText, withRequestType: .post) { (words, errorMessage) in
            
            guard words != [""] else {
                completion(unredactedText, errorMessage)
                return
            } // An error occurred
            
            unredactedWords = words
            
            // Unredact all the redacted words
            for (index, redactedWord) in redactedWords.enumerated() {
                redactedWord.lastRedactionState = redactedWord.redactionState // This probably has a problem
                redactedWord.redactionState = .unredacted
                print("redactedWord: \(redactedWord.string)")
                
                if let unredactedWord = unredactedWords[safeIndex: UInt(index)] {
                    redactedWord.unredactorPrediction = unredactedWord
                } else {
                    completion(ClassifiedText(withWords: words), "Something is wrong with the server response.") // Do nothing and display the error
                }
            }
            
            completion(unredactedText, errorMessage)
        }
    }
    
    private enum RequestType {
        case get, post
    }
    
    private func getUnredactedWords(fromText text: String, withRequestType requestType: RequestType, completion: @escaping (([String], String?) -> Void)) {
        
        var task: URLSessionDataTask
        
        print("REQUEST TYPE: \(requestType)")
        
        if requestType == .get {
            let urlString = "https://unredactor.com/api/unredact_bert?text=" + text
            print("URLSTRING: \(urlString)")
            let baseURL = URL(string: urlString)!
            
            task = URLSession.shared.dataTask(with: baseURL) { (data, response, error) in
                self.handleServerResponse(data: data, response: response, error: error, completion: { (unredactedWords, errorMessage) in
                    completion(unredactedWords, errorMessage)
                })
            }
            
            // Start the task
            task.resume()
        } else { // requestType = .post
            /*
            //from: https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method (accepted answer)
            let url = URL(string: "https://unredactor-mobile-3h3pagkfya-uw.a.run.app/unredact")!
            //let url = URL(string: "https://unredactor.com/unredactor")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpMethod = "POST"
            
            /*
            let parameters: [String: Any] = [
                "text": text,
            ]
 */
            let json: [String: Any] = ["text": text]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            //request.httpBody = parameters.percentEscaped().data(using: .utf8)
            request.httpBody = jsonData
            
            //print("request: \(parameters.percentEscaped())")
            
            task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil else {                                              // check for fundamental networking error
                        print("error", error ?? "Unknown error")
                        return
                }
                
                /*
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    return
                }
 */
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
                print("response: \(response)")
                
                self.handleServerResponse(data: data, response: response, error: error) { (unredactedWords, errorMessage) in
                    completion(unredactedWords, errorMessage)
                }
            }
 */
            
            let parameters = ["text": text]
            AF.request("https://unredactor-mobile-3h3pagkfya-uw.a.run.app/unredact", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [unowned self] (response) in
                print(response)
                
                self.handleServerResponse(data: response.data, response: nil, error: nil) { (unredactedWords, error) in
                    completion(unredactedWords, error)
                }
            }
            
            //AF.request("https://unredactor-mobile-3h3pagkfya-uw.a.run.app/unredact" , method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            
        }
    }
    
    // MARK: - Unredactor Info
    struct UnredactorInfo: Codable {
        var text: String // original text
        var unredacted_text: String // unredacted text
        var unredacted_words: [String] // unredacted words
        
        enum CodingKeys: String, CodingKey {
            case text// = "text"
            case unredacted_text// = "unredacted_text"
            case unredacted_words// = "words"
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.text = try valueContainer.decode(String.self, forKey: .text)
            self.unredacted_text = try valueContainer.decode(String.self, forKey: .unredacted_text)
            self.unredacted_words = try valueContainer.decode([String].self, forKey: .unredacted_words)
        }
    }
    
    // Takes a completion of (words: [String], errorMessage: String?)
    private func handleServerResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping ([String], String?) -> Void) {
        let jsonDecoder = JSONDecoder()
        
        if let response = response {
            print("RESPONSE: \(response)")
        }
        
        if let error = error {
            print("ERROR: \(error)")
            completion([""], "Couldn't get a response from the server. The server might be down or you might have a bad connection.")
        }
        
        if let data = data {
            if let unredactorInfo = try? jsonDecoder.decode(UnredactorInfo.self, from: data) {
                print(String(data: data, encoding: .utf8)!)
                completion(unredactorInfo.unredacted_words, nil)
            } else {
                completion([""], "The app couldn't understand the server response. Contact the developer or leave a review telling us how this happened.")
            }
        } else {
            completion([""], "Couldn't get a response from the server. The server might be down or you might have a bad connection.")
        }
    }
    
    /*
    private func decodeAlamofireJSONResponse(response: AFDataResponse<Any>, completion: @escaping ([String], String?) -> Void) {
        response.
    }
 */
}
