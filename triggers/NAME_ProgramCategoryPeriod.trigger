trigger NAME_ProgramCategoryPeriod on ProgramCategoryPeriod__c (before insert, before update) {

list<String> pcIds = new list<String>();
map<String, String> pcMap = new map<String, String>();

list<String> aIds = new list<String>();
map<String, String> aMap = new map<String, String>();

map<string, string> progMap = new Map<string,string>();

for(ProgramCategoryPeriod__c pcp:trigger.new){
	pcIds.add(pcp.ProgramCategory__c);
	aIds.add(pcp.Area__c);
}

for(ProgramCategory__c pc:[select Name from ProgramCategory__c where id in :pcIds]){
	pcMap.put(pc.id, pc.Name);
}

for(ProgramCategory__c pc:[select Program__r.ShortName__c from ProgramCategory__c where id in :pcIds]){
	progMap.put(pc.id, pc.Program__r.ShortName__c);
}

for(Area__c a : [select Name from Area__c where id in :aIds]){
	aMap.put(a.id, a.Name);
}

map<String, Integer> fieldMax;
list<String> orderList;
for(ProgramCategoryPeriod__c pcp: trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	
	//fields
	if(pcp.ProgramCategory__c!=null && pcMap.get(pcp.ProgramCategory__c)!=null){
		fieldMax.put(pcMap.get(pcp.ProgramCategory__c), 29);
		orderList.add(pcMap.get(pcp.ProgramCategory__c));
	}
	
	if(pcp.ProgramCategory__c!=null && progMap.get(pcp.ProgramCategory__c)!=null){
		fieldMax.put(progMap.get(pcp.ProgramCategory__c), 12);
		orderList.add(progMap.get(pcp.ProgramCategory__c));
	}
	
	if(pcp.Area__c != null && aMap.get(pcp.area__c)!=null){
		fieldMax.put(aMap.get(pcp.area__c), 28);
		orderList.add(aMap.get(pcp.area__c));
	}
	
	if(pcp.StartDate__c != null && pcp.EndDate__c != null){
		Datetime sd = Datetime.newInstance(pcp.startDate__c, Time.newInstance(0,0,0,0));
		Datetime ed = Datetime.newInstance(pcp.EndDate__c, Time.newInstance(0,0,0,0));
		String val = sd.format('M/yy')+'-'+ed.format('M/yy');
		fieldMax.put(val, 11);
		orderList.add(val);
	}
	
	else if(pcp.StartDate__c != null && pcp.EndDate__c == null){
		Datetime sd = Datetime.newInstance(pcp.startDate__c, Time.newInstance(0,0,0,0));
		String val = sd.format('M/yy');
		fieldMax.put(val, 5);
		orderList.add(val);
	}
	
	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  pcp.Name = nh.generateName();
}
}