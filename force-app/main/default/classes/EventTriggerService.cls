public with sharing class EventTriggerService {

    // For check related opportunity and update appointment date and update address on event object record.
    public static void updateEventAddressAndAppointmentDT(List<Event> newList,Map<Id,Event> OldMap){
        
        LeftMain_SecurityUtils.checkObjectIsReadable(Opportunity.SObjectType); 
        String OpportunityPrefix = Opportunity.SObjectType.getDescribe().getKeyPrefix();
        Set<String> OpportunityIdAppointmentDTSet = new Set<String>(); 
        Set<String> OpportunityIdSet = new Set<String>(); 
        
        LeftMain_SecurityUtils.checkRead( Event.SObjectType,new List<String> {
            'WhatId',
            'Subject'
        }); 
        
        //Get Opportunity Id
        for(Event EventOBJ : newList){ 
            if (EventOBJ.WhatId !=null  && String.valueOf(EventOBJ.WhatId).startsWith(OpportunityPrefix)) {
                OpportunityIdSet.add(EventOBJ.WhatId); 
            }
            if (EventOBJ.WhatId !=null && EventOBJ.Subject != null && string.valueOf(EventOBJ.WhatId).startsWith(OpportunityPrefix) &&
                ( EventOBJ.Subject.containsIgnoreCase('Acquisition') || EventOBJ.Subject.containsIgnoreCase('Appointment') ) ) 
            {
                OpportunityIdAppointmentDTSet.add(EventOBJ.WhatId); 
            }
        }

        LeftMain_SecurityUtils.checkRead( Opportunity.SObjectType,new List<String> {
            'Id',
            'Address_1__c',
            'Appointment_Date_Time__c'
        }); 
        List<Opportunity> OpportunityUpdateList = new List<Opportunity>();
        Map<Id,Opportunity> OpportunityMap =new Map<Id,Opportunity>([SELECT Id,Address_1__c
                                                                     FROM Opportunity WHERE Id IN :OpportunityIdSet AND Address_1__c != null]);
        Map<Id,Opportunity> OpportunityAppointmentDTMap =new Map<Id,Opportunity>([SELECT Id,Appointment_Date_Time__c
                                                                         FROM Opportunity WHERE Id IN :OpportunityIdAppointmentDTSet]);
        // Update Opportunity Appointment date and Event Location
        for(Event EventOBJ : newList){
            if(OpportunityMap != null && OpportunityMap.Size() > 0 && EventOBJ.WhatId != null &&
               OpportunityMap.containsKey(EventOBJ.WhatId) && String.isBlank(EventOBJ.Location) ){
                   EventOBJ.Location = OpportunityMap.get(EventOBJ.WhatId).Address_1__c;
               }
             if(EventOBJ.WhatId != null && OpportunityAppointmentDTMap != null && 
                   OpportunityAppointmentDTMap.Size() > 0 && OpportunityAppointmentDTMap.containsKey(EventOBJ.WhatId)){
                       Opportunity OppObj = OpportunityAppointmentDTMap.get(EventOBJ.WhatId);
                       OppObj.Appointment_Date_Time__c = EventOBJ.StartDateTime;
                       OpportunityUpdateList.add(OppObj);  
                   }
        }
        if(!OpportunityUpdateList.isEmpty()){
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, OpportunityUpdateList);
            update decision.getRecords(); 
        }
    }
    
    // For check related lead and opportunity. Update event count on both object records.
    public static void updateLeadEventCount(List<Event> newList,Map<Id,Event> OldMap){
        
        LeftMain_SecurityUtils.checkObjectIsReadable(Lead.SObjectType);
        LeftMain_SecurityUtils.checkObjectIsReadable(Opportunity.SObjectType); 

        String leadPrefix = Lead.SObjectType.getDescribe().getKeyPrefix();
        String opportunityPrefix = Opportunity.SObjectType.getDescribe().getKeyPrefix(); 
        Set<String> opportunityIdSet = new  Set<String>();
        Set<String> leadIdSet = new Set<String>();

        LeftMain_SecurityUtils.checkRead( Event.SObjectType,new List<String> {
            'WhatId',
            'Subject',
            'whoId',
            'Id',
            'ownerId'
        }); 
        for(Event EventOBJ : newList){
            if (EventOBJ.whoId != null && string.valueOf(EventOBJ.whoId).startsWith(leadPrefix)) {
                leadIdSet.add(EventOBJ.whoId);  
            }
            
            if (EventOBJ.WhatId != null && string.valueOf(EventOBJ.WhatId).startsWith(opportunityPrefix)) {
                opportunityIdSet.add(EventOBJ.WhatId); 
            }
        }
        if (!leadIdSet.isEmpty()){
            LeftMain_SecurityUtils.checkRead( Lead.SObjectType,new List<String> {
                'Id',
                'EventCount__c',
                'ownerId'
            }); 
            List<Lead> leadUpdateList = new List<Lead>();
            List<Lead> leadsList = [SELECT Id, EventCount__c,ownerId,
                                (SELECT Id,ownerId,subject FROM Events) 
                                 FROM Lead WHERE Id IN :leadIdSet WITH USER_MODE];
                    
            // Count related Event and update event count on lead.
            for (Lead leadObj : leadsList) {
                Integer eventcount = 0;
                for (Event evnt : leadObj.Events) {
                        eventcount ++;
                }
                leadObj.EventCount__c = eventcount;
                leadUpdateList.add(leadObj); 
            }
            
            LeftMain_SecurityUtils.checkUpdate(Lead.SObjectType,new List<String> 
            {
                'EventCount__c'
            }); 

            if(!leadUpdateList.isEmpty()){
                /* Commenting this because we are disabling FLS for this package 1.15 Uncomment this when you need FLS for Security Review.   */
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, leadUpdateList);
                update decision.getRecords();
                //update leadUpdateList;
            }
        }
        
        if (!opportunityIdSet.isEmpty()){
            
            LeftMain_SecurityUtils.checkRead( Opportunity.SObjectType,new List<String> {
                'Id',
                'Event_Count__c',
                'ownerId'
            }); 

            List<Opportunity> opportunityUpdateList = new List<Opportunity>();
            List<Opportunity> opportunityList = [SELECT Id, Event_Count__c,ownerId,
                                (SELECT Id,ownerId,subject FROM Events) 
                                 FROM Opportunity WHERE Id IN :opportunityIdSet WITH USER_MODE];
            
            // Count related Event and update event count on opportunity.
            for (Opportunity opportunityObj : opportunityList) {
                Integer eventcount = 0;
                for (Event evnt : opportunityObj.Events) { 
                        eventcount ++;
                }
                opportunityObj.Event_Count__c = eventcount;
                opportunityUpdateList.add(opportunityObj);
            }

            if(!opportunityUpdateList.isEmpty()){
                /*  Commenting this because we are disabling FLS for this package 1.15 Uncomment this when you need FLS for Security Review.   */
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, opportunityUpdateList);
                update decision.getRecords(); 
                //update opportunityUpdateList;  
            }
        }
    }
}