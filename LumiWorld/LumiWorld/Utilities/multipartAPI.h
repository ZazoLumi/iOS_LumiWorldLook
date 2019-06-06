//
//  multipartAPI.h
//  LumiWorld
//
//  Created by Ashish Patel on 2018/04/18.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface multipartAPI : NSObject
-(void)callMultipartAPI:(NSDictionary *)params withCompletionBlock:(void (^)(NSDictionary *response, NSError *error))handler;
@end
