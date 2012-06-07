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
private class UpdateEmployeeNameAfterInsertUpdate_TEST {

    private static Account testAcct;
    private static Employee__c testEmployee;
    
    static {
    
        // create test Account
        testAcct = new Account(name='test1',phone='2016742345',website='taxcreditco.com',BillingState='CA',BillingPostalCode='67890',BillingStreet='123 Anywhere',BillingCity='Somewhere',BillingCountry='United States');
        insert testAcct;
        
        testEmployee= new Employee__c (name='<Default>',FirstName__c='John', LastName__c='Doe', SSN__c='555121212', Account__c=testAcct.Id );
        insert testEmployee;        
    }
                
    static testMethod void CheckThatNameUpdatedAfterInsert () {
    	
    	Employee__c emp = [select Id, Name from Employee__c where Id =:testEmployee.Id];
    	
    	System.assert(emp.Name != '<Default>');         
        
    }
}