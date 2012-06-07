public with sharing class esignatureevalidate_controller {
    public boolean validate {get; set;}
    private string ssn;
    private string sessionId;
    private list<EmployeeSurvey__c> esList; 
    /************/
    public esignatureevalidate_controller(){
        validate = false;
        sessionId = Apexpages.currentPage().getParameters().get('sessionId');
        ssn = Apexpages.currentPage().getParameters().get('ssn');
        if(ssn != null && sessionId != null){
        	
        	// No longer validating in real-time. Just grab the correct record based on session        	
            esList = [Select Id
                     From EmployeeSurvey__c e
                     where Five9SessionID__c=:sessionId];
			
			if(esList != null && esList.size()>0)
			{
				 validate = true;
			}                                                                             
            
        }
    }
    
    /************/
    public void updateIfValid()
    {
        if(validate ==true && esList !=null && esList.size()>0)
        {
            List<string> documentIdList = new List<string>();
            
            List<wktDocument8850__c> documents = [select id, 
            											ElectronicSignatureText__c, 
            											ElectronicSignatureDateTime__c, 
            											ElectronicSignatureValidatedBit__c,
            											CongaWorkflowTrigger__c
            										from wktDocument8850__c 
            										where EmployeeSurvey__c in:esList];
            										
			if(documents != null && documents.size() > 0)
			{            										
				for(wktDocument8850__c doc: documents){
                	doc.ElectronicSignatureText__c = ssn;
                	doc.ElectronicSignatureDateTime__c = datetime.now();
                	doc.ElectronicSignatureValidatedBit__c = true;
                	doc.CongaWorkflowTrigger__c = true;
                
                	documentIdList.add(doc.Id);
            	}
            	update documents;
			}
        }
    }
    
    
    /************/
    private static testmethod void test_esVal(){
        Test_EmployeeSurveyInsert_Trigger t = new Test_EmployeeSurveyInsert_Trigger();
        t.insertData();
        EmployeeSurvey__c es = new EmployeeSurvey__c();
        es.Name = 'test';
        es.EmploymentPeriod__c = t.em.id;
        es.EntityLocation__c = t.el.id;
        es.Five9SessionID__c = '111222333';
        insert es;
        
        es = [select Id, EmployeeSSNFormula__c, Five9SessionID__c  from EmployeeSurvey__c where Five9SessionID__c = '111222333'];
        
        wktDocument8850__c ee = new wktDocument8850__c();
        ee.EmployeeSurvey__c = es.id;
        insert ee;
        
        test.startTest();
        	apexpages.currentPage().getParameters().put('ssn', es.EmployeeSSNFormula__c);
        	apexpages.currentPage().getParameters().put('sessionId', es.Five9SessionID__c);
        	esignatureevalidate_controller sc = new esignatureevalidate_controller();
        	sc.updateIfValid();
        	system.assert(sc.validate);
        test.stopTest();
    }
}