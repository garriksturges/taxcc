trigger NAME_AgencyAddress on AgencyAddress__c (before insert, before update) {
	map<String, Integer> fieldMax;
	list<String> orderList;
	list <String> aList = new list<String>();
	list<String> sList = new list<String>();
	for(AgencyAddress__c aa : trigger.new){
		aList.add(aa.Agency__c);
		sList.add(aa.State__c);	
	}
	
	list<Agency__c> agList = [select Name, id from Agency__c where id in :aList];
	map<String, String> aMap = new map<String, String>();
	for(Agency__c ag: agList){
		aMap.put(ag.Id, ag.Name);
	}
	
	list<State__c> states = [select id, StateAbbr__c from State__c where id in:sList];
	map<String, String> sMap = new map<String, String>();
	for(State__c s:states){
		sMap.put(s.id, s.StateAbbr__c);
	}
	
	for(AgencyAddress__c aa : trigger.new){
		fieldMax = new map<String, Integer>();
		orderList = new list<String>();
		if(aa.Agency__c != null && aMap.get(aa.Agency__c)!= null){
			fieldMax.put(aMap.get(aa.Agency__c), 25);
			orderList.add(aMap.get(aa.Agency__c));
		}
		if(aa.StreetAddressText__c !=null){
			fieldMax.put(aa.StreetAddressText__c, 25);
			orderList.add(aa.StreetAddressText__c);
		}
		if(aa.CityName__c !=null){
			fieldMax.put(aa.CityName__c, 24);
			orderList.add(aa.CityName__c);
		}
		if(aa.State__c  !=null && sMap.get(aa.State__c) != null){
			fieldMax.put(sMap.get(aa.State__c), 3);
			orderList.add(sMap.get(aa.State__c));
		}
		NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
		aa.Name = nh.generateName();
	}
}