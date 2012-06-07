trigger NAME_EntityFiscalYear on EntityFiscalyear__c (before insert, before update) {
list<String> eIds = new list<String>();
map<String, String> eMap = new map<String, String>();
for(EntityFiscalyear__c ef : trigger.new){
	eIds.add(ef.Entity__c);
}
for(Entity__c e: [select Name from Entity__c where id in :eIds]){
	eMap.put(e.Id, e.Name);
}
map<String, Integer> fieldMax;
list<String> orderList;
for(EntityFiscalyear__c ef: trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	if(ef.Entity__c != null && eMap.get(ef.Entity__c)!= null){
		fieldMax.put(eMap.get(ef.Entity__c), 74);
		orderList.add(eMap.get(ef.Entity__c));
	}
	if(ef.FiscalYearEndDate__c != null){
		Datetime ed = Datetime.newInstance(ef.FiscalYearEndDate__c, Time.newInstance(0,0,0,0));
		fieldMax.put(ed.format('M/yy'), 5);
		orderList.add(ed.format('M/yy'));
	}
	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  ef.Name = nh.generateName();
}

}