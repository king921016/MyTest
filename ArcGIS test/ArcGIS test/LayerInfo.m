//
//  LayerInfo.m
//  ArcGIS test
//
//  Created by 潇 on 16/8/8.
//  Copyright © 2016年 潇. All rights reserved.
//

#import "LayerInfo.h"
#import "ShipInfo.h"

@implementation LayerInfo

//处理服务器返回的字符串，解析成实体集合
- (NSMutableArray *)GetLayerInfoList:(NSString *)ServerLayerStr {

    NSMutableArray *arrayList = [NSMutableArray arrayWithCapacity:0];
    NSString *shipStr = ServerLayerStr;
    
    if (shipStr.length > 1 & [shipStr rangeOfString:@"|"].location != NSNotFound) {
        shipStr = [shipStr stringByReplacingOccurrencesOfString:@"|</string>" withString:@""];
        shipStr = [shipStr substringFromIndex:[shipStr rangeOfString:@"org"].location + 6];
        
        LayerInfo *layerinfo = [LayerInfo alloc];
        NSArray *array = [shipStr componentsSeparatedByString:@"|"];
        
        for (int i = 0; i < array.count; i++) {
            layerinfo = [self GetSingleLayerByStr:array[i]];
            [arrayList addObject:layerinfo];
        }
    }
    return  arrayList;
}

//把单个图层字符串处理成实体类
- (LayerInfo *)GetSingleLayerByStr:(NSString *)singleLayerStr {

    LayerInfo *layer = [LayerInfo alloc];
    if (singleLayerStr.length < 1) {
        return layer;
    }
    NSArray *array = [singleLayerStr componentsSeparatedByString:@";"];
    if (array.count == 5) {
        layer.type = array[0];
        layer.points = array[1];
        layer.fillcolor = array[2];
        layer.content = array[3];
        layer.namet = array[4];
    }
    return layer;
}


@end
