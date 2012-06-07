trigger EmploymentTriggerUpdateWtkLocation on Employment__c (after insert, after update) {
list<Employment__c>eList = Trigger.new;

//get all current wkt
list <string> employeeIds = new list<String>();
for(Employment__c e:eList){
	if(e.Employee__c!=null) employeeIds.add(e.Employee__c);
}
list<wktLocationEmployeeProgram__c> wktList = [Select HireLocation__c, HireDate__c, SurveyLocation__c,
																								Employment__c, Employee__c, EmployeeSurvey__c 
																								From wktLocationEmployeeProgram__c 
																								where Employee__c in :employeeIds];

map<String, list<wktLocationEmployeeProgram__c>> wktMap = new map<string, list<wktLocationEmployeeProgram__c>>();
list<wktLocationEmployeeProgram__c> mVal;
for(wktLocationEmployeeProgram__c wkt:wktList){
	mVal = wktMap.get(wkt.employee__c);
	if(mVal == null){
		mVal = new list<wktLocationEmployeeProgram__c>();
		mVal.add(wkt);
		wktMap.put(wkt.employee__c, mVal);
	}
	else{
		mVal.add(wkt);
		wktMap.put(wkt.employee__c, mVal);
	}
}																								
//fill out new and current wkt
list<wktLocationEmployeeProgram__c> upsertList = new list <wktLocationEmployeeProgram__c>();
for(Employment__c em:eList){
	wktLocationEmployeeProgram__c wkt;
	list<wktLocationEmployeeProgram__c> wktL = wktMap.get(em.Employee__c);
	if(wktL == null){
		wkt = new wktLocationEmployeeProgram__c();
		wkt.Employee__c = em.Employee__c;
		wkt.Employment__c = em.id;
		wkt.HireLocation__c = em.Location__c;
		wkt.HireLocationName__c  = em.Location__r.Name;
		wkt.HireDate__c = em.StartDate__c;
		upsertList.add(wkt);
	}
	else{
		for(wktLocationEmployeeProgram__c wktVal: wktL){
			if(wktVal.Employment__c == null || wktVal.Employment__c == em.id){
				wkt = wktVal;
				wkt.Employee__c = em.Employee__c;
				wkt.Employment__c = em.id;
				wkt.HireLocation__c = em.Location__c;
				wkt.HireLocationName__c  = em.Location__r.Name;
				//if(wkt.HireDate__c == null) wkt.HireDate__c = em.StartDate__c; //DO NOT THINK THE IF STATEMENT IS NEEDED
				wkt.HireDate__c = em.StartDate__c;
				//if( wkt.SurveyLocation__c == null || (wkt.HireLocation__c == wkt.SurveyLocation__c)) //DO NOT THINK THIS IS NEEDED EITHER
				upsertList.add(wkt);
			}
		}
	}			
}

//update or create all wkt
upsert(upsertList);
}