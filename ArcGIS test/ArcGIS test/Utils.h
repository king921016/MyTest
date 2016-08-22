//
//  Utils.h
//  ArcGIS test
//
//  Created by 潇 on 16/8/8.
//  Copyright © 2016年 潇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

//加了 extern 该变量就可以全局访问了
//web 头部
extern NSString *const WEB_HEAD;

//webService 头部
extern NSString *const WEBSERVICE_HEAD;

//URL
extern NSString *const HTTP_LOGIN_URL;//登录的 url
extern NSString *const HTTP_MAP_XML_URL; //地图配置文件 url


extern NSString *u_mymmsi;      ////船舶九位码
extern NSString *u_searchMmsi;//查询船舶九位码
extern NSString *u_mycbbh;      ////船舶编号


extern CGFloat u_phonewidth;
extern CGFloat u_phoneheight;

- (void)initData;

@end
