trigger NAME_EmployeeAddress on EmployeeAddress__c (before insert, before update) {
list<String> eIds = new list<String>();
list<String> sIds = new list<String>();
map<String, String> eMap = new Map<String, String>();
map<String, String> sMap = new Map<String, String>();

for(EmployeeAddress__c ea: trigger.new){
    eIds.add(ea.Employee__c);
    sIds.add(ea.State__c);
}

for(Employee__c e :[select Name from Employee__c where id in :eIds]){
    eMap.put(e.Id, e.Name);
}

for(State__c s : [select id, StateAbbr__c from State__c where id in :sIds]){
    sMap.put(s.id, s.StateAbbr__c);
}

map<String, Integer> fieldMax;
list<String> orderList;
for(EmployeeAddress__c ea: trigger.new){
    fieldMax = new map<String, Integer>();
    orderList = new list<String>();

    if(ea.Employee__c != null && eMap.get(ea.Employee__c) != null){
        fieldMax.put(eMap.get(ea.Employee__c), 25);
        orderList.add(eMap.get(ea.Employee__c));
    }
    if(ea.StreetAddressText__c != null){
        fieldMax.put(ea.StreetAddressText__c, 25);
        orderList.add(ea.StreetAddressText__c);
    }
    if(ea.CityName__c != null){
        fieldMax.put(ea.CityName__c, 24);
        orderList.add(ea.CityName__c);
    }
    if(ea.State__c!= null && sMap.get(ea.State__c)!= null){
        fieldMax.put(sMap.get(ea.State__c), 3);
        orderList.add(sMap.get(ea.State__c));
    }
    
    NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  ea.Name = nh.generateName();
  
}


}