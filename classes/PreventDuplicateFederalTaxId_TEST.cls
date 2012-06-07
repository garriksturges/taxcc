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
private class PreventDuplicateFederalTaxId_TEST {

    private static Account AccLocation;
    private static EntityStructure__c ents;
    private static Entity__c ef;
    
    static{
         AccLocation= new Account(name='test1',phone='2016742345',website='taxcreditco.com',BillingState='CA',BillingPostalCode='67890',BillingStreet='123 Anywhere',BillingCity='Somewhere',BillingCountry='United States');
        insert AccLocation;
        ef= new Entity__c (name='test2',ClientEntityId__c='1234567', Account__c=AccLocation.Id );
        insert ef;
        /*ents = new EntityStructure__c(EntityType__c='EntityType__c',CityName__c='Los Angeles',FederalTaxId__c='1234567890',
        StreetAddressText__c='400 North Hollywood',ZipCode__c='12345',EntityName__c=ef.id);
        insert ents;*/
    }
    static testMethod void PreventFederalTaxIdDuplicate(){
        EntityStructure__c entstructure = new EntityStructure__c();
        entstructure.EntityName__c=ef.id;
        entstructure.EntityType__c='C Corporation';
        entstructure.CityName__c='Los Angeles';
        entstructure.StreetAddressText__c='400 North Hollywood';
        entstructure.ZipCode__c='12345';
        entstructure.FederalTaxId__c='000000000';
        insert entstructure; 
        update entstructure;
        
    }
}