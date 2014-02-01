//
//  DKFileStorage.h
//  Dropkick Networking
//
//  Created by Josef Materi on 01.02.14.
//  Copyright (c) 2014 Josef Materi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKURLCache : NSObject

/**
 *  Returns a shared Cache object
 *
 *  @return DKURLCache
 */
+ (instancetype) sharedCache;

/**
 *  Checks the existance of a cache for a given NSURLRequest
 *
 *  @param request NSURLRequest
 *
 *  @return BOOL
 */

- (BOOL)hasCacheForURLRequest:(NSURLRequest *)request;

/**
 *  Creates a cache from file in a directory stored in the main bundle
 *
 *  @param directory NSString *directory
 */
- (void)deployCacheFromDirectory:(NSString *)directory;

/**
 *  Caches the response from all NSURLRequests inside the provided array and returns the paths of the cached responses in a completion block.
 *
 *  @param urlRequests NSArray *array (Array of NSURLRequests)
 *  @param complete (^)(NSArray *paths) Array of paths for cached responses
 *  @param failed NSError *error, BOOL *retryIfFailed
 */
- (void)cacheURLRequests:(NSArray *)urlRequests complete:(void (^)(NSArray *paths))complete failed:(void (^)(NSError *error, BOOL *retryIfFailed))failed;

@end
