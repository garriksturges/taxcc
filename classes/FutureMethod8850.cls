public class FutureMethod8850{
	
	@future
	public static void CreateRepository(Set<Id> docIds){
	
	System.debug('DocIds :'+docIds);
		
		list<RepositoryDocument__c> rdList = new list<RepositoryDocument__c>();
		DocumentStatus__c PendingEv = [Select id, DocumentStatusEID__c From DocumentStatus__c where DocumentStatusEID__c = 0.0 ];
		Documenttype__c Form8850 = [Select Id, DocumentTypeEID__c From Documenttype__c where DocumentTypeEID__c = 241.0];
		
		for(wktDocument8850__c rec : [Select Id,Employment__r.AccountEIDFormula__c, Employment__r.ReferenceID__c, Employment__r.Id, Employment__c, ElectronicSignatureText__c 
		    								From wktDocument8850__c where id in :docIds ]){
		
		if(rec.Employment__c != null && rec.ElectronicSignatureText__c != null){    	
		RepositoryDocument__c rd = new RepositoryDocument__c(Name =  rec.Employment__r.AccountEIDFormula__c+'_'+'WOTC Form 8850'+'_'+ rec.Employment__r.ReferenceID__c , Employment__c = Rec.Employment__c , 
		                                    wktDocument8850__c = rec.id, DocumentStatus__c = PendingEv.id, ScannedDate__c = System.now(),
		                                    Documenttype__c = Form8850.Id);
		        
		        rdList.add(rd);
		        
		    }
		System.debug('rdList:'+rdList);   
		If(rdList.size() > 0 && rdList != null){
		
		insert rdList;
		}    
		}
	// EmploymentReferenceNumber_Form8850_AccountEID.
			
	}

}