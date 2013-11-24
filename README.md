BCIPHONEPOPUP
=============

initial commit

i wrote this class in 2012. the code is nit ARC but works and is fully functional, i uploaded to people who need on iphone
a view like popOver on iPad. improve it!!, and be good guys. if i have time i´ll post an example but just to have an idea
use it like this :

ActionsTypeSelectorViewController is a tableVieController. 

showViewController : the embeded viewController
asPopUpInViewController : the view where popUp will be (must be viewcontroller class)
fromCoordinates : initial x,y (origin)
clearingParentViews : bool that indicate if a previus popUp exist on view hierarchy, remove it or not.

 ActionsTypeSelectorViewController *actionSelector = [[ActionsTypeSelectorViewController alloc]  initWithSelectedIndex:index andStyle:UITableViewStylePlain];
 BCFIPhonePopUp *pop  =     [BCFIPhonePopUp showViewController:actionSelector 
                                       asPopUpInViewController:self 
                                               fromCoordinates:CGPointMake(translatedCoordinates.x, translatedCoordinates.y)
                                           clearingParentViews:YES];
    [pop reduceHeightBy:110];
    [pop updateTitle:NSLocalizedString(@"action", nil)];
    [actionSelector release];
