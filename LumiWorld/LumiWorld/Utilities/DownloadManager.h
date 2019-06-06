//
//  DownloadManager.h
//  LumiWorld
//
//  Created by Ashish Patel on 2018/05/02.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//
#import <Foundation/Foundation.h>
typedef void (^fileDownloadCompletionBlock)(int fileId, NSURL *url);

@interface FileDownloadInfo : NSObject

@property (nonatomic) int fileId;

@property (nonatomic, strong) NSString *downloadSource;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) NSData *taskResumeData;

@property (nonatomic) double downloadProgress;

@property (nonatomic) BOOL isDownloading;

@property (nonatomic) BOOL downloadComplete;

@property (nonatomic) unsigned long taskIdentifier;

@property (nonatomic, copy) fileDownloadCompletionBlock progressHandler;

-(id)initWithFileTitle:(int)nfileId andDownloadSource:(NSString *)source;

@end

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject <NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSURL *docDirectoryURL;
@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;

-(void)initDownloadManagerData;
- (void)startFileDownloads:(FileDownloadInfo *)fdi withCompletionBlock:(void (^)(int fileId, NSURL *url))handler;
+ (instancetype)sharedManager;
-(void)cancelAllPendingDownloadTask;
@end
