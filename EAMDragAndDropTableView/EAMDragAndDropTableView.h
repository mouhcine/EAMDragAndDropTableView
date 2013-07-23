//
//  EAMDragAndDropTableView.h
//  
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class EAMDragAndDropTableView;

/**
 The delegate of a EAMDragAndDropTableView object must adot the EAMDrangAndDropTableViewDelegate protocol.
 */
@protocol EAMDrangAndDropTableViewDelegate <NSObject>

/**
 Asks the delegate if a cell with a given indexpath should be dragged or not.
 
 @param tableView The table view object that is making the request.
 @param indexPath An indexpath object locating the row in its section.
 @return YES if the cell should be dragged, otherwise NO.
 */
-(BOOL)dragAndDropTableView:(EAMDragAndDropTableView *)tableView shouldDragCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 Tells the delegate that the specifed cell is now being dragged.
 
 @param tableView The table view object that is making the request.
 @param indexPath An indexpath object locating the row in its section.
 */
-(void)dragAndDropTableView:(EAMDragAndDropTableView *)tableView didBeginDraggingCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 Tells the delegate that the specifed cell has been dropped.
 
 @param tableView The table view object that is making the request.
 @param indexPath An indexpath object locating the row and section where the cell was dropped.
 */
-(void)dragAndDropTableView:(EAMDragAndDropTableView *)tableView didEndDraggingCellToIndexPath:(NSIndexPath *)indexPath;

/**
 Tells the delegate that the dragging action on a particolar cell has been cancelled.
 
 @param tableView The table view object that is making the request.
 @param indexPath An indexpath object locating the row and section where the cell was dragged from.
 */

-(void)dragAndDropTableView:(EAMDragAndDropTableView *)tableView didCancelDraggingCellFromIndexPath:(NSIndexPath *)indexPath;

@end

/**
 EAMDragAndDropTableView is a simple subclass allowing a drag and drop feature. If dragAndDropEnabled property is set to NO (by default it is), EAMDragAndDropTableView acts just like a normal UITableView.
 */
@interface EAMDragAndDropTableView : UITableView

/**
 A boolean value indicating whether the table view enables drag and drop functionality or not. Default is NO.
 
 @discussion When the value of this property is NO. The table view acts as a UITableView instance.
 */
@property (nonatomic, getter = isDragAndDropEnabled) BOOL dragAndDropEnabled;

/**
 The object that acts as the drag and drop delegate of the receiving table view.
 
 @discussion The delegate must adopt the EAMDrangAndDropTableViewDelegate protocol.
 */
@property (nonatomic, weak) id <EAMDrangAndDropTableViewDelegate> dragAndDropDelegate;

@end
