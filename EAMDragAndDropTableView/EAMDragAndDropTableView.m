//
//  EAMDragAndDropTableView.m
//  EAMDragAndDropTableView
//
// Copyright (c) 2013 El Amine Mouhcine.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "EAMDragAndDropTableView.h"

static NSTimeInterval const EAMDropAnimationDuration = 0.3f;

@interface EAMDragAndDropTableView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *dragGestureRecognizer;

@property (nonatomic, strong) UIImageView *dragAndDropImageView;

@property (nonatomic, strong) NSIndexPath *draggedIndexPath;

@property (nonatomic) CGRect initialDraggedViewFrame;

@property (nonatomic) BOOL preDragScrollEnabledValue;

@end

@implementation EAMDragAndDropTableView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _baseInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _baseInit];
    }
    return self;
}

-(void)_baseInit
{
    _dragAndDropEnabled = NO;
}

-(void)setDragAndDropEnabled:(BOOL)dragAndDropEnabled
{
    if (_dragAndDropEnabled != dragAndDropEnabled) {
        _dragAndDropEnabled = dragAndDropEnabled;
        if (_dragAndDropEnabled) {
            [self addGestureRecognizer:self.dragGestureRecognizer];
        } else {
            [self removeGestureRecognizer:self.dragGestureRecognizer];
        }
    }
}

#pragma mark -
#pragma mark Gesture recognizer

-(UILongPressGestureRecognizer *)dragGestureRecognizer
{
    if (!_dragGestureRecognizer) {
        _dragGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(_longPressAction:)];
        _dragGestureRecognizer.delegate = self;
    }
    return _dragGestureRecognizer;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)_longPressAction:(UILongPressGestureRecognizer *)sender
{
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:[sender locationInView:self]];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (indexPath) {
                if ([self.dragAndDropDelegate dragAndDropTableView:self
                    shouldDragCellAtIndexPath:indexPath]) {
                    [self _didRecognizeDraggingWithCellAtIndexPath:indexPath];
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self _continueDragging];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self _didEndDragging];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [self _didCancelDragging];
        }
            break;
        default:
            break;
    }
}

-(void)_didRecognizeDraggingWithCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.preDragScrollEnabledValue = self.scrollEnabled;
    self.scrollEnabled = NO;

    self.draggedIndexPath = indexPath;
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];

    self.initialDraggedViewFrame = [self.superview convertRect:cell.bounds
                                                      fromView:cell];
    
    // Render cell into a UIImage
    CGSize size = cell.frame.size;
    UIGraphicsBeginImageContext(size);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * imageFromCell = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Init Image view that will be dragged and add it to superview
    self.dragAndDropImageView = [[UIImageView alloc] initWithImage:imageFromCell];
    self.dragAndDropImageView.frame = [self.superview convertRect:cell.frame
                                                         fromView:cell.superview];
    [self.superview addSubview:self.dragAndDropImageView];

    // Inform the delegate that the dragging did beging
    [self.dragAndDropDelegate dragAndDropTableView:self
                   didBeginDraggingCellAtIndexPath:indexPath];
    // Delete row
    [self deleteRowsAtIndexPaths:@[indexPath]
                withRowAnimation:UITableViewRowAnimationFade];
}

-(void)_continueDragging
{
    self.dragAndDropImageView.center = CGPointMake(CGRectGetMidX(self.bounds), [self.dragGestureRecognizer locationInView:self.superview].y) ;
}

-(void)_didEndDragging
{
    if (!self.dragAndDropImageView) {
        return;
    }
    CGRect actualDraggedViewRect = [self convertRect:self.dragAndDropImageView.frame
                                            fromView:self.dragAndDropImageView.superview];
    
    // If cell is dragged out of the table view then cancel
    if (!CGRectIntersectsRect(actualDraggedViewRect, self.bounds)) {
        [self _didCancelDragging];
        return;
    }
    NSIndexPath *indexPath = [[self indexPathsForRowsInRect:actualDraggedViewRect] lastObject];
    CGRect finalCellFrame = [self cellForRowAtIndexPath:indexPath].frame;
    
    if (!indexPath) {
        indexPath = [[self indexPathsForVisibleRows] lastObject];
        if (indexPath) {
            finalCellFrame = [self cellForRowAtIndexPath:indexPath].frame;
            indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1
                                           inSection:indexPath.section];
            finalCellFrame.origin.y += finalCellFrame.size.height;
        } else {
            indexPath = [NSIndexPath indexPathForRow:0
                                           inSection:0];
            finalCellFrame = CGRectMake(0.0f, 0.0f, self.dragAndDropImageView.frame.size.width, self.dragAndDropImageView.frame.size.height);
        }
    }
    
    // Inform the delegate that dragging did end
    [self.dragAndDropDelegate dragAndDropTableView:self
                     didEndDraggingCellToIndexPath:indexPath];
    
    [UIView animateWithDuration:EAMDropAnimationDuration
                     animations:^{
                         self.dragAndDropImageView.frame = [self.superview convertRect:finalCellFrame
                                                                              fromView:self];
                     }
                     completion:^(BOOL finished) {
                         [self reloadData];
                         [self.dragAndDropImageView removeFromSuperview];
                         [self _reset];
                     }];
}

-(void)_didCancelDragging
{
    if (!self.dragAndDropImageView) {
        return;
    }
    // Inform the delegate that the dragging was cancelled
    [self.dragAndDropDelegate dragAndDropTableView:self
                didCancelDraggingCellFromIndexPath:self.draggedIndexPath];
    
    // Animate the image view back to its original position and insert the missing row
    [UIView animateWithDuration:EAMDropAnimationDuration
                     animations:^{
                         self.dragAndDropImageView.frame = self.initialDraggedViewFrame;
                     }
                     completion:^(BOOL finished) {
                         [self insertRowsAtIndexPaths:@[self.draggedIndexPath]
                                     withRowAnimation:UITableViewRowAnimationFade];
                         [self.dragAndDropImageView removeFromSuperview];
                         [self _reset];
                     }];
}

-(void)_reset
{
    self.scrollEnabled = self.preDragScrollEnabledValue;
    self.draggedIndexPath = nil;
    self.dragAndDropImageView = nil;
}

@end
