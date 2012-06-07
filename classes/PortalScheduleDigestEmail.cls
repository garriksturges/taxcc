global class PortalScheduleDigestEmail implements Schedulable{
	/************************/
	global void execute(SchedulableContext SC){
 	 	 BATCH_EmailDigest.runBatch();
  }
  /************************/
  private static testmethod void testscheduler(){
  	Test.startTest();
  	Datetime dt = Datetime.now();
    	
      String jobId = System.schedule('testScheduledApex','0 0 0 3 9 ? 2022', new PortalScheduleDigestEmail());
    

      CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

    
      System.assertEquals('0 0 0 3 9 ? 2022', 
         ct.CronExpression);
  	
  	Test.stopTest();
  }
  /************************/
}