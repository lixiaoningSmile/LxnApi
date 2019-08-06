//
//  Route.swift
//  ScienTech
//
//  Created by 李晓宁 on 2019/8/4.
//  Copyright © 2019 李晓宁. All rights reserved.
//

import Foundation

enum STAPIManager {
    case getMallHome(parameters:[String: Any])
    case getAllProjUser
    case uploadPictures(paramsDic:NSMutableDictionary, dataAry:NSArray)  //上传图片
}
