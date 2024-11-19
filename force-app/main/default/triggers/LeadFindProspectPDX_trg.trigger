trigger LeadFindProspectPDX_trg on Lead (after insert,before Update,after update) {
        if(Trigger.isAfter && Trigger.isInsert){  
           // LeadFindProspectPDX_cls.findProspectLead(Trigger.new);  
        }
}