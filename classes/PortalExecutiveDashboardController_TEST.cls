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
private class PortalExecutiveDashboardController_TEST {
        
        public Account a1 {get; set;}
        public Contact c1 {get; set;}
        public AccountHierarchyLevel__c l1;
        public AccountHierarchyLevel__c l2;
        public AccountHierarchyLevel__c l3;
        public AccountHierarchyMember__c ahm1;
        public AccountHierarchyMember__c ahm2;
        public AccountHierarchyMember__c ahm3;
        public Location__c loc1;
        public Program__c prog1;
        public State__c state;
        public LocationProgram__c lp1;
        
        private  void setupTestData(){
            a1 = new Account();
            a1.Name = 'TEST ACCOUNT';
            insert a1;
            
            c1=new Contact();
            c1.FirstName = 'test';
            c1.LastName = 'tester';
            c1.AccountId = a1.id;
            insert c1;
            
            l1 = new AccountHierarchyLevel__c();
            l1.Account__c = a1.id;
            l1.AccountHierarchyLevelLabelName__c = 'test level 1';
            l1.LevelNumber__c = 1;
            insert l1;
            
            l2 = new AccountHierarchyLevel__c();
            l2.Account__c = a1.id;
            l2.AccountHierarchyLevelLabelName__c = 'test level 2';
            l2.LevelNumber__c = 2;
            l2.AccountHierarchyLevel__c = l1.id;
            insert l2;
            
            l3 = new AccountHierarchyLevel__c();
            l3.Account__c = a1.id;
            l3.AccountHierarchyLevelLabelName__c = 'test level 3';
            l3.LevelNumber__c = 3;
            l3.AccountHierarchyLevel__c = l2.id;
            insert l3;  
            
            ahm1 = new AccountHierarchyMember__c();
            ahm1.AccountHierarchyMemberName__c = 'test';
            ahm1.AccountHierarchyLevel__c = l1.id;
            ahm1.AccountHierarchyMemberLabelName__c = 'test';
            ahm1.Account__c = a1.id;
            insert ahm1;
            
            ahm2 = new AccountHierarchyMember__c();
            ahm2.ParentAccountHierarchyMember__c = ahm1.id;
            ahm2.AccountHierarchyMemberName__c = 'test2';
            ahm2.AccountHierarchyLevel__c = l2.id;
            ahm2.AccountHierarchyMemberLabelName__c = 'test';
            ahm2.Account__c = a1.id;
            insert ahm2;
            
            ahm3 = new AccountHierarchyMember__c();
            ahm3.ParentAccountHierarchyMember__c = ahm2.id;
            ahm3.AccountHierarchyMemberName__c = 'test3';
            ahm3.AccountHierarchyLevel__c = l3.id;
            ahm3.AccountHierarchyMemberLabelName__c = 'test';
            ahm3.Account__c = a1.id;
            insert ahm3;
            
        }
        
        private void addProgramAndLocation(){
            state = new State__c();
            state.Name = 'test';
            state.StateAbbr__c = 'tst';
            insert state;
            
            loc1 = new Location__c();
            loc1.StreetAddressText__c = 'test';
            loc1.State__c = state.id;
            loc1.Name = 'test';
            loc1.CityName__c = 'test city';
            loc1.AccountHierarchyMember__c = ahm3.id;
            loc1.Account__c = a1.id;
            insert loc1;
            
            prog1 = new Program__c();
            prog1.ShortName__c = 'PROG';
            prog1.MaximumLifetimeBenefitAmount__c = 123.0;
            insert prog1;
            
            lp1 = new LocationProgram__c();
            lp1.Location__c = loc1.id;
            lp1.Program__c = prog1.id;
            lp1.StartDate__c = Date.today().addDays(-4000);
            lp1.EndDate__c = Date.today().addDays(4000);
            insert lp1;
            
        }
        
    static testMethod void testConstructor() {
        PortalExecutiveDashboardController_TEST pct = new PortalExecutiveDashboardController_TEST();
        pct.setupTestData();
        Apexpages.currentPage().getParameters().put('id', pct.c1.id);
        PortalExecutiveDashboardController pc = new PortalExecutiveDashboardController();
        pc.accountId = pct.a1.id;
        pc.userACM = pct.ahm1.id;
        pc.setupTopNode();
        system.assert(pc.lwList.size()>0);
        pc.lwList[0].setSelectVal('pickle');
        pc.getDisplayValue();
        
        PortalExecutiveDashboardController.locationProgramWrapper lw = new PortalExecutiveDashboardController.locationProgramWrapper(pct.lp1, 'grey');
        lw.ValidScreens = 3;
        lw.ScreenTransfersOut = 7;
        lw.PortalScreeningComplianceDenom = 10;
        lw.PortalScreeningComplianceNum = 98;
        lw.PortalQualificationNum=30;
        lw.documentDenom = 8;
        lw.documentNum = 10;
        lw.getDocumentCompliancePCNT();
        lw.getQualificationRatePCNT();
        lw.getScreening();
        lw.getScreeningCompliancePCNT();
        
    }
        
