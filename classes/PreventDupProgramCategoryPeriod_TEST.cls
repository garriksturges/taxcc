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
private class PreventDupProgramCategoryPeriod_TEST{

private static program__c prg;
private static ProgramCategory__c Prgcat;
private static Area__c Area;
private static ProgramCategoryPeriod__c prgcatpriod;

  static{
  prg=new program__c(Name='TestProgram', ShortName__c='TP');
  insert prg;
  
  Prgcat=new ProgramCategory__c(Name='Test Program Category',Program__c=prg.Id);
  insert Prgcat;
  
  Area=new Area__c(Name='San Jose',AreaDefinitionMethod__c='State/Province'); 
  insert Area;
  
  prgcatpriod=new ProgramCategoryPeriod__c(Name='TestPQ9999',ProgramCategory__c=Prgcat.Id,Area__c=Area.Id,StartDate__c=Date.today());
  insert prgcatpriod;
  }
  static testmethod void PreventProgramCategoryPeriodDup(){
  ProgramCategoryPeriod__c ProgramCategoryPeriod=new ProgramCategoryPeriod__c();
  date startdate= date.parse('4/20/2011');
  ProgramCategoryPeriod.ProgramCategory__c=Prgcat.Id;
  ProgramCategoryPeriod.Area__c=Area.Id; 
  ProgramCategoryPeriod.Name='TestPCP786';
  ProgramCategoryPeriod.StartDate__c=startdate;
  
  insert ProgramCategoryPeriod;
  //update ProgramCategoryPeriod;  
  
  }
  }