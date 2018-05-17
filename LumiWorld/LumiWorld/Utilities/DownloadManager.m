//
//  DownloadManager.m
//  LumiWorld
//
//  Created by Ashish Patel on 2018/05/02.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//
#import "DownloadManager.h"
#import "LumiWorld-Swift.h" // You have to replace with your swift module name

@implementation FileDownloadInfo

-(id)initWithFileTitle:(int)nfileId andDownloadSource:(NSString *)source{
    if (self == [super init]) {
        self.fileId = nfileId;
        self.downloadSource = source;
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.downloadComplete = NO;
        self.taskIdentifier = -1;
    }
    return self;
}

@end


@implementation DownloadManager

+ (instancetype)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initDownloadManagerData];
    });
    return instance;
}



-(void)initDownloadManagerData {
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    self.docDirectoryURL = [URLs objectAtIndex:0];
    NSURL *dbDirectoryURL = [self.docDirectoryURL URLByAppendingPathComponent:@"Docs"];
    NSError *error = nil;
    if (![NSFileManager.defaultManager fileExistsAtPath:dbDirectoryURL.path]) {
        [NSFileManager.defaultManager createDirectoryAtPath:dbDirectoryURL.path withIntermediateDirectories:false attributes:nil error:&error];
    }
    self.docDirectoryURL = dbDirectoryURL;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.BGTransferDemo"];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
    
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    self.arrFileDownloadData = [[NSMutableArray alloc] init];
    
}
- (void)startFileDownloads:(FileDownloadInfo *)fdi withCompletionBlock:(void (^)(int fileId, NSURL *url))handler {
    // Access all FileDownloadInfo objects using a loop.
        // Check if a file is already being downloaded or not.
        if (!fdi.isDownloading) {
            // Check if should create a new download task using a URL, or using resume data.
            if (fdi.taskIdentifier == -1) {
                fdi.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource]];
            }
            else{
                fdi.downloadTask = [self.session downloadTaskWithResumeData:fdi.taskResumeData];
            }
            
            // Keep the new taskIdentifier.
            fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
            
            // Start the download.
            [fdi.downloadTask resume];
            
            // Indicate for each file that is being downloaded.
            fdi.isDownloading = YES;
            fdi.progressHandler = handler;
            [self.arrFileDownloadData addObject:fdi];
        }
}

-(void)cancelAllPendingDownloadTask {
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        [fdi.downloadTask suspend];
    }
    [self.arrFileDownloadData removeAllObjects];
    [self.session  getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if (!dataTasks || !dataTasks.count) {
            return;
        }
        for (NSURLSessionTask *task in dataTasks) {
            [task cancel];
        }
        for (NSURLSessionTask *task in downloadTasks) {
            [task cancel];
        }

    }];

}

#pragma mark - NSURLSession Delegate method implementation
    
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    if (self.arrFileDownloadData ==nil || self.arrFileDownloadData.count ==0) {
        return;
    }
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *destinationFilename = downloadTask.originalRequest.URL.lastPathComponent;
        NSURL *destinationURL = [self.docDirectoryURL URLByAppendingPathComponent:destinationFilename];
    
        if ([fileManager fileExistsAtPath:[destinationURL path]]) {
            [fileManager removeItemAtURL:destinationURL error:nil];
        }
        
        BOOL success = [fileManager copyItemAtURL:location
                                            toURL:destinationURL
                                            error:&error];
        
        if (success) {
            // Change the flag values of the respective FileDownloadInfo object.
            int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
            FileDownloadInfo *objfdi = [self.arrFileDownloadData objectAtIndex:index];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // Reload the respective table view row using the main thread.
            }];
            objfdi.progressHandler(objfdi.fileId,destinationURL);

            objfdi.isDownloading = NO;
            objfdi.downloadComplete = YES;
            
            // Set the initial value to the taskIdentifier property of the fdi object,
            // so when the start button gets tapped again to start over the file download.
            objfdi.taskIdentifier = -1;
            
            // In case there is any resume data stored in the fdi object, just make it nil.
            objfdi.taskResumeData = nil;
            [self.arrFileDownloadData removeObjectAtIndex:index];
            
        }
        else{
            NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
        }
    }

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error != nil) {
        NSLog(@"Download completed with error: %@", [error localizedDescription]);
    }
    else{
        NSLog(@"Download finished successfully.");
    }
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown transfer size");
    }
    else{
        // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
//        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            // Calculate the progress.
//            fdi.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
//
//            // Get the progress view of the appropriate cell and update its progress.
//        }];
    }
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
    // Check if all download tasks have been finished.

    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if ([downloadTasks count] == 0) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // Call the completion handler to tell the system that there are no other background transfers.
                
                // Show a local notification when all downloads are over.
            }];
        }
    }];
}

-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier{
    int index = 0;
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        if (fdi.taskIdentifier == taskIdentifier) {
            index = i;
            break;
        }
    }
    
    return index;
}


@end
