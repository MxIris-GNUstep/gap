/*
 Project: DataBasin
 DBSobject.h
 
 Copyright (C) 2010 Free Software Foundation
 
 Author: Riccardo Mottola
 
 Created by Riccardo Mottola on 20/07/10.
 
 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.
 
 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
 */


#import "DBSObject.h"


@implementation DBSObject

+ (NSString *)idTo18: (NSString *) id15
{
  NSMutableString *suffix;
  int i;
  int j;
  
  if ([id15 length] != 15)
    return nil;
  
  suffix = [NSMutableString stringWithCapacity: 3];
  for (i = 0; i < 3; i++)
    {
      int flags = 0;
      for (j = 0; j < 5; j++)
        {
          unichar c;
          c = [id15 characterAtIndex: i * 5 + j];
          if (c >= 'A' && c <= 'Z')
            flags += 1 << j;
        }
      if (flags <= 25)
        [suffix appendString: [@"ABCDEFGHIJKLMNOPQRSTUVWXYZ" substringWithRange: NSMakeRange(flags, 1)]];
      else
        [suffix appendString: [@"012345" substringWithRange: NSMakeRange(flags-26, 1)]];
    }
  return [id15 stringByAppendingString: suffix];  
}

- (id)init
{
  if ((self = [super init]))
    {
      fieldNames = [[NSMutableArray arrayWithCapacity: 1] retain];
      fieldProperties = [[NSMutableDictionary dictionaryWithCapacity: 1] retain];
      recordValues = [[NSMutableDictionary dictionaryWithCapacity: 1] retain];
    }
  return self;
}

- (void)dealloc
{
  [fieldNames release];
  [fieldProperties release];
  [recordValues release];
  [super dealloc];
}

- (NSString *)sfId
{
  return [recordValues objectForKey: @"Id"];
}

- (NSString *)sfId15
{
  NSString *sfid;
  
  sfid = [recordValues objectForKey: @"Id"];
  if ([sfid length] == 18)
    sfid = [sfid substringToIndex: 15];
  
  if ([sfid length] != 15)
    {
      NSLog(@"Invalid ID: %@", sfid);
      return nil;
    }
  
  return sfid;
}

- (NSString *)sfId18
{
  NSString *sfid;
  
  sfid = [recordValues objectForKey: @"Id"];
  if ([sfid length] == 15)
    sfid = [DBSObject idTo18: sfid];
  
  if ([sfid length] != 18)
    {
      NSLog(@"Invalid ID: %@", sfid);
      return nil;
    }
  
  return sfid;
}

- (void)setProperties: (NSDictionary *)properties forField: (NSString *)field
{
  // TODO should check if field is not already present
  [fieldNames addObject: field];
  [fieldProperties setObject: properties forKey: field];
}

- (NSDictionary *)propertiesOfField: (NSString *)field
{
  return [fieldProperties objectForKey: field];
}

- (NSArray *)fieldNames
{
  return fieldNames;
}

- (NSString *)fieldValue: (NSString *)field
{
  return [recordValues objectForKey: field];
}

@end