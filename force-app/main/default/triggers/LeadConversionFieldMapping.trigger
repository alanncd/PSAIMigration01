trigger LeadConversionFieldMapping on Lead (after insert,before Update,before Insert,after update) {

    //check form custom setting that trigger is on or not.
    if(LeadConversionSettings__c.getOrgDefaults().Activate_Trigger__c) { 

        if(Trigger.isBefore && Trigger.isUpdate && !System.isFuture()){ 
            // Convert lead where convertLead checkbox is true. 
            LeadConversionService.convertSelectedLead(Trigger.new,Trigger.oldMap);
        } 

        if(Trigger.isAfter && Trigger.isUpdate){   
            // Mapping lead fields on account and opportunity after covert.
            LeadConversionService.LeadFieldMapping(Trigger.new,Trigger.oldMap); 
        }

    }  

    if(LeadConversionSettings__c.getOrgDefaults().Activate_Chatter_Mapping__c){
        if(Trigger.isAfter && Trigger.isUpdate){  
            // Chatter Mapping from Lead to Opportunity 
            LeadConversionService.MapChatterPost(Trigger.new,Trigger.oldMap);
        }
    }
    //System.debug(LeadConversionSettings__c.getOrgDefaults());
    if(LeadConversionSettings__c.getOrgDefaults().Find_Prospect__c) { 
       
        if(Trigger.isBefore && Trigger.isInsert){  
            LeadConversionService.updAddressIndexedCreate(Trigger.new);
        }
        if(Trigger.isBefore && Trigger.isUpdate){  
                LeadConversionService.updAddressIndexedUpd(Trigger.new,Trigger.oldMap);                
        }
        if(Trigger.isAfter && Trigger.isInsert){  
                LeadConversionService.findProspectLead(Trigger.new);  
        }
        
    }
    
}