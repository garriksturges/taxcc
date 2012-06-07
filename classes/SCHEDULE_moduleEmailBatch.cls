global class SCHEDULE_moduleEmailBatch implements Schedulable{
   global void execute(SchedulableContext sc) {
      BATCH_ModuleEmailDigest b = new BATCH_ModuleEmailDigest();
			Database.executeBatch(b);
   }
	private static testmethod void testSched(){
		System.schedule('test sched', '0 0 0 3 9 ? 2022', new SCHEDULE_moduleEmailBatch());
	}

}