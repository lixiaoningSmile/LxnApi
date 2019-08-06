//
//  STClientAPI.swift
//  ScienTech
//
//  Created by 李晓宁 on 2019/3/18.
//  Copyright © 2019 李晓宁. All rights reserved.
//

import Foundation
import Moya

let STClientAPI = MoyaProvider<STAPIManager>()

/// 超时时长
private var requestTimeOut: Double = 30

let headerFields: [String: String] = [
    "platform": "iOS",
    "sys_ver": String(UIDevice.version())
]

let appendedParams: [String: Any] = [
    "uid": "123456" as AnyObject
]

///endpointClosure
private let myEndpointClosure = { (target: STAPIManager) -> Endpoint in
    print("请求连接：\(target.baseURL)\(target.path) \n方法：\(target.method)\n参数：\(String(describing: target.task)) ")
    ///主要是为了解决URL带有？无法请求正确的链接地址的bug
    let url = target.baseURL.absoluteString + target.path
    var endpoint = Endpoint(
        url: url,
        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
        method: target.method,
        task: target.task,
        httpHeaderFields: target.headers
    ).adding(newHTTPHeaderFields: headerFields)
    switch target {
    case .getMallHome:
        requestTimeOut = 5//按照项目需求针对单个API设置不同的超时时长
        return endpoint
    default:
        requestTimeOut = 30//设置默认的超时时长
        return endpoint
    }
}

struct Network {
    static let provider = MoyaProvider<STAPIManager>(endpointClosure: myEndpointClosure)
    static func request(_ target: STAPIManager, successCallback: @escaping ([String: Any]) -> Void,
                        failure failureCallback: @escaping (String) -> Void) {
        provider.request(target) { (result) in
            
            switch result {
            case let .success(response):
                if let json = try? response.mapJSON() as! [String: Any] {
                    successCallback(json)
                } else {
                    print("服务器连接成功,数据获取失败")
                }
            case let .failure(error):
                failureCallback(error.errorDescription!)
            }
        }
    }
    // MARK: - 取消所有网络请求
    static func cancelAllRequest() {
        provider.manager.session.getAllTasks { (tasks) in
            tasks.forEach {
                print("取消网络请求一次")
                $0.cancel()
            }
        }
    }
}

protocol MoyaAddable {
    var cacheKey: String? { get }
    var isShowHud: Bool { get }
}

extension STAPIManager: TargetType, MoyaAddable {
    var baseURL: URL {
        return URL(string: "T##String")!
    }
    
    var path: String {
        switch self {
        case .getMallHome:
            return "Login"
        default:
            return ""
        }
    }
    //请求方式
    var method: Moya.Method {
        return .post
    }
    //这个就是做单元测试模拟的数据，只会在单元测试文件中有作用
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var getPartmeters: [String: Any] {
        switch self {
        case let .getMallHome(dict):
            return dict
        case .getAllProjUser:
            return [:]
        default:
            return [:]
        }
    }
    //请求任务事件，带上参数
    var task: Task {
        switch self {
        case .uploadPictures(paramsDic:let paramsDic, dataAry:let dataAry):
            let formDataAry: NSMutableArray = NSMutableArray()
            for (index, image) in dataAry.enumerated() {
                //图片转成Data
                let data: Data = (image as! UIImage).jpegData(compressionQuality: 0.9)!
                //根据当前时间设置图片上传时候的名字
                let date: Date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
                var dateStr: String = formatter.string(from: date as Date)
                //别忘记这里给名字加上图片的后缀哦
                dateStr = dateStr.appendingFormat("-%i.png", index)
                
                let formData = MultipartFormData(provider: .data(data), name: "file", fileName: dateStr, mimeType: "image/jpeg")
                formDataAry.add(formData)
            }
            return .uploadCompositeMultipart(formDataAry as! [MultipartFormData], urlParameters: paramsDic as! [String: Any])
        default:
            return .requestParameters(parameters: getPartmeters, encoding: JSONEncoding.default)
        }
    }
    //请求头
    var headers: [String: String]? {
        return nil
    }
    
    //验证方式
    var validationType: ValidationType {
        return .none
    }
    
    var cacheKey: String? {
        return nil
    }
    
    var isShowHud: Bool {
        return false
    }
}
