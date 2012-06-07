trigger SurveyProgramTriggerUpdateWkt on SurveyProgramScreened__c (after insert, after update) {
	//get employee ID's
	list<String> eList = new list<String>(); 
	list<String> spsIds  = new list<String>();
	
	for(SurveyProgramScreened__c sps:Trigger.new){
			spsIds.add(sps.Id);	
		}
	list<SurveyProgramScreened__c> spsl = [select Survey__r.EntityLocation__r.Location__c, Survey__r.ReportedHireDate__c, Survey__r.EmploymentPeriod__r.Employee__c, Survey__r.EmploymentPeriod__r.Employee__r.Name,
																				Program__c, Program__r.ShortName__c, Program__r.ProgramStartSummary__c, Program__r.ProgramEndSummary__c, Survey__c, Survey__r.SurveyDate__c
																				from  SurveyProgramScreened__c where id in :spsIds and Survey__r.EmploymentPeriod__r.Employee__c != null];

	for(SurveyProgramScreened__c sps : spsl){
		eList.add(sps.Survey__r.EmploymentPeriod__r.Employee__c);
	}

																				
	//get existing wkts
	list<wktLocationEmployeeProgram__c> wktList = [Select SurveyProgramScreened__c, SurveyLocation__c, SurveyDate__c, Program__c, Name,
																								ProgramStartDate__c, ProgramEndDate__c, HireLocation__c, HireDate__c, ProgramQualification__c,
																								Employment__c, Employee__c, EmployeeSurvey__c, HireLocationName__c, EmployeeName__c
																								From wktLocationEmployeeProgram__c
																								where Employee__c in :eList];
	//system.debug('wktList Size!!!!!'+spsl.size());																							
	
	map<String, list<wktLocationEmployeeProgram__c>> wktMap = new map<String, list<wktLocationEmployeeProgram__c>>();
	for(wktLocationEmployeeProgram__c wkt: wktList){
		list<wktLocationEmployeeProgram__c> subList = wktMap.get(wkt.Employee__c);
		if(sublist == null){
			subList = new list<wktLocationEmployeeProgram__c>();
			subList.add(wkt);
			wktMap.put(wkt.employee__c, subList);
		}
		else{
			sublist.add(wkt);
			wktMap.put(wkt.employee__c, subList);
		}
	}
	
	
	wktLocationEmployeeProgram__c wktVal;
	set<wktLocationEmployeeProgram__c> deleteSet = new set<wktLocationEmployeeProgram__c>();
	list<wktLocationEmployeeProgram__c> upsertList = new list<wktLocationEmployeeProgram__c>();
	for(SurveyProgramScreened__c sps : spsl){
		//System.debug('HEREHREHERHERHEHREHRE'+sps.Survey__r.EmploymentPeriod__r.Employee__c);
		if(sps.Survey__r.EmploymentPeriod__r.Employee__c != null){
			wktList  = wktMap.get(sps.Survey__r.EmploymentPeriod__r.Employee__c);
			if(wktList == null){
				wktVal = new wktLocationEmployeeProgram__c();
				
			}
			else{
				wktLocationEmployeeProgram__c wktA= null;
				wktLocationEmployeeProgram__c wktB= null;
				wktLocationEmployeeProgram__c wktC= null;
				for(wktLocationEmployeeProgram__c w : wktList){
					if(w.SurveyProgramScreened__c== null && (w.Program__c == null || w.Program__c == sps.Program__c)) wktB = w;
					else if(w.SurveyProgramScreened__c == sps.Id) wktA = w;
					else wktC = w;
				}
				if(wktA != null){
					wktVal = wktA;					
				}
				else if(wktB != null){
					
					wktVal = new wktLocationEmployeeProgram__c();
					wktVal.Employment__c = wktB.employment__c;
					wktVal.HireLocation__c = wktB.HireLocation__c;
					wktVal.HireLocationName__c  = wktB.HireLocationName__c;
					wktVal.HireDate__c = wktB.HireDate__c;
					deleteSet.add(wktB);
				}
				else{
					wktVal = new wktLocationEmployeeProgram__c();
					wktVal.Employment__c = wktC.employment__c;
					wktVal.HireLocation__c = wktC.HireLocation__c;
					wktVal.HireLocationName__c  = wktC.HireLocationName__c;
					wktVal.HireDate__c = wktC.HireDate__c;
				}		
			}
			if(sps.Survey__r.ReportedHireDate__c !=null) wktVal.HireDate__c = sps.Survey__r.ReportedHireDate__c;
			wktVal.SurveyProgramScreened__c = sps.id;
			wktVal.SurveyLocation__c = sps.Survey__r.EntityLocation__r.Location__c;
			wktVal.Employee__c = sps.Survey__r.EmploymentPeriod__r.Employee__c;
			wktVal.EmployeeName__c = sps.Survey__r.EmploymentPeriod__r.Employee__r.Name;
			wktVal.Program__c = sps.Program__c;
			wktVal.ProgramName__c = sps.Program__r.ShortName__c;
			wktVal.ProgramStartDate__c= sps.Program__r.ProgramStartSummary__c; 
			wktVal.ProgramEndDate__c = sps.Program__r.ProgramEndSummary__c;
			wktVal.EmployeeSurvey__c = sps.Survey__c;
			wktVal.SurveyDate__c=sps.Survey__r.SurveyDate__c;			
			upsertList.add(wktVal);
		}
	}
	/*
	for(wktLocationEmployeeProgram__c wkt : wktList){
		wktMap.put(wkt.employee__c, wkt);
	}																		
	//add updated/new wkt to list
	list <wktLocationEmployeeProgram__c> upsertList = new list<wktLocationEmployeeProgram__c>();
	for(SurveyProgramScreened__c sps:Trigger.new){
		wktLocationEmployeeProgram__c wkt = wktMap.get(sps.Survey__r.EmploymentPeriod__r.Employee__c);
		if(wkt == null || (wkt.SurveyProgramScreened__c != null && wkt.SurveyProgramScreened__c != sps.id)){
			if(wkt == null){
				wkt = new wktLocationEmployeeProgram__c();
				wkt.SurveyProgramScreened__c = sps.id;
			}
			else if(wkt != null && wkt.Employment__c != null && wkt.SurveyProgramScreened__c == null){
				wkt.SurveyProgramScreened__c = sps.id;
			}
			else{
				wktLocationEmployeeProgram__c wkto = wkt;
				wkt = new wktLocationEmployeeProgram__c();
				wkt.SurveyProgramScreened__c = sps.id;
				wkt.Employment__c = wkto.employment__c;
				wkt.HireLocation__c = wkto.HireLocation__c;
				wkt.HireDate__c = wkto.HireDate__c;
			}
				wkt.SurveyLocation__c = sps.Survey__r.EntityLocation__r.Location__c;
				wkt.Employee__c = sps.Survey__r.EmploymentPeriod__r.Employee__c;
				wkt.EmployeeName__c = sps.Survey__r.EmploymentPeriod__r.Employee__r.Name;
				wkt.Program__c = sps.Program__c;
				wkt.ProgramName__c = sps.Program__r.ShortName__c;
				wkt.ProgramStartDate__c= sps.Program__r.ProgramStartSummary__c; 
				wkt.ProgramEndDate__c = sps.Program__r.ProgramEndSummary__c;
				wkt.EmployeeSurvey__c = sps.Survey__c;
				wkt.SurveyDate__c=sps.Survey__r.SurveyDate__c;
				if(wkt.HireLocationName__c == null || wkt.SurveyLocation__c == null || (wkt.HireLocation__c == wkt.SurveyLocation__c))
					upsertList.add(wkt);
		}
	}	
	*/
	upsert(upsertList);
	list<wktLocationEmployeeProgram__c> dList = new list<wktLocationEmployeeProgram__c>();
	dList.addAll(deleteSet);	
	delete(dList);						
}