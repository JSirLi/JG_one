//
//  ViewController.m
//  TestRunTime
//
//  Created by pangpangpig-Mac on 2017/4/24.
//  Copyright © 2017年 蚊子工作室. All rights reserved.
//

#import "ViewController.h"
#import <objc/objc-runtime.h>
#import <objc/runtime.h>
#import <objc/objc.h>

#import "TestRunTime-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //////////////////////////// 改变方法的实现  //////////////////////////
    // 如果 msgSend(p1,s1) 不能用 配置settings enable ... objc_msgSend Calls  ---NO
//    objc_msgSend(self, @selector(askLog));
    
    Method m1 = class_getInstanceMethod(self.class, @selector(askLog));
    Method m2 = class_getInstanceMethod(self.class, @selector(answerLog));
    
    method_exchangeImplementations(m1, m2); //交换两个方法的实现
    objc_msgSend(self, @selector(askLog));
    
    // swift 需要预编译一次
    Animal * animal= [[Animal alloc]init];
    [animal eat];
    
    
    //////////////////////////////  动态添加方法  //////////////////////////
        class_addMethod(animal.class, @selector(walk), (IMP)walk, "i@:");
    [animal performSelector:@selector(walk)];

    

//////////////////////////////////  访问成员变量  //////////////////////////
    unsigned count = 0;
    Ivar  * ivars = class_copyIvarList(animal.class, &count);
    
    for (int i = 0; i < count; i ++) {
        
        // 保护 指针指向的地址不被改变,即 s 可以指向其他地址，但是 s[1] = "s";不行
        const char * s = ivar_getName(ivars[i]);
        NSString * property = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
        NSLog(@" property = %@", property);
        //kvo 赋值
        [animal setValue:@"tomLI" forKey:property];
    }
    
/////////////////  valueForKeyPath 和 valueForKey的区别   ////////////////////////
    NSDictionary * dict = @{@"one":@"1",
                            @"two":@{@"three":@"23"}
                            };
    NSLog(@"value %@",[dict valueForKeyPath:@"two.three"]); // 可以访问到 23
    NSLog(@"value %@",[dict valueForKey:@"two.three"]);    // 访问不到 23 ，
    NSLog(@"animal name = %@", animal.name);
    
    //  c 里面的字符串定义。 cstr 是一个指针
    char * cstr = "sfg";
    char cstrs[12] = "234abc";
    NSLog(@"cstr = %s = cstrs = %s",cstr, cstrs);
 
/**
 *  _cmd在Objective-C的方法中表示当前方法的selector，正如同self表示当前方法调用的对象实例一样。
 */
    NSLog(@"_cmd %@", NSStringFromSelector(_cmd));
    
    
/////////////////  动态添加属性  ////////////////////////
    self.testName = @"这是动态添加的属性";
    NSLog(@"testName = %@", self.testName);
    
}

void walk(id self, SEL _cmd){
    NSLog(@"给动物类添加走路的方法!!");
}

void add(id self, SEL _cmd){
    NSLog(@"这是动态添加方法！");
}


- (void)askLog
{
    NSLog(@"我是谁！！！");
}
- (void)answerLog
{
    NSLog(@"我是你大爷");
}


static char const * testNameKey = "testNameKey";
- (void)setTestName:(NSString*)name
{
    /*
     OBJC_ASSOCIATION_ASSIGN;            //assign策略
     OBJC_ASSOCIATION_COPY_NONATOMIC;    //copy策略
     OBJC_ASSOCIATION_RETAIN_NONATOMIC;  // retain策略
     
     OBJC_ASSOCIATION_RETAIN;
     OBJC_ASSOCIATION_COPY;
     */
    /*
     * id object 给哪个对象的属性赋值
     const void *key 属性对应的key
     id value  设置属性值为value
     objc_AssociationPolicy policy  使用的策略，是一个枚举值，和copy，retain，assign是一样的，手机开发一般都选择NONATOMIC
     objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
     */
    objc_setAssociatedObject(self, testNameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*)testName
{
    return (NSString*)objc_getAssociatedObject(self, testNameKey);
}


// 今天来揭开 神秘的Runtime 机制的面纱。希望不局限于会，最重要的是 会用！！！！



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
