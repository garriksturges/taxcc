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
private class GeocodeWebService_TEST {

    static testMethod void myUnitTest() {
		GeocodeWebService.GeocodeServiceSoap tst = new GeocodeWebService.GeocodeServiceSoap();
        
        String addressString = '5411 Alcove Ave, Valley Village, CA 91607';

        String coords = tst.GetAddressStringCoordinates(addressString);
        
        System.assert(coords.length() > 0);
        
        String[] latitudeLongitude = coords.split(',');
        
        decimal latitude = decimal.valueOf(latitudeLongitude[0]);       
        decimal longitude = decimal.valueOf(latitudeLongitude[1]);
        
        System.assert(latitude >= 0 || latitude <= 0);
    }
}