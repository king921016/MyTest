//
//  LayerInfo.h
//  ArcGIS test
//
//  Created by 潇 on 16/8/8.
//  Copyright © 2016年 潇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayerInfo : NSObject

@property (nonatomic, copy) NSString *points;
@property (nonatomic, copy) NSString *namet;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *fillcolor;
@property (nonatomic, copy) NSString *content;


- (NSMutableArray *)GetLayerInfoList:(NSString *)ServerLayerStr;


@end
