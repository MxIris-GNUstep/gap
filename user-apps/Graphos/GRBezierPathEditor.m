/*
 Project: Graphos
 GRBezierPathEditor.m

 Copyright (C) 2000-2013 GNUstep Application Project

 Author: Enrico Sersale (original GDRaw implementation)
 Author: Ing. Riccardo Mottola

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
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "GRBezierPathEditor.h"
#import "GRDocView.h"
#import "GRFunctions.h"

@implementation GRBezierPathEditor

- (id)initEditor:(GRDrawableObject *)anObject
{
    self = [super initEditor:anObject];
    if(self != nil)
    {  
    }
    return self;
}



- (NSPoint)moveControlAtPoint:(NSPoint)p
{
  GRBezierControlPoint *cp, *pntonpnt;
  NSEvent *event;
  CGFloat zFactor;
  NSPoint pp;
  BOOL found = NO;
  NSInteger i;

  for(i = 0; i < [[(GRBezierPath *)object controlPoints] count]; i++)
    {
      cp = [[(GRBezierPath *)object controlPoints] objectAtIndex: i];
      if(pointInRect([cp centerRect], p))
        {
	  [self selectForEditing];
	  [(GRBezierPath *)object setCurrentPoint:cp];
	  [cp select];
	  found = YES;
        }
    }
  if(!found)
    return p;
  
  zFactor = [object zoomFactor];

  event = [[[object view] window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];

  if([event type] == NSLeftMouseDragged)
    {
      [[object view] verifyModifiersOfEvent: event];
      do
        {
          pp = [event locationInWindow];
          pp = [[object view] convertPoint: pp fromView: nil];
          pp = GRpointDeZoom(pp, zFactor);
          if([[object view] shiftclick])
            pp = pointApplyingCostrainerToPoint(pp, p);
          
          pntonpnt = [(GRBezierPath *)object pointOnPoint: (GRBezierControlPoint *)[(GRBezierPath *)object currentPoint]];
          if(pntonpnt)
            {
              if([(GRBezierPath *)object currentPoint] == [(GRBezierPath *)object firstPoint] || pntonpnt == [(GRBezierPath *)object firstPoint])
                [pntonpnt moveToPoint: pp];
            }
          [[(GRBezierPath *)object currentPoint] moveToPoint: pp];
          [(GRPathObject *)object remakePath];
          
          [[object view] setNeedsDisplay: YES];
          event = [[[object view] window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
          [[object view] verifyModifiersOfEvent: event];
        }
      while([event type] != NSLeftMouseUp);
    }
  
  return pp;
}

- (void)moveControlAtPoint:(NSPoint)oldp toPoint:(NSPoint)newp
{
  GRBezierControlPoint *cp, *pntonpnt;
  BOOL found = NO;
  NSUInteger i;
  
  for(i = 0; i < [[(GRBezierPath *)object controlPoints] count]; i++)
    {
      cp = [[(GRBezierPath *)object controlPoints] objectAtIndex: i];
      if(pointInRect([cp centerRect], oldp))
        {
          [self selectForEditing];
          [(GRBezierPath *)object setCurrentPoint:cp];
          [cp select];
          found = YES;
        }
    }
  if(!found)
    return;
  
  pntonpnt = [(GRBezierPath *)object pointOnPoint: (GRBezierControlPoint *)[(GRBezierPath *)object currentPoint]];
  if(pntonpnt)
    {
      if([(GRBezierPath *)object currentPoint] == [(GRBezierPath *)object firstPoint] || pntonpnt == [(GRBezierPath *)object firstPoint])
        [pntonpnt moveToPoint: newp];
    }
  [[(GRBezierPath *)object currentPoint] moveToPoint: newp];
  [(GRPathObject *)object remakePath];
  [[object view] setNeedsDisplay: YES];
}

- (NSPoint)moveBezierHandleAtPoint:(NSPoint)p
{
  GRBezierControlPoint *cp, *pntonpnt;
  GRBezierHandle handle;
  BOOL found = NO;
  NSEvent *event;
  NSPoint op, pp, c;
  NSUInteger i;
  
  if(!editSelected)
    return p;
  
  for(i = 0; i < [[(GRBezierPath *)object controlPoints] count]; i++)
    {
      cp = [[(GRBezierPath *)object controlPoints] objectAtIndex: i];
      if([cp isActiveHandle])
        {
          handle = [cp bzHandle];
          if(pointInRect(handle.firstHandleRect, p) || pointInRect(handle.secondHandleRect, p))
            {
              [cp select];
              [(GRBezierPath *)object setCurrentPoint:cp];
              found = YES;
            }
        }
    }
  if(!found)
    return p;
  
  event = [[[object view] window] nextEventMatchingMask:
                                    NSLeftMouseUpMask | NSLeftMouseDraggedMask];
  if([event type] == NSLeftMouseDragged)
    {
      [[object view] verifyModifiersOfEvent: event];
      op.x = p.x;
      op.y = p.y;
      do
        {
            pp = [event locationInWindow];
            pp = [[object view] convertPoint: pp fromView: nil];
            if([[object view] shiftclick])
            {
                c = [(GRBezierControlPoint *)[(GRBezierPath *)object currentPoint] center];
                pp = pointApplyingCostrainerToPoint(pp, c);
            }

            pntonpnt = [(GRBezierPath *)object pointOnPoint: (GRBezierControlPoint *)[(GRBezierPath *)object currentPoint]];
            if(pntonpnt) {
                if([(GRBezierPath *)object currentPoint] == [(GRBezierPath *)object firstPoint] || pntonpnt == [(GRBezierPath *)object firstPoint])
                    [pntonpnt moveBezierHandleToPosition: pp oldPosition: op];
            }
            [(GRBezierControlPoint *)[(GRBezierPath *)object currentPoint] moveBezierHandleToPosition: pp oldPosition: op];
            [(GRPathObject *)object remakePath];

            op.x = pp.x;
            op.y = pp.y;
            [[object view] setNeedsDisplay: YES];
            event = [[[object view] window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            [[object view] verifyModifiersOfEvent: event];
        } while([event type] != NSLeftMouseUp);
    }

    return pp;
}

- (void)moveBezierHandleAtPoint:(NSPoint)oldp toPoint:(NSPoint)newp
{
    GRBezierControlPoint *cp, *pntonpnt;
    GRBezierHandle handle;
    BOOL found = NO;
    int i;

    for(i = 0; i < [[(GRBezierPath *)object controlPoints] count]; i++)
    {
        cp = [[(GRBezierPath *)object controlPoints] objectAtIndex: i];
        if([cp isActiveHandle])
        {
            handle = [cp bzHandle];
            if(pointInRect(handle.firstHandleRect, oldp)
               || pointInRect(handle.secondHandleRect, oldp))
            {
                [cp select];
                [(GRBezierPath *)object setCurrentPoint:cp];
                found = YES;
            }
        }
    }
    if(!found)
        return;

    pntonpnt = [(GRBezierPath *)object pointOnPoint: (GRBezierControlPoint *)[(GRBezierPath *)object currentPoint]];
    if(pntonpnt)
    {
        if([(GRBezierPath *)object currentPoint] == [(GRBezierPath *)object firstPoint] || pntonpnt == [(GRBezierPath *)object firstPoint])
            [pntonpnt moveBezierHandleToPosition: newp oldPosition: oldp];
    }
    [(GRBezierControlPoint *)[(GRBezierPath *)object currentPoint] moveBezierHandleToPosition: newp oldPosition: oldp];
    [(GRPathObject *)object remakePath];
    [[object view] setNeedsDisplay: YES];
}



- (void)selectAsGroup
{
    if([object locked])
        return;
    if(!groupSelected)
    {
        groupSelected = YES;
        editSelected = NO;
        isvalid = NO;
        [[object view] unselectOtherObjects: object];
    }
}

- (void)selectForEditing
{
    if([object locked])
        return;
    editSelected = YES;
    groupSelected = NO;
    isvalid = NO;
    [[object view] unselectOtherObjects: object];
}

- (void)unselect
{
    int i;

    [super unselect];
    for(i = 0; i < [[(GRBezierPath *)object controlPoints] count]; i++)
        [[[(GRBezierPath *)object controlPoints] objectAtIndex: i] unselect];
}


- (void)unselectOtherControls:(GRBezierControlPoint *)cp
{
    GRBezierControlPoint *ctrlp;
    int i;

    [(GRBezierPath *)object setCurrentPoint:cp];
    for(i = 0; i < [[(GRBezierPath *)object controlPoints] count]; i++) {
        ctrlp = [[(GRBezierPath *)object controlPoints] objectAtIndex: i];
        if(ctrlp != cp)
            [ctrlp unselect];
    }
}

- (void)setIsValid:(BOOL)value
{
    isvalid = value;
}

- (BOOL)isValid
{
    return isvalid;
}

- (void)draw
{
  GRBezierControlPoint *cp;
  NSInteger i;
  
  if(![[(GRBezierPath *)object controlPoints] count] || ![object visible])
    return;
  
  if(groupSelected)
    {
      for(i = 0; i < [[(GRBezierPath *)object controlPoints] count]; i++)
        {
          cp = [[(GRBezierPath *)object controlPoints] objectAtIndex: i];
          [cp drawControlAsSelected:YES];
        }
    }
  
  if(editSelected)
    {
      for(i = 0; i < [[(GRBezierPath *)object controlPoints] count]; i++)
        {
          cp = [[(GRBezierPath *)object controlPoints] objectAtIndex: i];
          [cp drawControl];
        }
    }
}

@end



