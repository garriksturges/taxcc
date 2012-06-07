trigger NAME_EntityAgreement on EntityAgreement__c (before insert, before update) {
list<String> eIds = new list<String>();
list<String> aIds = new list<String>();
map<String, String> eMap = new map<String, String>();
map<String, String> aMap = new map<String, String>();
for(EntityAgreement__c ea: trigger.new){
	eIds.add(ea.Entity__c);
	aIds.add(ea.Agency__c);
}

for(Entity__c e: [select Name from Entity__c where id in :eIds]){
	eMap.put(e.id, e.Name);
}
for(Agency__c a : [select Name from Agency__c where id in :aIds]){
	aMap.put(a.id, a.Name);
}

map<String, Integer> fieldMax;
list<String> orderList;
for(EntityAgreement__c ea: trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	//fields
	if(ea.Entity__c != null && eMap.get(ea.Entity__c)!= null){
		fieldMax.put(eMap.get(ea.Entity__c), 31);
		orderList.add(eMap.get(ea.Entity__c));
	}
	if(ea.Agency__c != null && aMap.get(ea.Agency__c)!=null){
		fieldMax.put(aMap.get(ea.Agency__c), 31);
		orderList.add(aMap.get(ea.Agency__c));
	}
	if(ea.AgreementType__c != null){
		String val;
		if(ea.AgreementType__c == 'Power of Attorney') val = 'POA';
		else if(ea.AgreementType__c == 'Pre-authorization') val = 'Auth';
		else val = ea.AgreementType__c;
		fieldMax.put(val, 4);
		orderList.add(val);
	}
	if(ea.StartDate__c != null && ea.EndDate__c != null){
		Datetime sd = Datetime.newInstance(ea.startDate__c, Time.newInstance(0,0,0,0));
		Datetime ed = Datetime.newInstance(ea.EndDate__c, Time.newInstance(0,0,0,0));
		String val = sd.format('M/yy')+'-'+ed.format('M/yy');
		fieldMax.put(val, 11);
		orderList.add(val);
	}
	else if(ea.StartDate__c != null && ea.EndDate__c == null){
		Datetime sd = Datetime.newInstance(ea.startDate__c, Time.newInstance(0,0,0,0));
		String val = sd.format('M/yy');
		fieldMax.put(val, 5);
		orderList.add(val);
	}
	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  ea.Name = nh.generateName();
}
}