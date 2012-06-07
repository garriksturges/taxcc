public class Trigger_qualificationDocRequirementHelp {

 public Trigger_qualificationDocRequirementHelp(){}
 
 /************************************************/
 //get list of of all ProgramQual
	public list<string> getPQIds(list<string> qdrIds){
		list<QualificationDocumentRequirement__c> qdrList = [Select q.ProgramQualification__r.Id, q.ProgramQualification__c, q.DocumentStatusEIDFormula__c, // QDR DOCUMENT STATUS
																												 q.ProgramCategoryQualification__r.ProgramQualification__c, q.DocumentStatus__r.DocumentStatusEID__c,
																												 q.ProgramCategoryQualification__c, q.ProgramCategoryQualification__r.ProgramQualification__r.id,
																												 q.DocumentStatus__c, q.DocumentStatusExternal__c
																												 From QualificationDocumentRequirement__c q
																												 where id in :qdrIds];		
		list<string> pqIds = new list<String>();
		for(QualificationDocumentRequirement__c qdr : qdrList){
			if(qdr.ProgramQualification__c != null) pqIds.add(qdr.ProgramQualification__r.Id);
			if(qdr.ProgramCategoryQualification__c != null && qdr.ProgramCategoryQualification__r.ProgramQualification__r.id!=null) pqIds.add(qdr.ProgramCategoryQualification__r.ProgramQualification__r.id);
		}																												 
		return pqIds;
	}
 /************************************************/
 //get all QDR's who have ultimate PQ as parent(get pq employment and program period)
 public list<QualificationDocumentRequirement__c> getAllQdr(list<String>pqIds){
 	list<QualificationDocumentRequirement__c> qdrList = [Select q.ProgramQualification__r.Id, q.ProgramQualification__c, q.DocumentStatusEIDFormula__c, // QDR DOCUMENT STATUS
 																											q.ProgramQualification__r.ProgramPeriod__r.Program__c, q.ProgramQualification__r.Employment__c,
 																											q.ProgramCategoryQualification__r.ProgramQualification__r.ProgramPeriod__r.Program__c, 
 																											q.ProgramCategoryQualification__r.ProgramQualification__r.Employment__c,
 																											q.ProgramQualification__r.ProgramPeriod__r.Program__r.id, q.ProgramQualification__r.Employment__r.id,
 																											q.ProgramQualification__r.ProcessStage__r.RankOrder__c, q.ProgramQualification__r.ProcessStage__c,
 																											q.ProgramCategoryQualification__r.ProgramQualification__r.ProcessStage__r.RankOrder__c,
 																											q.ProgramCategoryQualification__r.ProgramQualification__r.ProcessStage__c,
 																											q.ProgramCategoryQualification__r.ProgramQualification__r.ProgramPeriod__r.Program__r.id, 
 																											q.ProgramCategoryQualification__r.ProgramQualification__r.Employment__r.id,
																											q.ProgramCategoryQualification__r.ProgramQualification__c, q.DocumentStatus__r.RankOrder__c,
																											q.ProgramCategoryQualification__c, q.DocumentRequirement__r.Id, q.DocumentRequirement__r.SortOrder__c,
																											q.DocumentRequirement__c, q.ProgramCategoryQualification__r.ProgramQualification__r.id,
																											q.DocumentStatus__r.DocumentStatusEID__c, q.DocumentStatus__c, q.DocumentStatusExternal__c,
																											q.DocumentStatusExternal__r.DocumentStatusEID__c
																											From QualificationDocumentRequirement__c q
																											where ProgramQualification__r.Id in :pqIds
																											or  ProgramCategoryQualification__r.ProgramQualification__r.id in :pqIds
																											order by DocumentStatusExternal__r.RankOrder__c, DocumentRequirement__r.SortOrder__c];
 	
 	return qdrList;
 }
 /************************************************
 //get list of Doc Option who have DR in list and DocSource EID in [1,2,3]
 public list<DocumentOption__c> getDo(list<String> drList){
 	list<double> eidList = new double[]{1.0, 2.0, 3.0};
 	list<DocumentOption__c> doList = [Select d.DocumentType__r.DocumentSource__c, d.DocumentType__c, d.DocumentStep__r.DocumentRequirement__c, d.DocumentStep__r.DocumentRequirement__r.SortOrder__c,
 																	 d.DocumentStep__c, d.DocumentType__r.DocumentSource__r.DocumentSourceEID__c, d.DocumentStep__r.DocumentRequirement__r.id
 																	 From DocumentOption__c d
 																	 where d.DocumentStep__r.DocumentRequirement__r.id in :drList
 																	 and DocumentType__r.DocumentSource__r.DocumentSourceEID__c in :eidList];
 	return doList;
 }
 /************************************************/
 public list<DocumentInstruction__c> getDi(list<string> drList){
 	list<DocumentInstruction__c> diList  =[Select d.InstructionSummaryText__c, d.DocumentRequirement__r.Id, 
 																				d.DocumentRequirement__c, d.Language__c, d.Audience__c, d.DocumentRequirement__r.SortOrder__c
 																				From DocumentInstruction__c d
 																				where DocumentRequirement__r.Id in :drList
 																				and Audience__c = 'Employee'
 																				and Language__c = 'English'];
 	return diList;
 }
 /************************************************/
 public list <QDRandDI> matchupQdrWithDi(list<DocumentInstruction__c> diList, list<QualificationDocumentRequirement__c>qdrList){
 	//map dr id to DocInstruction
 	map <string, string> drToDi = MakeDIMap(diList);
 	list <QDRandDI> matchList = matchup(qdrList, drToDi);
 	return matchList;
 }
 /************************************************/
 private map<String, string> makeDiMap(list<DocumentInstruction__c> diList){
 	map<string, string> drToDi = new map<string, string>();
 	string instructions;
 	for(DocumentInstruction__c di : diList){
 		instructions = drToDi.get(di.DocumentRequirement__r.Id);
 		if(instructions == null) instructions = di.InstructionSummaryText__c;
 		else instructions = instructions+'; '+di.InstructionSummaryText__c;
 		drToDi.put(di.DocumentRequirement__r.Id, instructions);
 	}
 	return drToDi;	
 }
 /************************************************/
 public list<QDRandDI> matchup(list<QualificationDocumentRequirement__c>qdrList, map <String, string> drToDi){
 		double rValue;
	 	try{
	 		rValue = [Select q.RankOrder__c, q.QualificationProcessStageEID__c From QualificationProcessStage__c q where QualificationProcessStageEID__c = 5 limit 1].RankOrder__c;
	 	}
	 	catch(exception e){
	 		rValue = 0;
	 	}
 		list<QDRandDI> matchList = new list<QDRandDI>();
 		string di;
 		for(QualificationDocumentRequirement__c qdr: qdrList){
 			di = drToDi.get(qdr.DocumentRequirement__r.Id);
 			if(di!=null) matchList.add(new QDRandDI(qdr, di, rValue));
 		}
 		return matchList;
 }
 /************************************************/
 public list<list<String>> getempAndProgPeriodIds(list <QDRandDI> matchList){
 	list<list<String>> rVals = new list<list<string>>();
 	list<String> empIds = new list<String>();
 	list<string> ppIds = new list<String>();
 	for(QDRandDI match: matchList){
 		if(match.qdr.ProgramQualification__c != null){
 			empIds.add(match.qdr.ProgramQualification__r.Employment__c);
 			ppIds.add(match.qdr.ProgramQualification__r.ProgramPeriod__r.Program__c);
 		}
 		if(match.qdr.ProgramCategoryQualification__c != null && match.qdr.ProgramCategoryQualification__r.ProgramQualification__c != null){
 			empIds.add(match.qdr.ProgramCategoryQualification__r.ProgramQualification__r.Employment__c);
 			ppIds.add(match.qdr.ProgramCategoryQualification__r.ProgramQualification__r.ProgramPeriod__r.Program__c);
 		}
 	}
 	rVals.add(empIds);
 	rVals.add(ppIds);
 	return rVals;
 }
 /************************************************/
 public list<wktLocationEmployeeProgram__c> getWktLocationEmployeeProgramList(list<String> empIds, list<String> ppIds){
 	list<wktLocationEmployeeProgram__c> wktList = [Select w.Program__c, w.Employment__c,
 																								 w.Program__r.id, w.Employment__r.id,
 																								 w.DocumentReplacementNeededText__c, w.ProgramQualification__c,
 																								 w.DocumentReceivedText__c, w.DocumentNeededText__c 
 																								 From wktLocationEmployeeProgram__c w
 																								 where Employment__r.id in :empIds
 																								 and Program__r.id in :ppIds];
 	return wktList;
 }
 /************************************************/
 public map<string, wktLocationEmployeeProgram__c> makeWktMap(list<wktLocationEmployeeProgram__c> wktList){
 	map<String, wktLocationEmployeeProgram__c> wktMap = new map<string, wktLocationEmployeeProgram__c>();
 	for(wktLocationEmployeeProgram__c wkt:wktList){
 		//wktMap.put(String.valueOf(wkt.Employment__r.id)+String.valueOf(wkt.Program__r.id), wkt);
 		wktMap.put(wkt.ProgramQualification__c, wkt);
 	}
 	return wktMap;
 }
 /************************************************/
 public list<string> makeQdrEmpPpIds(list <QDRandDI> matchList){
 	list<String> keys = new list<String>();
 	for(QDRandDI match: matchList){
 		if(match.qdr.ProgramQualification__c != null){
 			//keys.add(String.valueOf(match.qdr.ProgramQualification__r.Employment__r.id)+string.valueOf(match.qdr.ProgramQualification__r.ProgramPeriod__r.Program__r.id));
 			keys.add(match.qdr.ProgramQualification__c);
 		}
 		if(match.qdr.ProgramCategoryQualification__c != null && match.qdr.ProgramCategoryQualification__r.ProgramQualification__c != null){
 			//keys.add(String.valueOf(match.qdr.ProgramCategoryQualification__r.ProgramQualification__r.Employment__r.id)+string.valueOf(match.qdr.ProgramCategoryQualification__r.ProgramQualification__r.ProgramPeriod__r.Program__r.id));
 			keys.add(match.qdr.ProgramCategoryQualification__r.ProgramQualification__c);
 		}
 	}
 	return keys;
 }
 /************************************************/
 public void clearWktsForUpdate(list<String> QdrEmpPpIds, map<string, wktLocationEmployeeProgram__c>wktMap){
 	wktLocationEmployeeProgram__c wkt;
 	for(string key : QdrEmpPpIds){
 		wkt = wktMap.get(key);
 		if(wkt != null){
			wkt.DocumentNeededText__c = '';
			wkt.DocumentReceivedText__c = '';
			wkt.DocumentReplacementNeededText__c = '';
			wktMap.put(key, wkt); 			
 		}
 	}
 }
 /************************************************/
 public void updateWktFields(list<QDRandDI> matchList, map<String, wktLocationEmployeeProgram__c> wktMap){
 	string key;
 	wktLocationEmployeeProgram__c wkt;
 	boolean BLANK = false;
 	for(QDRandDI match: matchList){
 		if(match.qdr.ProgramQualification__c != null){
 			//key = (String.valueOf(match.qdr.ProgramQualification__r.Employment__r.id)+string.valueOf(match.qdr.ProgramQualification__r.ProgramPeriod__r.Program__r.id));
 			key = match.qdr.ProgramQualification__c;
 			wkt = wktMap.get(key);
 			if(wkt!= null){
 				if(match.blank) wkt.DocumentNeededText__c = 'BLANK';
 				updateWktField(match, wkt);
 				wktMap.put(key, wkt);
 			}
 		}
 		if(match.qdr.ProgramCategoryQualification__c != null && match.qdr.ProgramCategoryQualification__r.ProgramQualification__c != null){
 			//key = (String.valueOf(match.qdr.ProgramCategoryQualification__r.ProgramQualification__r.Employment__r.id)+string.valueOf(match.qdr.ProgramCategoryQualification__r.ProgramQualification__r.ProgramPeriod__r.Program__r.id));
 			key = match.qdr.ProgramCategoryQualification__r.ProgramQualification__c;
 			wkt = wktMap.get(key);
 			if(wkt!= null){
 				if(match.blank) wkt.DocumentNeededText__c = 'BLANK';
 				updateWktField(match, wkt);
 				wktMap.put(key, wkt);
 			}
 		}
 	}
 }
 /************************************************/
 private void updateWktField(QDRandDI qi, wktLocationEmployeeProgram__c wkt){
 	if(qi.qdr.DocumentStatusExternal__c == null || qi.qdr.DocumentStatusExternal__r.DocumentStatusEID__c == null){
 		//doc needed
 		if(wkt.DocumentNeededText__c != 'BLANK'){
 			if(wkt.DocumentNeededText__c == '') wkt.DocumentNeededText__c = qi.di;
 			else wkt.DocumentNeededText__c =wkt.DocumentNeededText__c+ '; '+qi.di;
 		}
 	}
 	if(qi.qdr.DocumentStatusExternal__r.DocumentStatusEID__c  == 3.0 ||qi.qdr.DocumentStatusExternal__r.DocumentStatusEID__c  == 4.0 ){
 		//doc replacement
 		if(wkt.DocumentReplacementNeededText__c == '') wkt.DocumentReplacementNeededText__c = qi.di;
 		else wkt.DocumentReplacementNeededText__c =wkt.DocumentReplacementNeededText__c+ '; '+qi.di;
 	}
 	if(qi.qdr.DocumentStatusExternal__r.DocumentStatusEID__c  == 0.0 ||qi.qdr.DocumentStatusExternal__r.DocumentStatusEID__c  == 1.0||qi.qdr.DocumentStatusExternal__r.DocumentStatusEID__c  == 2.0 ){
 		//doc received
 		if(wkt.DocumentReceivedText__c =='') wkt.DocumentReceivedText__c = qi.di;
 		else wkt.DocumentReceivedText__c = wkt.DocumentReceivedText__c+'; '+qi.di;
 	}
 }
 /************************************************/
 public list<wktLocationEmployeeProgram__c> makeWktUpdateList(list<String> QdrEmpPpIds, map<string, wktLocationEmployeeProgram__c>wktMap){
 	set<String> cleanKeys = new set<String>();
 	cleanKeys.addAll(QdrEmpPpIds);
 	list<wktLocationEmployeeProgram__c>updateList = new list<wktLocationEmployeeProgram__c>();
 	wktLocationEmployeeProgram__c wkt;
 	for(string key : cleanKeys){
 		wkt = wktMap.get(key);
 		if(wkt != null){
 			getRidOfDuplicates(wkt);
 			updateList.add(wkt); 			
 		}
 	}
 	return updateList;
 }
 /************************************************/
 public void getRidOfDuplicates(wktLocationEmployeeProgram__c wkt){
 		wkt.DocumentNeededText__c = deduplicate(wkt.DocumentNeededText__c);
 		wkt.DocumentReplacementNeededText__c = deduplicate(wkt.DocumentReplacementNeededText__c);
 		wkt.DocumentReceivedText__c = deduplicate(wkt.DocumentReceivedText__c);
 }
 /************************************************/
 public string deduplicate(string val){
 	if(val == null || val =='' || val =='BLANK') return '';
 	String[] strArray = val.split(';');
 	set<string> sVals = new set <string>();
 	string rVal = '';
 	for(string s : strArray){
 		s = s.trim();
 		if(sVals.contains(s)==false){
 			sVals.add(s);
 			if(rVal.length() == 0) rVal = rVal + s;
 			else rVal = rVal +'; '+s;
 		}
 	}
 	
 	return rVal;
 }
 /************************************************/
 /*****/
 public class QDRandDI{
 	public QualificationDocumentRequirement__c qdr {get; set;}
 	public string di	{get; set;}
 	public boolean blank {get; set;}
 	
 	public QDRandDI(QualificationDocumentRequirement__c q, string d, double rValue){
 		qdr = q;
 		di = d;
 		checkBlank(q, rValue);
 	}
 	/**********/
 	private void checkBlank(QualificationDocumentRequirement__c qdr, double rValue){
 		blank = false;
 		if(qdr.ProgramQualification__c != null && qdr.ProgramQualification__r.ProcessStage__c != null && qdr.ProgramQualification__r.ProcessStage__r.RankOrder__c != null && qdr.ProgramQualification__r.ProcessStage__r.RankOrder__c>=rValue){
 			blank = true;
 		}
 		if(qdr.ProgramCategoryQualification__c!=null&& qdr.ProgramCategoryQualification__r.ProgramQualification__c != null && qdr.ProgramCategoryQualification__r.ProgramQualification__r.ProcessStage__c != null && qdr.ProgramCategoryQualification__r.ProgramQualification__r.ProcessStage__r.RankOrder__c != null
 			&& qdr.ProgramCategoryQualification__r.ProgramQualification__r.ProcessStage__r.RankOrder__c>=rValue){
 			 blank = true;
 		}
 	}		
 	/**********/
 }
 /*****/
 /*
 If the QDR.PCQ.PQ.QPS.RankOrder >= QPS[EID=5].RankOrder (meaning the process stage is at "Ready to Prepare Application" or later)

OR QDR.PQ.QPS.RankOrder >= QPS[EID=5].RankOrder (because QDR can also be connected directly to PQ)

THEN wktLEP.Documents Needed = empty
q.ProgramQualification__r.ProcessStage__r.RankOrder__c, q.ProgramQualification__r.ProcessStage__c,
 																											q.ProgramCategoryQualification__r.ProgramQualification__r.ProcessStage__r.RankOrder__c,
 																											q.ProgramCategoryQualification__r.ProgramQualification__r.ProcessStage__c,
*/
}