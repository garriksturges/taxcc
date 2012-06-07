trigger NAME_EntityLocation on EntityLocation__c (before insert, before update) {
list<String> eIds = new list<String>();
map<String, String> eMap = new map<String, String>();
list<String> lIds = new list<String>();
map<String, String> lMap = new map<String, String>();

for(EntityLocation__c el : trigger.new){
	eIds.add(el.Entity__c);
	lIds.add(el.Location__c);
}

for(Entity__c e: [select Name from Entity__c where id in :eIds]){
	eMap.put(e.Id, e.Name);
}
for(Location__c e: [select Name from Location__c where id in :lIds]){
	lMap.put(e.Id, e.Name);
}


map<String, Integer> fieldMax;
list<String> orderList;
for(EntityLocation__c el: trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	if(el.Entity__c != null && eMap.get(el.Entity__c)!= null){
		fieldMax.put(eMap.get(el.Entity__c), 40);
		orderList.add(eMap.get(el.Entity__c));
	}
	if(el.Location__c != null && lMap.get(el.Location__c)!= null){
		fieldMax.put(lMap.get(el.Location__c), 39);
		orderList.add(lMap.get(el.Location__c));
	}
	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  el.Name = nh.generateName();
}

}