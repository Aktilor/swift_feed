//
//  XKCDFetcher.swift
//  NewsFeed
//
//  Created by Josselin Tual on 06/11/2019.
//  Copyright © 2019 Josselin Tual. All rights reserved.
//

import Foundation

class XKCDFetcher {
    private var comics : [[String:Any]] = []
    private var lock = NSLock()
    
    func getComics() -> [[String:Any]] {
        return Array(comics)
    }
    
    func getComic(_ index: Int) -> [String: Any] {
        return comics[index]
    }
    
    var count : Int {
        return comics.count
    }
    
    func getLatest(done: @escaping ()->()) {
        lock.lock()
        URLSession.shared.dataTask(with: URL(string: "https://xkcd.com/info.0.json")!, completionHandler: { data, response, error in
            if let d = data, let json = (try? JSONSerialization.jsonObject(with: d, options: [])) as? [String:Any] {
                self.comics.removeAll()
                self.comics.append(json)
            }
                self.lock.unlock()
            done()
            }).resume()
    }
    
    func get(_ index: Int, done: @escaping ([String:Any])->()) {
        URLSession.shared.dataTask(with: URL(string: "https://xkcd.com/\(index)/info.0.json")!, completionHandler: { data, response, error in
            if let d = data, let json = (try? JSONSerialization.jsonObject(with: d, options: [])) as? [String:Any] {
                done(json)
            }
            }).resume()
    }
    
    func get20more(done: @escaping ()->()) {
        if let oldest = comics.first, let index = oldest["num"] as? Int {
            var cIndex = index - 1
            while cIndex >= 0 && index - cIndex <= 20 {
                get(cIndex) { (json) in
                    self.comics.insert(json, at: 0)
                    self.lock.unlock()
                }
                cIndex -= 1
            }
        }
        done()
    }
    
    public static let monthKey = "month"
    public static let yearKey = "year"
    public static let dayKey = "day"
    public static let numKey = "num"
    public static let imgKey = "img"
    public static let titleKey = "title"
    public static let altKey = "alt"
}
