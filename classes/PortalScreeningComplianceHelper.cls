public with sharing class PortalScreeningComplianceHelper {
/*
Screens Valid:(SurveyDate time on or before current system time/Date + WOTC date check) 
                            Complete screens, pass WOTC date check.
*/
 /***************************************/
 public static void setupPSC(list<PortalExecutiveDashboardController.locationProgramWrapper> ll, Date sd, Date ed){
        list<String> locationIds = setupLocationIds(ll);
        string prog;
        if(ll!=null && ll.size()>0) prog = ll[0].lp.Program__r.id;
        list <wktLocationEmployeeProgram__c> wktListFULL = setupwktListFULL(locationIds, sd, ed, prog);
        map<string, double> employeesMap = setupEmployeesMap(locationIds, wktListFULL, sd, ed);
        list <map<String, double>> statMaps = setupStatMaps(locationIds, prog, sd, ed, wktListFULL);
        map<String, double> numMap =    statMaps[0];
        map<String, double> qualificationMap = statMaps[1];
        map<String, double> validScreensMap = statMaps[2];
        map<string, double> screenTransfersOutMap  = statMaps[3];
        map<string, double> screenTransfersInMap  = statMaps[4];
        map<string, double> invalidScreens = statMaps[5];
        map<String, double> screensNotHired = statMaps[6];
        map<String, double> docNum = statMaps[7];
        map<String, double> docDenom = statMaps[8];
        updateLocationListPSC(employeesMap, numMap, qualificationMap, validScreensMap, screenTransfersOutMap, screenTransfersInMap, invalidScreens, screensNotHired,  docNum, docDenom, ll);
 }
 /***************************************/
 private static list<String> setupLocationIds(list<PortalExecutiveDashboardController.locationProgramWrapper>ll){
    list<String> locationIds = new list<String>();
    for( PortalExecutiveDashboardController.locationProgramWrapper lpw:ll){
            locationIds.add(lpw.lp.Location__r.Id);
        }
    return locationIds;
 }
 /***************************************/
 private static list <wktLocationEmployeeProgram__c> setupwktListFULL(list<String>locationIds, Date sd, Date ed, string prog){   
    list <wktLocationEmployeeProgram__c> wktList;
    if(sd == null || ed == null || ed <= sd){
     wktList = [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c, Employment__r.Location__c,
                            ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Status__c,
                            HireLocation__c, HireDate__c, Employee__c,  
                            QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__r.RankOrder__c, QualificationProcessStage__r.QualificationProcessStageEID__c, QualificationProcessStage__r.Name, QualificationProcessStage__c 
                            From wktLocationEmployeeProgram__c 
                            where HireLocation__c in :locationIds//];
                            and (Program__c = :prog or Program__c=null)];
                            //and  (ProgramQualification__r.ProgramPeriod__r.Program__r.Id =: prog ];
    }
    else{
        wktList = [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c,Employment__r.Location__c,
                            ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Status__c,
                            HireLocation__c, HireDate__c, Employee__c, 
                            QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__r.RankOrder__c, QualificationProcessStage__r.QualificationProcessStageEID__c, QualificationProcessStage__r.Name, QualificationProcessStage__c 
                            From wktLocationEmployeeProgram__c 
                            where HireLocation__c in :locationIds
                            and HireDate__c >= :sd
                            and HireDate__c <= :ed//];
                            and (Program__c = :prog or Program__c=null)];
                            //and  (ProgramQualification__r.ProgramPeriod__r.Program__r.Id =: prog ];
    }
    wktList = filterWktListProgAndNull(wktList);
    return wktList;
 }
 /***************************************/
 private static list <wktLocationEmployeeProgram__c> filterWktListProgAndNull(list <wktLocationEmployeeProgram__c> wktList){
 	list <wktLocationEmployeeProgram__c> rVal = new list <wktLocationEmployeeProgram__c>();
 	map<String, wktLocationEmployeeProgram__c> wktMap = new Map<string, wktLocationEmployeeProgram__c>();
 	wktLocationEmployeeProgram__c t;
 	for(wktLocationEmployeeProgram__c wkt : wktList){
 		t = wktMap.get(wkt.id);
 		if(t==null) wktMap.put(wkt.id, wkt);
 		else{
 			if(wkt.Program__c != null) wktMap.put(wkt.Id, wkt);
 		}
 	}
 set<string> keys = wktMap.keySet();
 for(String k:keys){
 	rVal.add(wktMap.get(k));
 }
 return rVal;
 }
 /***************************************/
 private static  map<String, double> setupEmployeesMap(list<String>locationIds, list <wktLocationEmployeeProgram__c> wktList, Date sd, Date ed){
    map<String, set<String>> lsMap = setupLocationSetMap(wktList);
    map<String, double> countMap = setupCountMap(lsMap, locationIds);
    return countMap;
 }
    /***************************************/
    private static list <map<String, double>> setupStatMaps(list<String>locationIds, string prog, Date sd, Date ed, list <wktLocationEmployeeProgram__c> wktListFULL){
        list <wktLocationEmployeeProgram__c> wktList = getNumWKTList(locationIds, prog, sd, ed);
        
        
        map<String, double> screensNotHired = setupScreensNotHired(wktList);
       
        wktList = filterNotHiredFromWktList(wktList);
        
        map<String, double> invalidScreens = null;
        if(wktList != null &&wktList.size()>0 && 'WOTC'.equalsIgnoreCase(wktList[0].program__r.shortName__c)){
            wktList = filterWktList(wktList);
            invalidScreens = setupInvalidScreens(wktList);
        }            
        
        //system.debug('TCC shortname: ' + wktList[0].program__r.shortName__c);                                           
                                        
        map<String, set<String>> lsMap = setupLocationSetMap(wktList);
        map<String, double> countMap = setupCountMap(lsMap, locationIds);
        map<String, double> validScreens = setupValidScreensMap(wktList);
        map<String, double> screenTransfersOut = screenTransfersOutMap(wktList);
        map<String, double> screenTransfersIn = screenTransfersInMap(wktList);
        list<map<string, double>> qualificationAndDocumentMap = setupQualificationAndDocumentMaps(wktList, wktListFULL);
        map<string, double> qualificationMap = qualificationAndDocumentMap[0];
        map<string, double> docNum = qualificationAndDocumentMap[1];//setupDocNum(wktList);
        map<string, double> docDenom = qualificationAndDocumentMap[2];//setupDocDenom(wktList);
        return new list <map<String, double>>{countMap, qualificationMap, validScreens, screenTransfersOut, screenTransfersIn, invalidScreens, screensNotHired, docNum, docDenom};
    }
    /***************************************/
    public static map<String, double> setupDocDenom(list<wktLocationEmployeeProgram__c> wktList){
        map<String, double> rVal = new map<string, double>();
        
        double val;
        for(wktLocationEmployeeProgram__c wkt: wktList){
            val = rVal.get(wkt.Employment__r.Location__c);
            if(val == null) val = 0;
            if(wkt.QualificationProcessStage__r.QualificationProcessStageEID__c != null && wkt.QualificationProcessStage__r.QualificationProcessStageEID__c != 1 && wkt.QualificationProcessStage__r.QualificationProcessStageEID__c != 9 && wkt.QualificationProcessStage__r.QualificationProcessStageEID__c != 10) rVal.put(wkt.Employment__r.Location__c, val+1);
            else rVal.put(wkt.Employment__r.Location__c, val);
        }
        return rVal;
    }
    /***************************************/
    public static map<String, double> setupDocNum(list<wktLocationEmployeeProgram__c> wktList){
        map<String, double> rVal = new map<string, double>();
        double val;
        for(wktLocationEmployeeProgram__c wkt: wktList){
            val = rVal.get(wkt.Employment__r.Location__c);
            if(val == null) val = 0;
            if(wkt.QualificationProcessStage__r.QualificationProcessStageEID__c != null && wkt.QualificationProcessStage__r.QualificationProcessStageEID__c == 8) rVal.put(wkt.Employment__r.Location__c, val+1);
            else rVal.put(wkt.Employment__r.Location__c, val);
        }
        return rVal;
    }
    /***************************************/
    private static list<wktLocationEmployeeProgram__c> filterNotHiredFromWktList(list<wktLocationEmployeeProgram__c> wktList){
        list<wktLocationEmployeeProgram__c> newList = new list<wktLocationEmployeeProgram__c>();
        for(wktLocationEmployeeProgram__c wkt : wktList){
            if(wkt.Employment__r.Status__c == 'Hired') newList.add(wkt);
        }
        return newList;
    }
    /***************************************/
    private static map<String, double> screenTransfersInMap(list<wktLocationEmployeeProgram__c> wktList){
        map<String, double> screenTransfers = new map<string, double>();
        double val;
        for(wktLocationEmployeeProgram__c wkt: wktList){
            val = screenTransfers.get(wkt.Employment__r.Location__c);
            if(val == null) val = 0;
            if(wkt.Employment__r.Location__c != wkt.SurveyLocation__c) screenTransfers.put(wkt.Employment__r.Location__c, val+1);
        }
        return screenTransfers;
 }
    /***************************************/
    private static map<String, double> screenTransfersOutMap(list<wktLocationEmployeeProgram__c> wktList){
        map<String, double> screenTransfers = new map<string, double>();
        double val;
        for(wktLocationEmployeeProgram__c wkt: wktList){
            val = screenTransfers.get(wkt.SurveyLocation__c);
            if(val == null) val = 0;
            if(wkt.Employment__r.Location__c != wkt.SurveyLocation__c) screenTransfers.put(wkt.SurveyLocation__c, val+1);
        }
        return screenTransfers;
 }
 /***************************************/
 private static map<String, double> setupScreensNotHired(list<wktLocationEmployeeProgram__c> wktList){
    map<String, double> screensNotHired = new map<string, double>();
    double val;
    for(wktLocationEmployeeProgram__c wkt: wktList){
        val = screensNotHired.get(wkt.SurveyLocation__c);
        if(val == null) val = 0;
        if(wkt.Employment__r.Status__c == 'Pending') screensNotHired.put(wkt.SurveyLocation__c, val+1);
    }
    
    return screensNotHired;
 }
/***************************************/
 private static map<String, double> setupInvalidScreens(list<wktLocationEmployeeProgram__c> wktList){
    map<String, double> invalidScreens = new map<string, double>();
    double val;
    for(wktLocationEmployeeProgram__c wkt: wktList){
        val = invalidScreens.get(wkt.SurveyLocation__c);
        if(val == null) val = 0;
        if(wkt.SurveyDate__c.Date() > wkt.HireDate__c) invalidScreens.put(wkt.SurveyLocation__c, val+1);
    }
    
    return invalidScreens;
 }
 /***************************************/
  private static map<String, double> setupValidScreensMap(list<wktLocationEmployeeProgram__c> wktList){
    map<string, set<string>> screensMap = new map<string, set<string>>();
    set<string> eIds;
    for(wktLocationEmployeeProgram__c wkt: wktList){
        eIds = screensMap.get(wkt.SurveyLocation__c);
        if(eIds == null) eIds = new set<String>();
        if(wkt.SurveyDate__c <= Datetime.now()) eIds.add(wkt.Employee__c);
        screensMap.put(wkt.SurveyLocation__c, eIds);
    }
    
    map<String, double> validScreens = new map<string, double>();
    double val;
    set<string> keys = screensMap.keySet();
    for(string k: keys){
         validScreens.put(k, screensMap.get(k).size());
    }
    
    return validScreens;
 }
 /***************************************/
 public static list<map<String, double>> setupQualificationAndDocumentMaps(list<wktLocationEmployeeProgram__c> wktList, list <wktLocationEmployeeProgram__c> wktListFULL){
    if(wktListFULL == null || wktListFULL.size() == 0 || wktList == null || wktList.size()==0) return new list<map<string, double>>{new map<string, double>(), new map<string, double>(), new map<string, double>()};
    list<String> employmentList = getListOfEmploymentIDs(wktListFULL);
    set<String> qualifiedEmployments = getQualifiedEmploymentsSet(employmentList, wktList[0].program__c);
    if(qualifiedEmployments == null) return new list<map<string, double>>{new map<string, double>(), new map<string, double>(), new map<string, double>()};
    return setupQualificationCounts(wktListFULL, qualifiedEmployments); 
 }
    /***************************************/
    private static list<map<String, double>> setupQualificationCounts(list<wktLocationEmployeeProgram__c>wktList, set<String> eIdSet){
        QualificationProcessStage__c qps = [Select q.RankOrder__c, q.QualificationProcessStageEID__c, q.Name, q.ExternalName__c From QualificationProcessStage__c q where QualificationProcessStageEID__c=5];
        map<String, double> qualMap = new map<String, double>();
        map<String, double> dnMap = new map<String, double>();
        map<String, double> ddMap = new map<String, double>();
        double q;
        double dn;
        double dd;
        for(wktLocationEmployeeProgram__c wkt:wktList){
            //Qual map
            q = qualMap.get(wkt.HireLocation__c);
            if(q == null) q = 0;
            if(eIdSet.contains(wkt.Employment__c)) q = q +1;
            qualMap.put(wkt.HireLocation__c, q);
            
            //Doc numerator
            dn = dnMap.get(wkt.Employment__r.Location__c);
            if(dn == null) dn = 0;
            if(wkt.QualificationProcessStage__c != null && wkt.QualificationProcessStage__r.QualificationProcessStageEID__c != null && wkt.QualificationProcessStage__r.RankOrder__c >= qps.RankOrder__c) dnMap.put(wkt.Employment__r.Location__c, dn+1);
            else dnMap.put(wkt.Employment__r.Location__c, dn);
            
            //Doc Denom
            dd = ddMap.get(wkt.Employment__r.Location__c);
            if(dd == null) dd = 0;
            if(wkt.QualificationProcessStage__c == null ||wkt.QualificationProcessStage__r.QualificationProcessStageEID__c == null || wkt.QualificationProcessStage__r.QualificationProcessStageEID__c != 3) ddMap.put(wkt.Employment__r.Location__c, dd+1);
            else ddMap.put(wkt.Employment__r.Location__c, dd);
        }
        
        return new list <map<String, double>>{qualMap, dnMap, ddMap};
    }   
    /***************************************/
    private static set<String> getQualifiedEmploymentsSet(list<String> eIds, string pId){
        list<ProgramQualification__c> pqList = [Select ProgramPeriod__r.Program__c, ProgramPeriod__c, Name, Employment__c 
                                                                                        From ProgramQualification__c 
                                                                                        where ProgramPeriod__r.Program__c = :pId
                                                                                        and Employment__c in :eIds];
        if(pqList == null || pqList.size() == 0) return null;
        set<String> qeMap= new set<String>();
        for(ProgramQualification__c pq:pqList){
            qeMap.add(pq.Employment__c);
        }
        return qeMap;
    }
    /***************************************/
    private static list<String> getListOfEmploymentIDs(list<wktLocationEmployeeProgram__c>wktList){
        list<String> eIds = new list<String>();
        for(wktLocationEmployeeProgram__c wkt : wktList){
            eIds.add(wkt.Employment__c);
        }
        return eIds;
    }
    /***************************************/
    private static list<wktLocationEmployeeProgram__c> getNumWKTList(list<String> locationIds, string prog, Date sd, Date ed){
        list <wktLocationEmployeeProgram__c> wktList;
        if(sd == null || ed == null || ed <= sd){
            wktList = [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c,
                                ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Location__c,
                                HireLocation__c, HireDate__c, Employee__c, Employment__r.Status__c,
                                QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__r.RankOrder__c, QualificationProcessStage__r.QualificationProcessStageEID__c, QualificationProcessStage__r.Name, QualificationProcessStage__c  
                                From wktLocationEmployeeProgram__c w 
                                where SurveyLocation__c in :locationIds
                                and Program__c = :prog];
        }                   
        else{
            wktList = [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c, Employment__r.Location__c,
                                ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Status__c,
                                HireLocation__c, HireDate__c, Employee__c, 
                                QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__r.RankOrder__c, QualificationProcessStage__r.QualificationProcessStageEID__c, QualificationProcessStage__r.Name, QualificationProcessStage__c
                                From wktLocationEmployeeProgram__c w 
                                where SurveyLocation__c in :locationIds
                                and Program__c = :prog
                                and SurveyDate__c >= :sd
                                and SurveyDate__c <= :ed];
        }
                                        
        return wktList;
 }
    /***************************************/
    public static list<wktLocationEmployeeProgram__c> filterWktList(list<wktLocationEmployeeProgram__c> wktList){
        list<wktLocationEmployeeProgram__c> returnVal = new list<wktLocationEmployeeProgram__c>();
        for(wktLocationEmployeeProgram__c wkt : wktList){
            if(wkt.HireDate__c != null && wkt.SurveyDate__c != null && wkt.HireDate__c >= wkt.SurveyDate__c.Date()){
                returnVal.add(wkt);
            }
        }
        return returnVal;
    }
    /***************************************/
    private static map<String, set<String>> setupLocationSetMap(list<wktLocationEmployeeProgram__c> wktList){
        map<String, set<String>> lsMap = new map<String, set<String>>();                                                                                                
        set<String> empIdSet;                                                                                                   
        for(wktLocationEmployeeProgram__c wkt:wktlist){
            empIdSet    = lsMap.get(wkt.HireLocation__c);
            if(empIdSet == null){
                empIdSet = new set<String>();
            }
            if(wkt.Employment__r.Status__c == 'Hired'){
                empIdSet.add(wkt.Employee__c);
                lsMap.put(wkt.HireLocation__c, empIdSet);
            }
        }
        return lsMap;
    }
    /***************************************/
    private static map<string, double> setupCountMap(map<string, set<String>> lsMap, list<String> locationIds){     
        set<String> empIdSet;
        map<String, double> returnVal= new map<String, Double>();
        for(String locId:locationIds){
            empIdSet =  lsMap.get(locId);
            if(empIdSet == null){
                returnVal.put(locId, 0);
            }
            else{
                returnVal.put(locId, double.valueof(empIdSet.size()));
            }
        }
        return returnVal;                                                                                                   
 }
 /***************************************/
 private static void updateLocationListPSC(map<String, double> denomMap, map<String, double> numMap,
                                                                                     map<String, double> qualificationMap, map<String, double> validScreensMap,
                                                                                     map<String, double> screenTransfersOut, map<String, double> screenTransfersIn,
                                                                                     map<String, double> invalidScreens, map<String, double> screensNotHired,
                                                                                     map<String, double> docNum, map<String, double> docDenom,
                                                                                     list<PortalExecutiveDashboardController.locationProgramWrapper> ll){
    double num;
    double denom;
    double qVal;
    for(PortalExecutiveDashboardController.locationProgramWrapper lw: ll){
        
        /*num = numMap.get(lw.lp.Location__r.id);
        if(qualificationMap != null) qVal = qualificationMap.get(lw.lp.Location__r.id);
        //PORTAL SCREENING COMPLIANCE
        if(denom == null || num == null || num == 0){
             lw.PortalScreeningCompliance = 0;
             lw.PortalScreeningComplianceNum = 0;
             if(denom == null) lw.PortalScreeningComplianceDenom = 0;
             else lw.PortalScreeningComplianceDenom = Integer.valueOf(denom);
        }
        else{
             lw.PortalScreeningCompliance = Math.round(Decimal.valueOf((num/denom)*100));
             lw.PortalScreeningComplianceDenom= Integer.valueOf(denom);
             lw.PortalScreeningComplianceNum = Integer.valueOf(num);
        }
        //PORTAL QUALIFICATION
        if(num == null || num == 0 || qualificationMap == null || qVal == null ){
             lw.portalQualificationRate =0;
             lw.portalQualificationNum = 0;
        }
        else{
            lw.portalQualificationRate = Math.round(Decimal.valueOf((qVal/num)*100));
            lw.PortalQualificationNum = Integer.valueOf(qVal);
        }*/
        
        //SCREEN TRANSFERS OUT
        double transfersOut = screenTransfersOut.get(lw.lp.Location__r.id);
        if(transfersOut == null) transfersOut = 0;
        lw.ScreenTransfersOut = Integer.valueOf(transfersOut);
        //SCREEN TRANSFERS IN
        double transfersIn = screenTransfersIn.get(lw.lp.Location__r.id);
        if(transfersIn == null) transfersIn = 0;
        lw.ScreenTransfersIn = Integer.valueOf(transfersIn);
        //VALID SCREENS
        double screens = validScreensMap.get(lw.lp.Location__r.id);
        if(screens == null) screens = 0;
        //lw.ValidScreens = integer.valueOf(screens-transfersOut);
        lw.ValidScreens = integer.valueOf(screens);
        //INVALID SCREENS
        double invalid;
        if(invalidScreens == null) invalid = 0;
        else invalid = invalidScreens.get(lw.lp.Location__r.id);
        if(invalid == null) invalid = 0;
        lw.InvalidScreens = Integer.valueOf(invalid);
        //NOT HIRED
        double notHired = screensNotHired.get(lw.lp.Location__r.id);
        if(notHired == null) notHired = 0;
        lw.NotHiredScreens = Integer.valueOf(notHired);
        //Employees
        denom = denomMap.get(lw.lp.Location__r.id);
        if(denom == null) denom=0;
        denom=denom+transfersOut;//-transfersIn;
        lw.PortalScreeningComplianceDenom = integer.valueOf(denom); 
        //UNSCREENED
      //lw.Unscreened = Integer.valueOf(denom - (screens-transfersOut+transfersIn));
      lw.Unscreened = Integer.valueOf(denom - (screens));

        //COMPLIANCE SCREENING
        lw.PortalScreeningComplianceNum = integer.valueOf(screens); 
        //QUALIFICATION
        double qualification;
        if (qualificationMap == null) qualification= 0;
        else{
            qualification = qualificationMap.get(lw.lp.Location__r.id);
            if(qualification == null) qualification= 0;
        }
        lw.PortalQualificationNum = integer.valueOf(qualification); 
        //DOCUMENT COMPLIANCE
        double docN = docNum.get(lw.lp.Location__r.id);
        if(docN == null) docN =0;
        lw.documentNum = integer.valueOf(docN);
        double docD = docDenom.get(lw.lp.Location__r.id);
        if(docD == null) docD =0;
        lw.documentDenom = integer.valueOf(docD);
    }
 }
 /***************************************/
}