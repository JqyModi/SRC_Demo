//
//  BaseModel.swift
//  LT
//
//  Created by Modi on 2018/7/10.
//  Copyright © 2018年 Modi. All rights reserved.
//

import ObjectMapper

class BaseModel: MDBaseObject, NSCoding, Mappable {
    
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
    }
    
}
