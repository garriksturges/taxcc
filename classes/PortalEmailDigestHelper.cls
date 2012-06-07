public with sharing class PortalEmailDigestHelper {
	public list <String> programList;
	public list <String> locationIds;
	public set<String> qualificationSet;
	public integer LIST_SIZE_LIMIT = 1000;
	/*********************************/
	public PortalEmailDigestHelper(map<string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats){
		//get list of programs
		setupProgramList(locationStats);
		//get list of locationIds
		setupLocationIdsList(locationStats);	
	}
	/*********************************/
	public list<list<PortalEmailDigestHelper.employeeDigestSubClass>> generateSingleEmployeeLists(map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap){
		if(employeeStatsMap == null){
			list<list<PortalEmailDigestHelper.employeeDigestSubClass>> nullVl = new list<list<PortalEmailDigestHelper.employeeDigestSubClass>>();
			nullVl.add(null);
			nullVl.add(null);
			return nullVl;
		}
		
		list<PortalEmailDigestHelper.employeeDigestSubClass> rVals = new list<PortalEmailDigestHelper.employeeDigestSubClass>();
		list<PortalEmailDigestHelper.employeeDigestSubClass> eList;
		//get employees by id and number of records
		map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> eMap = generateEmployeeRecordsMap(employeeStatsMap);
		//make list with filtering
		set<String> keys = eMap.keySet();
		for(string key:keys){
			eList = eMap.get(key);
			if(eList.size()==1) rVals.add(eList[0]);
			else rVals.add(makeDisplayEd(eList));
		}
		return seperateLists(rVals);
	}
	/*********************************/
	public list<list<PortalEmailDigestHelper.employeeDigestSubClass>> seperateLists(list<PortalEmailDigestHelper.employeeDigestSubClass> masterList){
		list<PortalEmailDigestHelper.employeeDigestSubClass> unscreenedList = new list<PortalEmailDigestHelper.employeeDigestSubClass>();
		list<PortalEmailDigestHelper.employeeDigestSubClass> doc8List = new list<PortalEmailDigestHelper.employeeDigestSubClass>();
		for(PortalEmailDigestHelper.employeeDigestSubClass val : masterList){
			if(val.screened == 'Unscreened') unscreenedList.add(val);
			//if(val.processStageEID == 8) doc8List.add(val);
			if(val.dNeeded != '—'|| val.dReplace != '—') doc8List.add(val);
		}
		 list<list<PortalEmailDigestHelper.employeeDigestSubClass>> rval = new list<list<PortalEmailDigestHelper.employeeDigestSubClass>>();
		 rval.add(unscreenedList);
		 rval.add(doc8List);
		return rval;
	}
	/*********************************/
	public employeeDigestSubClass makeDisplayEd(list<employeeDigestSubClass> eList){
		employeeDigestSubClass rVal;
		for(employeeDigestSubClass ed : eList){
			if(rVal == null) rVal = ed;
			else{
				//screening
				if(ed.screened == 'Unscreened') rVal.screened = ed.screened;
				//document
				/*if(ed.statusRank > rVal.statusRank){
					rVal.statusRank = ed.statusRank;
					rval.screeningStatus = ed.screeningStatus;
				}*/
				
				if(rVal.dNeeded == null) rVal.dNeeded = ed.dNeeded;
				else{
					if(ed.dNeeded != '—'){
						if(rVal.dNeeded == '—') rVal.dNeeded = ed.dNeeded;
						else rVal.dNeeded +='; '+ed.dNeeded;
					}
				}
				if(rVal.dReplace == null) rVal.dReplace = ed.dReplace;
				else{
					if(ed.dReplace != '—'){
						if(rVal.dReplace == '—') rVal.dReplace = ed.dReplace;
						else rVal.dReplace +='; '+ed.dReplace;
					}
				}
				
				if(ed.qualified == 'Yes') rVal.qualified = ed.qualified;
			}
		}
		return rVal;
	}
	/*********************************/
	public map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> generateEmployeeRecordsMap(map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap){
		map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> rVal = new map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>>();
		set<string> progs = employeeStatsMap.keySet();
		list<PortalEmailDigestHelper.employeeDigestSubClass> eList;
		list<PortalEmailDigestHelper.employeeDigestSubClass> newEList;
		string eid;
		for(String key:progs){
			eList = employeeStatsMap.get(key);
			if(eList!=null){
				for(PortalEmailDigestHelper.employeeDigestSubClass ed : eList){
					newEList = rVal.get(ed.employeeId);
					if(newEList == null){
						newEList = new list<PortalEmailDigestHelper.employeeDigestSubClass>();
						newElist.add(ed);
						rVal.put(ed.employeeId, newEList);
					}
					else{
						newEList.add(ed);
						rVal.put(ed.employeeId, newEList);
					}
				}
			}
		}
		return rVal;
	}
	/*********************************/
	public map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> generateEmployeeMap(Date startDate, Date endDate){
	//public list<PortalEmailDigestHelper.employeeDigestSubClass> generateEmployeeMap(Date startDate, Date endDate){
		if(locationIds == null || locationIds.size() == 0) return null;
		map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> rVal = new map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>>();
		list <wktLocationEmployeeProgram__c> wktList;
		list<PortalEmailDigestHelper.employeeDigestSubClass> mapList;
		for(string prog:programList){
			//get all wkts
			//wktList = employeeWktList(prog, endDate.addDays(-90), endDate);//CHANGED TO BE IN LAST 90 DAYS
			//wktList = employeeWktList(prog, endDate.addYears(-91), endDate);//FOR TESTING!!!
			wktList = employeeWktList(prog, startDate, endDate);
			qualificationSet= new set<String>();
			if(wktList != null && wktList.size()>0){
				//setup qualification set
				setupQualificationSet(wktList, wktList[0].Program__c);
				//make list of employee subclass
				mapList = makeMapLists(wktList);
				rVal.put(prog, mapList);
			}
			else rVal.put(prog, null);
		}
		return rVal;
	}
	/*********************************/
	public void setupQualificationSet(list <wktLocationEmployeeProgram__c> wktList, string pId){
		list<String> eIds = new list<String>();
		for(wktLocationEmployeeProgram__c wkt : wktList){
			eIds.add(wkt.Employment__c);
		}
		list<ProgramQualification__c> pqList = [Select ProgramPeriod__r.Program__c, ProgramPeriod__c, Name, Employment__c 
																						From ProgramQualification__c 
																						where ProgramPeriod__r.Program__c = :pId
																						and Employment__c in :eIds];
		for(ProgramQualification__c pq:pqList){
			qualificationSet.add(pq.Employment__c);
		}
	}
	/*********************************/
	public list<PortalEmailDigestHelper.employeeDigestSubClass> makeMapLists(list <wktLocationEmployeeProgram__c> wktList){
		list<PortalEmailDigestHelper.employeeDigestSubClass> mapList = new list<PortalEmailDigestHelper.employeeDigestSubClass>();
		for(wktLocationEmployeeProgram__c wkt:wktList){
			mapList.add(makeEmployeeDigest(wkt));
		}
		return mapList;
	}
	/*********************************/
	public list<wktLocationEmployeeProgram__c> employeeWktList(String prog, Date sd, Date ed){
		list<wktLocationEmployeeProgram__c> wktList = [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Program__r.Name, Employment__c,Employment__r.Location__c,
																		 							ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Status__c, Employee__r.SSN__c,
																									HireLocation__c, HireDate__c, Employee__c, Employee__r.LastName__c,Employee__r.FirstName__c, EmployeeName__c,
																									QualificationProcessStage__r.RankOrder__c, QualificationProcessStage__r.Name, QualificationProcessStage__c,
																									QualificationProcessStage__r.QualificationProcessStageEID__c, Employment__r.EndDate__c, EmployeeFullNameFormula__c,
																									Employment__r.SurveyProject__c, Employment__r.SurveyProject__r.SendNotificationBit__c,
																									DocumentReplacementNeededText__c, DocumentReceivedText__c, DocumentNeededText__c 
																		 							From wktLocationEmployeeProgram__c 
																		 							where HireLocation__c in :locationIds
																		 							and HireDate__c >= :sd
																		 							and HireDate__c <= :ed
																		 							and (Program__r.Name = :prog or Program__c = null)//Program__r.shortName__c = :prog
																		 							and Employment__r.EndDate__c = null //not terminated
																		 							//and(SurveyDate__c = null or(SurveyDate__c>=:sd and QualificationProcessStage__r.QualificationProcessStageEID__c = 8))//not surveyed or process stage of 8
																		 							and(SurveyDate__c = null or(SurveyDate__c>=:sd))//not surveyed or process stage of 8
																		 							and(Employment__r.SurveyProject__c = null or (Employment__r.SurveyProject__c != null and Employment__r.SurveyProject__r.SendNotificationBit__c != false))
																		 							order by Employee__r.LastName__c
																		 							limit :LIST_SIZE_LIMIT];
		//system.assert(false, locationIds.size());
		return wktList;
	}
	/*********************************/
	public void setupProgramList(map<string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats){
		programList = new list<String>();
		programList.addAll(locationStats.keySet());
		programList.sort();
	}
	/*********************************/
	public void setupLocationIdsList(map<string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats){
		locationIds = new list<String>();
		list<PortalExecutiveDashboardController.locationProgramWrapper> lwList;
		for(String program : programList){
			lwList = locationStats.get(program);
			for(PortalExecutiveDashboardController.locationProgramWrapper lw: lwList){
				locationIds.add(lw.lp.Location__c);
			}			
		}
	}
	/*********************************/
	public employeeDigestSubClass makeEmployeeDigest(wktLocationEmployeeProgram__c wkt){
		employeeDigestSubClass ed = new employeeDigestSubClass();
		//employeeid
		ed.employeeId = wkt.EmployeeFullNameFormula__c;
		//name
		ed.name = wkt.EmployeeName__c;
		//hire date
		ed.hiredDate = String.valueOf(wkt.HireDate__c);
		//survey date/Screened
		if(wkt.SurveyDate__c !=null) ed.screened = 'Screened';//wkt.SurveyDate__c.format('MM/dd/yy');
		else ed.screened = 'Unscreened';
		//screening status
		if(wkt.Program__c != null && wkt.Program__r.shortName__c.equalsIgnoreCase('WOTC')){
			if(wkt.SurveyDate__c !=null) ed.screeningStatus = '--';
			else if(wkt.SurveyDate__c.Date() == null || wkt.SurveyDate__c.Date()>wkt.HireDate__c) ed.screeningStatus = 'Incorrect';
			else ed.screeningStatus = 'Correct';
		}
		else{
			if(wkt.SurveyDate__c != null && wkt.SurveyDate__c <= Datetime.now()) ed.screeningStatus = 'Correct';
			else ed.screeningStatus = 'Incorrect';
		}
		//qualified
		if(qualificationSet.contains(wkt.Employment__c)) ed.qualified = 'Yes';
		else ed.qualified = 'No';
		//documents
		if(wkt.QualificationProcessStage__c != null){
			ed.processStageEID = wkt.QualificationProcessStage__r.QualificationProcessStageEID__c;
			if(wkt.QualificationProcessStage__r.Name !=null) ed.documentStatus = wkt.QualificationProcessStage__r.Name;
			else ed.documentStatus='none';
			if(wkt.QualificationProcessStage__r.RankOrder__c !=null) ed.statusRank = integer.valueOf(wkt.QualificationProcessStage__r.RankOrder__c);
			else ed.statusRank = 0;
		}
		else{
			 ed.documentStatus = 'none';
			 ed.statusRank = 0;
		}
		if(wkt.DocumentReplacementNeededText__c == null || wkt.DocumentReplacementNeededText__c == '') ed.dReplace = '—';
    else ed.dReplace = wkt.DocumentReplacementNeededText__c;
    if(wkt.DocumentReceivedText__c == null || wkt.DocumentReceivedText__c == '') ed.dReceived = '—';
    else ed.dReceived = wkt.DocumentReceivedText__c;
    if(wkt.DocumentNeededText__c == null || wkt.DocumentNeededText__c == '') ed.dNeeded = '—';
    else ed.dNeeded = wkt.DocumentNeededText__c;
		//SSN 
		ed.ssn = wkt.Employee__r.SSN__c;
		
		return ed;
	}
	/*********************************/
	/*****/
	public class employeeDigestSubClass{
		public string employeeId			{get; set;}			
		public string name						{get; set;}
		public string hiredDate 			{get; set;}
		public string screened				{get; set;}
		public string screeningStatus	{get; set;}
		public string qualified				{get; set;}
		public string documentStatus	{get; set;}
		public Integer statusRank			{get; set;}
		public double processStageEID	{get; set;}
		public string ssn							{get; set;}	
		public string dReceived				{get; set;}
		public string dReplace				{get; set;}
		public string dNeeded					{get; set;}
	
		public employeeDigestSubClass(){}
	}
	/*****/
}