global class ScheduleEmailBatch Implements Schedulable
{
   global void execute(SchedulableContext sc)
   {
    	sendmail();
   }
   public void sendmail()
   {
         BATCH_EmailDigest.runBatch();  
   }
}