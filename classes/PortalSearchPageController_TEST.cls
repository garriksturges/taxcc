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
private class PortalSearchPageController_TEST {
		public Account a{get; set;}
		

		public PortalSearchPageController_TEST(){
			a = new Account();
			a.Name = 'test account';	
			insert a;
			
			Employee__c eyee1 = new Employee__c();
			eyee1.FirstName__c = 'ttest1';
			eyee1.LastName__c = 'ttest1';
			eyee1.SSN__c = '000-00-0000';
			eyee1.Account__c = a.id;
			insert eyee1;
			
			Employee__c eyee2 = new Employee__c();
			eyee2.FirstName__c = 'ttest2';
			eyee2.LastName__c = 'ttest2';
			eyee2.SSN__c = '000-00-1234';
			eyee2.Account__c = a.id;
			insert eyee2;
			
			AccountHierarchyLevel__c l1 = new AccountHierarchyLevel__c();
			l1.Account__c = a.id;
			l1.AccountHierarchyLevelLabelName__c = 'test level 1';
			l1.LevelNumber__c = 1;
			insert l1;
			
			AccountHierarchyMember__c ahm1 = new AccountHierarchyMember__c();
			ahm1.AccountHierarchyMemberName__c = 'test';
			ahm1.AccountHierarchyLevel__c = l1.id;
			ahm1.AccountHierarchyMemberLabelName__c = 'test';
			ahm1.Account__c = a.id;
			insert ahm1;
			
			Location__c l = new Location__c();
			l.Name = 'test';
			l.Account__c = a.id;
			l.AccountHierarchyMember__c = ahm1.id;
			l.StreetAddressText__c='123 test st';
			insert l;
			
			Location__c lc2 = new Location__c();
			lc2.Name = 'test2';
			lc2.Account__c = a.id;
			lc2.AccountHierarchyMember__c = ahm1.id;
			lc2.StreetAddressText__c = '444 test ave';
			insert lc2;
			
		}

    static testMethod void myUnitTest() {
        PortalSearchPageController_TEST t = new PortalSearchPageController_TEST();
        test.startTest();
        Apexpages.currentPage().getParameters().put('searchVal','te');
        PortalSearchPageController sc = new PortalSearchPageController();
        System.debug('!!!!!!!!!!!!! AID TEST:'+t.a.id);
        sc.setaccountId(t.a.id);
        sc.setupSearch();
        list<Employee__c> eList = [Select LastName__c, FirstName__c, ClientEmployeeID__c, SSN__c, Account__c from Employee__c where Account__c = :t.a.id];
        list<Location__c> lList=[Select StreetAddressText__c, State__r.Name, State__c, Name, CityName__c, Account__c from Location__c where Account__c = :t.a.id];
        sc.makeWrappers(lList, eList);
        System.assert(sc.ewList.size()!=0);
        System.assert(sc.lList.size()!=0);
        sc.nextEmployees();
        sc.nextLocations();
        sc.previousEmployees();
        sc.previousLocations();
        System.assert(sc.ewList.size()!=0);
        System.assert(sc.lList.size()!=0);
				test.stopTest();
    }
}