//
//  GetDocumentsDirectory.m
//  Slackers
//
//  Created by mahboud on 6/18/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "GetDocumentsDirectory.h"

NSString *GetDocumentsDirectory(void) {
  NSArray <NSString *>*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths firstObject];
}


