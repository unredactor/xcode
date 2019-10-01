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

// I'm going to make this a singleton because there should only be one unredactor and it doesn't carry info between things, it only performs functions
class Unredactor {
    static var maskToken: String = "unk"
    
    func unredact(_ redactedText: ClassifiedText, completion: @escaping (ClassifiedText) -> Void) {
        // Implement by accessing the website API
        
        // Get array of words that are unredacted back:
        var unredactedWords: [String] = [] // Placeholder for now
        
        // Create a copy of redactedText
        let unredactedText: ClassifiedText = redactedText.copy() as! ClassifiedText
        
        let redactedWords = unredactedText.words.filter { $0.redactionState == .redacted }
        
        // Placeholder definition of unredactedWords - get from API
        //unredactedWords = Array(repeating: "prediction", count: redactedWords.count)// TODO: Replace with accessing the API and stuff]
        
        getUnredactedWords(fromText: unredactedText.urlText, withRequestType: .get) { (words) in
            
            unredactedWords = words
            
            // Unredact all the redacted words
            for (index, redactedWord) in redactedWords.enumerated() {
                redactedWord.lastRedactionState = redactedWord.redactionState
                redactedWord.redactionState = .unredacted
                print("redactedWord: \(redactedWord.string)")
                
                let unredactedWord = unredactedWords[safeIndex: UInt(index)] ?? "Not enough unredacted words were returned from getUnredactedWords()"
                
                redactedWord.unredactorPrediction = unredactedWord
            }
            
            completion(unredactedText)
        }
    }
    
    private enum RequestType {
        case get, post
    }
    
    private func getUnredactedWords(fromText text: String, withRequestType requestType: RequestType, completion: @escaping (([String]) -> Void)) {
        
        var task: URLSessionDataTask
        
        if requestType == .get {
            let urlString = "https://unredactor.com/api/unredact_bert?text=" + text
            print("URLSTRING: \(urlString)")
            let baseURL = URL(string: urlString)!
            
            task = URLSession.shared.dataTask(with: baseURL) { (data, response, error) in
                self.handleServerResponse(data: data, response: response, error: error, completion: { (unredactedWords) in
                    completion(unredactedWords)
                })
            }
        } else { // requestType = .post
            //from: https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method (accepted answer)
            let url = URL(string: "https://unredactor.com/unredactor")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let parameters: [String: Any] = [
                "text": text,
            ]
            request.httpBody = parameters.percentEscaped().data(using: .utf8)
            
            task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil else {                                              // check for fundamental networking error
                        print("error", error ?? "Unknown error")
                        return
                }
                
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    return
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
            }
            
        }
        
        // Start the task
        task.resume()
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
    
    private func handleServerResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping ([String]) -> Void) {
        let jsonDecoder = JSONDecoder()
        
        if let response = response {
            print("RESPONSE: \(response)")
        }
        
        if let error = error {
            print("ERROR: \(error)")
        }
        
        if let data = data {
            if let unredactorInfo = try? jsonDecoder.decode(UnredactorInfo.self, from:data) {
                
                completion(unredactorInfo.unredacted_words)
                print(String(data: data, encoding: .utf8)!)
            } else {
                completion(["getUnredactedWords() failed; couldn't properly parse JSON response."])
            }
        } else {
            completion(["getUnredactedWords() failed; couldn't get JSON response from server"])
        }
    }
}
