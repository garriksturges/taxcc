trigger NAME_Employment on Employment__c (before insert, before update) {
list<String> emIds = new list<String>();
list<String> entIds = new list<String>();
map<String, String> emMap= new map<String, String>();
map <String, String> entMap = new map <String, string>();
for(Employment__c em : trigger.new){
	emIds.add(em.Employee__c);
	entIds.add(em.Entity__c);
}

for(Employee__c e: [select FullNameFormula__c from employee__c where Id in :emIds]){
	emMap.put(e.id, e.FullNameFormula__c);
}

for(Entity__c e:[select name from Entity__c where Id in :entIds]){
	entMap.put(e.id, e.Name);
}
map<String, Integer> fieldMax;
list<String> orderList;
for(Employment__c e : trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	//fields
	if(e.Employee__c != null && emMap.get(e.Employee__c) != null){
		fieldMax.put(emMap.get(e.Employee__c), 35);
		orderList.add(emMap.get(e.Employee__c));
	}
	if(e.Entity__c != null && entMap.get(e.Entity__c) != null){
		fieldMax.put(entMap.get(e.Entity__c), 35);
		orderList.add(entMap.get(e.Entity__c));
	}
	if(e.StartDate__c != null){
		Time t= Time.newInstance(0, 0, 0, 0);
		Datetime dt = Datetime.newInstance(e.StartDate__c, t);
		fieldMax.put(dt.format('M/d/yy'), 8);
		orderList.add(dt.format('M/d/yy'));
	}
		
	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  e.Name = nh.generateName();
}


}