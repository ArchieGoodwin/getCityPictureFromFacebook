//
//  DKAHelper.h
//  Reccit2
//
//  Created by Nero Wolfe on 25/01/14.
//  Copyright (c) 2014 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DKA_FACEBOOK_PAGE_PICTURE @"http://graph.facebook.com/%@/picture?height=300"

typedef void (^RCCompleteBlockWithResult)  (BOOL result, NSError *error);

@interface DKAHelper : NSObject <NSURLSessionDelegate>

@property (nonatomic, strong) NSCache *imagesCache;

@end
