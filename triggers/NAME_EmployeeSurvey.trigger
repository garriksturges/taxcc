trigger NAME_EmployeeSurvey on EmployeeSurvey__c (before insert, before update) {

list<String> entityLocationIds = new list<String>();
list<String> employmentIds = new list<String>();

map<String, String> elMap = new map<String, String>();
map<String, String> entMap = new Map<string,string>();
map<String, String> employeeMap = new Map<string,string>();

for(EmployeeSurvey__c es: trigger.new){
	if(es.EntityLocation__c != null) entityLocationIds.add(es.EntityLocation__c);
	if(es.EmploymentPeriod__c != null) employmentIds.add(es.EmploymentPeriod__c);
}

for(Employment__c emp: [select Employee__r.FullNameFormula__c from Employment__c where id in :employmentIds]){
	employeeMap.put(emp.id, emp.Employee__r.FullNameFormula__c);
}

for(Employment__c ent: [select Entity__r.Name from Employment__c where id in :employmentIds]){
	entMap.put(ent.id, ent.Entity__r.Name);
}

for(EntityLocation__c eloc : [select Location__r.Name from EntityLocation__c where id in :entityLocationIds]){
	elMap.put(eloc.id, eloc.Location__r.Name);
}

map<String, Integer> fieldMax;
list<String> orderList;
for(EmployeeSurvey__c es: trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	
	//fields
	if(es.EmploymentPeriod__c != null && employeeMap.get(es.EmploymentPeriod__c)!= null){
		fieldMax.put(employeeMap.get(es.EmploymentPeriod__c), 22);		
		orderList.add(employeeMap.get(es.EmploymentPeriod__c));
	}
	
	if(es.EmploymentPeriod__c != null && entMap.get(es.EmploymentPeriod__c)!= null){
		fieldMax.put(entMap.get(es.EmploymentPeriod__c), 22);		
		orderList.add(entMap.get(es.EmploymentPeriod__c));
	}
	
	if(es.EntityLocation__c != null && elMap.get(es.EntityLocation__c) != null){
		fieldMax.put(elMap.get(es.EntityLocation__c), 22);
		orderList.add(elMap.get(es.EntityLocation__c));
	}	
	if(es.SurveyDate__c != null){
		fieldMax.put(es.SurveyDate__c.format('M/d/yy'), 8);
		orderList.add(es.SurveyDate__c.format('M/d/yy'));
	}	
	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  es.Name = nh.generateName();
}
}