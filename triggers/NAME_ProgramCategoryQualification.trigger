trigger NAME_ProgramCategoryQualification on ProgramCategoryQualification__c (before insert, before update) {
list <String> programQualIds = new list<String>();
list <String> programCatIds = new list<String>();

map<String, String> employeeMap = new map<String, String>();
map<String, String> programCatMap = new map<String, String>();
map<String, ProgramQualification__c> programQualMap = new map<String, ProgramQualification__c>();
map<string, string> programMap = new Map<string,string>();
 if(  !QualificationDocReqHelper.isDocReqExist &&   trigger.isInsert) {
 	
    QualificationReadiness__c qualReadiAvail = [Select Id, QualificationReadinessEID__c from QualificationReadiness__c where QualificationReadinessEID__c = 2.0];
    QualificationProcessStage__c qps = [Select Id, QualificationProcessStageEID__c from QualificationProcessStage__c where QualificationProcessStageEID__c = 22];
        
        for(ProgramCategoryQualification__c pcq : trigger.new){
            programQualIds.add(pcq.ProgramQualification__c);
            programCatIds.add(pcq.ProgramCategoryPeriod__c);
           
        }
        
        for(ProgramQualification__c pq:[select Employment__r.Employee__r.FullNameFormula__c, EffectiveDate__c from  ProgramQualification__c where id in :programQualIds]){
            employeeMap.put(pq.id, pq.Employment__r.Employee__r.FullNameFormula__c);
            programQualMap.put(pq.id, pq);
        }
        
        for(ProgramCategoryPeriod__c pc :[select ProgramCategory__r.Name from ProgramCategoryPeriod__c where id in :programCatIds]){
            programCatMap.put(pc.id, pc.ProgramCategory__r.Name);
        }
        
        for(ProgramCategoryPeriod__c pc :[select ProgramCategory__r.Program__r.ShortName__c from ProgramCategoryPeriod__c where id in :programCatIds]){
            programMap.put(pc.id, pc.ProgramCategory__r.Program__r.ShortName__c);
        }
 	
         
        map<String, Integer> fieldMax;
        list<String> orderList;
        for(ProgramCategoryQualification__c pcq : trigger.new){
            fieldMax = new map<String, Integer>();
            orderList = new list<String>();
            
            if(pcq.ProgramQualification__c != null && employeeMap.get(pcq.ProgramQualification__c)!=null){
                fieldMax.put(employeeMap.get(pcq.ProgramQualification__c), 31);
                orderList.add(employeeMap.get(pcq.ProgramQualification__c));  
            }
        
            
            if(pcq.ProgramCategoryPeriod__c !=null && programCatMap.get(pcq.ProgramCategoryPeriod__c)!= null){
                fieldMax.put(programCatMap.get(pcq.ProgramCategoryPeriod__c), 30);
                orderList.add(programCatMap.get(pcq.ProgramCategoryPeriod__c));     
            }
            
            if(pcq.ProgramCategoryPeriod__c !=null && programMap.get(pcq.ProgramCategoryPeriod__c)!= null){
                fieldMax.put(programMap.get(pcq.ProgramCategoryPeriod__c), 12);
                orderList.add(programMap.get(pcq.ProgramCategoryPeriod__c));     
            }
            
            
            if(pcq.ProgramQualification__c != null && programQualMap.get(pcq.ProgramQualification__c).EffectiveDate__c !=null){
                Datetime sd = Datetime.newInstance(programQualMap.get(pcq.ProgramQualification__c).EffectiveDate__c, Time.newInstance(0,0,0,0));    
                fieldMax.put(sd.format('M/yy'),5);
                orderList.add(sd.format('M/yy'));
            }
            
            System.debug('fieldMax:'+fieldMax);
            System.debug('orderList:'+orderList);
            
            NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
            pcq.Name = nh.generateName();
            System.debug('PcqName:'+pcq.Name);
          if(QualificationDocReqHelper.byPassCode && trigger.isInsert)
                pcq.Readiness__c = qualReadiAvail.Id;
                pcq.ProcessStage__c = qps.Id;
                pcq.ProcessStageDate__c = System.now();
        
        }
 }
        //For Updating Process Stage
         if(Trigger.isUpdate ){
         	
         	if(QualificationDocReqHelper.byPassCode)
          		ProcessStageHelper.updateProcessStage(trigger.new,trigger.oldMap);
          	
         	//The folllowing code for updating readiness when pcq updated manually
          	if(trigger.new.size() == 1 && QualificationDocReqHelper.isManualUpdate ){
          		System.debug('Entering into Manual Update');
          		QualificationDocReqHelper.updateReadinessManually(trigger.new,trigger.oldMap);
          	}
         } 	    	
 	}