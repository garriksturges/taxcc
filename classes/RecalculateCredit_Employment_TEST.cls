@isTest
private class RecalculateCredit_Employment_TEST{
  private static Account AccEmp;
  private static ProgramQualification__c pcq;
  private static Employee__c Emp;
  private static Employment__c Employment;
  private static Entity__c Entity;
  private static Area__c area;
  private static Agency__c agency;
  private static Program__c program;
  private static ProgramPeriod__c programperiod;

 
  
  Static{ 
       AccEmp=new Account(Name ='TestAccount1',Type='Press',Website='www.taxcreditco.com',BillingState ='GA',BillingPostalCode='30040',BillingStreet='Colchester Creek',BillingCity='PeachTree',BillingCountry='United States');
       insert AccEmp;
       Emp=new Employee__c(FirstName__c='Steve',LastName__c='Jobs',SSN__c='999-64-1098',Account__c=AccEmp.Id);
       insert Emp;  
       Entity= new Entity__c(Account__c=AccEmp.Id,Name='Ent Name');
       insert Entity;
       Employment=new Employment__c(Name='Employment Test',Entity__c=Entity.id,Employee__c=Emp.id,StartDate__c=Date.Today(),EndDate__c=Date.Today()); 
       area=new Area__c(Name='Las Angeles',AreaDefinitionMethod__c='Country');
       insert area;
       agency=new Agency__c(Name='Test Agency');
       insert agency;
       program=new Program__c(Name='Test Program');
       insert program;
       programperiod=new ProgramPeriod__c(Name='Test Program Period',Agency__c=agency.id,Area__c=area.id,Program__c=program.id,StartDate__c=Date.Today(),EndDate__c=Date.Today());
       insert programperiod;
       }
       
       static testmethod void RecalculateCreditEmployment(){  
       ProgramQualification__c programqualification = new ProgramQualification__c();
       programqualification.Name='Test PCQ';
       programqualification.Employment__c=Employment.id;
       programqualification.ProgramPeriod__c=programperiod.id;

       try{
       insert programqualification;
       //update programqualification;
       }catch(Exception e){
       e.getMessage();
       }
             
       }
}