//
//  STHttpResponse.swift
//  ScienTech
//
//  Created by 李晓宁 on 2019/4/19.
//  Copyright © 2019 李晓宁. All rights reserved.
//

import Foundation

// 分页
struct PageModel {
    
}

class STHttpResponse {
    var code: Int {
        guard let temp = json["statuscode"] as? Int else {
            return -1
        }
        return temp
    }
    
    var message: String? {
        guard let temp = json["msg"] as? String else {
            return nil
        }
        return temp
    }
    
    var jsonData: Any? {
        guard let temp = json["result"] else {
            return nil
        }
        return temp
    }
    
    let json: [String: Any]
    
    init?(data: Any) {
        guard let temp = data as? [String: Any] else {
            return nil
        }
        self.json = temp
    }
    
    func json2Data(_ object: Any) -> Data? {
        return try? JSONSerialization.data(withJSONObject: object, options: [])
    }
}

class STListResponse<T>: STHttpResponse where T: Codable {
    var dataList: [T]? {
        guard code == 200,
            let jsonData = jsonData as? [String: Any],
            let listData = jsonData["data"],
            let temp = json2Data(listData) else {
                return nil
        }
        return try? JSONDecoder().decode([T].self, from: temp)
    }
    
    var page: PageModel? {
        // PageModel的解析
        return nil
    }
}

class STModelResponse<T>: STHttpResponse where T: Codable {
    var data: T? {
        guard code == 200,
            let tempJSONData = jsonData,
            let temp = json2Data(tempJSONData)  else {
                return nil
        }
        return try? JSONDecoder().decode(T.self, from: temp)
    }
}
