trigger NAME_LocationProgram on LocationProgram__c (before insert, before update) {
list<String> lIds = new list<String>();
list<String> pIds = new list<String>();
map<String, String> lMap = new map<String, String>();
map<String, String> pMap = new map<String, String>();
for(LocationProgram__c lp: trigger.new){
	lIds.add(lp.location__c);
	pIds.add(lp.program__c);
}
for(Location__c l : [select Name from Location__c where id in :lIds]){
	lMap.put(l.id, l.Name);
}
for(Program__c p : [select ShortName__c from Program__c where id in :pIds]){
	pMap.put(p.id, p.ShortName__c);
}
map<String, Integer> fieldMax;
list<String> orderList;
for(LocationProgram__c lp: trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	//fields
	if(lp.Location__c != null && lMap.get(lp.Location__c)!= null){
		fieldMax.put(lMap.get(lp.Location__c), 34);
		orderList.add(lMap.get(lp.Location__c));
	}
	
	if(lp.Program__c != null && pMap.get(lp.Program__c)!=null){
		fieldMax.put(pMap.get(lp.Program__c), 33);
		orderList.add(pMap.get(lp.Program__c));
	}
	
	if(lp.StartDate__c != null && lp.EndDate__c != null){
		Datetime sd = Datetime.newInstance(lp.startDate__c, Time.newInstance(0,0,0,0));
		Datetime ed = Datetime.newInstance(lp.EndDate__c, Time.newInstance(0,0,0,0));
		String val = sd.format('M/yy')+'-'+ed.format('M/yy');
		fieldMax.put(val, 11);
		orderList.add(val);
	}
	else if(lp.StartDate__c != null && lp.EndDate__c == null){
		Datetime sd = Datetime.newInstance(lp.startDate__c, Time.newInstance(0,0,0,0));
		String val = sd.format('M/yy');
		fieldMax.put(val, 5);
		orderList.add(val);
	}
	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  lp.Name = nh.generateName();
}

}