//
//  main.m
//  Controller360
//
//  Created by Joseph Gentle on 4/04/13.
//  Copyright (c) 2013 Joseph Gentle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/usb/IOUSBLib.h>

#define PRODUCT_ID 0x028e // xbox360 controller
#define VENDOR_ID 0x045e // microsoft
#define EXPECTED_VERSION 0x0114

void pump(io_iterator_t iter) {
  io_service_t ref;
  while ((ref = IOIteratorNext(iter))) {
    NSLog(@"Gamepad connected");
  }
}

void gamepadConnected(void *unused, io_iterator_t iter) {
  NSLog(@"hi");
  pump(iter);
}

int main(int argc, const char * argv[]) {

  @autoreleasepool {
    CFMutableDictionaryRef matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    CFDictionaryAddValue(matchingDict, CFSTR(kUSBVendorID), [[NSNumber numberWithInt:VENDOR_ID] autorelease]);
    CFDictionaryAddValue(matchingDict, CFSTR(kUSBProductID), [[NSNumber numberWithInt:PRODUCT_ID] autorelease]);
    
//    IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);
    
    IONotificationPortRef port = IONotificationPortCreate(kIOMasterPortDefault);
    CFRunLoopSourceRef source = IONotificationPortGetRunLoopSource(port);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);

    //    IONotificationPortRef port = IONotificationPortCreate(CFRunLoopGetMain());
    io_iterator_t iter;
    
    IOReturn ret = IOServiceAddMatchingNotification(port, kIOFirstMatchNotification, matchingDict, gamepadConnected, NULL, &iter);
    if (ret != kIOReturnSuccess) {
      NSLog(@"error: %d", ret);
    }
    
    pump(iter);
    
    CFRunLoopRun();
  }
  return 0;
}

