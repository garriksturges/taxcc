/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestUpdateSurveyDateTime {

  	static testMethod void dateutilityTest() 
	{
        Account acct = new Account(Name='Test');
        insert acct;
        
        Entity__c ent = new Entity__c(Account__c = acct.Id, Name='Test');
        insert ent;
        
        Employee__c emp=new Employee__c(Account__c=acct.Id, BirthDate__c=date.today(), Email__c='test@test.com', LastName__c='test', FirstName__c='test', SSN__c='234-23-1890');
        insert emp;
    
        EmployeeAddress__c empaddress=new EmployeeAddress__c(CityName__c='test', Longitude__c=100, StreetAddressText__c='test', Employee__c=emp.Id, ZipCode__c='11009');
        insert empaddress;
        
        Location__c loc = new Location__c(Account__c = acct.Id, Name='Test');
		insert loc;
        
        EntityLocation__c el = new EntityLocation__c(Entity__c =ent.Id, Location__c=loc.Id);
        insert el;
        
        Employment__c Employment=new Employment__c(DepartmentName__c='test', StartDate__c=date.today(), Employee__c=emp.Id, Entity__c = el.Entity__c);
        insert Employment;       
        
        EmployeeSurvey__c EmployeeSurvey=new EmployeeSurvey__c(EmploymentPeriod__c = Employment.Id, SurveyDate__c=Datetime.now(), SurveySource__c='Online', EntityLocation__c=el.Id);
        insert EmployeeSurvey;
		
		
		UpdateSurveyDateTimePlugin dtutil=new UpdateSurveyDateTimePlugin();
    	Map<String,Object> inputParams = new Map<String,Object>();

        
        InputParams.put('EmployeeSurveyId', EmployeeSurvey.Id);
        InputParams.put('StringDateTime',Datetime.now().format());

        Process.PluginRequest request = new Process.PluginRequest(inputParams); 
    	//Process.PluginRequest request=new Process.PluginRequest();
    	dtutil.invoke(request);
    	dtutil.describe();
  	}
}