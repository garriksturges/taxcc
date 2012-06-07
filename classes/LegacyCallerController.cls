public class LegacyCallerController
{

    public String callerInput {get; set;}
    public String legacySearchString {get; set;}
    
    public LegacyCallerController(){
        
        if(ApexPages.currentPage().getParameters().get('sbstr') != null)
        {
            callerInput = ApexPages.currentPage().getParameters().get('sbstr');
            legacySearchString = 'https://na6.salesforce.com/search/SearchResults?searchType=1&sen=a0a&sbstr=' + callerInput;
        }
        else
        {
            return;
        }
    }
   	private static testmethod void testc(){
		LegacyCallerController lc = new LegacyCallerController();
		ApexPages.currentPage().getParameters().put('sbstr', 'test');
		lc = new LegacyCallerController();
	} 
}