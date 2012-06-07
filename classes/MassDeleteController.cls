Public class MassDeleteController{
	
	public MassDeleteController(ApexPages.standardController std){
		
	}

public PageReference RepositoryMassDelete(){

	String rdIdStr = ApexPages.currentPage().getParameters().get('RepositoryIds');
	PageReference pageRef = new PageReference('/a0j');
	List<RepositoryDocument__c> rdToDelete = new List<RepositoryDocument__c>();

	System.debug('rdIdStr:'+rdIdStr);
		if(rdIdStr != null && rdIdStr.length() > 0){
			
			for(String rdId : rdIdStr.split(',')){

				rdToDelete.add(new RepositoryDocument__c(id = rdId));

			}

			if(rdToDelete != null && rdToDelete.size() > 0)

				DataBase.delete(rdToDelete,false);

			}

	pageRef.getParameters().put('retURL',ApexPages.currentPage().getParameters().get('retURL'));
	pageRef.getParameters().put('ent','RepositoryDocument__c');
	pageRef.getParameters().put('cancelURL',ApexPages.currentPage().getParameters().get('cancelURL'));

	return pageRef ;

	}
}