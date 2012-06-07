public with sharing class PortalSearchBoxController {
public String searchVal {get; set;}

 public PortalSearchBoxController(){
 	//searchVal = Apexpages.currentPage().getParameters().get('searchVal');
 	if(searchVal == null || searchVal == '') searchVal = 'SEARCH';
            else if (searchVal != null || searchVal != '')searchVal = Apexpages.currentPage().getParameters().get('searchVal');
 }

	public Pagereference goToSearchPage(){
		Pagereference pr = new Pagereference('/apex/PortalSearchPage?searchVal='+searchVal);
		pr.setRedirect(true);
		return pr;
	}

	private static testmethod void  testClass(){
		PortalSearchBoxController sbc = new PortalSearchBoxController();
		sbc.searchVal = 'blah';
		Pagereference pr = sbc.goToSearchPage();
		System.assert(pr!=null);
	}
}