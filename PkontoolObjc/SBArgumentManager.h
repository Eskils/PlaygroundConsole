//
//  SBArgumentManager.h
//  PkontoolObjc
//
//  Created by Eskil Sviggum on 17/10/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBArgumentManager : NSObject

- (void)registerHandlerForArgument:(NSString*)argument handler:(SEL)handler;
- (void)registerHelpHandler:(SEL)handler;
- (void)runHandlerForArguments:(int)argc argv:(const char *_Nullable*_Nullable)argv target:(NSObject*)target;
    
@end

NS_ASSUME_NONNULL_END
