public with sharing class PORTAL_EmploymentDownload {

	private string employmentId;
	private wktDocument8850__c w8850;
	private wktDocumentEDDRelease__c wEdd;
	public Attachment a8850 {get; set;}
	public Attachment aEdd	{get; set;}
	public boolean r8850		{get; set;}
	public boolean rEdd			{get; set;}
	private list<string> pIdList;
	/*************************************************************************************/
	public PORTAL_EmploymentDownload(){
		pIdList = new list<String>();		
		this.employmentId = Apexpages.currentPage().getParameters().get('eId');
		r8850 = false;
		rEdd = false;
		if(employmentId != null){
			setupWKTS();
			setupAttachments();	
		}
	}
	/*************************************************************************************/
	private void setupWKTS(){
		list <wktDocument8850__c> w8850List = [Select w.Employment__c  
																						From wktDocument8850__c w 
																						where Employment__c = :employmentId];
		if(w8850List != null && w8850List.size()>0){
				 r8850 = true;
				 w8850 = w8850List[0];
				 pIdList.add(w8850.id);
		}
																										
		list <wktDocumentEDDRelease__c> wEddList=[Select w.Employment__c 
																								From wktDocumentEDDRelease__c w 
																								where Employment__c = :employmentId];	
		if(wEddList != null && wEddList.size() >0){
				 rEdd = true;
				 wEdd = wEddList[0];
				 pIdList.add(wEdd.id);
		}	
	}
	/*************************************************************************************/
	private void setupAttachments(){
		list<Attachment> aList = [Select a.ParentId, a.Name, a.Description,
														 a.CreatedDate, a.ContentType, a.BodyLength, 
														 a.Body From Attachment a
														 where ParentId in :pIdList
														 order by CreatedDate];	
		if(aList != null && aList.size()>0){														 
			if(w8850!= null) a8850 = findAttachment(w8850.id, aList);
			if(wEdd != null) aEdd = findAttachment(wEdd.id, aList);
		}														 
	}
	/*************************************************************************************/
	private Attachment findAttachment(string wId, list<Attachment> aList){
		for(Attachment a : aList){
			if(a.ParentId == wId){
				return a;
			}
		}
		return null;
	}
	/*************************************************************************************/
}