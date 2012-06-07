public with sharing class PortalHomeController 
{
    public string ContactId {get; set;}
    public string PortalRoleName {get; set;}
    public boolean ShowScreening {get; set;}
    public boolean IsLocationProcessManager {get; set;}

    
    public PortalHomeController()
    {
        if(ApexPages.currentPage().getParameters().get('id') != null)
        {
            ContactId = ApexPages.currentPage().getParameters().get('id');
            
            list<PortalRole__c> portalRoleObjects = [select Name from PortalRole__c where Id in (select PortalRole__c from PortalUser__c where Contact__c =:contactId) limit 1];
            if(portalRoleObjects != null && portalRoleObjects.size()>0)
            	PortalRoleName = portalRoleObjects[0].name;
            
            if(PortalRoleName!=null && PortalRoleName == 'Location Process Manager')
            {
                IsLocationProcessManager = true;
                ShowScreening = true;
            }
            else
            {
                IsLocationProcessManager = false;
                ShowScreening = false;
            }
            

        }
        else
        {
            return;
        }
    }    

	public static testmethod void testController(){
		
		Contact c = new Contact();
		c.firstName = 'test';
		c.LastName = 'test';
		insert c;
		
		PortalRole__c pr = new PortalRole__c();
		pr.Name = 'Location Process Manager';
		insert pr;
		
		PortalUser__c pu = new PortalUser__c();
		pu.Contact__c = c.id;
		pu.PortalRole__c = pr.id;
		insert pu;
		
		Apexpages.currentPage().getParameters().put('id', c.id);
		PortalHomeController phc = new PortalHomeController();
		System.assert(phc.ShowScreening == true);
		
		Contact c2 = new Contact();
		c2.FirstName = 'arf';
		c2.lastName = 'bark';
		insert c2;
		Apexpages.currentPage().getParameters().put('id', c2.id);
		phc = new PortalHomeController();
		System.assert(phc.ShowScreening == false);
	}

}