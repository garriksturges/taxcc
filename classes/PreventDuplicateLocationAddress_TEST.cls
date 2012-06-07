@isTest
Private class PreventDuplicateLocationAddress_TEST {

  private static Account AccLocation;
  private static Location__c Loc;
  
   Static{
       AccLocation= new Account(Name = 'Test Account',Type='Partner',Website='www.taxcreditco.com',BillingState ='VA',BillingPostalCode='23294',BillingStreet='Colchester Creek',BillingCity='Cumming',BillingCountry='United States');
       insert AccLocation;
     
       Loc = new Location__c(Name='Henrico Office',StreetAddressText__c='2490 Mariner Square Loop',CityName__c='Alameda',ZipCode__c='94501',Account__c=AccLocation.Id);
       insert Loc;
  } 
  static testmethod void PreventLocationDuplicate(){
       Location__c Locat = new Location__c();
       Locat.Account__c = AccLocation.Id;
       Locat.StreetAddressText__c = '2490 Mariner Square Loop'; 
       Locat.CityName__c ='Alameda';
       Locat.ZipCode__c='94501';
       //Locat.Account__c ='Test Account';
  
  insert Locat;
  update Locat;
  
 }

}