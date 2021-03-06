//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             Binary.m
//|
//|             D.V.
//|             Copyright (c) 2014-2015 D.V. All rights reserved.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------------//

#import "Binary.h"

//----------------------------------------------------------------------------//
@implementation Architecture

- (instancetype)initWithURL:(NSURL*)url offset:(uint32_t)offset name:(NSString*)name
{
    self = [super init];
    
    NSParameterAssert(url);
    NSParameterAssert(name);
    _name = [name lowercaseString];
    _offset = offset;
    
    NSArray* (^makeArgs)(NSArray*) = ^(NSArray *input) {
        NSMutableArray *args = [NSMutableArray array];
        [args addObject:@"-arch"];
        [args addObject:_name];
        [args addObjectsFromArray:input];
        [args addObject:url.path];
        return args;
    };
    
    // Mach Header
    {
        NSString *machHeader = [NSTask outputForLaunchedTaskWithLaunchPath:@OTOOL_PATH arguments:makeArgs(@[@"-h"])];
        _machHeader = [OtoolUtil parseMachHeader:machHeader];
    }
    
    // Load COmmands
    {
        NSString *loadCommands = [NSTask outputForLaunchedTaskWithLaunchPath:@OTOOL_PATH arguments:makeArgs(@[@"-l"])];
        _loadCommands = [OtoolUtil parseLoadCommands:loadCommands];
    }
    
    return self;
}

@end



//----------------------------------------------------------------------------//
@implementation Binary

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)binaryAtURL:(NSURL*)url
{
    static NSMutableDictionary *memo;
    if (memo == nil)
        memo = [[NSMutableDictionary alloc] init];
    
    if (memo[url] == nil)
        @autoreleasepool { memo[url] = [[self alloc] initWithURL:url]; }
    
    return memo[url];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithURL:(NSURL*)url
{
    self = [super init];
    
    _url = url;
    
    // Fat header
    {
        NSString *otoolFatHeader = [NSTask outputForLaunchedTaskWithLaunchPath:@OTOOL_PATH arguments:@[@"-f", url.path]];
        if ([otoolFatHeader rangeOfString:@"No such file or directory"].location != NSNotFound)
            return nil;
        
        _fatHeader = [OtoolUtil parseFatHeader:otoolFatHeader];
        
        NSString *otoolVerboseFatHeader = [NSTask outputForLaunchedTaskWithLaunchPath:@OTOOL_PATH arguments:@[@"-f", @"-v", url.path]];
        if ([otoolVerboseFatHeader rangeOfString:@"No such file or directory"].location != NSNotFound)
            return nil;
        
        _fatHeader_verbose = [OtoolUtil parseFatHeader:otoolVerboseFatHeader];
    }
    
    if (_fatHeader_verbose)
    {
        NSMutableArray *architectures = [[NSMutableArray alloc] init];
        
        NSDictionary *arches = _fatHeader_verbose[@"architecture"];
        for (NSString *arch in arches) {
            [architectures addObject:[[Architecture alloc] initWithURL:_url offset:(uint32_t)[[arches[arch] objectForKey:@"offset"] integerValue] name:arch]];
        }
        
        _architectures = architectures;
    }
    else
    {
        // Get the arch name
        NSString *args = [NSString stringWithFormat:@"%@ -h -v %@ | tail -n 1 | awk '{print $2}' | tr -d '\n'", @OTOOL_PATH, url.path];
        NSString *archName = [NSTask outputForLaunchedTaskWithLaunchPath:@SHELL_PATH arguments:@[@"-c", args]];
        Architecture *arch = [[Architecture alloc] initWithURL:_url offset:0 name:archName];
        _architectures = @[arch];
    }
    
    return self;
}

@end
