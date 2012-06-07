/********************************************************************************
Trigger to Update Document Status in the Qualification Document Step when a Qualification Document Option is Inserted, Updated & Deleted. 
********************************************************************************/


trigger UpdateQualificationDocumentStep on QualificationDocumentOption__c ( after insert, after update, after delete) {
    //QualificationDocumentStep__c
    Set<id> qualiDocsSteps = new Set<id>();
    map<string,Integer> qdsMap = new map<string,Integer>();
    map<string,integer> qdsRankMap = new map<string,integer>();
    map<Id,QualificationDocumentOption__c> dsMap = new map<Id,QualificationDocumentOption__c>();
    list<QualificationDocumentStep__c> qdsUpdateList = new list<QualificationDocumentStep__c>();
    DocumentStatus__c pendingStatus = [select id from DocumentStatus__c where DocumentStatusEID__c = 0 limit 1 ];
    
/************************************************/    
    if(trigger.isDelete){
    	system.debug('trigger.old' + trigger.old);
        for(QualificationDocumentOption__c qdo : trigger.old){
         if(qdo.DocumentStatusGenerated__c != null )
            qualiDocsSteps.add(qdo.QualificationDocumentStep__c);//,qdo.DocumentStatusGenerated__c);   
            
     }
    }
/************************************************/    
    if(!trigger.isDelete ){
         for(QualificationDocumentOption__c qdo : trigger.new){
            
             if(qdo.DocumentStatusGenerated__c != null )
                qualiDocsSteps.add(qdo.QualificationDocumentStep__c);//,qdo.DocumentStatusGenerated__c);  
             
        }
    }
 /************************************************/   
// Checking the Step Id's in the List.
    System.debug('Qualification Docs Step :'+qualiDocsSteps);
    if(qualiDocsSteps != null && qualiDocsSteps.size() > 0){
// Finding the Minimum Document Status.
            list<AggregateResult> aggr = [select MIN(DocumentStatusRankOrderGenerted__c) minRank,QualificationDocumentStep__c from
                                          QualificationDocumentOption__c where QualificationDocumentStep__c in :qualiDocsSteps group 
                                          by QualificationDocumentStep__c ];
            for(AggregateResult agg: aggr){
                qdsMap.put(string.valueof(String.valueOf(agg.get('QualificationDocumentStep__c'))),Integer.valueof(agg.get('minRank'))); 
            }
            system.debug('qdsMap' + qdsMap); 
            for(QualificationDocumentOption__c docOption : [select QualificationDocumentStep__c,DocumentStatusRankOrderGenerted__c,EmployeeSourceEidFormula__c,DocumentStatusGenerated__c from QualificationDocumentOption__c
                                                             where QualificationDocumentStep__c in :qualiDocsSteps and
                                                            DocumentStatusRankOrderGenerted__c in :qdsMap.values() ]){
                                                                
                   // dsMap.put(docOption.QualificationDocumentStep__c,docOption.DocumentStatusGenerated__c) ; 
                   dsMap.put(docOption.QualificationDocumentStep__c,docOption) ;
                    qdsRankMap.put(string.valueof(docOption.QualificationDocumentStep__c),integer.valueof(docOption.DocumentStatusRankOrderGenerted__c));                                                   
            }
              system.debug('qdsRankMap' + qdsRankMap); 
            for(Id qdStepId : qualiDocsSteps )    {
               if(dsMap.containsKey(qdStepId)){
                    QualificationDocumentStep__c qdStep = new QualificationDocumentStep__c(id = qdStepId ,DocumentStatus__c = dsMap.get(qdStepId).DocumentStatusGenerated__c,DocumentStatusRankSummar__c = qdsRankMap.get(qdStepId), QDOEmoployeeSourceFormula__c= dsMap.get(qdStepId).EmployeeSourceEidFormula__c );
                    qdsUpdateList.add(qdStep);
               } else {
                 QualificationDocumentStep__c qdStep = new QualificationDocumentStep__c(id = qdStepId ,DocumentStatus__c = pendingStatus.id, QDOEmoployeeSourceFormula__c= null);
                    qdsUpdateList.add(qdStep);
               }
            }
    		
            if(qdsUpdateList != null && qdsUpdateList.size() >0){
            	System.debug('qdsUpdateList:'+qdsUpdateList.size());
                update qdsUpdateList;
            }
    }
         
}