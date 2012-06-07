global class SaveEmployeeInformationPlugin implements Process.Plugin{

    global Process.PluginResult invoke(Process.PluginRequest request)
    {
        String AccountId = (String)request.inputParameters.get('AccountId');
        String EntityId = (String)request.inputParameters.get('EntityId');
        String LocationId = (String)request.inputParameters.get('LocationId');
        String FirstName = (String)request.inputParameters.get('FirstName');
        String MiddleName = (String)request.inputParameters.get('MiddleName');
        String LastName = (String)request.inputParameters.get('LastName');
        Date Birthday = Date.valueOf((Datetime)request.inputParameters.get('Birthday'));
        String SSN = (String)request.inputParameters.get('SSN');
        String SessionId  = (String)request.inputParameters.get('SessionId');
        
        String Street = (String)request.inputParameters.get('Street');
        String City = (String)request.inputParameters.get('City');
        String State = (String)request.inputParameters.get('State');
        String ZipCode = (String)request.inputParameters.get('ZipCode');
        String County = (String)request.inputParameters.get('County');
        Decimal Latitude = (Decimal)request.inputParameters.get('Latitude');
        Decimal Longitude = (Decimal)request.inputParameters.get('Longitude');
        
        Date HireDate = Date.valueOf((Datetime)request.inputParameters.get('HireDate'));
        Decimal HourlyWage = (Decimal)request.inputParameters.get('HourlyWage');
        String JobTitle = (String)request.inputParameters.get('JobTitle');
        String Department = (String)request.inputParameters.get('Department');
        
        string EmployeeSFID = '';
        string EmployeeAddressSFID = '';
        string EmploymentSFID = '';

        
        Employee__c emp = new Employee__c(Account__c = AccountId, 
                                        FirstName__c = FirstName, 
                                        LastName__c = LastName, 
                                        MiddleName__c = MiddleName, 
                                        BirthDate__c = Birthday,
                                        SSN__c = SSN,
                                        FlowSession__c = SessionId);
        insert emp;
        
        EmployeeSFID = emp.Id;
        
        EmployeeAddress__c eaddr = new EmployeeAddress__c(Employee__c = emp.Id, 
                                                    CityName__c = City,
                                                    County__c = County,
                                                    EffectiveDate__c = HireDate,
                                                    Latitude__c = Latitude,
                                                    Longitude__c = Longitude,
                                                    State__c = State,
                                                    StreetAddressText__c = Street,
                                                    ZipCode__c = ZipCode,
                                                    FlowSession__c = SessionId);
                                                    
        insert eaddr;
        
        EmployeeAddressSFID =  eaddr.Id;                                
        
        
        Employment__c hire = new Employment__c(Employee__c = emp.Id,
                                            DepartmentName__c = Department,
                                            Entity__c = EntityId,
                                            StartDate__c = HireDate,
                                            InitialHourlyRateAmount__c = HourlyWage,
                                            JobTitleName__c = JobTitle,
                                            Location__c = LocationId,
                                            FlowSession__c = SessionId,
                                            Status__c = 'Hired');
        
        insert hire;
        
        EmploymentSFID = hire.Id;
        

        
        
        
        
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('EmployeeSFID',EmployeeSFID);
        result.put('EmployeeAddressSFID',EmployeeAddressSFID);
        result.put('EmploymentSFID',EmploymentSFID);
        
        return new Process.PluginResult(result);   
    }
    
    global Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult  result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('AccountId', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('EntityId', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('LocationId', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('FirstName', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('MiddleName', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('LastName', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('Birthday', Process.PluginDescribeResult.ParameterType.DATETIME, true),
            new Process.PluginDescribeResult.InputParameter('SSN', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('Street', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('City', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('State', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('ZipCode', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('County', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('Latitude', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
            new Process.PluginDescribeResult.InputParameter('Longitude', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
           new Process.PluginDescribeResult.InputParameter('HireDate', Process.PluginDescribeResult.ParameterType.DATETIME, true),
            new Process.PluginDescribeResult.InputParameter('HourlyWage', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
            new Process.PluginDescribeResult.InputParameter('JobTitle', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('Department', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('SessionId', Process.PluginDescribeResult.ParameterType.STRING, true)
            
        };
        
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('EmployeeSFID', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('EmployeeAddressSFID', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('EmploymentSFID', Process.PluginDescribeResult.ParameterType.STRING)
        };
        
        return result;            
    }       
}