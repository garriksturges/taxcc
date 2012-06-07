trigger NAME_ProgramPeriod on ProgramPeriod__c (before insert, before update) {
list<String> pIds = new list<String>();
list<String> AgIds = new list<String>();
list<String> ArIds = new list<String>();
map<String, String> pMap = new Map<String, String>();
map<String, String> AgMap = new Map<String, String>();
map<String, String> ArMap = new Map<String, String>();

for(ProgramPeriod__c pp : Trigger.new){
	pIds.add(pp.Program__c);
	ArIds.Add(pp.Area__c);
	AgIds.add(pp.Agency__c);
}
for(Program__c p : [select ShortName__c from Program__c where Id in :pIds]){
	pMap.put(p.id, p.ShortName__c);
}

for(Area__c a : [Select Name from Area__c where Id in :ArIds]){
	ArMap.Put(a.Id, a.Name);
}

for(Agency__c a : [Select Name from Agency__c where Id in :AgIds]){
	AgMap.put(a.Id, a.Name);
}



map<String, Integer> fieldMax;
list<String> orderList;
for(ProgramPeriod__c pp : trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	//fields
	if(pp.Program__c != null && pMap.get(pp.Program__c)!=null){
		fieldMax.put(pMap.get(pp.Program__c), 12);
		orderList.add(pMap.get(pp.Program__c));
	}
	
	if(pp.Agency__c!=null && AgMap.get(pp.Agency__c)!= null){
		fieldMax.put(AgMap.get(pp.Agency__c), 27);
		orderList.add(AgMap.get(pp.Agency__c));
	}
	
	if(pp.Area__c != null && ArMap.get(pp.Area__c)!= null){
		fieldMax.put(ArMap.get(pp.Area__c), 27);
		orderList.add(ArMap.get(pp.Area__c));
	}
	
	if(pp.StartDate__c != null && pp.EndDate__c != null){
		Datetime sd = Datetime.newInstance(pp.startDate__c, Time.newInstance(0,0,0,0));
		Datetime ed = Datetime.newInstance(pp.EndDate__c, Time.newInstance(0,0,0,0));
		String val = sd.format('M/yy')+'-'+ed.format('M/yy');
		fieldMax.put(val, 11);
		orderList.add(val);
	}
	else if(pp.StartDate__c != null && pp.EndDate__c == null){
		Datetime sd = Datetime.newInstance(pp.startDate__c, Time.newInstance(0,0,0,0));
		String val = sd.format('MM/yy');
		fieldMax.put(val, 5);
		orderList.add(val);
	}
	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  pp.Name = nh.generateName();
}
}