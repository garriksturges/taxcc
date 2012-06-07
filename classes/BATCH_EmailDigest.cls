global class BATCH_EmailDigest implements Database.Batchable<sObject>{
  /***********************************************/
  global database.querylocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([ Select  p.NextDigestDate__c, p.Frequency__c, p.DigestType__c, p.Contact__c,
						p.Contact__r.AccountHierarchyMember__c,  p.Contact__r.Id, p.Contact__r.ExecutiveAccessBit__c, p.Contact__r.AccountId, 
						p.Contact__r.Account.Name, p.Contact__r.Name, p.Contact__r.Email, p.Contact__r.Account.ShortName__c
						From PortalNotificationSchedule__c p
						where (NextDigestDate__c = :Date.today() or
						(DigestType__c = 'First' and NextDigestDate__c = null))]);
  }
  /***********************************************/
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		Attachment a;
		PortalNotification__c pn;
		Datetime prevDate;
		Messaging.SingleEmailMessage[] emailList;// = new List<Messaging.SingleEmailMessage>();
		list <PortalNotificationSchedule__c>pNotificationList;// = new list<PortalNotificationSchedule__c>();
		list<PortalNotification__c> pnList;// = new list<PortalNotification__c>();
		list<Attachment> attachments;// = new list<Attachment>();
		PortalEmailDigestListCreate lc = new PortalEmailDigestListCreate();
		for(PortalNotificationSchedule__c p :(list<PortalNotificationSchedule__c>)scope){
			lc.addToLists(p);
		}
		lc.sendUpdateAndInsertInfo();
	}
	/***********************************************/
	global void finish(Database.BatchableContext BC){
		
	}
	/***********************************************/
	global static void runBatch(){
		BATCH_EmailDigest b = new BATCH_EmailDigest();
		Database.executeBatch(b);
	}

}