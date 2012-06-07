trigger QualificationDocumentRequirement_UpdateWKTLocationEmployeeProgram on QualificationDocumentRequirement__c (after insert, after update) {
//get list of qdr whose status has changed
    list<String> qdrIds = new list<String>();
    
    QualificationDocumentRequirement__c qdrOld;
    for(QualificationDocumentRequirement__c qdr : trigger.new){
        if(trigger.oldMap == null) qdrOld = null;
        else qdrOld = ((QualificationDocumentRequirement__c)trigger.oldMap.get(qdr.id));
        
        if(qdr.DocumentStatus__c == null || qdrOld == null ||(qdr.DocumentStatusExternal__c != qdrOld.DocumentStatusExternal__c )) qdrIds.add(qdr.id); // QDR DOCUMENT STATUS
    }

//get list of of all ProgramQual
    Trigger_qualificationDocRequirementHelp helper = new Trigger_qualificationDocRequirementHelp();
    list<string> pqIds = helper.getPQIds(qdrIds);

//get all QDR's who have ultimate PQ as parent(get pq employment and program period)
    list <QualificationDocumentRequirement__c> qdrList = helper.getAllQdr(pqIds);

//get list of Doc req ids
    list <String> drList = new list<string>();
    for(QualificationDocumentRequirement__c qdr : qdrList){
        drList.add(qdr.DocumentRequirement__r.id);
    }

//get list of Doc Option who have DR in list and DocSource EID in [1,2,3]
/*    list<DocumentOption__c> doList = helper.getDo(drList);
*/
//get refined list of DR ids from this list
/*    drList = new list<String>();
    for(DocumentOption__c dopt : doList){
        drList.add(dopt.DocumentStep__r.DocumentRequirement__r.id);
    }*/
//get list of Doc Instructions whose DR in new list
    list<DocumentInstruction__c> diList = helper.getDi(drList);

//match QDR with Docinstructions where DOC reqID is the same
//assuming one DI for each DR 
    list<Trigger_qualificationDocRequirementHelp.QDRandDI>matchList = helper.matchupQdrWithDi(diList, qdrList);

//get the employment and program period ids
    list<list<string>> empAndProgPeriodIds = helper.getempAndProgPeriodIds(matchList);
    list <string> empIds = empAndProgPeriodIds[0];
    list <string> ppIds  = empAndProgPeriodIds[1];
    
//get wkt to be update
    list<wktLocationEmployeeProgram__c>wktList = helper.getWktLocationEmployeeProgramList(empIds, ppIds);

//put wkt in employment+programperiod -> wkt map
    map<String, wktLocationEmployeeProgram__c> wktMap = helper.makeWktMap(wktList);

//make list of QDR employment + program period ids
    list<string> QdrEmpPpIds = helper.makeQdrEmpPpIds(matchList);

//clear wkt's to be updated
    helper.clearWktsForUpdate(QdrEmpPpIds, wktMap);

//update wkt fields
    helper.updateWktFields(matchList, wktMap);

//get list of wkt to update and get rid of duplicate values
    list<wktLocationEmployeeProgram__c> updateList = helper.makewktUpdateList(QdrEmpPpIds, wktMap);

//upate wkt
    update updateList;
}