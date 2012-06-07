trigger Name_Wage on Wage__c (before insert, before update) {
list<String> eIds = new list<String>();
map<String, Employment__c> eMap = new map<String, Employment__c>();
for(Wage__c w : trigger.new){
	eIds.add(w.EmploymentPeriod__c);
}
for(Employment__c e : [select Employee__r.FullNameFormula__c, Entity__r.Name from Employment__c where id in :eIds]){
	eMap.put(e.id, e);
}

map<String, Integer> fieldMax;
list<String> orderList;
Employment__c emp;
for(Wage__c w : trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	//fields
	if(w.EmploymentPeriod__c != null && eMap.get(w.EmploymentPeriod__c)!= null){
		emp = eMap.get(w.EmploymentPeriod__c);
		if(emp.Employee__r.FullNameFormula__c != null){
			fieldMax.put(emp.Employee__r.FullNameFormula__c, 31);
			orderList.add(emp.Employee__r.FullNameFormula__c);
		}
		if(emp.Entity__r.Name!= null){
			fieldMax.put(emp.Entity__r.Name, 27);
			orderList.add(emp.Entity__r.Name);			
		}
	}
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
	
	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  w.Name = nh.generateName();
}
}