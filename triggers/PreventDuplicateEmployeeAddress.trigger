/******************************************************************************************************************************************
Trigger Name : PreventDuplicateEmployeeAddress
Created By   : Nagaraju Naidu
Description  : This Trigger prevents adding a EmployeeAddress with same Employee Id, Street Address and Zip code for the same Employee.   
Modification History: 
   
*******************************************************************************************************************************************/

trigger PreventDuplicateEmployeeAddress on EmployeeAddress__c (before insert, before update) {

    Set<Id> newbpf = new Set<Id>();

    for (EmployeeAddress__c b : Trigger.new) {
        newbpf.add(b.Employee__c);
    }

    Map<String, Id> existbpf = new Map<String, Id>();
 
    for (EmployeeAddress__c ebpf : [select id, Employee__c, StreetAddressText__c,ZipCode__c from EmployeeAddress__c where Employee__c =:newbpf]) {
        existbpf.put(ebpf.Employee__c+ebpf.StreetAddressText__c + ebpf.ZipCode__c, ebpf.Id );
    }

    for (EmployeeAddress__c b2 : Trigger.new) {
        if (existbpf.containsKey(b2.Employee__c+b2.StreetAddressText__c + b2.ZipCode__c)) {
            if ((Trigger.isInsert) || ((Trigger.isUpdate) && (existbpf.get(b2.Employee__c+b2.StreetAddressText__c + b2.ZipCode__c) != b2.Id))) {
                b2.addError('That address has already been entered for this employee. No need to re-enter it, you see.');
            }
        }
    }

}