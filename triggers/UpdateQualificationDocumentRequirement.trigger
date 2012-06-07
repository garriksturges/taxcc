/**********************************************************************************************************************************
This Trigger is for updating the Document Status of Qualification Document Requirement through Qualification Document Step.
*************************************************************************************************************************************/
trigger UpdateQualificationDocumentRequirement on QualificationDocumentStep__c (before update , after update, after delete) {

set<Id> QualDocRqmts = new set<Id>();
map<string, Integer> qdrmap = new map<string, Integer>();
map<Id,QualificationDocumentStep__c> dsMap = new map<Id,QualificationDocumentStep__c>(); 
list<QualificationDocumentRequirement__c> qdrUpdateList = new list<QualificationDocumentRequirement__c>();
set<Id> qdrIds = new set<Id>();
Map<id,QualificationDocumentStep__c> docSortOrder = new Map<Id,QualificationDocumentStep__c>();
set<Id> goodToBad = new set<Id>();
boolean isAfterUpdate = false ;
map<Id,QualificationDocumentStep__c> minStepOrder = new map<Id,QualificationDocumentStep__c>();
DocumentStatus__c inProgressDoc;
DocumentStatus__c PendingEvaluation;
QualificationDocumentRequirement__c qdReq;
Set<Decimal> QDOEmoployeeSource = new Set<Decimal>{1,2,3};
Set<Id> allStatusBlank = new Set<id>();
map<Id,QualificationDocumentStep__c> matchStepOrder = new map<Id,QualificationDocumentStep__c>();
/************************************************/

if(trigger.isDelete) {
    
    for (QualificationDocumentStep__c qds : trigger.old) {
        if(qds.DocumentStatus__c != null && qds.QualificationDocumentRequirement__c!= null )
          QualDocRqmts.add(qds.QualificationDocumentRequirement__c);
    }
}
/************************************************/

    if(!trigger.isDelete){
        for(QualificationDocumentStep__c qds : trigger.new) {
            if(trigger.isBefore && qds.DocumentStatus__c <> trigger.OldMap.get(qds.Id).DocumentStatus__c) // Before Update
                qds.DocumentStatusDate__c = System.now();
            
            else if(trigger.isAfter) {
                 List<DocumentStatus__c> stepStatus= [ Select RankOrder__c,Id, DocumentStatusEID__c From DocumentStatus__c where DocumentStatusEID__c  in(6.0,0.0) ] ;
                 inProgressDoc = stepStatus[0];
                 PendingEvaluation = stepStatus[1];
                isAfterUpdate = true ; // After Update
                    // If there a Document Status in the QDR 
                    system.debug('qds.DocumentStatus__c' + qds.DocumentStatus__c);
                    if(qds.DocumentStatus__c != null && qds.DocumentStatus__c <> trigger.OldMap.get(qds.Id).DocumentStatus__c || 
                    (qds.DocumentStatus__c == null && trigger.OldMap.get(qds.Id).DocumentStatus__c != null) ){
                        QualDocRqmts.add(qds.QualificationDocumentRequirement__c); 
                       
                     // Updating PCQ when a QDS is updated to GOOD Document Status.
                    if(qds.DocumentStatusEIDFormula__c == 1.0 && trigger.OldMap.get(qds.id).DocumentStatusEIDFormula__c <> 1.0){ // Good
                        qdrIds.add(qds.QualificationDocumentRequirement__c);
                        docSortOrder.put(qds.QualificationDocumentRequirement__c,qds);
                        goodToBad.remove(qds.QualificationDocumentRequirement__c);
                      }
                      // Changing the MIN QDS from Good to anything else.
                    if(qds.DocumentStatusEIDFormula__c <> 1.0 && trigger.OldMap.get(qds.id).DocumentStatusEIDFormula__c == 1.0 && !qdrIds.contains(qds.QualificationDocumentRequirement__c)){
                        goodToBad.add(qds.QualificationDocumentRequirement__c);
                      }
                    }
                }
            }
        }
/************************************************/  
// Checking the Qualificaiton Document Requirement Id's in the List.

   System.debug('Qualification Document Requirement'+QualDocRqmts);
    
   if(QualDocRqmts != null && QualDocRqmts.Size() > 0 && isAfterUpdate) {
      
      list<AggregateResult> aggr = [Select Max(DocumentStatusStepOrder__c) MaxStepOrder, QualificationDocumentRequirement__c 
                                     from QualificationDocumentStep__c where QualificationDocumentRequirement__c in: 
                                      QualDocRqmts  group by QualificationDocumentRequirement__c ];
                                        
        for(AggregateResult agg: aggr) {
             qdrMap.put(string.valueof(String.valueOf(agg.get('QualificationDocumentRequirement__c'))), Integer.valueof(agg.get('MaxStepOrder')));
          }
           system.debug('qdrMap' + qdrMap); 
          
        for(QualificationDocumentStep__c docstep : [select QualificationDocumentRequirement__c,QPSRankOrderFormula__c,QDOEmoployeeSourceFormula__c,DocumentStatusEIDFormula__c,DocumentStatusStepOrder__c, DocumentStatus__c from QualificationDocumentStep__c
                                                       where QualificationDocumentRequirement__c in : QualDocRqmts and DocumentStatusStepOrder__c in : qdrMap.values()  
                                                        order by DocumentStatusRankOrderFormula__c  desc ]) {
             if( docstep.DocumentStatusEIDFormula__c == 1.0 && qdrMap.get(docstep.QualificationDocumentRequirement__c) == docstep.DocumentStatusStepOrder__c ) //Document Status = Good
             // dsMap.put(docstep.QualificationDocumentRequirement__c , docstep.DocumentStatus__c );
             dsMap.put(docstep.QualificationDocumentRequirement__c , docstep );
             else  if(!dsMap.containsKey(docstep.QualificationDocumentRequirement__c) && docstep.DocumentStatusEIDFormula__c <> 1.0  && qdrMap.get(docstep.QualificationDocumentRequirement__c) == docstep.DocumentStatusStepOrder__c ) //Document Status =! good
                //dsMap.put(docstep.QualificationDocumentRequirement__c , docstep.DocumentStatus__c );
                dsMap.put(docstep.QualificationDocumentRequirement__c , docstep );
            
             else if(!qdrMap.containsKey(docstep.QualificationDocumentRequirement__c) && !dsMap.containsKey(docstep.QualificationDocumentRequirement__c)  && docstep.DocumentStatus__c != null)
                // dsMap.put(docstep.QualificationDocumentRequirement__c , docstep.DocumentStatus__c );
                dsMap.put(docstep.QualificationDocumentRequirement__c , docstep);
            if(QDOEmoployeeSource.contains(docstep.QDOEmoployeeSourceFormula__c)) 
                matchStepOrder.put(docstep.QualificationDocumentRequirement__c , docstep);  
          }
        for(QualificationDocumentStep__c docstep : [select QualificationDocumentRequirement__c,QPSRankOrderFormula__c,QDOEmoployeeSourceFormula__c,DocumentStatusEIDFormula__c,DocumentStatusStepOrder__c, DocumentStatus__c  from QualificationDocumentStep__c
                                                       where QualificationDocumentRequirement__c in :QualDocRqmts and DocumentStatus__c  != null  //and QDOEmoployeeSourceFormula__c in:QDOEmoployeeSource // code added
                                                       order by DocumentStatusStepOrder__c  asc ]){
                                               if(QDOEmoployeeSource.contains(docstep.QDOEmoployeeSourceFormula__c))
                                                 minStepOrder.put(docstep.QualificationDocumentRequirement__c,docstep); 
                                                 allStatusBlank.add(docStep.QualificationDocumentRequirement__c);
                                                         
                                                       }                                           
    system.debug('dsMap' + dsMap); 
    system.debug('matchStepOrder' + matchStepOrder); 
    system.debug('minStepOrder' + minStepOrder); 
        for(Id qdReqId : QualDocRqmts ) {
        	System.debug('Qdr Id :'+qdReqId);
         if (dsMap.containsKey(qdReqId) && dsMap.get(qdReqId).DocumentStatus__c != null  ) {
           
                if(matchStepOrder.containsKey(qdReqId) && matchStepOrder.get(qdReqId).DocumentStatus__c != null )
                     qdReq = new QualificationDocumentRequirement__c(Id = qdReqId, DocumentStatusDate__c = System.now(), DocumentStatus__c = dsMap.get(qdReqId).DocumentStatus__c, DocumentStatusExternal__c =  matchStepOrder.get(qdReqId).DocumentStatus__c);
                 else  if(minStepOrder.containsKey(qdReqId) && minStepOrder.get(qdReqId).DocumentStatus__c != null )
                     qdReq = new QualificationDocumentRequirement__c(Id = qdReqId, DocumentStatusDate__c = System.now(), DocumentStatus__c = dsMap.get(qdReqId).DocumentStatus__c, DocumentStatusExternal__c =  minStepOrder.get(qdReqId).DocumentStatus__c);
               
                else
                     qdReq = new QualificationDocumentRequirement__c(Id = qdReqId, DocumentStatusDate__c = System.now(), DocumentStatus__c = dsMap.get(qdReqId).DocumentStatus__c,  DocumentStatusExternal__c = null /*PendingEvaluation.id*/ ); // When all the QDO's are deleted then the DocumentStatusExternal is InProgress
                 qdrUpdateList.add(qdReq);
                 qdrIds.remove(qdReqId);
                 goodToBad.remove(qdReqId);
                
               }
                else if (qdrIds.size() == 0 && goodToBad.size() ==0 && minStepOrder.containsKey(qdReqId) && minStepOrder.get(qdReqId).DocumentStatus__c != null && QDOEmoployeeSource.contains(minStepOrder.get(qdReqId).QDOEmoployeeSourceFormula__c) ){
        // Updating External Document Status on QDR when a Min QDS has a value.
        		System.debug('Inside good to bad Qdr Id :'+qdReqId);         
                     qdReq = new QualificationDocumentRequirement__c(Id = qdReqId, DocumentStatusDate__c = System.now(), DocumentStatus__c = inProgressDoc.id, DocumentStatusExternal__c =  minStepOrder.get(qdReqId).DocumentStatus__c);
                     qdrUpdateList.add(qdReq);
            }
            else if(!allStatusBlank.contains(qdReqId)){
            	System.debug('No Steps have the status:+'+qdReqId);
            	 qdReq = new QualificationDocumentRequirement__c(Id = qdReqId, DocumentStatusDate__c = System.now(), DocumentStatus__c = null, DocumentStatusExternal__c = null);
            	 goodToBad.remove(qdReqId);
                     qdrUpdateList.add(qdReq);
            }
           }
    }
/************************************************/  
    if(qdrUpdateList != null && qdrUpdateList.size() >0){
        
       System.debug('Start Updating QDR');
       System.debug('qdrUpdateList' + qdrUpdateList); 
        
        update qdrUpdateList;
        
       System.debug('End Updating QDR');
    }
       System.debug('qdrIds : '+qdrIds);
         
//Updating stage on PCQ or PQ if document status is null on QDR

    if(qdrIds != null && qdrIds.size()>0){
        ProcessStageHelper.updateStageonPCQORPQ(qdrIds,docSortOrder);
     //DocumentStatus__c inProgressDoc = [ Select RankOrder__c,Id, DocumentStatusEID__c From Documentstatus__c where DocumentStatusEID__c  = 6.0 ] ;
       for(Id qdrId : qdrIds){
             if(minStepOrder.containsKey(qdrId) && minStepOrder.get(qdrId).DocumentStatus__c != null && QDOEmoployeeSource.contains(minStepOrder.get(qdrId).QDOEmoployeeSourceFormula__c))
                  qdReq = new QualificationDocumentRequirement__c(Id = qdrId, DocumentStatusDate__c = System.now(), DocumentStatus__c = inProgressDoc.id,DocumentStatusExternal__c =  minStepOrder.get(qdrId).DocumentStatus__c );
             else 
                  qdReq = new QualificationDocumentRequirement__c(Id = qdrId, DocumentStatusDate__c = System.now(), DocumentStatus__c = null/*inProgressDoc.id*//* DocumentStatusExternal__c =  null*/);     
             qdrUpdateList.add(qdReq);
        }
        QualificationDocReqHelper.byPassInProgress = true ;
        System.debug('qdrUpdateList in Good:' + qdrUpdateList);
        update qdrUpdateList ;
   }
    if(goodToBad != null && goodToBad.size() >0 ){
        ProcessStageHelper.updateStageOnGoodToBad(goodToBad);
       
       for(Id qdrId : goodToBad){
             if(minStepOrder.containsKey(qdrId) && minStepOrder.get(qdrId).DocumentStatus__c != null && QDOEmoployeeSource.contains(minStepOrder.get(qdrId).QDOEmoployeeSourceFormula__c))
                  qdReq = new QualificationDocumentRequirement__c(Id = qdrId, DocumentStatusDate__c = System.now(), DocumentStatus__c = inProgressDoc.id,DocumentStatusExternal__c =  minStepOrder.get(qdrId).DocumentStatus__c );
             else if(allStatusBlank.contains(qdrId))
                  qdReq = new QualificationDocumentRequirement__c(Id = qdrId, DocumentStatusDate__c = System.now(), DocumentStatus__c = null /*inProgressDoc.id*/, DocumentStatusExternal__c =  null);
             qdrUpdateList.add(qdReq);
        }
        QualificationDocReqHelper.byPassInProgress = true ;
        System.debug('qdrUpdateList from Good to Bad:' + qdrUpdateList);
        update qdrUpdateList;
    }
   
}