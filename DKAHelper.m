//
//  DKAHelper.m
//  Reccit2
//
//  Created by Nero Wolfe on 25/01/14.
//  Copyright (c) 2014 Sergey Dikarev. All rights reserved.
//

#import "DKAHelper.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation DKAHelper


-(void)getCityPictureByCityName:(NSString *)city state:(NSString *)state country:(NSString *)country imgView:(UIImageView *)imgView completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    NSString *nameHash = [NSString stringWithFormat:@"%lu",(unsigned long)[city hash]];
    UIImage *cacheImage =  [self.imagesCache objectForKey:nameHash];
    if(!cacheImage)
    {
        
        NSDictionary *states  = @{@"AL":@"Alabama",@"AK":@"Alaska",@"AZ":@"Arizona",@"AR":@"Arkansas",@"CA":@"California",@"CO":@"Colorado",@"CT":@"Connecticut",@"DE":@"Delaware",@"FL":@"Florida",@"GA":@"Georgia",@"HI":@"Hawaii",@"ID":@"Idaho",@"IL":@"Illinois", @"IN":@"Indiana", @"IA":@"Iowa", @"KS":@"Kansas",@"KY":@"Kentucky",@"LA":@"Louisiana",@"ME":@"Maine",@"MD":@"Maryland", @"MA":@"Massachusetts",@"MI":@"Michigan",@"MN":@"Minnesota",@"MS":@"Mississippi",@"MO":@"Missouri",@"MT":@"Montana",@"NE":@"Nebraska",@"NV":@"Nevada",@"NH":@"New Hampshire",@"NJ":@"New Jersey",@"NM":@"New Mexico",@"NY":@"New York",@"NC":@"North Carolina",@"ND":@"North Dakota",@"OH":@"Ohio",@"OK":@"Oklahoma", @"OR":@"Oregon",@"PA":@"Pennsylvania",@"RI":@"Rhode Island",@"SC":@"South Carolina",@"SD":@"South Dakota",@"TN":@"Tennessee",@"TX":@"Texas",@"UT":@"Utah",@"VT":@"Vermont",@"VA":@"Virginia",@"WA":@"Washington",@"DC":@"Washington D.C.",@"WV":@"West Virginia",@"WI":@"Wisconsin",@"WY":@"Wyoming"};
        
        NSString *cityString = @"";
        
        if(state)
        {
            cityString = [NSString stringWithFormat:@"%@, %@", city, [states objectForKey:state]];
        }
        else
        {
            cityString = [NSString stringWithFormat:@"%@, %@", city, country];
        }
        
        NSString *query = [NSString stringWithFormat:@"SELECT name,page_id,name,description,type,location FROM page WHERE type=\"CITY\" and name=\"%@\"", cityString];
        
        NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
        // Make the API request that uses FQL
        FBRequest *postRequest = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
        postRequest.session = FBSession.activeSession;
        [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(!error)
            {
                NSLog(@"getCityPictureByCityName result: %@", [result objectForKey:@"data"]);
                if(((NSArray *)[result objectForKey:@"data"]).count > 0)
                {
                    NSArray *arr = ((NSArray *)[result objectForKey:@"data"]);
                    
                    NSString *pageId = [NSString stringWithFormat:@"%@",[arr[0] objectForKey:@"page_id"]];
                    
                    
                    NSLog(@"facebook id %@", pageId);
                    if(pageId && ![pageId isEqualToString:@"0"] && ![pageId isEqualToString:@"-1"])
                    {
                        NSString *url2check = [NSString stringWithFormat:DKA_FACEBOOK_PAGE_PICTURE, pageId];
                        
                        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
                        sessionConfig.timeoutIntervalForRequest = 30.0;
                        sessionConfig.timeoutIntervalForResource = 30.0;
                        sessionConfig.HTTPMaximumConnectionsPerHost = 15;
                        
                        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
                        
                        NSURLSessionDownloadTask *getImageTask =
                        [session downloadTaskWithURL:[NSURL URLWithString:url2check]
                                        completionHandler:^(NSURL *location, NSURLResponse *response,
                                                            NSError *error) {
                                            if(!error)
                                            {
                                                UIImage *downloadedImage = [UIImage imageWithData:
                                                                            [NSData dataWithContentsOfURL:location]];
                                                
                                                NSLog(@"url2check %@", url2check);
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if(downloadedImage)
                                                    {
                                                        NSLog(@"url2check 2 %@  %@", city, nameHash);
                                                        
                                                        [self.imagesCache setObject:downloadedImage forKey:nameHash];
                                                        imgView.image = downloadedImage;
                                                        
                                                    }
                                                    else
                                                    {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self.imagesCache setObject:[UIImage imageNamed:@"img_city_default"] forKey:nameHash];
                                                            imgView.image = [UIImage imageNamed:@"img_city_default"];
                                                            
                                                        });                                                    }
                                                    
                                                });
                                            }
                                            else
                                            {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self.imagesCache setObject:[UIImage imageNamed:@"img_city_default"] forKey:nameHash];
                                                    imgView.image = [UIImage imageNamed:@"img_city_default"];
                                                    
                                                });
                                                
                                                
                                                NSLog(@"error for place image %@", error.localizedDescription);
                                            }
                                            
                                        }];
                        
                        [getImageTask resume];
                        
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.imagesCache setObject:[UIImage imageNamed:@"img_city_default"] forKey:nameHash];
                            imgView.image = [UIImage imageNamed:@"img_city_default"];
                            
                        });
                    }
                    
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.imagesCache setObject:[UIImage imageNamed:@"img_city_default"] forKey:nameHash];
                        imgView.image = [UIImage imageNamed:@"img_city_default"];
                        
                    });
                    
                }
                
            }
            else
            {
                
                NSLog(@"error: %@", [error description]);
                
            }
        }];
        
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            imgView.image = cacheImage;
            
            
        });
        
    }
    
    
}

@end
