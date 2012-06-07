global class StringTitleCase {

	//converts a given string to Title Case where the
	//first letter of every word is capitalised and the rest are small
	global static String MakeTitleCase(String phrase)
	{
		String titlePhrase = '';
		//a set of words that should always (or at least, almost always) be in lower case when in Title Case
		//eg The Day of the Jackal.  First and last word of a phrase should always be Capped though.
		Set<String> forceLower = new Set<String>{'of', 'the', 'for', 'and', 'a', 'to', 'at' ,'an', 'but', 'if', 'or', 'nor'};
		Set<String> forceUpper = new Set<String>{'ID','WIA','SSI','CDIB','SSA','EBT','Non-US','FL21802','CAEZ'};
		
		if(phrase != null && phrase.length() > 0)
		{
		    String[] splitPhrase = phrase.trim().split(' ');
					
		    for(integer i = 0; i < splitPhrase.size(); i++)
		    {
		      	if((!forceUpper.contains(splitPhrase[i].toUpperCase()) && !forceLower.contains(splitPhrase[i].toLowerCase())) 
		      	&& (i == 0 || i == (splitPhrase.size()-1)))
		      	{
		        	titlePhrase += (splitPhrase[i].substring(0,1).toUpperCase())+(splitPhrase[i].substring(1).toLowerCase())+' ';
		      	}
		      	else if(forceLower.contains(splitPhrase[i].toLowerCase()))
		      	{
		        	titlePhrase += splitPhrase[i].toLowerCase()+' ';
		        }
		        else if(forceUpper.contains(splitPhrase[i].toUpperCase()))
		        {
		        	titlePhrase += splitPhrase[i].toUpperCase() +' ';
		        }
			}
		}
		return titlePhrase.trim();
	}
	
	static testMethod void TEST_StringTitleCase() 
	{
		test.startTest();
    	    String result = StringTitleCase.MakeTitleCase('hello world');
    	    system.assert(result == 'Hello World');
        test.stopTest();
    }
}