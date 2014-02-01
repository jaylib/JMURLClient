//
//  DKFileStorage.m
//  Dropkick Networking
//
//  Created by Josef Materi on 01.02.14.
//  Copyright (c) 2014 Josef Materi. All rights reserved.
//

#import "DKURLCache.h"
#import <AFNetworking.h>
#import "RNCachingURLProtocol.h"

static NSString *const fileStorageRoot = @"http://www.i-pol.com/dropkick/";

@interface DKURLCache()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpRequestOperationManager;
@end

@implementation DKURLCache

#pragma mark -
#pragma mark Singleton.

+ (instancetype) sharedCache {
    
    static dispatch_once_t once;
    static DKURLCache *singleton;
    
    dispatch_once(&once, ^ {
        singleton = [[DKURLCache alloc] init];
    });
    
    return singleton;
}

#pragma mark - Designated Initializer

- (instancetype)init {
    if ([super init]) {
        self.httpRequestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:fileStorageRoot]];
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

#pragma mark - Query Cache

- (BOOL)hasCacheForURLRequest:(NSURLRequest *)request {
    NSString *cachePathForRequest = [RNCachingURLProtocol cachePathForRequest:request];
    return [[NSFileManager defaultManager] fileExistsAtPath:cachePathForRequest];
}

#pragma mark - Create cache from Bundle Content

- (void)deployCacheFromDirectory:(NSString *)directory {
    
    NSString *cacheDirectory = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], directory];
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:cacheDirectory error:&error];
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSError *error = nil;
        
        NSString *fileInDirectory = [[NSBundle mainBundle] pathForResource:obj ofType:@"" inDirectory:directory];
        
        NSString *destinationPath  = [cachesPath stringByAppendingPathComponent:obj];
        
        BOOL fileAlreadyExists = [[NSFileManager defaultManager] fileExistsAtPath:destinationPath];
        
        if (!fileAlreadyExists) {
            [[NSFileManager defaultManager] copyItemAtPath:fileInDirectory
                                                    toPath:destinationPath
                                                     error:&error];        
        }
        
    }];

}

#pragma mark - Cache NSURLRequests

- (void)cacheURLRequests:(NSArray *)urlRequests complete:(void (^)(NSArray *paths))complete failed:(void (^)(NSError *error, BOOL *retryIfFailed))failed {

    NSMutableArray *requestOperations = [NSMutableArray array];
    
    [urlRequests enumerateObjectsUsingBlock:^(NSURLRequest *request, NSUInteger idx, BOOL *stop) {
        AFURLConnectionOperation *urlConnectionOperation = [[AFURLConnectionOperation alloc] initWithRequest:request];
        [requestOperations addObject:urlConnectionOperation];
    }];
    
    NSMutableArray *failedRequests = [NSMutableArray array];
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:requestOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
    
    } completionBlock:^(NSArray *operations) {
            
       [operations enumerateObjectsUsingBlock:^(AFHTTPRequestOperation *obj, NSUInteger idx, BOOL *stop) {
       
           NSURLRequest *request = obj.request;
           NSHTTPURLResponse *response = obj.response;
           
           dispatch_async(dispatch_get_main_queue(), ^{
               if (!response.statusCode != 200) {
                   [failedRequests addObject:request];
               }
           });
           
       }];
     
       if ([failedRequests count] > 0) {
           
           BOOL retryIfFailed = NO;
           
           if (failed) failed([[failedRequests objectAtIndex:0] error], &retryIfFailed);
           
           if (retryIfFailed) {
               [self cacheURLRequests:urlRequests complete:complete failed:failed];
           }
           
       } else {
           if (complete) complete([self cachePathsForRequests:urlRequests]);
       }
        
    }];
    
    [self.operationQueue addOperations:operations waitUntilFinished:NO];
}

- (NSArray *)cachePathsForRequests:(NSArray *)requests {
    NSMutableArray *array = [NSMutableArray array];
    [requests enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:[RNCachingURLProtocol cachePathForRequest:obj]];
    }];
    return array;
}

#pragma mark - Convenience Methods for filename based requests

- (void)cacheRequestsForFilenames:(NSArray *)filenames withBaseURL:(NSURL *)baseURL complete:(void (^)(NSArray *paths))complete failed:(void (^)(NSError *error, BOOL *retryIfFailed))failed {
    NSArray *requestsForFileNames = [self requestForFilenames:filenames withBaseURL:baseURL];
    [self cacheURLRequests:requestsForFileNames complete:complete failed:failed];
}

- (NSArray *)requestForFilenames:(NSArray *)filenames withBaseURL:(NSURL *)baseURL {
    NSMutableArray *requests = [NSMutableArray array];
    [filenames enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
        NSURLRequest *request = [self requestForFilename:filename withBaseURL:baseURL];
        [requests addObject:request];
    }];
    return requests;
}

- (NSURLRequest *)requestForFilename:(NSString *)filename withBaseURL:(NSURL *)baseURL{
    return [NSURLRequest requestWithURL:[NSURL URLWithString:filename relativeToURL:baseURL]];
}


@end
