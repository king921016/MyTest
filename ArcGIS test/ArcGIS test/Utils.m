//
//  Utils.m
//  ArcGIS test
//
//  Created by 潇 on 16/8/8.
//  Copyright © 2016年 潇. All rights reserved.
//

#import "Utils.h"

NSString *const WEB_HEAD = @"http://192.168.0.28:8042/";//8037

NSString *const WEBSERVICE_HEAD =@"http://59.175.177.180:6006";// @"http://59.175.177.179:6006/";
//NSString *const WEBSERVICE_HEAD =@"http://192.168.0.28:8035";
//NSString *const WEBSERVICE_HEAD =@"http://192.168.0.212:8085";
NSString *const HTTP_LOGIN_URL = @"<web>webui/app/applogin.aspx?u=<loginname>&p=<pwd>";
NSString *const HTTP_MAP_XML_URL = @"<web>WebUI/App/ArcGisMapPackage/iphone/LocalMap.xml";

NSString *u_mymmsi = @"";       ////船舶九位码
NSString *u_myshipname = @"";   ////船舶名称
NSString *u_searchMmsi=@"";     ////查询船舶九位码
NSString *u_mycbbh = @"";       ////船舶编号

CGFloat u_phonewidth = 0;
CGFloat u_phoneheight= 0;

@implementation Utils

-(void)initData{
    
    u_phonewidth = [UIScreen mainScreen].bounds.size.width;
    u_phoneheight= [UIScreen mainScreen].bounds.size.height;
}
@end
