public with sharing class PortalLocationEmployeesController {

    public Location__c loc {get; set;}
    public list <EmployeeWrapper> ewList    {get; set;}
    public integer ewListSize   {get; set;}
    private string locationID;
		private set <String> employeeIdSet;
		public set<String> getemployeeIdSet(){
			if(test.isRunningTest())
				return employeeIdSet;
			else
				return null;
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


    /****************************************************************/
    public PortalLocationEmployeesController(){
        locationID = Apexpages.currentPage().getParameters().get('locId');
        if(locationId == null)
        	return;
        list <Location__c> llist = [select Name, id from Location__c where id = :locationID];
        if(llist!=null && llist.size()>0)
            loc = llist[0];
        
        list <Hour__c> hrs = [Select Wage__c, Location__c From Hour__c where Location__c = :locationID];
				set<String> wIds = new set<String>();
				for(Hour__c h : hrs){
					wIds.add(h.Wage__c);
				}
				list<Wage__c> wages = [Select EmploymentPeriod__r.Employee__c, EmploymentPeriod__c
															 From Wage__c
															 where id in :wIds];
	
        employeeIdSet = new set<String>();
        for(Wage__c w: wages){
            employeeIdSet.add(w.EmploymentPeriod__r.Employee__c);
        }
        
        list<EmployeeSurvey__c> esList = [Select EntityLocation__r.Location__c, EntityLocation__c, 
                                          EmploymentPeriod__r.Employee__c, EmploymentPeriod__c 
                                          From EmployeeSurvey__c 
                                          Where EntityLocation__r.Location__c = :locationID];
        
        for(EmployeeSurvey__c es : esList){
            employeeIdSet.add(es.EmploymentPeriod__r.Employee__c);
        }
        
        
        list<Employee__c> employees = [Select Name, LastName__c, FirstName__c, ClientEmployeeID__c, SSN__c, Id //last 4 digits of SSN 
                     From Employee__c
                     where id in :employeeIdSet
                     order by LastName__c limit 50];
                                 
        ewList = new list<EmployeeWrapper>();
        string color ='white';
        for(Employee__c e : employees){
            ewList.add(new EmployeeWrapper(e, color));
            if(color =='white')
            	color = 'white';//'lightgrey';
            else
            	color = 'white';
        }   
        ewListSize = employeeIdSet.Size();                      
    }
    /****************************************************************/
    public void nextPage(){
    	if(ewList == null || ewList.size()==0)
    		return;
    	list<Employee__c> employees = [Select Name, LastName__c, FirstName__c, ClientEmployeeID__c, SSN__c, Id //last 4 digits of SSN 
                     From Employee__c
                     where id in :employeeIdSet
                     and LastName__c > :ewList[ewList.size()-1].lastName
                     order by LastName__c limit 50];	
    	if(employees == null || employees.size() == 0)
    		return;
    	string color ='white';
	    for(Employee__c e : employees){
	        ewList.add(new EmployeeWrapper(e, color));
	        if(color =='white')
	        	color = 'white';//'lightgrey';
	        else
	        	color = 'white';
	    }	
    }
    /****************************************************************/
    public void previousPage(){
    	if(ewList == null || ewList.size()==0)
    		return;
    	list<Employee__c> employees = [Select Name, LastName__c, FirstName__c, ClientEmployeeID__c, SSN__c, Id //last 4 digits of SSN 
                     From Employee__c
                     where id in :employeeIdSet
                     and LastName__c < :ewList[0].lastName
                     order by LastName__c limit 50];	
    	if(employees == null || employees.size() == 0)
    		return;
    	string color ='white';
	    for(Employee__c e : employees){
	        ewList.add(new EmployeeWrapper(e, color));
	        if(color =='white')
	        	color = 'white';//'lightgrey';
	        else
	        	color = 'white';
	    }
    }
}