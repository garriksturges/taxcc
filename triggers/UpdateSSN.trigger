trigger UpdateSSN on Employee__c (before insert,before update)
{

    for(Employee__c Employee:trigger.new)
    {
        if(Employee.SSN__c != null)
        {
            string ssn=Employee.SSN__c;
            if(ssn.contains('-'))
            {
                string ssnew=ssn.replaceAll('-','');
                Employee.SSN__c=ssnew;
            }
        }
    
    }
}