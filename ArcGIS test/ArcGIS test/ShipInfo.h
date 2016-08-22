//
//  ShipInfo.h
//  ArcGIS test
//
//  Created by 潇 on 16/8/8.
//  Copyright © 2016年 潇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShipInfo : NSObject

@property (nonatomic, copy) NSString *mmsi;
@property (nonatomic, copy) NSString *lon;
@property (nonatomic, copy) NSString *lat;
@property (nonatomic, copy) NSString *speed;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *systime;
@property (nonatomic, copy) NSString *zwcm;
@property (nonatomic, copy) NSString *cbcd;
@property (nonatomic, copy) NSString *cbxk;
@property (nonatomic, copy) NSString *lc;

//single 一个
//经过经纬度查询周围的船舶
- (NSString *)GetServerShipInfoStr:(NSString *)mmsi Lon:(NSString *)lon Lat:(NSString *)lat Diff:(NSString *)diff;

//经过船舶定位搜索查询周围的船舶
- (NSString *)GetServerShipStrDw:(NSString *)mmsi Lookmmsi:(NSString *)lmmsi Diff:(NSString *)diff Flag:(NSString *)flag;

//处理服务器返回的字符串，解析成实体集合
- (NSMutableArray *)GetShipInfoList:(NSString *)ServerShipStr;

//把单个船舶字符串处理成船舶实体类
- (ShipInfo *)GetSingleShipByStr:(NSString *)singleShipStr;

//获取绑定船舶预警信息
- (NSString *)GetWarningStr:(NSString *)mmsi Lon:(NSString *)lon Lat:(NSString *)lat Metre:(NSString *)metre Lastlon:(NSString *)lastlon Lastlat:(NSString *)lastlat;

//船舶搜索定位
- (NSString *)GetSearchList:(NSString *)searchKey;

//经过经纬度查询图层
- (NSString *)GetServerLayerListStr:(NSString *)lon Lat:(NSString *)lat Diff:(NSString *)diff;

//经过mmsi查询船舶信息
- (ShipInfo *)GetShipInfoByMmsi:(NSString *)mmsi;

@end
