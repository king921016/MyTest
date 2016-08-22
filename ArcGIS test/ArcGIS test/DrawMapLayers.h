//
//  DrawMapLayers.h
//  ArcGIS test
//
//  Created by 潇 on 16/8/5.
//  Copyright © 2016年 潇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import <ArcGIS/ArcGIS.h>

@interface DrawMapLayers : NSObject

- (void)initload:(AGSMapView *)mView;
- (void)DrawPolygonLayer;   //画多边形图层
- (void)startThread;    //开始分线程
- (void)stopThread;     //结束分线程
- (void)startDrawLayer:(NSString *)lon lat:(NSString *)lat diff:(NSString *)diff;   //开始画船的位置
@end
