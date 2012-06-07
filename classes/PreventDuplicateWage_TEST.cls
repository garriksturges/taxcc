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
private class PreventDuplicateWage_TEST
{
 	private static Account account = [select id from Account where AccountEID__c = 227];
	private static Entity__c entity = [select Id from Entity__c where EntityEID__c = 681];
 	private static EntityLocation__c entityLoc = [select Id from EntityLocation__c where EntityLocationEID__c = 40086];
 	private static Employee__c employee;
 	private static Employment__c employment;
 	private static Wage__c wage;
 		
   	static
  	{	
  		employee = new Employee__c(FirstName__c = 'Test', LastName__c = 'Test', Account__c = account.Id, SSN__c = '111223333');
  		insert employee;
  		
  		employment = new Employment__c(Entity__c = entity.Id, Employee__c = employee.Id, StartDate__c = date.parse('06/01/2011') );
  		insert employment;
  		
  		wage = new Wage__c(StartDate__c = date.parse('06/01/2011'), EndDate__c = date.parse('12/01/2011'), WageAmount__c = 100, EmploymentPeriod__c = employment.Id);
  		insert wage;
  	}

	
	static testmethod void preventEntityDup()		
	{
		try
		{				
			Wage__c newWage = new Wage__c(StartDate__c = date.parse('06/01/2011'), EndDate__c = date.parse('12/01/2011'), WageAmount__c = 100, EmploymentPeriod__c = employment.Id);
			insert newWage;
		}
		catch(System.DMLException e)
        {
            System.assert(e.getMessage().contains('Duplicate wages found within same period'));
        }   
         
	}
	
}