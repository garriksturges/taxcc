public class AccountHierarchyController{
    public string debugString {get;set;}
    public string accountObjectName {get; set;}
    public string accountHierarchyLevelNewOrEdit {get;set;}
    public string accountHierarchyMemberFilter {get; set;}    
    public string accountHierarchyMemberFilterGroup {get; set;}
    public List<SelectOption> accountHierarchyMemberSelectOptionList {get; set;}
    public string accountHierarchyMemberNewOrEdit {get;set;}  
    public string hiddenSelectedLocationId {get; set;}  
    public string hiddenSelectedContactId {get; set;}  
    public string hiddenSelectedUsersId {get; set;}  
    public List<SelectOption> locationSelectOptionList {get; set;}   
    public List<SelectOption> contactSelectOptionList {get; set;}
    
    public List<SelectOption> UserSelectOptionList {get; set;}   
    public string pageParentLabel {get; set;}
    public List<SelectOption> parentAccountHierarchyMemberSelectOptionList {get; set;}   
    
    public List<SelectOption> selectedLocationItemsSelectOptionList {get; set;}   
    public List<SelectOption> selectedContactItemsSelectOptionList {get; set;}
    
    public List<SelectOption> selecteduserItems{get; set;}   
    public String TreeViewData {get; set;}   
    
    public string updateLevelId {get; set;}
    public string updateClientOrgId {get; set;}
    public string ClientOrgIdRead {get; set;}
    public string parentClientOrgLevelName {get;set;}
    public string parentClientOrgLevelId {get;set;}
    public string ClientOrgLevelNameRead {get; set;}
    public string DeleteClientOrgId {get; set;}
    public string ClientLevelEditParentName {get; set;}
    public string ClientOrgNameRead {get;set;}
    public string ClientOrgNameMsg{get;set;}
    public string ClientOrgLevelNameMsg{get; set;}
    public string hdDeleteIDList {get;set;}
    public boolean isValidation{get; set;}
    public string ShowModalWindow {get;set;}   
    public String[] treeList {get; set;}
    public string AccountHierarchyMemberObjectId {get; set;}
    public string accountHierarchyMemberLabelName {get; set;}
    public string AccountId {get; set;}
    public string ParentClientOrg {get; set;}
    public List<SelectOption> ClientLevelList {get; set;}
    public string ClientOrgLevelId {get; set;}
    public string ClientOrgLevelName {get; set;}
    public string Location {get; set;}
    public string uniqueID{get;set;}
    
    public AccountHierarchyController(ApexPages.StandardController controller)
    {
        if(ApexPages.currentPage().getParameters().get('accountId') != null)
        {
            accountId = ApexPages.currentPage().getParameters().get('accountId');
            Account accountObj = [select name from account where id=:accountId limit 1];
            accountObjectName = accountObj.name;
        }
        else
        {
            return;
        }
        
        bindTreeView();
        initializePage();
    }
    
    public AccountHierarchyController()
    {
        if(ApexPages.currentPage().getParameters().get('accountId') != null)
        {
            accountId = ApexPages.currentPage().getParameters().get('accountId');
            Account accountObj = [select name from account where id=:accountId limit 1];
            accountObjectName = accountObj.name;
        }
        else
        {
            return;
        }
        
        bindTreeView();
        initializePage();
    }
    
    public void bindTreeView()
    {
        TreeViewData = '<ul id=\"tree\">';
        List<AccountHierarchyMember__c> accountHierarchyMemberList = [select id, AccountHierarchyMemberLabelName__c, ParentAccountHierarchyMember__c, AccountHierarchyMemberName__c from AccountHierarchyMember__c where Account__c=:accountId order by AccountHierarchyLevel__r.LevelNumber__c, AccountHierarchyMemberLabelName__c asc];
        treeList = new String[accountHierarchyMemberList.size()];
        
        for(integer i=0; i < accountHierarchyMemberList.size(); i++)
        {
            string treeNode = '[' + accountHierarchyMemberList[i].id + '|' + accountHierarchyMemberList[i].AccountHierarchyMemberName__c + ': ' + accountHierarchyMemberList[i].AccountHierarchyMemberLabelName__c + '|' + accountHierarchyMemberList[i].ParentAccountHierarchyMember__c + ']';
            treeNode = treeNode.replace('\'','**]**');
            treeNode = treeNode.replace('\"','**]!**');
            treeList[i] = treeNode;
        }
    }
    
    public void initializePage()
    {
        if(updateClientOrgId != null && updateClientOrgId != '')
        {
            AccountHierarchyMember__c co = [select id, AccountHierarchyMemberLabelName__c, Account__c, ParentAccountHierarchyMember__c, AccountHierarchyLevel__c, AccountHierarchyMemberName__c, name from AccountHierarchyMember__c where id=:updateClientOrgId limit 1][0];
            AccountHierarchyMemberObjectId = co.id;
            accountHierarchyMemberLabelName = co.AccountHierarchyMemberLabelName__c;
            accountId =co.Account__c;
            accountHierarchyMemberFilter = co.ParentAccountHierarchyMember__c;
            ClientOrgLevelId = co.AccountHierarchyLevel__c;
            ClientOrgLevelName = co.AccountHierarchyMemberName__c;
            ClientOrgLevelNameRead = co.AccountHierarchyMemberName__c;
            uniqueID = co.name;
           
            /*******************************************Bind Locations**************************************************/
            List<Location__c> locList = [select Id from Location__c where AccountHierarchyMember__c =:co.id limit 1000];
            string delimitedLocationIds = '';
            for(Location__c location : locList)
            {
                delimitedLocationIds += location.Id + ';';
            }
            hiddenSelectedLocationId = delimitedLocationIds;
            
            /*****************************************Bind Contacts****************************************************/
            List<Contact> contactList = [select Id from Contact where AccountHierarchyMember__c =:co.id limit 1000];
            string delimitedContactIds = '';
            for(Contact ct : contactList)
            {
                delimitedContactIds += ct.Id + ';';
            }
            hiddenSelectedContactId = delimitedContactIds;
            
            
            
            
           /*

            string seluserlist='';
            List<SelectOption> usroptions = new List<SelectOption>();
            List<Contact> lstcont=[select id from contact where AccountHierarchyMember__c =:updateClientOrgId];
            if(lstcont!=null && lstcont.size()>0)
            {
                List<User> lstuser=[select id,name from User where ContactId in :lstcont];
                for(User usr:lstuser)
                {
                    usroptions.add(new SelectOption(usr.id,usr.name));
                    seluserlist += usr.Id + ';';
                }
                selecteduserItems=usroptions;
                hiddenSelectedUsersId=seluserlist;
            }
            */
            
        }
        
        
        initControlList();       
    }
    
    public void initControlList()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<SelectOption> Groups = new List<SelectOption>();
        List<AccountHierarchyMember__c> thisItems = [select id, AccountHierarchyMemberLabelName__c, AccountHierarchyMemberName__c, AccountHierarchyLevel__r.AccountHierarchyLevelLabelName__c from AccountHierarchyMember__c where Account__c=:accountId order by AccountHierarchyLevel__r.LevelNumber__c asc];
                
        options.add(new SelectOption('','Account: ' + accountObjectName));
        Groups.add(new SelectOption('ALL','Account: ' + accountObjectName));

        for(AccountHierarchyMember__c thisItem : thisItems)
        {
            options.add(new SelectOption(thisItem.id, thisItem.AccountHierarchyMemberName__c + ': ' + thisItem.AccountHierarchyMemberLabelName__c));
            Groups.add(new SelectOption(thisItem.id, thisItem.AccountHierarchyMemberName__c + ': ' + thisItem.AccountHierarchyMemberLabelName__c));
        }
        
        parentAccountHierarchyMemberSelectOptionList = options;
        accountHierarchyMemberSelectOptionList = Groups;
        initLocationItems();
        initSelectedItems();
        initLevelName();
    }


    public void initLocationItems()
    {     
        List<SelectOption> options = new List<SelectOption>();
        List<SelectOption> usroptions = new List<SelectOption>();
        
        String[] SelectedIDList = null;
        String[] SelectedContactIdList =null;
        
        List<EntityLocation__c> thisItems = null;
        List<Contact> thisContactItems = null;
    
        if(hiddenSelectedLocationId != '' && hiddenSelectedLocationId != null){
             SelectedIDList = hiddenSelectedLocationId.split(';');
        }    
        
           
        if(SelectedIDList == null)
        {
            thisItems = [select Location__r.id, Location__r.name from EntityLocation__c where Entity__r.Account__c =:accountId order by Location__r.Name limit 1000];

        }
        else
        {        
            thisItems = [select Location__r.id, Location__r.name from EntityLocation__c where Entity__r.Account__c =:accountId and Location__r.id not in :SelectedIDList order by Location__r.Name limit 1000 ];
        }

        if(thisItems != null)
        {
            for(EntityLocation__c thisItem : thisItems)
            {
                options.add(new SelectOption(thisItem.Location__r.id, thisItem.Location__r.name));
            }
        }
        locationSelectOptionList = options;
        
        
        /*************************************************Contacts*****************************************/
        if(hiddenSelectedContactId!='' && hiddenSelectedContactId !=null)
        {
             SelectedContactIdList = hiddenSelectedContactId.split(';');
        }        

        if(SelectedContactIdList == null)
        {
            thisContactItems = [select Id, Name from Contact where AccountId =:accountId and Id in(select ContactId from User where AccountId =:accountId) order by Name limit 1000];
        }
        else
        {        
            thisContactItems = [select Id, Name from Contact where AccountId =:accountId and Id in(select ContactId from User where AccountId =:accountId) and id not in :SelectedContactIdList order by Name limit 1000 ];
        }

        if(thisContactItems != null)
        {
            for(Contact thisContactItem : thisContactItems)
            {
                usroptions.add(new SelectOption(thisContactItem.id, thisContactItem.name));
            }
        }
        contactSelectOptionList = usroptions;        
    }
    
    public void initSelectedItems()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<SelectOption> usroptions = new List<SelectOption>();   
          
        if(hiddenSelectedLocationId != '' && hiddenSelectedLocationId != null)
        {
            String[] SelectedIDList = hiddenSelectedLocationId.split(';');
            List<EntityLocation__c> thisItems = [select Location__r.id, Location__r.name from EntityLocation__c where Location__r.id in :SelectedIDList];
        
            for(EntityLocation__c thisItem : thisItems)
            {
                options.add(new SelectOption(thisItem.Location__r.id, thisItem.Location__r.name));
            }
        }        
        selectedLocationItemsSelectOptionList = options;

        /*************************************************Contacts*****************************************/        
        if(hiddenSelectedContactId != '' && hiddenSelectedContactId != null)
        {
            String[] SelectedContactIdList = hiddenSelectedContactId.split(';');
            List<Contact> thisContactItems = [select id, name from Contact where Id in(select ContactId from User where AccountId =:accountId) and id in :SelectedContactIdList];
        
            for(Contact thisContactItem : thisContactItems)
            {
                usroptions.add(new SelectOption(thisContactItem.id, thisContactItem.name));
            }
        }        
        selectedContactItemsSelectOptionList = usroptions;        
        
    }
    
    public void initLevelName()
    {
        if(accountHierarchyMemberFilter != null && accountHierarchyMemberFilter != '')
        {
            ClientLevelList = new List<SelectOption>();
            List<AccountHierarchyMember__c> co = [Select AccountHierarchyLevel__r.id, AccountHierarchyLevel__r.AccountHierarchyLevelLabelName__c, AccountHierarchyLevel__r.LevelNumber__c from AccountHierarchyMember__c where id=:accountHierarchyMemberFilter limit 1];
            
            if(co.size() > 0)
            {
                List<AccountHierarchyLevel__c> col = [select id, AccountHierarchyLevelLabelName__c from AccountHierarchyLevel__c where account__c=:accountId and LevelNumber__c =:Co[0].AccountHierarchyLevel__r.LevelNumber__c+1 limit 1 ];
                if(col.size() > 0)
                {
                    ClientOrgLevelName = col[0].AccountHierarchyLevelLabelName__c;
                    ClientOrgLevelNameRead = col[0].AccountHierarchyLevelLabelName__c;
                    ClientOrgLevelId = col[0].Id;
                }
                else
                {
                    ClientOrgLevelName = '';
                    ClientOrgLevelNameRead = '';
                    ClientOrgLevelId = '';
                }
            }
            else
            {
                ClientOrgLevelName = '';
                ClientOrgLevelNameRead = '';
                ClientOrgLevelId = '';
            }
        }
        else
        {
            List<AccountHierarchyLevel__c> col = [select id, AccountHierarchyLevelLabelName__c from AccountHierarchyLevel__c where AccountHierarchyLevel__c = '' and account__c=:accountId limit 1 ];
            
            if(col.size() > 0)
            {
                ClientOrgLevelName = col[0].AccountHierarchyLevelLabelName__c;
                ClientOrgLevelNameRead = col[0].AccountHierarchyLevelLabelName__c;
                ClientOrgLevelId = col[0].Id;
            }
            else
            {
                ClientOrgLevelName = '';
                ClientOrgLevelNameRead = '';
                ClientOrgLevelId = '';
            }
        }
    }
    
    public PageReference groupChange()
    {
        initSelectedItems();
        initLocationItems();
        return null;
    }
    
    public void ParentOrgChange()
    {
        if(accountHierarchyLevelNewOrEdit == 'Edit' || accountHierarchyLevelNewOrEdit == 'New')
        {
            return;
        }
        else
        {
            accountHierarchyMemberFilterGroup = accountHierarchyMemberFilter;
            initSelectedItems();
            initLocationItems();
            initLevelName();
        }
    }
    
    public void AddChildClientOrg()
    {
        accountHierarchyMemberFilter=updateClientOrgId;
        ClientOrgNameRead = ClientOrgNameRead;
        parentClientOrgLevelName = ClientOrgLevelNameRead;
        parentClientOrgLevelId = ClientOrgLevelId;
        accountHierarchyMemberNewOrEdit='New';
        updateClientOrgId='';
        accountHierarchyMemberLabelName = '';
        accountHierarchyMemberFilterGroup = accountHierarchyMemberFilter;
        hiddenSelectedLocationId = '';
    
        if(accountHierarchyMemberFilter == 'AccountId')
        {
            accountHierarchyMemberFilter = '';
            accountHierarchyMemberFilterGroup = '';
            parentClientOrgLevelName = 'Account';
            parentClientOrgLevelId = '';
        }
        
        initializePage();
    }
    
    public void AddLocation(){
      pageParentLabel = 'AddLocation';

        initializePage();
    }
    
    
    public void EditClientOrg(){
        initializePage();
    }
    
    public void ResponseEditLevel(){
        accountHierarchyLevelNewOrEdit = 'Edit';
        initializePage();
    }
    
    public void ResponseNewLevel(){
        accountHierarchyLevelNewOrEdit = 'New';
        initializePage();
    }
    
    public void CloseModalWindow(){
        ShowModalWindow = 'Close';
        pageParentLabel = 'Close';
        ClientOrgNameMsg = '';
        ClientOrgLevelNameMsg = '';
    }
    
    public void updateClientOrg()
    {
        debugString = updateClientOrgId ;
        ShowModalWindow = 'Open';
        accountHierarchyMemberNewOrEdit='';
        if(updateClientOrgId != null)
        {
            if(updateClientOrgId == 'AccountId')
            {            
                clientOrgLevelName = 'Account';
                accountHierarchyMemberLabelName = accountObjectName;
                hiddenSelectedLocationId = '';
                hiddenSelectedUsersId='';
                List<EntityLocation__c> lst = [select Location__r.id from EntityLocation__c where Entity__r.Account__c =:accountId];                
                accountHierarchyMemberFilter = '';
                accountHierarchyMemberFilterGroup = '';
                initControlList();
            }
            else
            {
                AccountHierarchyMember__c co = [select Account__c, AccountHierarchyLevel__c, AccountHierarchyMemberName__c, AccountHierarchyMemberLabelName__c, ParentAccountHierarchyMember__c, ParentAccountHierarchyMember__r.AccountHierarchyMemberLabelName__c, name from AccountHierarchyMember__c where id=:updateClientOrgId limit 1];
                accountId = co.Account__c;
                accountObjectName = [select name from Account where id=: co.Account__c][0].name;
                accountHierarchyMemberFilter = co.ParentAccountHierarchyMember__c;
                ClientOrgLevelNameRead = co.AccountHierarchyMemberName__c;
                ClientOrgLevelName = co.AccountHierarchyMemberName__c;
                ClientOrgLevelId = co.AccountHierarchyLevel__c;
                accountHierarchyMemberLabelName = co.AccountHierarchyMemberLabelName__c;
                ClientOrgNameRead = co.AccountHierarchyMemberLabelName__c;
                accountHierarchyMemberFilterGroup = co.ParentAccountHierarchyMember__c;
                uniqueID = co.name;
                
                List<Location__c> locList = [select Id from Location__c where AccountHierarchyMember__c =:co.id];
                string delimitedLocationIds = '';
                if(locList.size() > 0)
                {
                    for(Location__c location : locList)
                    {
                        delimitedLocationIds += location.Id + ';';
                    }
                }                
                hiddenSelectedLocationId = delimitedLocationIds;
                
                List<Contact> contactList = [select Id from Contact where AccountHierarchyMember__c =:co.id];
                string delimitedContactIds = '';
                if(contactList.size() > 0)
                {
                    for(Contact ct : contactList)
                    {
                        delimitedContactIds += ct.Id + ';';
                    }
                }                
                hiddenSelectedContactId = delimitedContactIds;            

                
                initControlList();
            }
        }
    }
    
    public void SaveClientOrg()
    {
        
        if(ClientOrgLevelName == null || ClientOrgLevelName == '')
        {
            ClientOrgLevelNameMsg = 'Cannot be blank';
            isValidation = true;
            return;
        }
        else
        {
            isValidation = false;
            ClientOrgLevelNameMsg = '';
        }
        
        if(accountHierarchyMemberLabelName == null || accountHierarchyMemberLabelName == '')
        {
            ClientOrgNameMsg = 'Cannot be blank';
            isValidation = true;
            return;
        }
        else
        {
            isValidation = false;
            ClientOrgNameMsg = '';
        }
        
        Decimal levelNum = 1;
        string newId = '';
        
        if(ClientOrgLevelNameRead == null || ClientOrgLevelNameRead == '')
        {
            
            AccountHierarchyLevel__c col = new AccountHierarchyLevel__c();
            col.AccountHierarchyLevelLabelName__c = ClientOrgLevelName;
            
            if(parentClientOrgLevelId != '' && parentClientOrgLevelId != null)
            {
                col.AccountHierarchyLevel__c = parentClientOrgLevelId;
                col.Account__c = accountId;
                List<AccountHierarchyLevel__c> cols = [select AccountHierarchyLevel__c,LevelNumber__c from AccountHierarchyLevel__c where id=:parentClientOrgLevelId and account__c=:accountId];
              
                if(cols.size() > 0)
                {
                    col.LevelNumber__c = cols[0].LevelNumber__c + 1;
                    levelNum = cols[0].LevelNumber__c + 1;
                }
                else
                {
                    col.LevelNumber__c = 1;
                    levelNum = 1;
                }
            }
            else
            {               
                col.Account__c = accountId;
                col.LevelNumber__c = 1;
                levelNum = 1;            
            }
            
            insert col;
            system.debug('testcols'+col);
            ClientOrgLevelId = col.id;
            ClientOrgLevelName = col.AccountHierarchyLevelLabelName__c;
            newId = col.Id;
            List<AccountHierarchyLevel__c> updateCols = null;
            updateCols = [select id, LevelNumber__c from AccountHierarchyLevel__c where account__c=:accountId and LevelNumber__c >= :levelNum and id <>:newId order by LevelNumber__c asc];
            
            if(updateCols.size() > 0)
            {
                for(AccountHierarchyLevel__c coLevel : updateCols)
                {
                    coLevel.LevelNumber__c = coLevel.LevelNumber__c + 1;
                }
                
                update updateCols;
            }
        }
        else if(ClientOrgLevelName != ClientOrgLevelNameRead)
        {
            AccountHierarchyLevel__c editObj = [select id, AccountHierarchyLevelLabelName__c, LevelNumber__c, AccountHierarchyLevel__c from AccountHierarchyLevel__c where id=:ClientOrgLevelId];
            editObj.AccountHierarchyLevelLabelName__c = ClientOrgLevelName;

            update editObj;

            List<AccountHierarchyMember__c> oldList = [select id,AccountHierarchyMemberName__c from AccountHierarchyMember__c where AccountHierarchyLevel__c =: editObj.id];
            List<AccountHierarchyMember__c> newList = new List<AccountHierarchyMember__c>();

            for(AccountHierarchyMember__c newObj : oldList)
            {
                newObj.AccountHierarchyMemberName__c = editObj.AccountHierarchyLevelLabelName__c;
                newList.add(newObj);
            }
            
            update newList;
        }
                
        if(updateClientOrgId != '' && updateClientOrgId != null)
        {
            AccountHierarchyMember__c co = [select id, AccountHierarchyMemberLabelName__c, ParentAccountHierarchyMember__c, AccountHierarchyLevel__c, AccountHierarchyMemberName__c from AccountHierarchyMember__c where id=:updateClientOrgId limit 1];
            co.AccountHierarchyMemberLabelName__c = accountHierarchyMemberLabelName;
            co.ParentAccountHierarchyMember__c = accountHierarchyMemberFilter;
            co.AccountHierarchyLevel__c = ClientOrgLevelId;
            co.AccountHierarchyMemberName__c = ClientOrgLevelName;
            
            Location__c[] location = [select Id, AccountHierarchyMember__c from Location__c where AccountHierarchyMember__c=:co.id];
            if(location.size() > 0)
            {
                for(Location__c loc : location)
                {
                    loc.AccountHierarchyMember__c = null;
                    update loc;
                }           
            }
            
            String[] locationIds = hiddenSelectedLocationId.split(';');
            if(locationIds.size() > 0)
            {
                if(locationIds[0].length() > 1)
                {
                    for(String locId : locationIds)
                    {
                        Location__c locationToUpdate = [select Id, AccountHierarchyMember__c from Location__c where id=:locId];
                        locationToUpdate.AccountHierarchyMember__c = co.Id;
                        update locationToUpdate;                
                    }
                }
            }


            Contact[] ctary = [select Id, AccountHierarchyMember__c from Contact where AccountHierarchyMember__c=:co.id];
            if(ctary.size() > 0)
            {
                for(Contact ct : ctary)
                {
                    ct.AccountHierarchyMember__c = null;
                    update ct;
                }           
            }
            
            String[] contactIds = hiddenSelectedContactId.split(';');
            if(contactIds.size() > 0)
            {
                if(contactIds[0].length() > 1)
                {
                    for(String ctId : contactIds)
                    {
                        Contact contactToUpdate = [select Id, AccountHierarchyMember__c from Contact where id=:ctId];
                        contactToUpdate.AccountHierarchyMember__c = co.Id;
                        update contactToUpdate;                
                    }
                }
            }
            
            update co;
        }
        else
        {        
            AccountHierarchyMember__c co = new AccountHierarchyMember__c();
            co.AccountHierarchyMemberLabelName__c = accountHierarchyMemberLabelName;
            co.account__c = accountId;
         
            if(accountHierarchyMemberFilter != '' && accountHierarchyMemberFilter != null)
            {
                co.ParentAccountHierarchyMember__c = accountHierarchyMemberFilter;
            }
            
            co.AccountHierarchyLevel__c = ClientOrgLevelId;
            co.AccountHierarchyMemberName__c = ClientOrgLevelName;
            Database.SaveResult saveres = Database.insert(co, false);
            String accountHierarchyMemberId = saveres.getId();
            
            String[] locationIds = hiddenSelectedLocationId.split(';');
            if(locationIds.size() > 0)                        
            {
                if(locationIds[0].length() > 1)
                {
                    for(String locId : locationIds)
                    {
                        Location__c locationToUpdate = [select Id, AccountHierarchyMember__c from Location__c where id=:locId];
                        locationToUpdate.AccountHierarchyMember__c = accountHierarchyMemberId;
                        update locationToUpdate;                
                    }
                }
            }
            
            String[] contactIds = hiddenSelectedContactId.split(';');
            if(contactIds.size() > 0)                        
            {
                if(contactIds[0].length() > 1)
                {
                    for(String ctId : contactIds)
                    {
                        Contact contactToUpdate = [select Id, AccountHierarchyMember__c from Contact where id=:ctId];
                        contactToUpdate.AccountHierarchyMember__c = accountHierarchyMemberId;
                        update contactToUpdate;                
                    }
                }
            }
            
        }        
    }
    
    public void deleteItem()
    {
        //delete Client Level
        if(accountHierarchyLevelNewOrEdit != '' && accountHierarchyLevelNewOrEdit != null){
            AccountHierarchyLevel__c col = [select id from AccountHierarchyLevel__c where id=:DeleteClientOrgId];
            List<AccountHierarchyMember__c> delCos = [select id from AccountHierarchyMember__c where AccountHierarchyLevel__c = :col.Id];
            delete delCos;
            delete col;
            List<AccountHierarchyLevel__c> updateLevels = [select id,LevelNumber__c,AccountHierarchyLevel__c from AccountHierarchyLevel__c where account__c=:accountId order by LevelNumber__c asc];
            for(Integer i =0;i<updateLevels.size();i++){
                updateLevels[i].LevelNumber__c = i+1; 
                if(i > 0){
                    updateLevels[i].AccountHierarchyLevel__c = updateLevels[i-1].id;
                } 
            }
            update updateLevels;
        }else{
            List<String> slst = hdDeleteIDList.split(';');
            List<AccountHierarchyMember__c> delIDs = new List<AccountHierarchyMember__c>();
            for(string s : slst){
                delIDs.add(new AccountHierarchyMember__c(id = s));
            }
            if(delIDs.size() <= 200){
                database.delete(delIDs);
            }else{
                List<AccountHierarchyMember__c> lst = delIDs;
                List<AccountHierarchyMember__c> tmpLst = new List<AccountHierarchyMember__c>();
                integer count = lst.size();
                for(integer i=0;i < count;i++){
                    tmpLst.add(lst.get(0));
                    lst.remove(0);
                    if(tmpLst.size() == 200){
                        database.delete(tmpLst);
                        tmpLst.clear();
                    }else if(i == (count-1)){
                        database.delete(tmpLst);
                        tmpLst.clear();
                    }
                }
            }
        }
    }   
}