    static testMethod void testNodeChanges() {
              PortalExecutiveDashboardController_TEST pct = new PortalExecutiveDashboardController_TEST();
        pct.setupTestData();
        Apexpages.currentPage().getParameters().put('id', pct.c1.id);
        PortalExecutiveDashboardController pc = new PortalExecutiveDashboardController();
        pc.accountId = pct.a1.id;
        pc.userACM = pct.ahm1.id;
        pc.setupTopNode();
        
        pc.lwList[0].selectVal = '--Select--';
        pc.updateNodeList();
        System.Assert(pc.lwList.size()!=0);
        
        pc.lwList[0].selectVal = pct.ahm1.id;
        pc.updateNodeList();
        System.Assert(pc.lwList.size()!=0, '!!!!!!'+pc.lwList.size());
        
        pc.lwList[1].selectVal = pct.ahm2.id;
        pc.updateNodeList();
        System.Assert(pc.lwList.size()==3);
        
        pc.lwList[2].selectVal = pct.ahm3.id;
        pc.updateNodeList();
        System.Assert(pc.lwList.size()==3);
        
        pc.lwList[1].selectVal = '--Select--';
        pc.updateNodeList();
        System.Assert(pc.lwList.size()!=0);
        
        
        }
        
 static testMethod void testNodeChangesWithPrograms(){
                PortalExecutiveDashboardController_TEST pct = new PortalExecutiveDashboardController_TEST();
        pct.setupTestData();
        pct.addProgramAndLocation();
        Apexpages.currentPage().getParameters().put('id', pct.c1.id);
        PortalExecutiveDashboardController pc = new PortalExecutiveDashboardController();
				pc.accountId = pct.a1.id;
        pc.userACM = pct.ahm1.id;
        pc.setupTopNode();       
       
        pc.lwList[0].selectVal = '--Select--';
        pc.updateNodeList();
        System.Assert(pc.lwList.size()!=0);
        
        pc.lwList[0].selectVal = pct.ahm1.id;
        pc.updateNodeList();
        System.Assert(pc.lwList.size()!=0, '!!!!!!'+pc.lwList.size());
        
        pc.lwList[1].selectVal = pct.ahm2.id;
        pc.updateNodeList();
        System.Assert(pc.lwList.size()==3);
        
        pc.lwList[2].selectVal = pct.ahm3.id;
        pc.updateNodeList();
        System.Assert(pc.lwList.size()==3);
        
        pc.lwList[1].selectVal = '--Select--';
        pc.updateNodeList();
        System.Assert(pc.lwList.size()!=0);
        
        //getters and setters
        String val = pc.getselectedMemberId();
        val = pc.getselectedProgram();
        pc.setselectedMemberId(val);
        pc.setSelectedProgram(val);
        System.Assert(pc.lwList.size()!=0);
            }
            
 static testMethod void testExtendedListLink(){
                PortalExecutiveDashboardController_TEST pct = new PortalExecutiveDashboardController_TEST();
        pct.setupTestData();
        pct.addProgramAndLocation();
        Apexpages.currentPage().getParameters().put('id', pct.c1.id);
        PortalExecutiveDashboardController pc = new PortalExecutiveDashboardController();
        pc.accountId = pct.a1.id;
        pc.userACM = pct.ahm1.id;
        pc.setupTopNode();
        pc.lwList[0].selectVal = pct.ahm1.id;
        pc.expandedLocationLink();
        System.assert(pc.lwList.size() >0);
        
        Apexpages.currentPage().getParameters().put('id', pct.c1.id);
        Apexpages.currentPage().getParameters().put('levelIds', pct.ahm1.id+':--Select--');
        pc = new PortalExecutiveDashboardController();
        pc.accountId = pct.a1.id;
        pc.userACM = pct.ahm1.id;
        pc.setupTopNode();
        pc.expandedLocationSetup();
        System.assert(pc.lwList.size()>1);
        
        pc.nextLLPage();
        pc.previousLLPage();
        System.assert(pc.lwList.size()>1);
				String arf = pc.getselectedProgram();
        pc.setSelectedProgram('arf');
        pc.getselectedMemberId();
        pc.setselectedMemberId('123');
				System.assert(arf!=null);
            }
}