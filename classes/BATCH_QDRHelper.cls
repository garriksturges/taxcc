public class BATCH_QDRHelper{
	
	public static void InvokeBatch(){
		System.debug('Calling Batch ..!');
		CreateAsyncQualificationDocs batch = new CreateAsyncQualificationDocs();
	id batchId = Database.executeBatch(batch,200);
	AsyncApexJob asynJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchId ];
	System.debug('End Batch Processing with ' + asynJob.NumberOfErrors + 'Errors');
	}
}