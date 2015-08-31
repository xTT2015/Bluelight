//
//  Commom.h
//  SmartLight
//
//  Created by BDE on 3/28/15.
//  Copyright (c) 2015 BDE. All rights reserved.
//

#ifndef SmartLight_Commom_h
#define SmartLight_Commom_h

#define LIB_VERSION @"1.01"
#define NSStringFromPropery(propety) NSStringFromSelector(@selector(propety))


inline dispatch_queue_t global_queue(void)
{
  return  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}
#endif

