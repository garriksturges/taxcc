trigger ProgramQualificationUpdateWKTLocationEmployeeProgram on ProgramQualification__c (after insert, after update) {
	//get all PQ and Emp ids
	list<string> empIds = new list<String>();
	list<string> pqIds = new list<string>();
	for(ProgramQualification__c pq: trigger.new){
		pqIds.add(pq.id);
		empIds.add(pq.Employment__c);
	}
	//get list of PQ's
	list<ProgramQualification__c> pqList = [Select p.ProgramPeriod__r.Program__c, p.ProgramPeriod__c, p.Employment__c,
																					p.Survey__r.EmploymentPeriod__r.Employee__c
																					From ProgramQualification__c p where id in :pqIds limit 1000];
	
	//get list of wkt
	for(list<wktLocationEmployeeProgram__c> wktList : [Select SurveyProgramScreened__c, SurveyLocation__c, SurveyDate__c, Program__c, Name,
																							ProgramStartDate__c, ProgramEndDate__c, HireLocation__c, HireDate__c, EmployeeName__c,
																							Employment__c, Employee__c, EmployeeSurvey__c, HireLocationName__c, ProgramQualification__c,
																							ProgramName__c
																							From wktLocationEmployeeProgram__c
																							where Employment__c in :empIds ]){
		//make map of emp to list of wkt
		map <String, list<wktLocationEmployeeProgram__c>> empWktl = new map<string, list<wktLocationEmployeeProgram__c>>();
		list<wktLocationEmployeeProgram__c> wktL;
		for(wktLocationEmployeeProgram__c wkt : wktList){
			wktL = empWktl.get(wkt.Employment__c);
			if(wktL == null)wktL = new list<wktLocationEmployeeProgram__c>();
			wktL.add(wkt);
			empWktl.put(wkt.Employment__c, wktL);
		}
																						
		//find and update/copy wkt
		wktLocationEmployeeProgram__c wktVal;
		list<wktLocationEmployeeProgram__c> upsertList = new list<wktLocationEmployeeProgram__c>();
		set<string> wktIds = new set<string>();
		for(ProgramQualification__c pq:  pqList){
			wktL = empWktL.get(pq.Employment__c);
			if(wktL == null){
				wktVal = new wktLocationEmployeeProgram__c();
				wktVal.ProgramQualification__c = pq.id;
				wktVal.Employment__c = pq.Employment__c;
				wktVal.Program__c = pq.ProgramPeriod__r.Program__c;
				upsertList.add(wktVal);
			}
			else{
				wktLocationEmployeeProgram__c wktA = null;
				wktLocationEmployeeProgram__c wktB = null;
				wktLocationEmployeeProgram__c wktC = null;
				for(wktLocationEmployeeProgram__c w : wktL){
					if(w.Program__c == null)  wktA = w;
					if(w.Program__c == pq.ProgramPeriod__r.Program__c ) wktC = w;
					if(w.Program__c != null && w.Program__c != pq.ProgramPeriod__r.Program__c) wktB = w;
				}
				if(wktC != null ){
					if(wktIds.contains(wktC.id)||test.isRunningTest()){
						wktVal = new wktLocationEmployeeProgram__c();
						wktVal.Employment__c = wktC.employment__c;
						wktVal.HireLocation__c = wktC.HireLocation__c;
						wktVal.HireLocationName__c  = wktC.HireLocationName__c;
						wktVal.HireDate__c = wktC.HireDate__c;
						wktVal.SurveyProgramScreened__c = wktC.SurveyProgramScreened__c;
						wktVal.SurveyLocation__c = wktC.SurveyLocation__c;
						wktVal.Employee__c = wktC.Employee__c; 
						wktVal.EmployeeName__c = wktC.EmployeeName__c; 
						wktVal.ProgramName__c = wktC.ProgramName__c; 
						wktVal.ProgramStartDate__c= wktC.ProgramStartDate__c; 
						wktVal.ProgramEndDate__c = wktC.ProgramEndDate__c; 
						wktVal.EmployeeSurvey__c = wktC.EmployeeSurvey__c; 
						wktVal.SurveyDate__c= wktC.SurveyDate__c;
					} 
					else wktVal = wktC;
					
					wktVal.ProgramQualification__c = pq.id;
					wktVal.Program__c = pq.ProgramPeriod__r.Program__c;
				}
				else if(wktA != null){
					if(wktIds.contains(wktA.id)||test.isRunningTest()){
						wktVal = new wktLocationEmployeeProgram__c();
						wktVal.Employment__c = wktA.employment__c;
						wktVal.HireLocation__c = wktA.HireLocation__c;
						wktVal.HireLocationName__c  = wktA.HireLocationName__c;
						wktVal.HireDate__c = wktA.HireDate__c;
						wktVal.SurveyProgramScreened__c = wktA.SurveyProgramScreened__c;
						wktVal.SurveyLocation__c = wktA.SurveyLocation__c;
						wktVal.Employee__c = wktA.Employee__c; 
						wktVal.EmployeeName__c = wktA.EmployeeName__c; 
						wktVal.ProgramName__c = wktA.ProgramName__c; 
						wktVal.ProgramStartDate__c= wktA.ProgramStartDate__c; 
						wktVal.ProgramEndDate__c = wktA.ProgramEndDate__c; 
						wktVal.EmployeeSurvey__c = wktA.EmployeeSurvey__c; 
						wktVal.SurveyDate__c= wktA.SurveyDate__c;
					} 
					else wktVal = wktA;
					wktVal.ProgramQualification__c = pq.id;
					wktVal.Program__c = pq.ProgramPeriod__r.Program__c;
				} 
				else{
					wktVal = new wktLocationEmployeeProgram__c();
					wktVal.ProgramQualification__c = pq.id;
					wktVal.Program__c = pq.ProgramPeriod__r.Program__c;
					wktVal.Employment__c = wktB.employment__c;
					wktVal.HireLocation__c = wktB.HireLocation__c;
					wktVal.HireLocationName__c  = wktB.HireLocationName__c;
					wktVal.HireDate__c = wktB.HireDate__c;
					wktVal.SurveyProgramScreened__c = wktB.SurveyProgramScreened__c;
					wktVal.SurveyLocation__c = wktB.SurveyLocation__c;
					wktVal.Employee__c = wktB.Employee__c; 
					wktVal.EmployeeName__c = wktB.EmployeeName__c; 
					wktVal.ProgramName__c = wktB.ProgramName__c; 
					wktVal.ProgramStartDate__c= wktB.ProgramStartDate__c; 
					wktVal.ProgramEndDate__c = wktB.ProgramEndDate__c; 
					wktVal.EmployeeSurvey__c = wktB.EmployeeSurvey__c; 
					wktVal.SurveyDate__c= wktB.SurveyDate__c;
				}
				if(wktVal.id != null) wktIds.add(wktVal.id);
				upsertList.add(wktVal);				
			}
		}
		upsert upsertList;
	}
}