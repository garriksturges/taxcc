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
private class AccountHierarchyController_TEST
{
   
      static testMethod void ControllerTest() 
    {
      
      Account a1 = new Account();
            a1.Name = 'TEST ACCOUNT';
            insert a1;
     AccountHierarchyLevel__c l1 = new AccountHierarchyLevel__c();
      l1.Account__c = a1.id;
      l1.AccountHierarchyLevelLabelName__c = 'test level 1';
      l1.LevelNumber__c = 1;
      insert l1;
      
      AccountHierarchyLevel__c l2 = new AccountHierarchyLevel__c();
      l2.Account__c = a1.id;
      l2.AccountHierarchyLevelLabelName__c = 'test level 2';
      l2.LevelNumber__c = 2;
      l2.AccountHierarchyLevel__c = l1.id;
      insert l2;
      
      AccountHierarchyMember__c ahm = new AccountHierarchyMember__c();
      ahm.AccountHierarchyMemberLabelName__c = 'State';
      //ahm.ParentAccountHierarchyMember__c='West';
      ahm.AccountHierarchyLevel__c=l1.Id;
      ahm.Account__c=a1.Id;
      ahm.AccountHierarchyMemberName__c='California';
      insert ahm;
      AccountHierarchyMember__c ahm2 = new AccountHierarchyMember__c();
      ahm2.AccountHierarchyMemberLabelName__c = 'State';
      //ahm.ParentAccountHierarchyMember__c='West';
      ahm2.AccountHierarchyLevel__c=l1.Id;
      ahm2.Account__c=a1.Id;
      ahm2.AccountHierarchyMemberName__c='California';
      insert ahm2;
      
      AccountHierarchyLevel__c l3 = new AccountHierarchyLevel__c();
            l3.Account__c = a1.id;
            l3.AccountHierarchyLevelLabelName__c = 'test level 2';
            l3.LevelNumber__c = 2;
            
            insert l3; 
            Entity__c Entity=new Entity__c(Account__c=a1.Id,ClientEntityId__c='test123',IE2EntityId__c=123);
            insert Entity;
              State__c state = new State__c();
      state.Name = 'test';
      state.StateAbbr__c = 'tst';
      insert state;
            Location__c loc1 = new Location__c();
      loc1.StreetAddressText__c = 'test';
      loc1.State__c = state.id;
      loc1.Name = 'test';
      loc1.CityName__c = 'test city';
      loc1.AccountHierarchyMember__c = ahm.id;
      loc1.Account__c = a1.id;
      insert loc1;
            EntityLocation__c EntityLocation=new EntityLocation__c(Entity__c=Entity.Id,Location__c=loc1.Id);
            insert EntityLocation;
            ApexPages.currentPage().getParameters().put('accountId',a1.Id);
            AccountHierarchyController acccon=new AccountHierarchyController();
      ApexPages.StandardController cont=new ApexPages.StandardController(ahm);
      AccountHierarchyController controller=new AccountHierarchyController(cont);
      controller.updateClientOrgId=ahm.id;
      controller.DeleteClientOrgId=l3.id;
    
    
    controller.accountHierarchyMemberFilter=ahm.Id;
    controller.EditClientOrg();
    controller.bindTreeView();
    controller.initializePage();
    controller.initControlList();
    controller.initLocationItems();
    controller.initSelectedItems();
    controller.initLevelName();
    controller.groupChange();
    controller.ParentOrgChange();
    controller.AddChildClientOrg();
    controller.AddLocation();
    controller.ResponseEditLevel();
    controller.ResponseNewLevel();
    controller.CloseModalWindow();
    controller.updateClientOrgId=ahm.Id;
    controller.updateClientOrg();
    controller.SaveClientOrg();
    controller.ClientOrgLevelNameRead ='';
    controller.SaveClientOrg();
    controller.deleteItem();
    controller.accountHierarchyLevelNewOrEdit='';
    String slst=ahm2.Id+';'+ahm.Id;
    
    controller.hdDeleteIDList=slst;
    controller.deleteItem();
    }
    
      
    }