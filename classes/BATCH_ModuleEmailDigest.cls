global class BATCH_ModuleEmailDigest implements Database.Batchable<sObject>{
	/***********************************************/
  global database.querylocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([Select p.ContentModule__c, 
       																	 p.ContentModule__r.Name,
       																	 p.PortalNotificationSchedule__c, 
       																	 p.PortalNotificationSchedule__r.DigestType__c, 
       																	 p.PortalNotificationSchedule__r.NextDigestDate__c,
       																	 p.Name,  
       																	 p.PortalNotificationSchedule__r.Contact__c,
																				 p.PortalNotificationSchedule__r.Contact__r.AccountHierarchyMember__c, 
																				 p.PortalNotificationSchedule__r.Contact__r.Id, 
																				 p.PortalNotificationSchedule__r.Contact__r.ExecutiveAccessBit__c, 
																				 p.PortalNotificationSchedule__r.Contact__r.AccountId, 
																				 p.PortalNotificationSchedule__r.Contact__r.Account.Name, 
																				 p.PortalNotificationSchedule__r.Contact__r.Name, 
																				 p.PortalNotificationSchedule__r.Contact__r.Email, 
																				 p.PortalNotificationSchedule__r.Contact__r.Account.ShortName__c
       																	 From PortalNotificationModule__c p
																				 where (PortalNotificationSchedule__r.NextDigestDate__c = :Date.today() or
																				(PortalNotificationSchedule__r.DigestType__c = 'First' 
																				and PortalNotificationSchedule__r.NextDigestDate__c = null))]);
  }
  /***********************************************/
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
		list<String> pnsIds = new list<string>();
		for(PortalNotificationModule__c pnm : (list<PortalNotificationModule__c>)scope){
			pnsIds.add(pnm.PortalNotificationSchedule__c);
		}
		
		PortalModuleEmailHelper pme = new PortalModuleEmailHelper();
		map<string, list<PortalNotificationModule__c>> cToPnmMap = pme.makeContactToPNMMap((list<PortalNotificationModule__c>)scope);
		map<string, list<PortalNotificationContent__c>> cToPncMap = pme.makeContactToPNCMap(pnsIds);
		pme.generateAndSendEmailForEachContact(cToPncMap, cToPnmMap);
	}
	/***********************************************/
	global void finish(Database.BatchableContext BC){
		
	}
	/***********************************************/
	global static void runBatch(){
		BATCH_ModuleEmailDigest b = new BATCH_ModuleEmailDigest();
		Database.executeBatch(b);
	}

}