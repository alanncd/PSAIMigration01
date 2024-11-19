trigger RingCentral2_trg on RingCentral_Data_Store2__c (after insert) {
    if (RingCentralTaskSetting__c.getOrgDefaults().Activate_Trigger__c) {
        if (trigger.isAfter) {
            if (trigger.isInsert) {
                List<RingCentral_Data_Store2__c> rcdLst = trigger.new;
                Task tsk;
                Map<String, RingCentral_Data_Store2__c> mapRCDC = new Map<String, RingCentral_Data_Store2__c>();
                Set<String> phones = new Set<String>();
                
                for (RingCentral_Data_Store2__c r : rcdLst) {
                    if (r.Call_Result__c == 'Missed' || r.Call_Result__c == 'Hang Up' || r.Type__c == 'SMS') {
                        mapRCDC.put(r.Caller_Phone_Number__c, r);
                        phones.add(r.Caller_Phone_Number__c);
                        system.debug('rcdList Trg: ' + r.Caller_Phone_Number__c);
                    }
                }
                
                List<Lead> lea = [SELECT Id, LastName, Name, MobilePhone, Phone, OwnerId 
                                  FROM Lead 
                                  WHERE (MobilePhone IN :phones OR Phone IN :phones) 
                                  WITH USER_MODE];
                system.debug('leads: ' + lea);
                system.debug('leads size: ' + lea.size());

                Map<String, Lead> mapLead = new Map<String, Lead>();  // Mobile
                Map<String, Lead> mapLeadPhone = new Map<String, Lead>(); // Phone
                List<Lead> leadsToUpdate = new List<Lead>();
                for (Lead l : lea) {
                    mapLead.put(l.MobilePhone, l);
                    mapLeadPhone.put(l.Phone, l);
                    
                    if (mapRCDC.get(l.MobilePhone) != null || mapRCDC.get(l.Phone) != null) {
                        tsk = new Task();
                        tsk.Subject = 'RC Missed Call';
                        tsk.WhoId = l.Id;
                        tsk.Status = 'Open';
                        tsk.Priority = 'Normal';
                        tsk.Type = 'Call';
                        tsk.TaskSubtype = 'Call';
                        tsk.ActivityDate = Date.today();
                        tsk.OwnerId = l.OwnerId;

                        if (mapRCDC.get(l.MobilePhone) != null) {
                            l.Tracking_Number_RC__c = mapRCDC.get(l.MobilePhone).To_Phone_Number__c;
                            leadsToUpdate.add(l);
                            tsk.Tracking_Number__c = mapRCDC.get(l.MobilePhone).To_Phone_Number__c;
                            tsk.Description = 'Call back this Lead: ' + mapRCDC.get(l.MobilePhone).Caller_Phone_Number__c;

                            if (mapRCDC.get(l.MobilePhone).Type__c == 'SMS') {
                                tsk.Subject = 'RC Missed SMS Received';
                                String description = '';

                                if (l.MobilePhone != null && mapRCDC.containsKey(l.MobilePhone)) {
                                    description = 'Call back this Lead: ' + mapRCDC.get(l.MobilePhone).Caller_Phone_Number__c;
                                } else if (l.Phone != null && mapRCDC.containsKey(l.Phone)) {
                                    description = 'Call back this Lead: ' + mapRCDC.get(l.Phone).Caller_Phone_Number__c;
                                }

                                description += ' Subject: ' + tsk.Subject;
                                tsk.Description = description;
                            }

                            tsk.Lead_Phone_Number__c = mapRCDC.get(l.MobilePhone).Caller_Phone_Number__c;
                        } else {
							l.Tracking_Number_RC__c = mapRCDC.get(l.MobilePhone).To_Phone_Number__c;
                            leadsToUpdate.add(l);
                            tsk.Tracking_Number__c = mapRCDC.get(l.Phone).To_Phone_Number__c;
                            tsk.Lead_Phone_Number__c = mapRCDC.get(l.Phone).Caller_Phone_Number__c;
                            tsk.Description = 'Call back this Lead: ' + mapRCDC.get(l.Phone).Caller_Phone_Number__c;

                            if (mapRCDC.get(l.Phone).Type__c == 'SMS') {
                                system.debug('SMS record');
                                tsk.Subject = 'RC Missed SMS Received';
                                tsk.Description = 'Call back this Lead: ' + mapRCDC.get(l.Phone).Caller_Phone_Number__c + ' Subject:' + mapRCDC.get(l.Phone).Subject__c;
                            }
                        }
                    }

                    // Insert Task if not null
                    if (tsk != null) {
                        update leadsToUpdate;
                        insert tsk;
                    }
                }

                // Check for permissions to create Task records
                if (!Schema.sObjectType.Task.isCreateable() ||
                    !Schema.sObjectType.Task.fields.Subject.isCreateable() ||
                    !Schema.sObjectType.Task.fields.WhoId.isCreateable() ||
                    !Schema.sObjectType.Task.fields.Status.isCreateable() ||
                    !Schema.sObjectType.Task.fields.Priority.isCreateable() ||
                    !Schema.sObjectType.Task.fields.Type.isCreateable() ||
                    !Schema.sObjectType.Task.fields.TaskSubtype.isCreateable() ||
                    !Schema.sObjectType.Task.fields.ActivityDate.isCreateable() ||
                    !Schema.sObjectType.Task.fields.OwnerId.isCreateable() ||
                    !Schema.sObjectType.Task.fields.Tracking_Number__c.isCreateable() ||
                    !Schema.sObjectType.Task.fields.Lead_Phone_Number__c.isCreateable() ||
                    !Schema.sObjectType.Task.fields.Description.isCreateable()) {
                        throw new AuraHandledException('You do not have permission to create Tasks with the specified fields.');
                }

                // Insert leads that are not found
                List<Lead> leaInsertList = new List<Lead>();
                Lead leaInsert;
                for (String key : mapRCDC.keySet()) {
                    String mobile = mapRCDC.get(key).Caller_Phone_Number__c;
                    system.debug(mapLead.get(mobile) + '<<<');

                    if (mapLead.get(mobile) == null) {
                        leaInsert = new Lead();
                        leaInsert.LastName = (mapRCDC.get(key).Type__c == 'SMS') ? 'SMS Received' : 'Missed call';
                        leaInsert.Status = 'New Lead';
                        leaInsert.MobilePhone = mapRCDC.get(key).Caller_Phone_Number__c;
                        leaInsert.Phone = mapRCDC.get(key).Caller_Phone_Number__c;
                        leaInsert.LeadSource = 'Other';
                        leaInsert.Tracking_Number_RC__c = mapRCDC.get(key).To_Phone_Number__c;
                        leaInsertList.add(leaInsert);
                    }
                }

                // Insert leads and create tasks for new leads
                List<Id> successIds = new List<Id>();
                List<Database.SaveResult> results = Database.insert(leaInsertList, false);

                for (Database.SaveResult result : results) {
                    if (result.isSuccess()) {
                        successIds.add(result.getId());
                        system.debug('Results: ' + results);
                    }
                }

                // Create tasks for newly inserted leads
                Task tskNew;
                List<Task> tasksForNewLeads = new List<Task>();
                for (Id x : successIds) {
                    tskNew = new Task();
                    tskNew.Subject = 'RC Missed SMS / Call';
                    tskNew.WhoId = x;
                    tskNew.Status = 'Open';
                    tskNew.Priority = 'Normal';
                    tskNew.Type = 'Call';
                    tskNew.TaskSubtype = 'Call';
                    tskNew.ActivityDate = Date.today();
                    tskNew.Description = 'Call back this Lead';
                    tasksForNewLeads.add(tskNew);
                }

                if (!tasksForNewLeads.isEmpty()) {
                    insert tasksForNewLeads;
                }
            }
        }
    }
}