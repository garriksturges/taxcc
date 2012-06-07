public with sharing class PortalSearchPageController {

	public boolean 		showError						{get; set;}
	public string 		searchVal						{get; set;}
	public string 		accountName					{get; set;}
	public string 		locId					{get; set;}
	public string 		empId					{get; set;}
	public list<EmployeeWrapper> ewList		{get; set;}
	public list<locationWrapper> lList		{get; set;}

	
	private double		levelNumber;
	private string 		contactId;
	private string 		accountId;
	private string 		userACM;
	
	public void setaccountId(String val){if(test.isRunningTest())accountId = val;}
	
/*****************************************************/
	public PortalSearchPageController(){
			searchVal = Apexpages.currentPage().getParameters().get('searchVal');
			try{
				string userId = Userinfo.getUserId();
				ContactId = [Select u.Contact.FirstName, u.Contact.LastName, u.ContactId From User u where id =:userId].contactId;
        Contact contact = [select AccountId, Account.Name,  AccountHierarchyMember__c, ExecutiveAccessBit__c from Contact where Id =:ContactId];            
        accountName=contact.Account.Name;
        accountId = contact.AccountId;
        if(contact.AccountHierarchyMember__c!=null){
					userACM = contact.AccountHierarchyMember__c;
					levelNumber = [Select AccountHierarchyLevel__r.LevelNumber__c, AccountHierarchyLevel__c From AccountHierarchyMember__c where Id = :userACM].AccountHierarchyLevel__r.LevelNumber__c;
        }
        boolean executiveAccessBit = contact.ExecutiveAccessBit__c;
        	
        if(contact != null && (userACM != null|| executiveAccessBit) && accountId != null)
					setupSearch();
				else 
					showError = true;
				}
      catch(exception e){  
      	//system.assert(false, e +'USER ID'+Userinfo.getUserId());   
      	//!!!!!!! FOR DEVELOPMENT                                               
        if(userinfo.getProfileId() == '00e30000001iwE7AAI'){
        	accountId ='0013000000qKxdW';
          userACM = 'a07S00000029ZNjIAM';//--California State
          Account accountObject = [SELECT Id, Name FROM Account WHERE Id =:accountId];
          accountName = accountObject.Name;
          if(!test.isRunningTest())
          	setupSearch();
         }
         else 
					showError = true;
				}
	}
/*****************************************************/
	public void setupSearch(){
		if(searchVal == null || searchVal.length()<=1)
			showError = true;
		else{
			showError = false;
			doSearch();
		}
	}
/*****************************************************/
	private void doSearch(){
		//double levelNumber = [Select AccountHierarchyLevel__r.LevelNumber__c, AccountHierarchyLevel__c From AccountHierarchyMember__c where Id = :userACM].AccountHierarchyLevel__r.LevelNumber__c;
		String searchQuery = '*'+searchVal+'*';
		List<List<SObject>> searchList = [FIND :searchQuery IN ALL FIELDS RETURNING 
																			Location__c(StreetAddressText__c, State__r.Name, State__c, Name, CityName__c, Account__c, Id
																									where Account__c = :accountId 
																									//and(AccountHierarchyMember__c = :userACM or AccountHierarchyMember__r.AccountHierarchyLevel__r.LevelNumber__c > :levelNumber)
																									order by Name limit 25), 
																			Employee__c(LastName__c, FirstName__c, ClientEmployeeID__c, SSN__c, Account__c
																									where Account__c = :accountId
																									order by LastName__c
																									limit 25)];
	list<Location__c>locationList = searchList[0];
	list<Employee__c>employeeList = searchList[1];																									
	makeWrappers(locationList, employeeList);
	}
/*****************************************************/
	public void makeWrappers(list<Location__c>locationList, list<Employee__c>employeeList){
		string color = 'white';
		if(locationList != null && locationList.size() > 0){
			lList = new list<locationWrapper>();
			for (Location__c l : locationList){
				lList.add(new locationWrapper(l, color));
				if(color =='white')
	      	color = 'lightgrey';
	      else
	      	color = 'white';
			}
		}
		if(employeeList != null && employeeList.size()>0){
			color = 'white';
			ewList = new list<EmployeeWrapper>();
			for(Employee__c e : employeeList){
	    	ewList.add(new EmployeeWrapper(e, color));
	      if(color =='white')
	      	color = 'lightgrey';
	      else
	       color = 'white';
	    }
		}   
	}
/*****************************************************/
public void previousLocations(){
	if(lList == null || lList.size()==0)
		return;
	String searchQuery = '*'+searchVal+'*';
	List<List<SObject>> searchList = [FIND :searchQuery IN ALL FIELDS RETURNING 
																		Location__c(StreetAddressText__c, State__r.Name, State__c, Name, CityName__c, Account__c 
																								where Account__c = :accountId 
																								and(AccountHierarchyMember__c = :userACM or AccountHierarchyMember__r.AccountHierarchyLevel__r.LevelNumber__c > :levelNumber)
																								and Name < :lList[0].loc.Name
																								order by Name limit 25)];
	list<Location__c>locationList = searchList[0];
	makeWrappers(locationList, null);																								
}
/*****************************************************/
public void nextLocations(){
	if(lList == null || lList.size()==0)
		return;
	String searchQuery = '*'+searchVal+'*';
	List<List<SObject>> searchList = [FIND :searchQuery IN ALL FIELDS RETURNING 
																		Location__c(StreetAddressText__c, State__r.Name, State__c, Name, CityName__c, Account__c 
																								where Account__c = :accountId 
																								and(AccountHierarchyMember__c = :userACM or AccountHierarchyMember__r.AccountHierarchyLevel__r.LevelNumber__c > :levelNumber)
																								and Name > :lList[lList.size()-1].loc.Name
																								order by Name limit 25)];
	list<Location__c>locationList = searchList[0];
	makeWrappers(locationList, null);
}
/*****************************************************/
public void previousEmployees(){
	if(ewList == null || ewList.size()==0)
		return;
	String searchQuery = '*'+searchVal+'*';
	List<List<SObject>> searchList = [FIND :searchQuery IN ALL FIELDS RETURNING 
																		Employee__c(LastName__c, FirstName__c, ClientEmployeeID__c, SSN__c, Account__c
																									where Account__c = :accountId
																									and LastName__c < :ewList[0].lastName
																									order by LastName__c
																									limit 25)];
	list<Employee__c>employeeList = searchList[0];																									

	makeWrappers(null, employeeList);

}
/*****************************************************/
public void nextEmployees(){
	if(ewList == null || ewList.size()==0)
		return;
	String searchQuery = '*'+searchVal+'*';
	List<List<SObject>> searchList = [FIND :searchQuery IN ALL FIELDS RETURNING 
																		Employee__c(LastName__c, FirstName__c, ClientEmployeeID__c, SSN__c, Account__c
																									where Account__c = :accountId
																									and LastName__c > :ewList[ewList.size()-1].lastName
																									order by LastName__c
																									limit 25)];
	list<Employee__c>employeeList = searchList[0];																									
	makeWrappers(null, employeeList);

}
/*****************************************************/
/*****************/
    public class locationWrapper{
        public Location__c loc{get; set;}
        public string background {get; set;}
        public String locId{get; set;}
        public locationWrapper(Location__c l, string bg){
            loc = l;
            background = bg;
            locId = loc.Id;
        }
    }
/*************/
    public class EmployeeWrapper{
        public String lastName{get; set;}
        public String firstName{get; set;}
        public String clientEmployeeId{get; set;}
        public String ssn {get; set;}
        public String id{get; set;}
        public string background{get; set;}
        
        public EmployeeWrapper(Employee__c e, string bg){
            if(e.SSN__c !=null && e.SSN__c.length()>=4)
                ssn = e.SSN__c.substring(e.SSN__c.length()-4, e.SSN__c.length());
            else
                ssn = 'none';
            lastName = e.LastName__c;
            firstName = e.FirstName__c;
            clientEmployeeId = e.clientEmployeeId__c;
            id = e.Id;
            background = bg;
        }
    }
/*************/
}