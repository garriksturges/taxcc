/******************************************************************************************************************************************
Trigger Name : PreventDuplicateLocationAddress
Created By   : Nagaraju Naidu
Description  : This Trigger prevents adding a Location with same Location Name Street Address & Zip code.   
Modification History: 
   
*******************************************************************************************************************************************/

trigger PreventDuplicateLocationAddress on Location__c (before insert, before update) {

    Set<Id> newbpf = new Set<Id>();
    for (Location__c b : Trigger.new) {
        newbpf.add(b.Account__c);
    }

    Map<String, Id> existbpf = new Map<String, Id>();
    
    for (Location__c ebpf : [select id, Account__c, Name, StreetAddressText__c,ZipCode__c from Location__c where Account__c in: newbpf]) {
        existbpf.put(ebpf.Name+ebpf.StreetAddressText__c + ebpf.ZipCode__c, ebpf.Id );
    }

    for (Location__c b2 : Trigger.new) {
        if (existbpf.containsKey(b2.Name + b2.StreetAddressText__c + b2.ZipCode__c)) {
            if ((Trigger.isInsert) || ((Trigger.isUpdate) && (existbpf.get(b2.Name + b2.StreetAddressText__c + b2.ZipCode__c) != b2.Id))) {
                b2.addError('That location already exists. If you really want to add another location at the same address, at least name it differently.');
            }
        }
    }
}