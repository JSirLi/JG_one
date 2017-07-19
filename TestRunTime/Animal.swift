//
//  Animal.swift
//  TestRunTime
//
//  Created by pangpangpig-Mac on 2017/4/24.
//  Copyright © 2017年 蚊子工作室. All rights reserved.
//

import UIKit

class Animal: NSObject {

    var name : String? = nil;
    
    open func eat(){
        NSLog("我在吃东西！")
    }
    
}
