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
private class PreventDuplicateEmploymentPeriod_TEST{
 private static Account Acc;
 private static Entity__c Ent;
 private static Employee__c Emp;
 private static Employment__c Empperiod;
 
    static{
    Acc=new Account(Name ='TestAccForEmpPeriod',Type='Press',Website='www.taxcreditco.com',BillingState ='CA',BillingPostalCode='23451',BillingStreet='South BurnSide Avenue',BillingCity='Park Labrea',BillingCountry='USA');
    insert Acc;
   
    Ent=new Entity__c(Name='Target',Account__c=Acc.Id);
    insert Ent;
    
    Emp=new Employee__c(FirstName__c='Steve',LastName__c='Johnson',SSN__c='239-12-1338',Account__c=Acc.Id);
    insert Emp;
   /*
    Empperiod=new Employment__c(Entity__c=Ent.Id,StartDate__c=Date.today(),Employee__c=Emp.Id);
    insert Empperiod;
 */
    }
 
 static testmethod void PreventEmploymentPeriodDup(){  
          Employment__c Employmentperiod=new Employment__c();
          date hiredate= date.parse('12/17/2008');
          date enddate= date.parse('1/25/2010');
          Employmentperiod.Entity__c=Ent.Id;
          Employmentperiod.Employee__c=Emp.Id;
          Employmentperiod.StartDate__c=hiredate;
          Employmentperiod.EndDate__c=enddate;      
        
       insert Employmentperiod;
       //update Employmentperiod;
      
     }     
 }