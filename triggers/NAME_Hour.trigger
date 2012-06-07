trigger NAME_Hour on Hour__c (before insert, before update) {
list<String> wIds = new list<String>();
map <string, string> wMap = new map<String, String>();
list<String> lIds = new list<String>();
map <String, String> lMap = new map<String, String>();
map<string, Wage__c> wMap2 = new map<String, Wage__c>();
for(Hour__c h : trigger.new){
	wIds.add(h.Wage__c);
	lIds.add(h.Location__c);
}

for(Wage__c w :[select EmploymentPeriod__r.Employee__r.FullNameFormula__c, StartDate__c, EndDate__c from Wage__c where id in :wIds]){
	wMap.put(w.id, w.EmploymentPeriod__r.Employee__r.FullNameFormula__c);
	wMap2.put(w.id, w);
}
for(Location__c l : [select Name from Location__c where id in :lIds]){
	lMap.put(l.id, l.Name);
}

map<String, Integer> fieldMax;
list<String> orderList;
for(Hour__c h: trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	//fields
	if(h.Wage__c != null && wMap.get(h.Wage__c)!= null){
		fieldMax.put(wMap.get(h.Wage__c), 31);
		orderList.add(wMap.get(h.Wage__c));
	}
	if(h.Location__c != null && lMap.get(h.location__c)!= null){
		fieldMax.put(lMap.get(h.location__c), 30);
		orderList.add(lMap.get(h.Location__c));
	}
	if(h.Wage__c != null && wMap2.get(h.Wage__c)!= null){
		Wage__c w = wMap2.get(h.Wage__c);
		if(w.StartDate__c != null && w.EndDate__c != null){
			Datetime sd = Datetime.newInstance(w.startDate__c, Time.newInstance(0,0,0,0));
			Datetime ed = Datetime.newInstance(w.EndDate__c, Time.newInstance(0,0,0,0));
			String val = sd.format('M/d/yy')+'-'+ed.format('M/d/yy');
			fieldMax.put(val, 17);
			orderList.add(val);
		}
		else if(w.StartDate__c != null && w.EndDate__c == null){
			Datetime sd = Datetime.newInstance(w.startDate__c, Time.newInstance(0,0,0,0));
			String val = sd.format('M/d/yy');
			fieldMax.put(val, 8);
			orderList.add(val);
		}
	}
	
	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  h.Name = nh.generateName();
}
}