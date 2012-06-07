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
private class PreventDuplicateEmployeeAddress_TEST {


  private static Account AccEmp;
  private static Employee__c Emp;
  private static EmployeeAddress__c Empadd;

       Static{    
       AccEmp = new Account(Name ='TestAccount1',Type='Press',Website='www.taxcreditco.com',BillingState ='GA',BillingPostalCode='30040',BillingStreet='Colchester Creek',BillingCity='PeachTree',BillingCountry='United States');
       insert AccEmp;
       
       Emp= new Employee__c(FirstName__c='Steve',LastName__c='Jobs',SSN__c='999-64-1098',Account__c=AccEmp.Id);
       insert Emp;
         
       Empadd = new EmployeeAddress__c(StreetAddressText__c='2490 Mariner Square Loop',CityName__c='SanJose',ZipCode__c='98712',Employee__c=Emp.Id);
       insert Empadd;   
     
       }
        
       static testmethod void PreventEmployeeAddressDup(){                    
           EmployeeAddress__c EmpAddress=new EmployeeAddress__c();
           EmpAddress.Employee__c=Emp.Id;
           EmpAddress.CityName__c='Los Vegas';
           EmpAddress.StreetAddressText__c='South Burnside';
           EmpAddress.ZipCode__c='98123';
        
       insert EmpAddress;
       update EmpAddress;
      
     }   

}