global class BATCH_wktDocument8850_entity implements Database.Batchable<sObject>{
	
	public String query{get; set;}
	
	global void setDefaultQuery(){
		//query = 'Select w.EntityStructure__c, w.Employment__r.Entity__c, w.Employment__c From wktDocument8850__c w where EntityStructure__c = null';
		//if (test.isRunningTest()) query = 'Select w.EntityStructure__c, w.Employment__r.Entity__c, w.Employment__c From wktDocument8850__c w where EntityStructure__c = null limit 100';
		
		query = 'Select w.Id, w.CongaWorkflowTrigger__c,(Select Id From Attachments)  from wktDocument8850__c w limit 10000';
		if (test.isRunningTest()) query = 'Select w.Id, w.CongaWorkflowTrigger__c,(Select Id From Attachments) from wktDocument8850__c w limit 100';
		
	}
	    
	global database.querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	    
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
	  	list <String> entIds = new list<string>();
	  	list<wktDocument8850__c> wktl = new list<wktDocument8850__c>();
	  	list<Attachment> attl = new list<Attachment>();
	  	
	  	//get all entIds and make list of wkts
	  	for(wktDocument8850__c wkt : (list<wktDocument8850__c>)scope){
	  		wktl.add(wkt);
	  		
	  		if(wkt.Attachments.size() > 0)
	  		{
	  			for(Attachment a : wkt.Attachments)
	  			{
	  				attl.add(a);
	  			}
	  		}
	  		
	  		//entIds.add(wkt.Employment__r.Entity__c);
	  	}
	  	//get list of all EntityStructure__c
	  	//list<EntityStructure__c> esList =[Select e.EntityName__c, e.CreatedDate From EntityStructure__c e order by CreatedDate ASC];
	  	
	  	//set EntityStructure__c on wktDocument8850__c
	  	
	  	delete attl;
	  	
	  	for(wktDocument8850__c wkt : wktl)
	  	{
	  		
	  		/*
	  		for(EntityStructure__c es : esList){
	  			if(es.EntityName__c == wkt.Employment__r.Entity__c && wkt.EntityStructure__c == null){
	  				wkt.EntityStructure__c = es.id;
	  				break;
	  			}
	  		}
	  		*/
	  		
	  		wkt.CongaWorkflowTrigger__c = true;
	  	}
	  	
	  	update wktl;
	}
	 
  global void finish(Database.BatchableContext BC){
	         
  }

	global static void runBatch(){
		BATCH_wktDocument8850_entity b = new BATCH_wktDocument8850_entity();
		b.setDefaultQuery();
		Database.executeBatch(b);
	}	
	
	static testMethod void TEST_BATCH_wktDocument8850_entity() {
		test.startTest();
		BATCH_wktDocument8850_entity.runBatch();		
		test.stopTest();
  }    	

}