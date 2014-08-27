//
//  SideMenu.swift
//  Grow
//
//  Created by Kevin Sullivan on 8/27/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle = NSBundle.mainBundle()) -> UIView! {
        return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

class UISideViewController: UIViewController {
    var mainView: UISideMainView = UISideMainView()
    var menuView: UISideMenuView = UISideMenuView()
    
    override func viewDidLoad() {
        mainView = UISideMainView.loadFromNibNamed("SideMain") as UISideMainView
        menuView = UISideMenuView.loadFromNibNamed("SideMenu") as UISideMenuView

        let frameSize = self.view.bounds.size
        let mainFrame = CGRectMake(0, 0, frameSize.width - 20, frameSize.height)
        let menuFrame = CGRectMake(frameSize.width - 20, 0, 20, frameSize.height)
        
        mainView.frame = mainFrame
        menuView.frame = menuFrame
        
        self.view.addSubview(mainView)
        self.view.addSubview(menuView)

        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: "pulledLeft:")
        edgeSwipe.edges = UIRectEdge.Right
        self.view.addGestureRecognizer(edgeSwipe)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func pulledLeft(recognizer: UIScreenEdgePanGestureRecognizer) {
        
    }

    func moveDivider(points: Int) {
    
    }
}

class UISideMainView: UIView {
  
}

class UISideMenuView: UIView {
    
}



//- (void) displayContentController: (UIViewController*) content;
//{
//    [self addChildViewController:content];                 // 1
//    content.view.frame = [self frameForContentController]; // 2
//    [self.view addSubview:self.currentClientView];
//    [content didMoveToParentViewController:self];          // 3
//}
//Here’s what the code does:
//
//It calls the container’s addChildViewController: method to add the child. Calling the addChildViewController: method also calls the child’s willMoveToParentViewController: method automatically.
//It accesses the child’s view property to retrieve the view and adds it to its own view hierarchy. The container sets the child’s size and position before adding the view; containers always choose where the child’s content appears. Although this example does this by explicitly setting the frame, you could also use layout constraints to determine the view’s position.
//It explicitly calls the child’s didMoveToParentViewController: method to signal that the operation is complete.
//Eventually, you want to be able to remove the child’s view from the view hierarchy. In this case, shown in Listing 14-2, you perform the steps in reverse.
//
//Listing 14-2  Removing another view controller’s view to the container’s view hierarchy
//- (void) hideContentController: (UIViewController*) content
//{
//    [content willMoveToParentViewController:nil];  // 1
//    [content.view removeFromSuperview];            // 2
//    [content removeFromParentViewController];      // 3
//}
//Here’s what this code does:
//
//Calls the child’s willMoveToParentViewController: method with a parameter of nil to tell the child that it is being removed.
//Cleans up the view hierarchy.
//Calls the child’s removeFromParentViewController method to remove it from the container. Calling the removeFromParentViewController method automatically calls the child’s didMoveToParentViewController: method.
//For a container with essentially static content, adding and removing view controllers is as simple as that. Whenever you want to add a new view, add the new view controller as a child first. After the view is removed, remove the child from the container. However, sometimes you want to animate a new child onto the screen while simultaneously removing another child. Listing 14-3 shows an example of how to do this.
//
