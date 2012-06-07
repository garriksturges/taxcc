trigger NAME_CreditName on Credit__c (before insert, before update) {
list<String> catIds = new list<String>();
list<String> qualIds = new list<String>();
list<String> employmentIds = new list<String>();


map<String, String> catMap = new map<String, String>();
map<String, String> qualMap = new map<String, String>();
map<String, String> entMap = new map<String, String>();
map<String, String> employeeMap = new map<String, String>();

for(Credit__c c: trigger.new){
    if(c.ProgramCategory__c != null) catIds.add(c.ProgramCategory__c);
    if(c.ProgramQualification__c != null) qualIds.add(c.ProgramQualification__c);
    if(c.EmploymentPeriodGenerated__c != null) employmentIds.add(c.EmploymentPeriodGenerated__c); 
}

for(ProgramCategory__c pc: [select name from ProgramCategory__c where id in :catIds]){
    catMap.put(pc.id, pc.Name);
}

for(ProgramQualification__c pq : [select ProgramPeriod__r.Program__r.ShortName__c from ProgramQualification__c where id in :qualIds]){
    qualMap.put(pq.id, pq.ProgramPeriod__r.Program__r.ShortName__c);
}

for(Employment__c ep : [select Entity__r.Name, Employee__r.FullNameFormula__c from Employment__c where id in :employmentIds]){
	entMap.put(ep.Id, ep.Entity__r.Name);
	employeeMap.put(ep.Id, ep.Employee__r.FullNameFormula__c);
}


map<String, Integer> fieldMax;
list<String> orderList;

for(Credit__c c: trigger.new){
    fieldMax = new map<String, Integer>();
    orderList = new list<String>();
    //fields
    if(c.EmploymentPeriodGenerated__c != null && employeeMap.get(c.EmploymentPeriodGenerated__c)!= null){
        fieldMax.put(employeeMap.get(c.EmploymentPeriodGenerated__c), 16);     
        orderList.add(employeeMap.get(c.EmploymentPeriodGenerated__c));
    }
    
    if(c.EmploymentPeriodGenerated__c != null && entMap.get(c.EmploymentPeriodGenerated__c)!= null){
        fieldMax.put(entMap.get(c.EmploymentPeriodGenerated__c), 16);     
        orderList.add(entMap.get(c.EmploymentPeriodGenerated__c));
    }
    
    
    if(c.ProgramQualification__c != null && qualMap.get(c.ProgramQualification__c) != null){
        fieldMax.put(qualMap.get(c.ProgramQualification__c), 16);
        orderList.add(qualMap.get(c.ProgramQualification__c));
    }  
    
    if(c.ProgramCategory__c != null && catMap.get(c.ProgramCategory__c)!= null){
        fieldMax.put(catMap.get(c.ProgramCategory__c), 15);     
        orderList.add(catMap.get(c.ProgramCategory__c));
    }
 
    
   if(c.StartDate__c != null && c.EndDate__c != null){
		Datetime sd = Datetime.newInstance(c.startDate__c, Time.newInstance(0,0,0,0));
		Datetime ed = Datetime.newInstance(c.EndDate__c, Time.newInstance(0,0,0,0));
		String val = sd.format('M/d/yy')+'-'+ed.format('M/d/yy');
		fieldMax.put(val, 17);
		orderList.add(val);
	}
	else if(c.StartDate__c != null && c.EndDate__c == null){
		Datetime sd = Datetime.newInstance(c.startDate__c, Time.newInstance(0,0,0,0));
		String val = sd.format('M/d/yy');
		fieldMax.put(val, 8);
		orderList.add(val);
	}
        
    NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  c.Name = nh.generateName();
}

}