public with sharing class addBulkCadenceLead {
    public String selectedFolderSMS { get; set; }
    public String selectedFolderEmail { get; set; }
    public String selectedFolderTask { get; set; }
    public List<Lead> leads{get;private set;}  
    public List<Lead> filteredLeads = new List<Lead>();
    public Boolean activateTriggerCadences {get; set;}
    public Boolean activateSmartphone {get; set;} 
    public Boolean activateTask {get; set;} 
    public Boolean activateEmail {get; set;} 
    public String sObjectType;
    public List<Lead> allLeads { get; set; }
    public List<Opportunity> allOpportunities { get; set; }
    public List<Transactions__c> allTransactions { get; set; }
    public List<Contact> allContacts { get; set; }
    public List<Interested_Buyers__c> allIB { get; set; }
    @TestVisible
    public Boolean disableSaveButton { get; set; } {disableSaveButton = false ;}

    @TestVisible
    private Boolean hasBeenClickedAlready = false;
   
 
    public addBulkCadenceLead(ApexPages.StandardSetController stdSetController){
        loadSettings();
        // Returns all selected records
        sObjectType = String.valueOf(stdSetController.getRecord().getSObjectType());
        
        System.debug('EL OBJECT TYPE' + sObjectType);
        
        if(sObjectType == 'Lead') {
            allLeads = [SELECT Id, Name, Status, Has_Cadence__c, IsConverted FROM Lead WHERE Id IN :stdSetController.getSelected() AND Has_Cadence__c = false AND Status != 'Closed - Converted' WITH USER_MODE  ];
        } else if(sObjectType == 'Opportunity') {
            allOpportunities = [SELECT Id, Name, Full_Address__c, Has_Cadence__c  FROM Opportunity WHERE Id IN :stdSetController.getSelected() AND Has_Cadence__c = false WITH USER_MODE];
        } else if(sObjectType == 'Transactions__c' || sObjectType == 'Left_Main__Transactions__c' ) {
            allTransactions = [SELECT Id, Name, Has_Cadence__c  FROM Transactions__c WHERE Id IN :stdSetController.getSelected() AND Has_Cadence__c = false WITH USER_MODE];
             System.debug('EL OBJECT TYPE' + sObjectType);
        } else if(sObjectType == 'Contact') {
             allContacts = [SELECT Id, Name, Has_Cadence__c  FROM Contact WHERE Id IN :stdSetController.getSelected() AND Has_Cadence__c = false WITH USER_MODE];
             System.debug('EL OBJECT TYPE' + sObjectType);
        } else if(sObjectType == 'Interested_Buyers__c' || sObjectType == 'Left_Main__Interested_Buyers__c'  ) {
             allIB = [SELECT Id, Name, Has_Cadence__c FROM Interested_Buyers__c WHERE Id IN :stdSetController.getSelected() AND Has_Cadence__c = false WITH USER_MODE ];
             System.debug('EL OBJECT TYPE' + sObjectType);
        }
       
        
    }
   
    
    private void loadSettings() {
        CadencesTrigger__c settings = CadencesTriggerHandler.getCustomSettings();
        activateTriggerCadences = settings.Activate_trigger_cadences__c;
        activateSmartphone = settings.activateSmartphone__c;
        activateTask = settings.TaskAutomation__c;
        activateEmail = settings.EmailAutomation__c;
    }
    
    // Method to retrieve folder names from the first custom setting
    public List<SelectOption> getFolderOptions1() {
        List<String> folderNames1 = getPicklistSMS();
        return createSelectOptions(folderNames1);
    }

    // Method to retrieve folder names from the second custom setting
    public List<SelectOption> getFolderOptions2() {
        List<String> folderNames2 = getPicklistEmail();
        return createSelectOptions(folderNames2);
    }

    // Method to retrieve folder names from the third custom setting
    public List<SelectOption> getFolderOptions3() {
        List<String> folderNames3 = getPicklistTask();
        return createSelectOptions(folderNames3);
    }

    // Method to create SelectOption list from folder names
    private List<SelectOption> createSelectOptions(List<String> folderNames) {
        List<SelectOption> options = new List<SelectOption>();
        for (String folderName : folderNames) {
            options.add(new SelectOption(folderName, folderName));
        }
        return options;
    }
    
     // Method to check if an object exists
    public static Boolean doesObjectExist(String objectApiName) {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        return globalDescribe.containsKey(objectApiName);
    }

    // Method to retrieve folder names from the first custom setting
    public static List<String> getPicklistSMS() {
          String objectApiName;
          String picklistFieldName;
        if (doesObjectExist('Left_Main__LMR_TemplateSms__c')) {
            objectApiName = 'Left_Main__LMR_TemplateSms__c';
            picklistFieldName = 'Left_Main__Folder__c';
        } else if (doesObjectExist('LMR_TemplateSms__c')) {
            objectApiName = 'LMR_TemplateSms__c';
            picklistFieldName = 'Folder__c';
        } else {
            // Neither object exists, return an empty list or handle as appropriate
            System.debug('Neither custom object exists in the org.');
            return new List<String>();
        }
      
        List<String> picklistLabels = new List<String>();
        
            // Obtener la descripción del campo de objeto personalizado o estándar
            Schema.DescribeFieldResult fieldDescription = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(picklistFieldName).getDescribe();
            
            // Verificar si el campo es una lista de selección
           
                // Obtener los valores de la lista de selección
                List<Schema.PicklistEntry> picklistValues = fieldDescription.getPicklistValues();
                
                // Iterar sobre los valores de la lista de selección y añadir las etiquetas a la lista de cadenas
                for(Schema.PicklistEntry picklistEntry : picklistValues) {
                    picklistLabels.add(picklistEntry.getLabel());
                }
        
        // Devolver la lista de etiquetas de la lista de selección
        return picklistLabels;

    }

    // Method to retrieve folder names from the second custom setting
    public static List<String> getPicklistEmail() {
        String objectApiName;
         String picklistFieldName;
        if (doesObjectExist('Left_Main__Lead_Follow_Up_Sequence__c')) {
            objectApiName = 'Left_Main__Lead_Follow_Up_Sequence__c';
            picklistFieldName = 'Left_Main__Folder__c';
        } else if (doesObjectExist('Lead_Follow_Up_Sequence__c')) {
            objectApiName = 'Lead_Follow_Up_Sequence__c';
            picklistFieldName = 'Folder__c';
        } else {
            // Neither object exists, return an empty list or handle as appropriate
            System.debug('Neither custom object exists in the org.');
            return new List<String>();
        }
       
        List<String> picklistLabels = new List<String>();
        
            // Obtener la descripción del campo de objeto personalizado o estándar
            Schema.DescribeFieldResult fieldDescription = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(picklistFieldName).getDescribe();
            
            // Verificar si el campo es una lista de selección
           
                // Obtener los valores de la lista de selección
                List<Schema.PicklistEntry> picklistValues = fieldDescription.getPicklistValues();
                
                // Iterar sobre los valores de la lista de selección y añadir las etiquetas a la lista de cadenas
                for(Schema.PicklistEntry picklistEntry : picklistValues) {
                    picklistLabels.add(picklistEntry.getLabel());
                }
      
        
        // Devolver la lista de etiquetas de la lista de selección
        return picklistLabels;
    }

    // Method to retrieve folder names from the third custom setting
    public static List<String> getPicklistTask() {
        
         String objectApiName;
         String picklistFieldName;
        if (doesObjectExist('Left_Main__Task_Follow_Up_Sequence__c')) {
            objectApiName = 'Left_Main__Task_Follow_Up_Sequence__c';
            picklistFieldName = 'Left_Main__Task_Cadence_Folder__c';
        } else if (doesObjectExist('Task_Follow_Up_Sequence__c')) {
            objectApiName = 'Task_Follow_Up_Sequence__c';
            picklistFieldName = 'Task_Cadence_Folder__c';
        } else {
            // Neither object exists, return an empty list or handle as appropriate
            System.debug('Neither custom object exists in the org.');
            return new List<String>();
        }
       
        List<String> picklistLabels = new List<String>();
        
            // Obtener la descripción del campo de objeto personalizado o estándar
            Schema.DescribeFieldResult fieldDescription = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(picklistFieldName).getDescribe();
            
            // Verificar si el campo es una lista de selección
           
                // Obtener los valores de la lista de selección
                List<Schema.PicklistEntry> picklistValues = fieldDescription.getPicklistValues();
                
                // Iterar sobre los valores de la lista de selección y añadir las etiquetas a la lista de cadenas
                for(Schema.PicklistEntry picklistEntry : picklistValues) {
                    picklistLabels.add(picklistEntry.getLabel());
                }
        
        // Devolver la lista de etiquetas de la lista de selección
        return picklistLabels;
    }
    
    //
    //
    public PageReference captureButtonClick() {
        hasBeenClickedAlready = true;
         disableSaveButton = true;
        return null;
    }
   
    public PageReference submit() {
        List<Cadences__c> cadences = new List<Cadences__c>();
        try {
            
            if(this.disableSaveButton == true){return null;}
            this.disableSaveButton = true;
            System.debug('add bulk cadence 3');

            // Determine which set of records to process based on sObjectType
            List<SObject> recordsToProcess = new List<SObject>();
            if(sObjectType == 'Lead') {
                recordsToProcess.addAll(allLeads);
            } else if(sObjectType == 'Opportunity') {
                recordsToProcess.addAll(allOpportunities);
            } else if(sObjectType == 'Transactions__c' || sObjectType == 'Left_Main__Transactions__c') {
                recordsToProcess.addAll(allTransactions);
            } else if(sObjectType == 'Contact') {
                recordsToProcess.addAll(allContacts);
            } else if(sObjectType == 'Interested_Buyers__c' || sObjectType == 'Left_Main__Interested_Buyers__c') {
                recordsToProcess.addAll(allIB);
            }
            
            // Create Cadences__c records for each selected record
            for(SObject record : recordsToProcess) {
                cadences.add(createCadenceRecord(record.Id));
            }
            
            // Insert all Cadences__c records in a single DML operation
            if(!cadences.isEmpty() && Schema.sObjectType.Cadences__c.isCreateable() && Schema.sObjectType.Cadences__c.fields.TargetId__c.isCreateable() &&
            Schema.sObjectType.Cadences__c.fields.FolderEmail__c.isCreateable() && Schema.sObjectType.Cadences__c.fields.TaskEmailTemplate__c.isCreateable() &&
            Schema.sObjectType.Cadences__c.fields.SmsFolder__c.isCreateable() && Schema.sObjectType.Cadences__c.fields.Name.isCreateable()){

                //Database.insert(cadences, AccessLevel.User_mode);
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, cadences);
                cadences = decision.getRecords();
                Database.insert(cadences);
            }
          
        } catch(Exception e) {
           
            System.debug('Exception: ' + e);
        }
        
         // Dynamic redirection based on sObjectType
         String redirectUrl = '/lightning/o/';
         if(sObjectType.equals('Lead')) {
           redirectUrl += 'Lead/list?filterName=Recent';
         } else if(sObjectType.equals('Opportunity')) {
           redirectUrl += 'Opportunity/list?filterName=Recent';
         } else if(sObjectType.equals('Transactions__c')) { //|| sObjectType.equals('Left_Main__Transactions__c')
           redirectUrl += 'Transactions__c/list?filterName=Recent'; // Adjust the URL as needed for custom objects
         } else if( sObjectType.equals('Left_Main__Transactions__c')) {
           redirectUrl += 'Left_Main__Transactions__c/list?filterName=Recent'; // Adjust the URL as needed for custom objects
         } else if(sObjectType.equals('Contact')) {
           redirectUrl += 'Contact/list?filterName=Recent'; // Adjust the URL as needed for custom objects
         } else if(sObjectType.equals('Interested_Buyers__c')) { // || sObjectType.equals('Left_Main__Interested_Buyers__c')
           redirectUrl += 'Interested_Buyers__c/list?filterName=Recent'; // Adjust the URL as needed for custom objects
         } else if( sObjectType.equals('Left_Main__Interested_Buyers__c')) {
           redirectUrl += 'Left_Main__Interested_Buyers__c/list?filterName=Recent'; // Adjust the URL as needed for custom objects
         } else {
           redirectUrl += 'Home'; // Default redirection if sObjectType is unknown
         }
         return new PageReference(redirectUrl);
    }
    
    
    public Cadences__c createCadenceRecord(Id targetId) {
        return new Cadences__c(
            TargetId__c = targetId,
            FolderEmail__c = selectedFolderEmail,
            TaskEmailTemplate__c = selectedFolderTask,
            SmsFolder__c = selectedFolderSMS,
            Name = 'Bulk Initial Cadence'
        );
    }

    
}