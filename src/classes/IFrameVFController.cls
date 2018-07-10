public class IFrameVFController {
    	public PageReference finishCV() {
 		//PageReference pageRef = new PageReference('http://www.google.com');
        
        PageReference pageRef = new PageReference('http://40.69.74.208:8008/');   
        //PageReference pageRef = new PageReference('/apex/CompleteTest');
        //pageref.setRedirect(true);
		return pageRef;
 	}
}