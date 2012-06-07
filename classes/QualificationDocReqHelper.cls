/* Document Management Code For Readiness */

Public class QualificationDocReqHelper {
    
    public static boolean byPassCode = true ;
    public static boolean byPassTriggers = false ;
    public static boolean isManualUpdate = true ;
    public static boolean isDocReqExist = false ;
    public static boolean qdrInsertFromPCQ = false ;
    public static boolean PQDocumentSourceEid = false ;
    public static boolean updatePQDocSourceEid = false;
    public static boolean byPassInProgress = false ;
    public static Set<Id> pqSet = new Set<id>();
    public static map<id,boolean> isPqAlreadyProcessed = new Map<id,Boolean>(); 
    public static Map<id,ProgramCategoryQualification__c> finalMapToUpdate = new Map<id,ProgramCategoryQualification__c>();
    static Map<decimal,id> readinessMap = new Map<decimal,id>();
        static {
            for(QualificationReadiness__c ready: [Select QualificationReadinessEID__c, Id From QualificationReadiness__c ]){
                readinessMap.put(ready.QualificationReadinessEID__c , ready.id);
            }
        }
    public static void ProcessQualificationsDocs(List<QualificationDocumentRequirement__c> docsList ,Map<Id,QualificationDocumentRequirement__c> oldMap){
        Set<Id> prgCatQualIds = new Set<id>();
        Map<Id,Id> prgQualIds = new Map<id,id>();
        Map<Id,Id> prgQualIds1 = new Map<id,id>();
        Map<id,Integer> docCount = new Map<id,Integer>();
        Map<Id,List<QualificationDocumentRequirement__c>> docsListMap = new Map<id,List<QualificationDocumentRequirement__c>>();
        Map<Id,List<QualificationDocumentRequirement__c>> docsListMap1 = new Map<id,List<QualificationDocumentRequirement__c>>();
        Map<id,ProgramCategoryQualification__c>  catagoryRankMap= new   Map<id,ProgramCategoryQualification__c>();
        List<QualificationDocumentRequirement__c> docList ; 
        Map<id,List<ProgramCategoryQualification__c>> progCatMap;
        Set<id> catQualId = new Set<id>();
        boolean badDocExist = false ;
        Set<Decimal> docOrders = new Set<Decimal>{3,0,4,6};
        boolean pendingExist = false ;
        boolean isPrimary = false ;
        Set<Id> pqIdSet = new Set<id>();
        Map<Id,Integer> primaryPcqMap = new Map<Id,Integer>();
        Map<Id,Integer> idleCompletePcqMap = new Map<Id,Integer>();
        Map<Id,ProgramCategoryQualification__c> finalBadDocCatToUpdate = new Map<id,ProgramCategoryQualification__c>();
        Set<id> badDocPrimaryQualIds = new Set<id>();
        ProgramCategoryQualification__c temp ;
        System.debug('docsList size :'+docsList.size());
        Map<Id,String> docStatusMap = new Map<Id,String>();
/************************************************/       
// Checking for Eligibility in the Program Category Qualifications  
    for(QualificationDocumentRequirement__c qualDocs : docsList){
        System.debug('qualDocs.DocumentStatus__r.DocumentStatusEID__c:'+qualDocs.DocumentStatusEIDFormula__c); // QDR DOCUMENT STATUS
        if(qualDocs.DocumentStatus__c != null && qualDocs.ProgramCategoryQualification__c != null || 
        (qualDocs.DocumentStatus__c == null && oldMap.get(qualDocs.id).DocumentStatus__c != null && qualDocs.ProgramCategoryQualification__c != null)){//&& qualDocs.DocumentStatusEID__c  == 1 )
            prgCatQualIds.add(qualDocs.ProgramCategoryQualification__c);
            docStatusMap.put(qualDocs.ProgramCategoryQualification__c,qualDocs.DocumentStatus__c );
            }
            if(qualDocs.ProgramQualificationIdfromPCQFormula__c != null)
                pqIdSet.add(qualDocs.ProgramQualificationIdfromPCQFormula__c);
    }
    System.debug('prgCatQualIds:'+prgCatQualIds);
   
    if(prgCatQualIds != null && prgCatQualIds.size() > 0){
        
            for(AggregateResult aggr : [select count(id) pcqCount ,ProgramQualification__c pqId from ProgramCategoryQualification__c
                                            where ProgramQualification__c in :pqIdSet and  Readiness__r.QualificationReadinessEID__c = 4.0
                                            group by ProgramQualification__c]  ){
                              primaryPcqMap.put(String.valueOf(aggr.get('pqId')),Integer.valueOf(aggr.get('pcqCount'))) ;               
                       }
                         for(AggregateResult aggr : [select count(id) pcqCount ,ProgramQualification__c pqId from ProgramCategoryQualification__c
                                            where ProgramQualification__c in :pqIdSet and  Readiness__r.QualificationReadinessEID__c = 5.0
                                            group by ProgramQualification__c]  ){
                              idleCompletePcqMap.put(String.valueOf(aggr.get('pqId')),Integer.valueOf(aggr.get('pcqCount'))) ;               
                       }
                        System.debug('primaryPcqMap:'+primaryPcqMap);
            for(AggregateResult aggr : [select count(id) docsCount ,ProgramCategoryQualification__c catId from QualificationDocumentRequirement__c
                                            where ProgramCategoryQualification__c in :prgCatQualIds 
                                            group by ProgramCategoryQualification__c]  ){
                                              // MAP of PCQ & its QDR's
                               docCount.put(String.valueOf(aggr.get('catId')),Integer.valueOf(aggr.get('docsCount')));         
                    }
                    System.debug('docCount:'+docCount);
                                       
                    for(QualificationDocumentRequirement__c doc : [select ProgramCategoryQualification__c,ProgramCategoryQualification__r.Readiness__c, id, 
                                                            ProgramCategoryQualification__r.ReadinessEid__c,ProgramCategoryQualification__r.ProgramQualification__c,DocumentStatus__r.DocumentStatusEID__c from 
                                                               QualificationDocumentRequirement__c where ProgramCategoryQualification__c in :prgCatQualIds]){
                                        
                                         if(doc.ProgramCategoryQualification__r.ProgramQualification__c != null )
                                             prgQualIds1.put(doc.ProgramCategoryQualification__c,doc.ProgramCategoryQualification__r.ProgramQualification__c)  ;
                                       
                                                                
                                        if(docsListMap.get(doc.ProgramCategoryQualification__c) != null)    {
                                            docsListMap.get(doc.ProgramCategoryQualification__c).add(doc);
                                           
                                        }
                                        else {
                                            docList = new List<QualificationDocumentRequirement__c>();
                                            docList.add(doc);
                                            docsListMap.put(doc.ProgramCategoryQualification__c,docList);
                                        }  
                                                              
                                }
                                System.debug('docsListMap:'+docsListMap);
        /* Business Logic Starts*/                   
        //Query for all Program Category Qualification Categories by quering the Program Qualification         
                            if(prgQualIds1 != null && prgQualIds1.size() >0)
                                progCatMap = getProgramCatQualifications(prgQualIds1.values());              
               for(id pcqId : prgCatQualIds ){     
                        System.debug('pcqId:'+pcqId);  
                        badDocExist = false ;
                        pendingExist = false ;
                        isPrimary = false ;
                        if(docsListMap.get(pcqId).size() == 1 && docStatusMap.get(pcqId) == null){
                            //prgQualIds1
                            updateReadinessOnQDRIsNull(prgQualIds1.get(pcqId),pcqId);
                            
                        }else  if(docsListMap.get(pcqId).size() >= 1){
                                    for(QualificationDocumentRequirement__c doc : docsListMap.get(pcqId)){
                                             System.debug('doc.DocumentStatus__r.DocumentStatusEID__c:'+doc.DocumentStatus__r.DocumentStatusEID__c);   
                                             if(doc.ProgramCategoryQualification__r.ProgramQualification__c != null ){
                                                    prgQualIds.put(pcqId,doc.ProgramCategoryQualification__r.ProgramQualification__c)  ;
                                                    pqSet.add(doc.ProgramCategoryQualification__r.ProgramQualification__c);
                                                }
                                                                                           
                                                if(doc.DocumentStatus__r.DocumentStatusEID__c == 1){    
                                                    if(docsListMap1.get(doc.ProgramCategoryQualification__c) != null)    {
                                                        docsListMap1.get(doc.ProgramCategoryQualification__c).add(doc);
                                                        System.debug('docsListMap:'+docsListMap);
                                                    }
                                                    else {
                                                        docList = new List<QualificationDocumentRequirement__c>();
                                                        docList.add(doc);
                                                        docsListMap1.put(doc.ProgramCategoryQualification__c,docList);
                                                    }   
                                                    
                                                    // this is also Documentstep_c Map
                                                } else if(doc.DocumentStatus__r.DocumentStatusEID__c == 2){  // unusable
                                                        if(doc.ProgramCategoryQualification__r.ReadinessEid__c != 4){
                                                            temp = new ProgramCategoryQualification__c(id = doc.ProgramCategoryQualification__c, Readiness__c = readinessMap.get(3) ) ;
                                                           finalBadDocCatToUpdate.put( doc.ProgramCategoryQualification__c,temp);
                                                        } 
                                                        
                                                        else if(doc.ProgramCategoryQualification__r.ReadinessEid__c == 4 ){
                                                            temp = new ProgramCategoryQualification__c(id = doc.ProgramCategoryQualification__c, Readiness__c = readinessMap.get(3) ) ;
                                                            finalBadDocCatToUpdate.put( doc.ProgramCategoryQualification__c,temp);
                                                            isPrimary = true ;
                                                        } 
                                                            badDocPrimaryQualIds.add(doc.ProgramCategoryQualification__r.ProgramQualification__c);
                                                            badDocExist = true ; // for Disqualified Document Statuses.
                                                            pendingExist = false ; // For 3, 0, 4
                
                                                        // If the Document Status = 3, 0, 4 updating the current pcq record to Idle Incomplete.  
            
                                                } else if(docOrders.contains(doc.DocumentStatus__r.DocumentStatusEID__c) && !finalBadDocCatToUpdate.containsKey(doc.ProgramCategoryQualification__c)){
                                                       if((primaryPcqMap.containsKey(doc.ProgramCategoryQualification__r.ProgramQualification__c) && primaryPcqMap.get(doc.ProgramCategoryQualification__r.ProgramQualification__c) != null)
                                                        || idleCompletePcqMap.containsKey(doc.ProgramCategoryQualification__r.ProgramQualification__c)  )
                                                             temp = new ProgramCategoryQualification__c(id = doc.ProgramCategoryQualification__c, Readiness__c = readinessMap.get(1) ) ;
                                                        else
                                                             temp = new ProgramCategoryQualification__c(id = doc.ProgramCategoryQualification__c, Readiness__c = readinessMap.get(2) ) ;
                                                        finalBadDocCatToUpdate.put( doc.ProgramCategoryQualification__c,temp);
                                                        pendingExist = true ;
                                                    
                                                 if(doc.ProgramCategoryQualification__r.ReadinessEid__c == 4  )
                                                                isPrimary = true ;
                                                }
                                               
                                 }     //End QDR For Loop
                                    
                                    if(badDocExist){
                                        if(isPrimary)
                                            updateUnUsableCat(finalBadDocCatToUpdate,badDocPrimaryQualIds);
                                          else {
                                            QualificationDocReqHelper.byPassCode = true ;
                                            QualificationDocReqHelper.isManualUpdate = false ;
                                            System.debug('In UnUsable:'+finalBadDocCatToUpdate.values());
                                            update finalBadDocCatToUpdate.values();
                                        }
                                          
                                    }else if(pendingExist){
                                        if(isPrimary)
                                            updatePrimaryForPendingDocs(finalBadDocCatToUpdate,prgQualIds.values(),idleCompletePcqMap);
                                        else {
                                            QualificationDocReqHelper.byPassCode = true ;
                                            QualificationDocReqHelper.isManualUpdate = false ;
                                            System.debug('In Pending:'+finalBadDocCatToUpdate.values());
                                            update finalBadDocCatToUpdate.values();
                                        }
                                    }
                                    else {        
                                          //End Check for Eligibility     
                                          
                                                        
                                       // for(QualificationDocumentRequirement__c qualDoc : docsList){
                                            
                                            System.debug('pqSet:'+pqSet+':'+prgQualIds.get(pcqId));
                                            if(docCount.get(pcqId) != null && docsListMap1.containsKey(pcqId)
                                            && docCount.get(pcqId) == docsListMap1.get(pcqId).size()){
                                                if(isPqAlreadyProcessed.containsKey(prgQualIds.get(pcqId)) && isPqAlreadyProcessed.get(prgQualIds.get(pcqId))){
                                                    getUpdateProgramCatQualifications(prgQualIds.get(pcqId),progCatMap);
                                                }else {
                                                    isPqAlreadyProcessed.put(prgQualIds.get(pcqId),true);
                                                }
                                                
                                                
                                              System.debug('pcqId Before Processing:'+pcqId);
                                                    updateProgramCatQualifications(prgQualIds,progCatMap,pcqId);
                                                     
                                             }else if(docCount.get(pcqId) != null && docsListMap1.containsKey(pcqId)
                                            && docCount.get(pcqId) != docsListMap1.get(pcqId).size()){
                                                 isPqAlreadyProcessed.put(prgQualIds.get(pcqId),true);
                                                    System.debug('qualDocs Status null Processing:'+pcqId);
                                                    updateProgramCatQualificationsOnStatusNull(prgQualIds,progCatMap,pcqId);
                                            }
                                        }  
                                       
                                        //QualificationDocReqHelper.byPassCode = true ;
                                        //update finalMapToUpdate.values();                              
                                   
                    }
               }
     }                                                                 
    }

/************************************************/
// The following method for updating Program catagory Qualifications if all document status are good
// If the Current PCQ = 'Available' Updates to Primary. 

 private static void updateProgramCatQualifications(Map<Id,Id> prgQualIds,Map<id,List<ProgramCategoryQualification__c>> progCatMap, Id currentPcqId ){
    
   
    System.debug('All Pcqs to that PQ:'+progCatMap.get(prgQualIds.get(currentPcqId)));
    System.debug('Qdr Updated PCQ:'+currentPcqId);


        ProgramCategoryQualification__c temp ;
        
    for(ProgramCategoryQualification__c progCat : progCatMap.get(prgQualIds.get(currentPcqId))){
            System.debug('progCat.Readiness__r.QualificationReadinessEID__c:'+progCat.Readiness__r.QualificationReadinessEID__c);
            System.debug('progCat.:'+progCat.id);
                            if(currentPcqId == progCat.id){
                                if( progCat.Readiness__r.QualificationReadinessEID__c == 2.0 ) {// 2 -- Available
                                        System.debug('Match'+progCat.id+''+readinessMap.get(4));
                                        if(!finalMapToUpdate.containsKey(progCat.id)){
                                             progCat.Readiness__c =  readinessMap.get(4) ;
                                             finalMapToUpdate.put(progCat.id,progCat);
                                        }else {
                                            for(ProgramCategoryQualification__c progCat1 :getProgramCatPeridos(progCat,prgQualIds.get(currentPcqId))){
                                                finalMapToUpdate.put(progCat1.id,progCat1);
                                                System.debug('After Finding highest PCQ Rank Order :'+finalMapToUpdate);
                                            }
                                        }
                                }
                                /* QualificationReadinessEID__c =  4--PRimary , 1--Idle Incomplete , 3-- Disqualified 5--Idle Complete 2--Available */
                                
                                else if( progCat.Readiness__r.QualificationReadinessEID__c == 1.0 ||  progCat.Readiness__r.QualificationReadinessEID__c == 3.0 ) {
                                        for(ProgramCategoryQualification__c progCat1 :getProgramCatPeridos(progCat,prgQualIds.get(currentPcqId))){
                                            finalMapToUpdate.put(progCat1.id,progCat1);
                                            System.debug('After Finding highest PCQ Rank Order :'+finalMapToUpdate);
                                        }
                                }
                               // pqSet.remove(qualDocs.ProgramCategoryQualification__r.ProgramQualification__c);
                            }else if(progCat.Readiness__r.QualificationReadinessEID__c != 5.0 && progCat.Readiness__r.QualificationReadinessEID__c != 4.0){
                                System.debug('Inside Else'+progCat.id+''+readinessMap.get(1)); //Two Idle Incompletes are coming up!
                                 if(!finalMapToUpdate.containsKey(progCat.id)){ // ! in front on FinalMaptoUpdate removed on 5/22/2012
                                    progCat.Readiness__c = (progCat.Readiness__r.QualificationReadinessEID__c != 3.0  && progCat.Readiness__r.QualificationReadinessEID__c != 6.0) ? readinessMap.get(1)  : progCat.Readiness__c ;
                                    finalMapToUpdate.put(progCat.id,progCat);
                                 }
                            }
                        }
                        System.debug('finalMapToUpdate:'+finalMapToUpdate);
                        QualificationDocReqHelper.byPassCode = true ;
                        QualificationDocReqHelper.isManualUpdate = false ;
                            update finalMapToUpdate.values();    
                              
}

/************************************************/
// The following method is for updating Program category Qualifications if at least one document status is unusable

  private static void updateUnUsableCat(Map<id,ProgramCategoryQualification__c> finalBadDocCatToUpdate,Set<id> badDocPrimaryQualIds){
    System.debug('Entering Bad Docs :'+badDocPrimaryQualIds);
    List<ProgramCategoryQualification__c> completePcq = [select RankOrderofProgramcategory__c,id ,Readiness__r.QualificationReadinessEID__c,Readiness__c 
                                                        from ProgramCategoryQualification__c where ProgramQualification__c in :badDocPrimaryQualIds and id not in :finalBadDocCatToUpdate.KeySet() 
                                                        and Readiness__r.QualificationReadinessEID__c = 5 order by RankOrderofProgramcategory__c asc limit 1]; // changed ASC
                                                        
                                                        //(Readiness__r.QualificationReadinessEID__c = 5 or Readiness__r.QualificationReadinessEID__c = 4)
   if(completePcq != null && completePcq.size() > 0){
    
//If a Primary PCQ is changed to anything else quering for Idle Complete with highest PCQ Rank Order. 
        for(ProgramCategoryQualification__c progCat : completePcq){
            progCat.Readiness__c =   readinessMap.get(4) ;      
            finalBadDocCatToUpdate.put(progCat.id,progCat);                                         
                                                            
    } 
   } 
   else {
// If there are no Idle Complete then find out the Idle Incomplete and update the readiness to Available.
        for(ProgramCategoryQualification__c progCat : [select RankOrderofProgramcategory__c,id ,Readiness__r.QualificationReadinessEID__c,Readiness__c 
                                                            from ProgramCategoryQualification__c where ProgramQualification__c in :badDocPrimaryQualIds and id not in :finalBadDocCatToUpdate.KeySet() 
                                                            and Readiness__r.QualificationReadinessEID__c = 1]){
             progCat.Readiness__c =   readinessMap.get(2) ;  
             finalBadDocCatToUpdate.put(progCat.id,progCat);                                             
                                                                
        }
   }
System.debug('finalBadDocCatToUpdate:'+finalBadDocCatToUpdate);
QualificationDocReqHelper.byPassCode = true ;
QualificationDocReqHelper.isManualUpdate = false ;
update finalBadDocCatToUpdate.values();
    
}
/************************************************/
//The Following method is used for retrieving Program Category Qualifications */

 private static Map<id,List<ProgramCategoryQualification__c>> getProgramCatQualifications(List<id> prgQualIds){  
    Map<id,List<ProgramCategoryQualification__c>> progCatMap = new  Map<id,List<ProgramCategoryQualification__c>>();
    List<ProgramCategoryQualification__c> progCatList ;
    System.debug('prgQualIds:'+prgQualIds);
    for(ProgramCategoryQualification__c progCat : [Select Readiness__r.QualificationReadinessEID__c,
ProcessStageRankOrder__c, RankOrderofProgramcategory__c, ProgramQualification__c,ProgramCategoryPeriod__r.ProgramCategory__c, ProgramCategoryPeriod__c 
                                                    From ProgramCategoryQualification__c where ProgramQualification__c in :prgQualIds ]){
            if(progCatMap.containsKey(progCat.ProgramQualification__c)) {
                progCatMap.get(progCat.ProgramQualification__c).add(progCat);
            }   
            else {
                progCatList = new List<ProgramCategoryQualification__c>();
                progCatList.add(progCat);
                progCatMap.put(progCat.ProgramQualification__c,progCatList);
            }                                               
                                                        
    }
    
    return progCatMap ;
}
/************************************************/
//The Following method is used for retrieving latest Program Category Qualifications */

 private static Map<id,List<ProgramCategoryQualification__c>> getUpdateProgramCatQualifications(Id prgQualId, Map<id,List<ProgramCategoryQualification__c>> progCatMap){  
    //Map<id,List<ProgramCategoryQualification__c>> progCatMap = new  Map<id,List<ProgramCategoryQualification__c>>();
    List<ProgramCategoryQualification__c> progCatList =  new List<ProgramCategoryQualification__c>();    System.debug('prgQualIds:'+prgQualId);
    for(ProgramCategoryQualification__c progCat : [Select Readiness__r.QualificationReadinessEID__c,
ProcessStageRankOrder__c, RankOrderofProgramcategory__c, ProgramQualification__c,ProgramCategoryPeriod__r.ProgramCategory__c, ProgramCategoryPeriod__c 
                                                    From ProgramCategoryQualification__c where ProgramQualification__c =:prgQualId ]){
           
                
                progCatList.add(progCat);
               
            }                                               
     progCatMap.put(prgQualId,progCatList);                                                    
    
    
    System.debug('Update progCatMap:'+progCatMap);
    return progCatMap ;
}
// Also need to be changed in the test method 6/2/2012
public static Map<id,List<ProgramCategoryQualification__c>> TEST_getUpdateProgramCatQualifications(Id prgQualId ,Map<id,List<ProgramCategoryQualification__c>> pcqMap){
    if(test.isRunningTest()) return getUpdateProgramCatQualifications(prgQualId,pcqMap);
    else return null;
}
/************************************************/
//The Following method is used for retrieving Program Category Periods and their Rank orders

private static List<ProgramCategoryQualification__c> getProgramCatPeridos(ProgramCategoryQualification__c currentProgCat,Id currentPqId){   
    Map<id,List<ProgramCategoryQualification__c>> progCatMap = new  Map<id,List<ProgramCategoryQualification__c>>();
    List<ProgramCategoryQualification__c> progCatList ;
    Map<id,ProgramCategoryQualification__c> prgCatPeriodMap = new Map<id,ProgramCategoryQualification__c>();
    System.debug('prgQualIds:'+currentPqId); // Program Qualification
    double currentProgProcessRank = 0 ;
    Id primayrCat ;
    currentProgProcessRank = currentProgCat.ProcessStageRankOrder__c ; 
    
    ProgramCategoryQualification__c standProcessRank = [Select Readiness__c,ProcessStageRankOrder__c, ReadinessEid__c, Readiness__r.QualificationReadinessEID__c, RankOrderofProgramcategory__c, ProgramCategoryPeriod__r.ProgramCategory__c, ProgramCategoryPeriod__c, Id 
                                                From ProgramCategoryQualification__c where ProcessStageRankOrder__c < 100 order by ProcessStageRankOrder__c desc limit 1];
    for( ProgramCategoryQualification__c prg : [Select Readiness__c,RankOrderofProgramcategory__c   ,Readiness__r.QualificationReadinessEID__c, ProcessStageRankOrder__c, ProgramCategoryPeriod__r.ProgramCategory__c, ProgramCategoryPeriod__c, Id 
                                                From ProgramCategoryQualification__c where ProgramQualification__c =:currentPqId and 
                                                Readiness__r.QualificationReadinessEID__c = 4  ]){
                prgCatPeriodMap.put(prg.id,prg);  
                primayrCat = prg.id ;
                
                
                System.debug('Standard Rank :'+standProcessRank.ProcessStageRankOrder__c)  ;
                System.debug('currentProgramRank :'+currentProgProcessRank)  ;  
                System.debug('currentProgramCat :'+currentProgCat)  ;  
                System.debug('Primary Cat id :'+primayrCat)  ;                
           }
/************************************************/   
// If the Current PCQ Rank Order > Existing Primary PCQ Rank order then Current updates to 'Primary' Orelse to Idle Incomplete.
   if(prgCatPeriodMap != null && prgCatPeriodMap.size()>0 ){
                System.debug('Currnet Cat RanOrder :'+currentProgCat.RankOrderofProgramcategory__c);   
            System.debug('Primary Cat Rank Orderk :'+prgCatPeriodMap.get(primayrCat).RankOrderofProgramcategory__c)  ;
            if(currentProgCat.id <> primayrCat){ // code added on March 29
                if(currentProgProcessRank <= standProcessRank.ProcessStageRankOrder__c && //standProcessRank is STANDARD Process Stage Rank order which should be <100 
                    currentProgCat.RankOrderofProgramcategory__c < prgCatPeriodMap.get(primayrCat).RankOrderofProgramcategory__c ) { // change to <
                        currentProgCat.Readiness__c = readinessMap.get(4) ;
                        prgCatPeriodMap.get(primayrCat).Readiness__c = readinessMap.get(5) ;
                }else {
                    currentProgCat.Readiness__c = readinessMap.get(5) ;
                }
            }
    }
    else    
                currentProgCat.Readiness__c= readinessMap.get(4) ;
                
                prgCatPeriodMap.put(currentProgCat.id,currentProgCat);
    return prgCatPeriodMap.values();
}
/************************************************/
//The following Method is used for making primary if document status is not good and Unusable

private static void updatePrimaryForPendingDocs( Map<Id,ProgramCategoryQualification__c> finalBadDocCatToUpdate ,List<Id> pqIdsList,Map<id,Integer> icMap){
      System.debug('Entering Bad Docs :'+pqIdsList);
      // Quering for Idle Complete
      List<ProgramCategoryQualification__c> icPCQ = [select RankOrderofProgramcategory__c,id,ProgramQualification__c ,Readiness__r.QualificationReadinessEID__c,Readiness__c 
                                                    from ProgramCategoryQualification__c where ProgramQualification__c in :pqIdsList and id not in :finalBadDocCatToUpdate.KeySet() 
                                                    and Readiness__r.QualificationReadinessEID__c = 5 order by RankOrderofProgramcategory__c asc limit 1 ]; // changed to ASC
//Making the Idle Complete to Primary
    if(icPCQ != null && icPCQ.size()>0){
        for(ProgramCategoryQualification__c progCat : icPCQ){
            if(icMap.containsKey(progCat.ProgramQualification__c)){
             progCat.Readiness__c =   readinessMap.get(4) ;      
            finalBadDocCatToUpdate.put(progCat.id,progCat);   
            } 
        }    
// Making the PCQ's which are not 3 & 5 to Idle Incomplete(1)
        for(ProgramCategoryQualification__c progCat : [select RankOrderofProgramcategory__c,id,ProgramQualification__c ,Readiness__r.QualificationReadinessEID__c,Readiness__c 
                                                    from ProgramCategoryQualification__c where ProgramQualification__c in :pqIdsList and id not
                                                     in :finalBadDocCatToUpdate.KeySet() and Readiness__r.QualificationReadinessEID__c != 3
                                                      and Readiness__r.QualificationReadinessEID__c != 6]){
            if(progCat.Readiness__r.QualificationReadinessEID__c != 5 ){
                if(progCat.Readiness__r.QualificationReadinessEID__c == 4 )
                    progCat.Readiness__c =   readinessMap.get(5) ;
                else if(icMap.containsKey(progCat.ProgramQualification__c))
                    progCat.Readiness__c =   readinessMap.get(1) ; 
                else  
                     progCat.Readiness__c =   readinessMap.get(2) ;
            }
            finalBadDocCatToUpdate.put(progCat.id,progCat);                                             
                                                        
        }                                 
                                                        
    }else {
// If there are NO PCQ's with Idle Complete then updating all PCQ's to AVAILABLE
            for(ProgramCategoryQualification__c progCat : [select RankOrderofProgramcategory__c,id ,Readiness__r.QualificationReadinessEID__c,Readiness__c 
                                                                from ProgramCategoryQualification__c where ProgramQualification__c in :pqIdsList
                                                                and Readiness__r.QualificationReadinessEID__c != 3 and Readiness__r.QualificationReadinessEID__c != 6]){
                    progCat.Readiness__c =   readinessMap.get(2) ;  
                    finalBadDocCatToUpdate.put(progCat.id,progCat);                                             
                                                                    
            }
    }
System.debug('finalBadDocCatToUpdate:'+finalBadDocCatToUpdate);
QualificationDocReqHelper.byPassCode = true ;
QualificationDocReqHelper.isManualUpdate = false ;
update finalBadDocCatToUpdate.values();
}
    
/************************************************/
// The following method is for updating Readiness on PCQ which are not having QDR's.

public static void updateReadinessOnPCQ(List<QualificationDocumentRequirement__c> qdrList){
    
    System.debug('Entering into updateReadinessOnPCQ: '+qdrList);
     List<ProgramCategoryQualification__c> pcqList = new List<ProgramCategoryQualification__c>();
    Set<id> pcqIds = new Set<id>();
    Set<id> pqIds = new Set<id>();
     Set<id> pqIdsToProcess = new Set<id>();
      Set<id> pqSourceEID = new Set<id>();
     List<ProgramQualification__c> pqsToUpdate = new List<ProgramQualification__c>();
    QualificationProcessStage__c readyToPrepare, DocCollect, DocNeeded ;
    for(QualificationProcessStage__c processStage : [Select id,QualificationProcessStageEID__c, Name From   QualificationProcessStage__c 
                                                            where QualificationProcessStageEID__c in(5,22,26)]){
                                                                
                  if(processStage.QualificationProcessStageEID__c == 5 )
                       readyToPrepare = processStage;
                  else if(processStage.QualificationProcessStageEID__c == 22 )
                       DocCollect = processStage;
                  else 
                       DocNeeded  = processStage;
         }
                                                                                                           
            
        Map<String,Integer> highRank = new Map<String,Integer>();
        for(QualificationDocumentRequirement__c qdoc : qdrList){
            if(qdoc.ProgramCategoryQualification__c != null && !pcqIds.contains(qdoc.ProgramCategoryQualification__c))
                pcqIds.add(qdoc.ProgramCategoryQualification__c);
                 pqIds.add(qdoc.PQPCQIDFormula__c);
        }
        System.debug('PqIds :'+pqIds);
        System.debug('PcqIds:'+pcqIds);
        for(AggregateResult aggr : [select min(RankOrderofProgramcategory__c) rankOrder,ProgramQualification__c pqId from ProgramCategoryQualification__c where // changed to MIN
                                    ProgramQualification__c in :pqIds and id not in :pcqIds and ProcessStageEIDformula__c = 22 group by ProgramQualification__c]){
            highRank.put(String.valueOf(aggr.get('pqId')),Integer.valueOf(aggr.get('rankOrder')));
        }
        System.debug('highRank:'+highRank); //PQDocumentSourceEidGeneratedFormula__c
         for(ProgramCategoryQualification__c pcq : [select ProgramQualification__c ,PQDocumentSourceEidGeneratedFormula__c,RankOrderofProgramcategory__c,Readiness__c from ProgramCategoryQualification__c where 
                                    ProgramQualification__c in :pqIds and id not in :pcqIds and ProcessStageEIDformula__c = 22 ]){
                            
                        if(highRank.containsKey(pcq.ProgramQualification__c) && highRank.get(pcq.ProgramQualification__c) != null && pcq.RankOrderofProgramcategory__c == highRank.get(pcq.ProgramQualification__c)  ){
                            pcqList.add(new ProgramCategoryQualification__c(id = pcq.id ,Readiness__c = readinessMap.get(4)  ));
                            if(pcq.PQDocumentSourceEidGeneratedFormula__c != null && pqIds.contains( pcq.ProgramQualification__c))
                                pqsToUpdate.add(new ProgramQualification__c(id = pcq.ProgramQualification__c ,ProcessStage__c = DocCollect.id));
                            else if (pqIds.contains(pcq.ProgramQualification__c))
                             pqsToUpdate.add(new ProgramQualification__c(id = pcq.ProgramQualification__c ,ProcessStage__c = readyToPrepare.id));
                        }
                        else
                            pcqList.add(new ProgramCategoryQualification__c(id = pcq.id ,Readiness__c = readinessMap.get(5)  ));
                            pqIds.remove(pcq.ProgramQualification__c) ; 
        }
       System.debug('Remaining PqIds :'+pqIds);
        if(pcqIds != null && pcqIds.size() > 0){
          //  QualificationProcessStage__c processStage = [  Select id,QualificationProcessStageEID__c, Name From   QualificationProcessStage__c 
              //                                              where QualificationProcessStageEID__c = 26]; // 26 - Docs Needed
           for(QualificationDocumentRequirement__c qdoc :  qdrList){
          //  for(Id pcqId  :  pcqIds){
              
                if(pqIds != null && !pqIds.contains(qdoc.PQPCQIDFormula__c) && pcqIds.contains(qdoc.ProgramCategoryQualification__c))
                    pcqList.add(new ProgramCategoryQualification__c(id = qdoc.ProgramCategoryQualification__c , ProcessStage__c = DocNeeded.id,Readiness__c = readinessMap.get(1) ) );
                  //  pcqList.add(new ProgramCategoryQualification__c(id = pcqId , ProcessStage__c = processStage.id,Readiness__c = readinessMap.get(1) ) );
                else if(pcqIds.contains(qdoc.ProgramCategoryQualification__c))
                    pcqList.add(new ProgramCategoryQualification__c(id = qdoc.ProgramCategoryQualification__c , ProcessStage__c = DocNeeded.id,Readiness__c = readinessMap.get(2) ) );
                    
                    pcqIds.remove(qdoc.ProgramCategoryQualification__c);
                  //  pcqList.add(new ProgramCategoryQualification__c(id = pcqId , ProcessStage__c = processStage.id,Readiness__c = readinessMap.get(2) ) );
            }
       }
       System.debug('pcqList:'+pcqList);
       System.debug('pcqList:' +pcqList.size());
       System.debug('pqsToUpdate:'+pqsToUpdate);
       System.debug('pqsToUpdate:' +pqsToUpdate.size());
       QualificationDocReqHelper.isDocReqExist = true ; 
     // QualificationDocReqHelper.byPassTriggers = true ; // comment before Rep doc
        if(pcqList != null && pcqList.size() > 0)
            Database.update(pcqList,false);
        if(pqsToUpdate != null && pqsToUpdate.size() > 0) //tt
            Database.update( pqsToUpdate,false);       
 
  }  
/************************************************/
//The following method is used for updating Readiness on PCQ if None of the PCQs have qdrs
  
public static void updateReadinessOnNoQDRs(Map<Id,List<ProgramCategoryQualification__c>> pcqMap){
    Map<Id,Decimal> pcqRankOrderMap = new Map<Id,Decimal>();
    List<ProgramCategoryQualification__c> finalPcqstoUpdate = new   List<ProgramCategoryQualification__c>();
    Decimal maxRankOrder = 0 ;
//  QualificationProcessStage__c processStage = [   Select id,QualificationProcessStageEID__c, Name From   QualificationProcessStage__c 
  //                                                          where QualificationProcessStageEID__c = 26];
            
     for(AggregateResult aggr : [select min(RankOrderofProgramcategory__c) rankOrder,ProgramQualification__c pqId from ProgramCategoryQualification__c where  // changed to MIN
                                    ProgramQualification__c in :pcqMap.KeySet()  group by ProgramQualification__c]){
            pcqRankOrderMap.put(String.valueOf(aggr.get('pqId')),Integer.valueOf(aggr.get('rankOrder')));
        }
       
    for(Id pqId : pcqMap.KeySet()){
        System.debug('PqId:'+pqId);
        maxRankOrder = pcqRankOrderMap.get(pqId) ;
        for(ProgramCategoryQualification__c pcq : pcqMap.get(pqId)){
            if(pcq.RankOrderofProgramcategory__c == maxRankOrder  )
                finalPcqstoUpdate.add(new ProgramCategoryQualification__c(id = pcq.id,Readiness__c = readinessMap.get(4)));
            else 
                finalPcqstoUpdate.add(new ProgramCategoryQualification__c(id = pcq.id,Readiness__c = readinessMap.get(5)));
                
        }
    }
    System.debug('finalPcqstoUpdate:'+finalPcqstoUpdate);
    QualificationDocReqHelper.byPassCode = true ;
    QualificationDocReqHelper.byPassTriggers = true ;
    QualificationDocReqHelper.isManualUpdate = false ;
    update finalPcqstoUpdate ;
} 

/*************************************************/
//The following method is for updating Readiness when the PCQ is updated Manually 

public static void updateReadinessManually(List<ProgramCategoryQualification__c> newPCQs,Map<id,ProgramCategoryQualification__c> oldPcqMap){
    Set<Id> pqsIdSet = new Set<Id>();
    Map<Id,ProgramCategoryQualification__c> finalPCQToUpdate = new Map<Id,ProgramCategoryQualification__c>();
    for(ProgramCategoryQualification__c pcq : newPCQs){
        if((pcq.Readiness__c == readinessMap.get(6) || pcq.Readiness__c == readinessMap.get(3)) && oldPcqMap.get(pcq.id).Readiness__c == readinessMap.get(4))
            pqsIdSet.add(pcq.ProgramQualification__c);
            
           pcq.Readiness__c = (pcq.Readiness__c == readinessMap.get(3) &&  oldPcqMap.get(pcq.id).Readiness__c <> readinessMap.get(3))? readinessMap.get(6):  pcq.Readiness__c ;
    }
    if(pqsIdSet != null && pqsIdSet.size() > 0){
        System.debug('pqsIdSet:'+pqsIdSet);
        // Quering for Idle Complete
      List<ProgramCategoryQualification__c> icPCQ = [select RankOrderofProgramcategory__c,id ,Readiness__r.QualificationReadinessEID__c,Readiness__c 
                                                    from ProgramCategoryQualification__c where ProgramQualification__c in :pqsIdSet and id not in :newPCQs 
                                                    and Readiness__r.QualificationReadinessEID__c = 5 order by RankOrderofProgramcategory__c asc limit 1 ]; // changed to ASC
//Making the Idle Complete to Primary
    if(icPCQ != null && icPCQ.size()>0){
        for(ProgramCategoryQualification__c progCat : icPCQ){
             progCat.Readiness__c =   readinessMap.get(4) ;      
            finalPCQToUpdate.put(progCat.id,progCat);    
        }    
                                                        
    }else {
// If no PCQ with Idle Complete then updating all PCQ's to AVAILABLE
            for(ProgramCategoryQualification__c progCat : [select RankOrderofProgramcategory__c,id ,Readiness__r.QualificationReadinessEID__c,Readiness__c 
                                                                from ProgramCategoryQualification__c where ProgramQualification__c in :pqsIdSet
                                                                and  id not in :newPCQs 
                                                                and Readiness__r.QualificationReadinessEID__c != 3 and Readiness__r.QualificationReadinessEID__c != 6]){
                    progCat.Readiness__c =   readinessMap.get(2) ;  
                    finalPCQToUpdate.put(progCat.id,progCat);                                             
                                                               
            }
    }
System.debug('finalPCQToUpdate:'+finalPCQToUpdate);
QualificationDocReqHelper.byPassCode = true ;
QualificationDocReqHelper.isManualUpdate = false ;
update finalPCQToUpdate.values();
        
    }
}

/*************************************************/
//The following method is for updating readiness on PCQ when atleast one QDR is Good and the other QDR's are NULL

public static void updateProgramCatQualificationsOnStatusNull(Map<Id,Id> prgQualIds,Map<id,List<ProgramCategoryQualification__c>> progCatMap, Id currentPCQId ){
     
     System.debug('progCatMap.get(prgQualIds.get(qualDocs.id):'+progCatMap.get(prgQualIds.get(currentPCQId)));
     System.debug('currentPCQId:'+currentPCQId);
    
     ProgramCategoryQualification__c temp ;
     boolean existIdleComplete = false ;
     Map <Id,boolean> primaryPCQ = new Map <Id,boolean>();
      Map <Id,boolean> idleCompletePCQ = new Map <Id,boolean>();
     
    //The following line is used to identify primary PCQ
     for(ProgramCategoryQualification__c progCat :[select ProgramQualification__c, Readiness__r.QualificationReadinessEID__c from ProgramCategoryQualification__c
                                                    where ProgramQualification__c in :prgQualIds.values() and id <> :currentPCQId]){
        if(progCat.Readiness__r.QualificationReadinessEID__c == 4.0)
            primaryPCQ.put(progCat.ProgramQualification__c,true);
            
         if(progCat.Readiness__r.QualificationReadinessEID__c == 5.0){
            existIdleComplete = true ;
            idleCompletePCQ.put(progCat.ProgramQualification__c,true);
         }
     }
     System.debug('primaryPCQ:'+primaryPCQ);
        
    for(ProgramCategoryQualification__c progCat : [select ProgramQualification__c, Readiness__r.QualificationReadinessEID__c from ProgramCategoryQualification__c
                                                    where ProgramQualification__c in :prgQualIds.values()]){
            System.debug('progCat.Readiness__r.QualificationReadinessEID__c:'+progCat.Readiness__r.QualificationReadinessEID__c);
            System.debug('progCat.:'+progCat.id);
                            if(currentPCQId == progCat.id && progCatMap.get(prgQualIds.get(currentPCQId)).size() == 1){
                                        progCat.Readiness__c =  readinessMap.get(2) ;
                                        
                                }
                            else if(currentPCQId == progCat.id && progCatMap.get(prgQualIds.get(currentPCQId)).size() > 1 ) {
                                    if((primaryPCQ.containsKey(progCat.ProgramQualification__c) || 
                                    idleCompletePCQ.containsKey(progCat.ProgramQualification__c)) && (primaryPCQ.get(progCat.ProgramQualification__c)
                                    || idleCompletePCQ.get(progCat.ProgramQualification__c)))
                                         progCat.Readiness__c = ( /*progCat.Readiness__r.QualificationReadinessEID__c != 3.0 && Comment on 6/2*/  progCat.Readiness__r.QualificationReadinessEID__c != 6.0) ? readinessMap.get(1) :  progCat.Readiness__c  ;
                                    else
                                         progCat.Readiness__c =  readinessMap.get(2) ;
                                         System.debug('Logic 1:'+finalMapToUpdate);
                                        finalMapToUpdate.put(progCat.id,progCat);   
                                
                             }
                             else if(!primaryPCQ.containsKey(progCat.ProgramQualification__c) && existIdleComplete && progCat.Readiness__r.QualificationReadinessEID__c == 5.0 ){
                                 progCat.Readiness__c =  readinessMap.get(4) ;
                                 existIdleComplete = false ;
                             } else if(primaryPCQ.containsKey(progCat.ProgramQualification__c) || idleCompletePCQ.containsKey(progCat.ProgramQualification__c)) {
                                if( progCat.Readiness__r.QualificationReadinessEID__c <> 4.0 && progCat.Readiness__r.QualificationReadinessEID__c <> 3.0 &&  progCat.Readiness__r.QualificationReadinessEID__c <> 6.0 &&  progCat.Readiness__r.QualificationReadinessEID__c <> 5.0)
                                        progCat.Readiness__c =  readinessMap.get(1) ;
                             }
                             else //progCat.Readiness__c 
                                progCat.Readiness__c =  readinessMap.get(2) ;
                                
                                 finalMapToUpdate.put(progCat.id,progCat);
                             System.debug('Logic 2:'+finalMapToUpdate);
                            
     }
                        System.debug('finalMapToUpdate:'+finalMapToUpdate);
                        QualificationDocReqHelper.byPassCode = true ;
                        QualificationDocReqHelper.isManualUpdate = false ;
                            update finalMapToUpdate.values(); 
                            finalMapToUpdate.clear(); 
                             
                              
}
/*************************************************/
//The following method is for Updating PQDocumentSourceEid on PQ from its QDR's

public static void updatePQDocumentSourceEid( List<QualificationDocumentRequirement__c> qdrList){
    System.debug('updatePQDocumentSourceEid :'+qdrList);

    Map<Id,Id> docStepId = new Map<id,Id>();
    Map<Id,Id> qdrpqIds = new Map<id,Id>();
    Set<Decimal> eligibleEmpSourceEIDforPQ = new Set<Decimal>{1,2,3};
    Map<Id,Decimal> empSourceId = new Map<Id,Decimal>();
    Map<Id,Decimal> docReqs = new Map<id,Decimal>();
    Set<id> docReqId = new Set<Id>();
    Map<Id,ProgramQualification__c> pqsToUpdate = new Map<Id,ProgramQualification__c>();
        for(QualificationDocumentRequirement__c qdr : qdrList){
            system.debug('qdrList :'+qdrList);
            docReqId.add(qdr.DocumentRequirement__c);
            if(qdr.ProgramQualification__c != null){
                qdrpqIds.put(qdr.id,qdr.ProgramQualification__c);
            }
        }
        System.debug('docReqId:'+docReqId);
        for(DocumentStep__c ds : [select id,DocumentRequirement__c from DocumentStep__c where DocumentRequirement__c in :docReqId ]){
            docStepId.put(ds.id,ds.DocumentRequirement__c);
        }
        for(DocumentOption__c docOption : [select EmployeSourceEIDforPQFormula__c, DocumentStep__c from DocumentOption__c where DocumentStep__c in :docStepId.keySet()]){
            if(docOption.EmployeSourceEIDforPQFormula__c != null && eligibleEmpSourceEIDforPQ.contains(docOption.EmployeSourceEIDforPQFormula__c) &&!empSourceId.containsKey(docOption.DocumentStep__c))
                empSourceId.put(docOption.DocumentStep__c,docOption.EmployeSourceEIDforPQFormula__c);
        }
        for(Id docStep : empSourceId.KeySet()){
            docReqs.put(docStepId.get(docStep),empSourceId.get(docStep));
        }
    
        for(QualificationDocumentRequirement__c qdr :qdrList){
            if(docReqs.containsKey(qdr.DocumentRequirement__c) && docReqs.get(qdr.DocumentRequirement__c) != null){
                pqsToUpdate.put(qdr.ProgramQualification__c , new ProgramQualification__c(id = qdrpqIds.get(qdr.Id) ,PQDocumentSourceEidGenerated__c = docReqs.get(qdr.DocumentRequirement__c)  ));
            }
                
        }
        System.debug('pqsToUpdate:'+pqsToUpdate);
        if(pqsToUpdate != null && pqsToUpdate.size() > 0){
            QualificationDocReqHelper.updatePQDocSourceEid = true ;

            update pqsToUpdate.values() ;
        }
        
        
        
}

/*************************************************/
//The following method is for updating Readiness When PCQ contains only ONE QDR.

public static void updateReadinessOnQDRIsNull(id pqId,id currentPcqId){
    System.debug('PqId :'+pqId);
    System.debug('currentPcqId:'+currentPcqId);
    set<id> primarySet = new Set<id>() ;
    set<id> isidleComplete = new Set<id>() ;
    
    List<ProgramCategoryQualification__c> pcqListToUpdate = new List<ProgramCategoryQualification__c>();
    List<ProgramCategoryQualification__c> pcqList = [select id,RankOrderofProgramcategory__c,ProgramQualification__c, Readiness__r.QualificationReadinessEID__c from ProgramCategoryQualification__c where
                                                    ProgramQualification__c =:pqId order by  Readiness__r.QualificationReadinessEID__c desc];
    for(ProgramCategoryQualification__c pcq : pcqList){
        
        System.debug('Readiness EiD :'+pcq.Readiness__r.QualificationReadinessEID__c);
        if( pcq.Readiness__r.QualificationReadinessEID__c == 4.0 && currentPcqId <> pcq.id ){
            primarySet.add(pcq.ProgramQualification__c) ;
        }
        if(pcq.Readiness__r.QualificationReadinessEID__c == 5.0)
            isIdleComplete.add(pcq.ProgramQualification__c);
    }

    for(ProgramCategoryQualification__c pcq : pcqList){
        System.debug('PcqId:'+pcq.id);
        if(currentPcqId == pcq.id && (pcq.Readiness__r.QualificationReadinessEID__c == 4.0 || pcq.Readiness__r.QualificationReadinessEID__c == 5.0) ){
            
            if( isIdleComplete.contains(pcq.ProgramQualification__c) && pcq.Readiness__r.QualificationReadinessEID__c == 4.0 ){
                pcqListToUpdate.add(new ProgramCategoryQualification__c(id = pcq.id, Readiness__c =  readinessMap.get(1) ));
                //isIdleComplete.remove(pcq.ProgramQualification__c);
            }
            else if(pcq.Readiness__r.QualificationReadinessEID__c == 5.0 && primarySet.contains(pcq.ProgramQualification__c))
                pcqListToUpdate.add(new ProgramCategoryQualification__c(id = pcq.id, Readiness__c =  readinessMap.get(1) ));
            else if(primarySet.contains(pcq.ProgramQualification__c) || isIdleComplete.contains(pcq.ProgramQualification__c)){
                if( pcq.Readiness__r.QualificationReadinessEID__c <> 6.0)
                    pcqListToUpdate.add(new ProgramCategoryQualification__c(id = pcq.id, Readiness__c =  readinessMap.get(1) ));
            }
            else if( pcq.Readiness__r.QualificationReadinessEID__c <> 6.0)
             pcqListToUpdate.add(new ProgramCategoryQualification__c(id = pcq.id, Readiness__c =  readinessMap.get(2) ));
            
        }
        else if(!primarySet.contains(pcq.ProgramQualification__c) && pcq.Readiness__r.QualificationReadinessEID__c == 5.0){
                    pcqListToUpdate.add(new ProgramCategoryQualification__c(id = pcq.id, Readiness__c =  readinessMap.get(4) ));
                    primarySet.add(pcq.ProgramQualification__c) ;   
        }
        else if( primarySet.contains(pcq.ProgramQualification__c) || isIdleComplete.contains(pcq.ProgramQualification__c)){
            
                if( pcq.Readiness__r.QualificationReadinessEID__c != 5.0 && pcq.Readiness__r.QualificationReadinessEID__c != 4.0 &&   pcq.Readiness__r.QualificationReadinessEID__c != 6.0) 
            pcqListToUpdate.add(new ProgramCategoryQualification__c(id = pcq.id, Readiness__c =  readinessMap.get(1) ));
        }else if(pcq.Readiness__r.QualificationReadinessEID__c != 5.0 && pcq.Readiness__r.QualificationReadinessEID__c != 4.0 && pcq.Readiness__r.QualificationReadinessEID__c != 6.0)
            pcqListToUpdate.add(new ProgramCategoryQualification__c(id = pcq.id, Readiness__c =  readinessMap.get(2) ));        
    }
    System.debug('pcqListToUpdate:'+pcqListToUpdate);
    update pcqListToUpdate ;
   
}
}