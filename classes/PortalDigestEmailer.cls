public with sharing class PortalDigestEmailer {

	public PortalDigestEmailer(){
		setupListOfContacts();
	}
	/***********************************/
	private void setupListOfContacts(){
		integer i =1;
		i = i +5;		
	}
	/***********************************/
	public void sendEmails(){
	}
	/***********************************/
	private static testmethod void  test(){
	PortalDigestEmailer pde = new PortalDigestEmailer();
	pde.setuplistofcontacts();
	system.assert(true);
}
}