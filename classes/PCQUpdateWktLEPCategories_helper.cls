public with sharing class PCQUpdateWktLEPCategories_helper {

	private list<String> pqIds;
	
	
	/***************************/
	public PCQUpdateWktLEPCategories_helper(list<string> l){
		pqIds =l;
	}
	/***************************/
	public list<wktLocationEmployeeProgram__c> makeUpdateList(){
		list<ProgramCategoryQualification__c> pcqList = getAllPCQs();
		map<string, set<String>> pqToCategoriesMap = makepqToCategoriesMap(pcqList);
		list<wktLocationEmployeeProgram__c> wktL = getWktLEPs();
		updateWktCategoryFields(wktL, pqToCategoriesMap);
		return wktL;
	}
	/***************************/
	private list<ProgramCategoryQualification__c> getAllPCQS(){
		list<ProgramCategoryQualification__c> pcqList = [Select p.ProgramQualification__c, 
																										p.ProgramCategoryPeriod__r.ProgramCategory__c, p.ProgramCategoryPeriod__c,
																										p.ProgramCategoryPeriod__r.ProgramCategory__r.Name, 
																										p.ProgramCategoryPeriod__r.ProgramCategory__r.ShortName__c,
																										p.Readiness__c, p.Readiness__r.ExternalName__c
																										From ProgramCategoryQualification__c p
																										where ProgramQualification__c in :pqIds
																										and Readiness__r.ExternalName__c != 'Disqualified'];
		return pcqList;
	}
	/***************************/
	private map<string, set<String>> makepqToCategoriesMap(list<ProgramCategoryQualification__c> pcqList){
		map<string, set<String>> rval = new map<string, set<String>>();
		set<String> cats;
		string c;
		for(ProgramCategoryQualification__c pcq : pcqList){
			cats = rval.get(pcq.ProgramQualification__c);
			if(cats==null) cats = new set<string>();
			if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ShortName__c!=null) c= pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ShortName__c;
			else c= pcq.ProgramCategoryPeriod__r.ProgramCategory__r.Name;
			
			if(c!=null) cats.add(c);
			rval.put(pcq.ProgramQualification__c, cats);
		}
		return rval;
	}
	/***************************/
	private list<wktLocationEmployeeProgram__c> getWktLEPs(){
		list<wktLocationEmployeeProgram__c> wktL = [Select  w.ProgramQualification__c,w.QualifiedCategoryText__c 
																								From wktLocationEmployeeProgram__c w
																								where ProgramQualification__c in :pqIds
																								and ProgramQualification__c != null];
		return wktL;
	}
	/***************************/
	private void updateWktCategoryFields(list<wktLocationEmployeeProgram__c>wktL, map<string, set<String>>pqToCategoriesMap){
		set<String>cats;
		for(wktLocationEmployeeProgram__c wkt: wktL){
			cats = pqToCategoriesMap.get(wkt.ProgramQualification__c);
			wkt.QualifiedCategoryText__c = makeCategoryText(cats);
		}
		
	}
	/***************************/
	private string makeCategoryText(set<string> cats){
		if(cats ==null || cats.size() ==0) return '';
		string val='';
		list<String> l = new list<String>();
		l.addAll(cats);
		l.sort();
		for(string s: l){
			val=val+s+',';
		}
		val = val.substring(0, val.length()-1);
		return val;
	}
}