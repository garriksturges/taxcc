trigger NAME_EntityStructure on EntityStructure__c (before insert, before update) {
list<String> eIds = new list<String>();
map<String, String> eMap = new map<String, String>();
list<String> sIds = new list<String>();
map<String, String> sMap = new map<String, String>();

for(EntityStructure__c el : trigger.new){
	eIds.add(el.EntityName__c);
	sIds.add(el.State__c);
}

for(Entity__c e: [select Name from Entity__c where id in :eIds]){
	eMap.put(e.Id, e.Name);
}
for(State__c st: [select StateAbbr__c from State__c where id in :sIds]){
	sMap.put(st.Id, st.StateAbbr__c);
}

map<String, Integer> fieldMax;
list<String> orderList;
for(EntityStructure__c el: trigger.new){
	fieldMax = new map<String, Integer>();
	orderList = new list<String>();
	
	if(el.EntityName__c != null && eMap.get(el.EntityName__c)!= null){
		fieldMax.put(eMap.get(el.EntityName__c), 60);
		orderList.add(eMap.get(el.EntityName__c));
	}
	
	if(el.State__c != null && sMap.get(el.State__c)!= null){
		fieldMax.put(sMap.get(el.State__c), 3);
		orderList.add(sMap.get(el.State__c));
	}
	if(el.EntityType__c != null){
		
		string entityType = '';
		if(el.EntityType__c.indexOf('(') != -1)
		{
			entityType = el.EntityType__c.substring(el.EntityType__c.indexOf('(') + 1, el.EntityType__c.length() - 1);
			
			fieldMax.put(entityType, 4);
			orderList.add(entityType);
		}
		else
		{
			entityType = el.EntityType__c.substring(0,1) + el.EntityType__c.substring(el.EntityType__c.indexOf(' ') + 1, el.EntityType__c.indexOf(' ') + 2);
			fieldMax.put(entityType, 4);
			orderList.add(entityType);			
		}		
	}
	
	if(el.FederalTaxId__c != null && el.FederalTaxId__c.length()==9){
		String val = el.FederalTaxId__c.subString(0,2)+'-'+el.FederalTaxId__c.subString(2, el.FederalTaxId__c.length());
		fieldMax.put(val, 10);
		orderList.add(val);
	}

	NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
  el.Name = nh.generateName();
}
}