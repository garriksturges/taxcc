Public class ProcessStageHelper {
    
  static Map<Decimal,Id> processStage = new Map<Decimal,id>();
  
    static {
        for(QualificationProcessStage__c qualProc: [Select id,QualificationProcessStageEID__c, Name 
                                                       From QualificationProcessStage__c] ){
             processStage.put(qualProc.QualificationProcessStageEID__c ,qualProc.id );                               
                      }
    }
    public static void updateProcessStage(List<ProgramCategoryQualification__c> pcqList,Map<id,ProgramCategoryQualification__c> oldPCQ){
        Set<Id> pqSet = new Set<id>();
        Set<Id> pcqSet = new Set<id>();
        Integer maxStepOrder = 0;
        Map<Id,Decimal> pcqStagesId = new Map<Id,Decimal>();
        Map<Id,Decimal> pqStagesId = new Map<Id,Decimal>();
        Map<String,Integer> GoodDocMap = new Map<String,Integer>();
        Map<String,Integer> QdrcountMap = new Map<String,Integer>();
        Map<Id,Integer> disQualPQsCount = new Map<Id,Integer>();
        Map<id,ProgramQualification__c> pqToUpdate = new Map<id,ProgramQualification__c>();
        Set<id> disQualPQs = new Set<Id>();
        ProgramQualification__c temp ;
        Set<Id> primaryPqSet = new Set<id>();
        Map<Id,Decimal> completePCQSortOrder  = new Map<Id,Decimal>();
        Map<Id,Decimal> readyPQSortOrder = new Map<Id,Decimal>();
        Set<id> pqSourceEid = new Set<Id>();
        
        for(ProgramCategoryQualification__c pcq : pcqList){
            if(pcq.ProgramQualification__c != null )
                pqSet.add(pcq.ProgramQualification__c);
            if(pcq.ReadinessEid__c <> 3.0 &&( pcq.ReadinessEid__c <> 4.0 && oldPCQ.get(pcq.id).ReadinessEid__c == 4.0 || pcq.ReadinessEid__c <> 5.0 && oldPCQ.get(pcq.id).ReadinessEid__c == 5.0) )
                pcqSet.add(pcq.id);
              if(pcq.ReadinessEid__c == 4.0 )
                   primaryPqSet.add(pcq.ProgramQualification__c);
      }
            System.debug('pcqSet:'+pcqSet);
            System.debug('pqSet:'+pqSet);
            
        for(ProgramCategoryQualification__c pcq : [Select ProgramQualification__c, RankOrderofProgramcategory__c,ProcessStageEIDformula__c From ProgramCategoryQualification__c 
                                                        where ProgramQualification__c in :pqSet and ProcessStageEIDformula__c  = 22 order by RankOrderofProgramcategory__c asc]){ // asc
            
            if(!completePCQSortOrder .containsKey(pcq.ProgramQualification__c)) 
            completePCQSortOrder.put(pcq.ProgramQualification__c,pcq.RankOrderofProgramcategory__c);        
        
      }
            System.debug('completePCQSortOrder:'+completePCQSortOrder);
        for(ProgramQualification__c pq : [Select id, ReadyPQSortOrderFormula__c From ProgramQualification__c 
                                            where id in :pqSet order by ReadyPQSortOrderFormula__c desc]){
                                                
            if(!readyPQSortOrder .containsKey(pq.id))   
            readyPQSortOrder.put(pq.id,pq.ReadyPQSortOrderFormula__c);      
        
      } 
            System.debug('readyPQSortOrder:'+readyPQSortOrder); 
            
/************************************************/        
// pcqStagesId gets the highest QPS Sort Order from the QDS and its whole logic.
      for(QualificationDocumentStep__c docStep : [Select QPSCertificationEIDFormula__c,QPSRankOrderFormula__c,QualificationDocumentRequirement__r.ProgramCategoryQualification__c from QualificationDocumentStep__c
                                                    Where QualificationDocumentRequirement__r.ProgramCategoryQualification__c in:pcqSet and
                                                     QPSIncertificationProcessEID__c = 0 and DocumentStatusEIDFormula__c = 1 order by QPSRankOrderFormula__c]){
                                                        
                pcqStagesId.put(docStep.QualificationDocumentRequirement__r.ProgramCategoryQualification__c,docStep.QPSCertificationEIDFormula__c);
            }
            system.debug('pcqCountStagesId:'+pcqStagesId.size());
            
      for(QualificationDocumentStep__c docStep : [Select QPSCertificationEIDFormula__c,QPSRankOrderFormula__c,QualificationDocumentRequirement__r.ProgramQualification__c from QualificationDocumentStep__c
                                                    Where QualificationDocumentRequirement__r.ProgramQualification__c in:pqSet and
                                                     QPSIncertificationProcessEID__c = 1 and DocumentStatusEIDFormula__c = 1 order by QPSRankOrderFormula__c]){
                     
                pqStagesId.put(docStep.QualificationDocumentRequirement__r.ProgramQualification__c,docStep.QPSCertificationEIDFormula__c);
            }       
            system.debug('pq1StagesId:' +pqStagesId.size());
            
        System.debug('pcqStagesId:'+pcqStagesId);
        System.debug('processStage:'+processStage);
        
/************************************************/
 // Complete PCQ Sort order should be greater than the Rank order of the PQ condition.
 
        for(ProgramCategoryQualification__c pcq : pcqList){
            System.debug('pcq.ReadinessEid__c:'+pcq.RankOrderofProgramcategory__c );
            
//Updating Process Stage on PCQ
			        if( (pcq.ReadinessEid__c == 4.0 || pcq.ReadinessEid__c == 5.0 ) && completePCQSortOrder.containsKey(pcq.ProgramQualification__c) 
			            &&  pcq.RankOrderofProgramcategory__c > completePCQSortOrder.get(pcq.ProgramQualification__c) ) // changed
			                    pcq.ProcessStage__c = processStage.get(22);
			              else if(pcqSet.contains(pcq.id)&& pcqStagesId.containsKey(pcq.id) && pcqStagesId.get(pcq.id) != null )
			                        pcq.ProcessStage__c = processStage.get(pcqStagesId.get(pcq.id) );
			              else if (pcq.ReadinessEid__c <> 3.0 && pcq.ReadinessEid__c <> 6.0 ) /*pcq.ReadinessEid__c <> 4.0 || pcq.ReadinessEid__c <> 5.0)*/
			                       pcq.ProcessStage__c = processStage.get(26);
			           System.debug('completePCQSortOrderdebug:'+ completePCQSortOrder);
			           
			 // Updating the Process Stage Date in PCQ
			            if(pcq.ProcessStage__c <> oldPCQ.get(pcq.id).ProcessStage__c)
			                    pcq.ProcessStageDate__c = System.now() ;
			                        
/************************************************/              
 //Updating Process Stage on PQ
 
                 if((pcq.ReadinessEid__c == 4.0 || pcq.ReadinessEid__c == 5.0) && (readyPQSortOrder.containsKey(pcq.ProgramQualification__c) &&
                 				readyPQSortOrder.get(pcq.ProgramQualification__c) <= 90)){
                    			System.debug('readyPQSortOrder:'+readyPQSortOrder );
                    
                                     //pcq.ProcessStageRankOrder__c <= readyPQSortOrder.get(pcq.ProgramQualification__c))){
		                    if(pcq.PQDocumentSourceEidGeneratedFormula__c != null)                                     
		                      temp = new ProgramQualification__c(id = pcq.ProgramQualification__c ,ProcessStage__c =  processStage.get(8) ); // Doc Collection
		                    else 
		                        temp = new ProgramQualification__c(id = pcq.ProgramQualification__c ,ProcessStage__c =  processStage.get(5) ); // Ready to Prepare
		                       pqToUpdate.put( pcq.ProgramQualification__c , temp);
		 
		                 }
                 else if(pcq.ReadinessEid__c <> 4.0 && oldPCQ.get(pcq.id).ReadinessEid__c == 4.0){          
		                     if(!pqToUpdate.containsKey(pcq.ProgramQualification__c)) {  
		                        if(pqStagesId.containsKey(pcq.ProgramQualification__c) && pqStagesId.containsKey(pcq.ProgramQualification__c) != null) {
		                            temp = new ProgramQualification__c(id = pcq.ProgramQualification__c ,ProcessStage__c =  processStage.get(pqStagesId.get(pcq.ProgramQualification__c)) );
		                            pqToUpdate.put( pcq.ProgramQualification__c , temp);
		                        }else {
		                            temp = new ProgramQualification__c(id = pcq.ProgramQualification__c ,ProcessStage__c =  processStage.get(8) );
		                            pqToUpdate.put( pcq.ProgramQualification__c , temp);
		                        }
		                     }
		                    
                 }
                  else if(pcq.ReadinessEid__c <> 3.0 && !pqToUpdate.containsKey( pcq.ProgramQualification__c) &&  readyPQSortOrder.get(pcq.ProgramQualification__c) < 90){
                         temp = new ProgramQualification__c(id = pcq.ProgramQualification__c ,ProcessStage__c =  processStage.get(8) );
                            pqToUpdate.put( pcq.ProgramQualification__c , temp);
                     }
                //    Map<Id,Integer> disQualPQsCount = new Map<Id,Integer>();
          if((pcq.ReadinessEid__c == 3.0 ||  pcq.ReadinessEid__c == 6.0 ) && (pcq.ReadinessEid__c <> oldPCQ.get(pcq.id).ReadinessEid__c) ){
            		 pcq.ProcessStage__c = processStage.get(3);
		             if(disQualPQsCount.containsKey(pcq.ProgramQualification__c)){
		                
		                Integer pcqCount =  0 ;
		                pcqCount = disQualPQsCount.get(pcq.ProgramQualification__c);
		                disQualPQsCount.put(pcq.ProgramQualification__c,pcqCount + 1);
		                system.debug('disQualPQsCount:'+disQualPQsCount);
		             }
		             
		             else 
		                disQualPQsCount.put(pcq.ProgramQualification__c,1);
		                
		                disQualPQs.add(pcq.ProgramQualification__c);
		           }
           if(pcq.ReadinessEid__c == 4.0 /*&& oldPCQ.get(pcq.id).ReadinessEid__c <> 4.0)*/ || pcq.ReadinessEid__c == 5.0 /*&&  oldPCQ.get(pcq.id).ReadinessEid__c <> 5.0)*/ ){
           		 pcq.ProcessStage__c = processStage.get(22);
          
           }
        }//End For
/************************************************/           
 // If all the PCQ's are Disqualified updating PQ
 
      Map<String,Integer> disPcqCountMap = new Map<String,Integer>();
      Map<String,Integer> pcqCountMap = new Map<String,Integer>();
      Integer pcqCount = 0 ;
      System.debug('disQualPQs:'+disQualPQs);
       if(disQualPQs != null && disQualPQs.size()>0){
            for(AggregateResult aggr : [select count(id) pcqCount,ProgramQualification__c pq from ProgramCategoryQualification__c where ProgramQualification__c in :disQualPQs group by ProgramQualification__c ]){
                pcqCountMap.put(String.valueOf(aggr.get('pq')),Integer.valueOf(aggr.get('pcqCount')));
            }
            system.debug('pcqCountMap:'+ pcqCountMap);
             for(AggregateResult agg : [select Count(id) disCount ,ProgramQualification__c from ProgramCategoryQualification__c where ProgramQualification__c
                                                          in :disQualPQs and ProcessStage__c =:processStage.get(3) group by ProgramQualification__c]){
                            disPcqCountMap.put(String.valueOf(agg.get('ProgramQualification__c')),Integer.valueOf(agg.get('disCount')));                                                
                                               
            }
            System.debug('pcqCountMap:'+pcqCountMap);
             System.debug('disPcqCountMap:'+disPcqCountMap);
             System.debug('disQualPQsCount:'+disQualPQsCount);
            for(Id pqId :disQualPQs){
            //  if(pqIds != null && pqIds.size () > 0){
                if(disPcqCountMap.containsKey(pqid) && disPcqCountMap.get(pqid) != null ){
                    if((disPcqCountMap.get(pqid))+ 1 == pcqCountMap.get(pqid)) {
                         temp = new ProgramQualification__c(id = pqid ,ProcessStage__c =  processStage.get(3) );
                         pqToUpdate.put( pqid , temp);
                    }
                }else if(pcqCountMap.containsKey(pqid) && pcqCountMap.get(pqid) == 1){ // Only one PCQ
                    temp = new ProgramQualification__c(id = pqid ,ProcessStage__c =  processStage.get(3) );
                         pqToUpdate.put( pqid , temp);
                }
                else if(disQualPQsCount.containsKey(pqid) && pcqCountMap.get(pqid) == disQualPQsCount.get(pqid)){
                    temp = new ProgramQualification__c(id = pqid ,ProcessStage__c =  processStage.get(3) );
                         pqToUpdate.put( pqid , temp);
                }
            }
           // }
       }
      
      System.debug('Before Updaing PQ Stage :'+pqToUpdate.values());
      if(pqToUpdate.size() > 0)
        update pqToUpdate.values();
        
    }
 /************************************************/ 
 //The following method is used for Updating stage on PQ  when pcq is null on QDR 
 
  public static void updateProcessStageOnPQ(Set<Id> pqIds){
    
    System.debug('Entering into Update Stage on Pq :'+pqIds);
    Map<String,Integer> pcqCount = new Map<String,Integer>();
    Map<Id,ProgramQualification__c> pqsToUpdate = new Map<Id,ProgramQualification__c>();
    
    Map<id,ProgramQualification__c> pqStatus = new Map<id,ProgramQualification__c>([select id,ProcessStageEIDformula__c from ProgramQualification__c where id in :pqIds]);
    
    if(pqIds != null && pqIds.size () > 0){ // >90
         for(QualificationDocumentStep__c docStep : [Select QPSCertificationEIDFormula__c,QPSRankOrderFormula__c,QualificationDocumentRequirement__r.ProgramQualification__c from QualificationDocumentStep__c
                                                    Where QualificationDocumentRequirement__r.ProgramQualification__c in :pqIds and
                                                     QPSIncertificationProcessEID__c = 1 and DocumentStatusEIDFormula__c = 1 order by QPSRankOrderFormula__c]){
               if(pqStatus.containsKey(docStep.QualificationDocumentRequirement__r.ProgramQualification__c ) && 
                    pqStatus.get(docStep.QualificationDocumentRequirement__r.ProgramQualification__c).ProcessStageEIDformula__c <> 3.0)
                 pqsToUpdate.put(docStep.QualificationDocumentRequirement__r.ProgramQualification__c ,new ProgramQualification__c(id = docStep.QualificationDocumentRequirement__r.ProgramQualification__c ,ProcessStage__c = processStage.get(docStep.QPSCertificationEIDFormula__c) ) ); 
            }  
     }
     for(AggregateResult aggr : [select count(id) pcqCount,ProgramQualification__c pqId from ProgramCategoryQualification__c where ProgramQualification__c in :pqIds and 
                                Readiness__r.QualificationReadinessEID__c = 4 and PQDocumentSourceEidGeneratedFormula__c = null  group by ProgramQualification__c ]){
                            pcqCount.put(String.valueOf(aggr.get('pqId')),Integer.valueOf(aggr.get('pcqCount')));       
     }
     // Commented out this logic on March 16th
     for(Id pqId : pqIds){
        if(!pqsToUpdate.containsKey(pqid) && pcqCount.containsKey(pqid) && pcqCount.get(pqId) != null){
            pqsToUpdate.put(pqId,new ProgramQualification__c(id = pqId ,ProcessStage__c = processStage.get(5) ) ); // 90
            pqIds.remove(pqId);
        } 
        else if(!pqsToUpdate.containsKey(pqId) && (pqStatus.containsKey(pqId ) && pqStatus.get(pqId).ProcessStageEIDformula__c <> 3.0)) {
            pqsToUpdate.put(pqId,new ProgramQualification__c(id = pqId ,ProcessStage__c = processStage.get(8) ) ); // 90
            pqIds.remove(pqId);
  
        }
     } 
     System.debug('pqsToUpdate : '+pqsToUpdate);
     if(pqsToUpdate.size() > 0)
        update pqsToUpdate.values();
  } 
    
    
    
/***************
  /*  
    System.debug('Entering into Update Stage on Pq :'+pqIds);
    Map<String,Integer> pcqCount = new Map<String,Integer>();
    Map<Id,ProgramQualification__c> pqsToUpdate = new Map<Id,ProgramQualification__c>();
    
    Map<id,ProgramQualification__c> pqStatus = new Map<id,ProgramQualification__c>([select id,ProcessStageEIDformula__c,PQDocumentSourceEidGenerated__c,
    			ReadyPQSortOrderFormula__c from ProgramQualification__c where id in :pqIds]);
    
    // for(AggregateResult aggr : [select count(id) pcqCount,ProgramQualification__c pqId from ProgramCategoryQualification__c where ProgramQualification__c in :pqIds and 
    //                            Readiness__r.QualificationReadinessEID__c = 4 and PQDocumentSourceEidGeneratedFormula__c = null group by ProgramQualification__c ]){
   //                         pcqCount.put(String.valueOf(aggr.get('pqId')),Integer.valueOf(aggr.get('pcqCount')));       
   //  }
    if(pqIds != null && pqIds.size () > 0){ // >90
         for(QualificationDocumentStep__c docStep : [Select QPSCertificationEIDFormula__c,QPSRankOrderFormula__c,QualificationDocumentRequirement__r.ProgramQualification__c from QualificationDocumentStep__c
                                                    Where QualificationDocumentRequirement__r.ProgramQualification__c in :pqIds and
                                                     QPSIncertificationProcessEID__c = 1 and DocumentStatusEIDFormula__c = 1 order by QPSRankOrderFormula__c]){
               if(pqStatus.containsKey(docStep.QualificationDocumentRequirement__r.ProgramQualification__c ) && 
                    pqStatus.get(docStep.QualificationDocumentRequirement__r.ProgramQualification__c).ProcessStageEIDformula__c <> 3.0)
                    // && 
                     //pqStatus.get(docStep.QualificationDocumentRequirement__r.ProgramQualification__c).ReadyPQSortOrderFormula__c < 90 &&
                   // pcqCount.containsKey(docStep.QualificationDocumentRequirement__r.ProgramQualification__c))
                 pqsToUpdate.put(docStep.QualificationDocumentRequirement__r.ProgramQualification__c ,new ProgramQualification__c(id = docStep.QualificationDocumentRequirement__r.ProgramQualification__c ,ProcessStage__c = processStage.get(5) ) ); 
              
            else if(pqStatus.containsKey(docStep.QualificationDocumentRequirement__r.ProgramQualification__c ) && 
                    pqStatus.get(docStep.QualificationDocumentRequirement__r.ProgramQualification__c).ProcessStageEIDformula__c <> 3.0 &&
                    pcqCount.containsKey(docStep.QualificationDocumentRequirement__r.ProgramQualification__c))
                 pqsToUpdate.put(docStep.QualificationDocumentRequirement__r.ProgramQualification__c ,new ProgramQualification__c(id = docStep.QualificationDocumentRequirement__r.ProgramQualification__c ,ProcessStage__c = processStage.get(docStep.QPSCertificationEIDFormula__c) ) ); 
            }  
     }
    /* for(AggregateResult aggr : [select count(id) pcqCount,ProgramQualification__c pqId from ProgramCategoryQualification__c where ProgramQualification__c in :pqIds and 
                                Readiness__r.QualificationReadinessEID__c = 4 and PQDocumentSourceEidGeneratedFormula__c = null  group by ProgramQualification__c ]){
                            pcqCount.put(String.valueOf(aggr.get('pqId')),Integer.valueOf(aggr.get('pcqCount')));       
     //}
     // Commented out this logic on March 16th
     for(Id pqId : pqIds){
        if(!pqsToUpdate.containsKey(pqid) && pcqCount.containsKey(pqid) && pcqCount.get(pqId) != null && pqStatus.get(pqId).PQDocumentSourceEidGenerated__c == null){
            pqsToUpdate.put(pqId,new ProgramQualification__c(id = pqId ,ProcessStage__c = processStage.get(5) ) ); // 90 ready to Prepare
            pqIds.remove(pqId);
        } 
        else if(!pqsToUpdate.containsKey(pqId) && (pqStatus.containsKey(pqId ) && pqStatus.get(pqId).ProcessStageEIDformula__c <> 3.0)) {
            pqsToUpdate.put(pqId,new ProgramQualification__c(id = pqId ,ProcessStage__c = processStage.get(8) ) ); // 90
            pqIds.remove(pqId);
  
        }
     } 
     System.debug('pqsToUpdate : '+pqsToUpdate);
     if(pqsToUpdate.size() > 0)
        update pqsToUpdate.values();
  }  */
/************************************************/

//The following method is for updating Process Stage on PCQ or PQ when Document status is null on QDR
  
  public static void updateStageonPCQORPQ(set<id> qdrIds,Map<id,QualificationDocumentStep__c> docSortOrder){
    System.debug('Entering into updateStageonPCQORPQ : '+qdrIds);
    System.debug('docSortOrder:'+docSortOrder);
    System.debug('processStage:'+processStage.get(25));
    Map<id,Decimal> docStepOrder = new Map<id,Decimal>();
    for(QualificationDocumentStep__c qds : [select QualificationDocumentRequirement__c ,QPSRankOrderFormula__c, QPSCertificationEIDFormula__c from QualificationDocumentStep__c where id in :docSortOrder.values() ]){
        System.debug('qds:id:'+qds.id);
        docStepOrder.put(qds.QualificationDocumentRequirement__c,qds.QPSCertificationEIDFormula__c);
    }
    System.debug('docStepOrder:'+docStepOrder);
    List<ProgramCategoryQualification__c> pcqList = new List<ProgramCategoryQualification__c>();
    List<ProgramQualification__c> pqList = new List<ProgramQualification__c>();
    List<QualificationDocumentRequirement__c> qdrList = new List<QualificationDocumentRequirement__c>();
    Set<Id> pqIds = new Set<Id>();
    Map<id,Integer> pcqCount = new Map<Id,Integer>();
    for(QualificationDocumentRequirement__c qdr : [select id ,ProgramQualification__r.ReadyPQSortOrderFormula__c, ProgramQualification__r.PQDocumentSourceEidGenerated__c,ProgramCategoryQualification__r.PQDocumentSourceEidGeneratedFormula__c, ProgramCategoryQualification__r.ProcessStageRankOrderfromPCQ__c, 
                                                        ProgramCategoryQualification__c from QualificationDocumentRequirement__c where id in :qdrIds]){
            qdrList.add(qdr);
            if(qdr.ProgramQualification__c != null )
                pqIds.add(qdr.ProgramQualification__c)  ;                                                       
       } 
      if(pqIds != null && pqIds.size() > 0){
             for(AggregateResult aggr : [select count(id) pcqCount,ProgramQualification__c pqId from ProgramCategoryQualification__c where ProgramQualification__c in :pqIds and 
                                Readiness__r.QualificationReadinessEID__c = 4 and PQDocumentSourceEidGeneratedFormula__c != null  group by ProgramQualification__c ]){
                            pcqCount.put(String.valueOf(aggr.get('pqId')),Integer.valueOf(aggr.get('pcqCount')));
               }
       }
       for(QualificationDocumentRequirement__c qdr : qdrList ){
        if(qdr.ProgramQualification__c != null &&docSortOrder.get(qdr.id).QPSIncertificationProcessEID__c == 1 &&  docSortOrder.get(qdr.id).QPSRankOrderFormula__c >= qdr.ProgramQualification__r.ReadyPQSortOrderFormula__c)
            {
                System.debug('docSortOrder.get(qdr.id).QPSRankOrderFormula__c :'+docSortOrder.get(qdr.id).QPSRankOrderFormula__c ); // was docSortOrder.get(qdr.id).QPSCertificationEIDFormula__c
                if(pcqCount.containsKey(qdr.ProgramQualification__c) && docSortOrder.get(qdr.id).QPSRankOrderFormula__c < 90 )
                   pqList.add(new ProgramQualification__c(id = qdr.ProgramQualification__c,ProcessStage__c =  processStage.get(5) ));
                else if(docSortOrder.get(qdr.id).QPSRankOrderFormula__c >= 90)
                  pqList.add(new ProgramQualification__c(id = qdr.ProgramQualification__c,ProcessStage__c =  processStage.get(docStepOrder.get(qdr.id))) );
                System.debug('qdr.ProgramQualification__r.ReadyPQSortOrderFormula__c :'+qdr.ProgramQualification__r.ReadyPQSortOrderFormula__c ); // 5
            }
        if(qdr.ProgramCategoryQualification__c != null &&docSortOrder.get(qdr.id).QPSIncertificationProcessEID__c == 0 &&  docSortOrder.get(qdr.id).QPSRankOrderFormula__c >= qdr.ProgramCategoryQualification__r.ProcessStageRankOrderfromPCQ__c)
            {
            System.debug('docSortOrder.get(qdr.id).QPSRankOrderFormula__c :'+docStepOrder.get(qdr.id) ); //20.0
            pcqList.add(new ProgramCategoryQualification__c(id = qdr.ProgramCategoryQualification__c,ProcessStage__c =  processStage.get(docStepOrder.get(qdr.id) )) );
            System.debug('qdr.ProgramCategoryQualification__r.ProcessStageRankOrderfromPCQ__c :'+qdr.ProgramCategoryQualification__r.ProcessStageRankOrderfromPCQ__c ); // 5
            }
        
         System.debug('pcqList : '+pcqList);    
         System.debug('pqList : '+pqList);       
    }   
    try {
        if(pqList != null && pqList.size() > 0)
            update pqList ;
        if(pcqList != null && pcqList.size() > 0){
            QualificationDocReqHelper.byPassCode = false ;
            update pcqList ;
        }
    }catch(Exception e){
        System.debug('Exception occured while updating Stage:'+e.getMessage());
    }
 }
/************************************************/  
//The following method is used for updating stage when QDS document status is changed from GOOD.
 
    public static void updateStageOnGoodToBad(Set<Id> qdrIds){
    System.debug('Entering into updateStageOnGoodToBad : '+qdrIds);
    Set<Id> pcqIds = new Set<id>();
    Set<Id> pqIds = new Set<id>();
    Map<Id,QualificationDocumentStep__c> pqStagesId = new Map<Id,QualificationDocumentStep__c>();
    Map<Id,Decimal> pcqStagesId = new Map<Id,Decimal>();
    Map<Id,Integer> pcqCount = new Map<Id,Integer>();
    List<ProgramQualification__c> pqListToUpdate = new List<ProgramQualification__c>();
    List<ProgramCategoryQualification__c> pcqListToUpdate = new List<ProgramCategoryQualification__c>();
    for(QualificationDocumentRequirement__c qdr : [select id ,ProgramQualification__c,ProgramCategoryQualification__c from QualificationDocumentRequirement__c where id in :qdrIds]){
        if(qdr.ProgramQualification__c != null) 
            pqIds.add(qdr.ProgramQualification__c);
        if(qdr.ProgramCategoryQualification__c != null) 
            pcqIds.add(qdr.ProgramCategoryQualification__c);
   }
/************************************************/   
//Updating the highest QPS from QDS in the PQ
 
        if(pqIds != null && pqIds.size() > 0 ){
            System.debug('pqIds:'+pqIds);
            for(QualificationDocumentStep__c docStep : [Select QPSCertificationEIDFormula__c,QPSRankOrderFormula__c,QualificationDocumentRequirement__r.ProgramQualification__c from QualificationDocumentStep__c
                                                        Where QualificationDocumentRequirement__r.ProgramQualification__c in :pqIds and
                                                         QPSIncertificationProcessEID__c = 1 and DocumentStatusEIDFormula__c = 1 order by QPSRankOrderFormula__c]){
                  //  pqStagesId.put(docStep.QualificationDocumentRequirement__r.ProgramQualification__c,docStep.QPSCertificationEIDFormula__c);
                     pqStagesId.put(docStep.QualificationDocumentRequirement__r.ProgramQualification__c,docStep);
                }  
                 if(pqIds != null && pqIds.size() > 0){
             for(AggregateResult aggr : [select count(id) pcqCount,ProgramQualification__c pqId from ProgramCategoryQualification__c where ProgramQualification__c in :pqIds and 
                                Readiness__r.QualificationReadinessEID__c = 4  and PQDocumentSourceEidGeneratedFormula__c = null group by ProgramQualification__c ]){ // Change ADDED PQDocumentSourceEidGeneratedFormula__c = null
                            pcqCount.put(String.valueOf(aggr.get('pqId')),Integer.valueOf(aggr.get('pcqCount')));
               }
       }
                System.debug('pqStagesId:'+pqStagesId);
               for(Id pqId : pqIds) {
                    if(pqStagesId.containsKey(pqId) && pcqCount.containsKey(pqId)){
                    	System.debug('&^^&^&^&^&^&^&^&^&^&^&'+pqStagesId.get(pqId).QPSRankOrderFormula__c);
                       if(pqStagesId.get(pqId).QPSRankOrderFormula__c < 90)
                       		pqListToUpdate.add(new ProgramQualification__c(id = pqId ,ProcessStage__c =  processStage.get(5))); 
                       		
                       else
                         pqListToUpdate.add(new ProgramQualification__c(id = pqId ,ProcessStage__c =  processStage.get(pqStagesId.get(pqId).QPSCertificationEIDFormula__c)));
                    }
                    else if(pcqCount.containsKey(pqId))
                    	  pqListToUpdate.add(new ProgramQualification__c(id = pqId ,ProcessStage__c =   processStage.get(5))); 
                     else if(pqStagesId.containsKey(pqId))
                    	  pqListToUpdate.add(new ProgramQualification__c(id = pqId ,ProcessStage__c =   processStage.get(pqStagesId.get(pqId).QPSCertificationEIDFormula__c))); 
                    else
                         pqListToUpdate.add(new ProgramQualification__c(id = pqId ,ProcessStage__c =   processStage.get(8))); //processStage.get(pqStagesId.get(pqId).QPSCertificationEIDFormula__c)));
               } 
                System.debug('pqListToUpdate:'+pqListToUpdate);
               update pqListToUpdate;
        }    
/************************************************/       
// Updating the highest QPS from QDS in the PCQ
     if(pcqIds != null && pcqIds.size() > 0 ){
            System.debug('pcqIds:'+pcqIds);
             for(QualificationDocumentStep__c docStep : [Select QPSCertificationEIDFormula__c,QPSRankOrderFormula__c,QualificationDocumentRequirement__r.ProgramCategoryQualification__c from QualificationDocumentStep__c
                                                    Where QualificationDocumentRequirement__r.ProgramCategoryQualification__c in:pcqIds and
                                                     QPSIncertificationProcessEID__c = 0 and DocumentStatusEIDFormula__c = 1 order by QPSRankOrderFormula__c]){
                pcqStagesId.put(docStep.QualificationDocumentRequirement__r.ProgramCategoryQualification__c,docStep.QPSCertificationEIDFormula__c);
            }
            System.debug('pcqStagesId:'+pcqStagesId);
               for(Id pcqId : pcqIds) {
                    if(pcqStagesId.containsKey(pcqId))
                        pcqListToUpdate.add(new ProgramCategoryQualification__c(id = pcqId ,ProcessStage__c =  processStage.get(pcqStagesId.get(pcqId))));
                    else    
                        pcqListToUpdate.add(new ProgramCategoryQualification__c(id = pcqId ,ProcessStage__c =  processStage.get(26)));
               } 
               System.debug('pcqListToUpdate:'+pcqListToUpdate);
               QualificationDocReqHelper.byPassCode = false ;
               update pcqListToUpdate ;
        }    
/************************************************/      
    
  }
}