public with sharing class LiveLoopReqWrapper{
    
    public class reqWrapperClass{
        public string pipeline_object_type;
        public String sf_object_id;
        public String property_full_address;
        public propertyAddress property_address;
        public String start_date;
        public String last_touch_date;
        public string contact_name;
        public List<string> campaign;
        public string lead_source;
        public string source_date;
        public string lead_priority;
        public string lead_status;
        public string notes;
        public string property_condition;
        public string mls_description;
        public string mls_id;
        public string photo_url;
    }
    
    public class propertyAddress {
        public String street_address;
        public String city;
        public String state;
        public String zipcode;
    }
    
    public static String getOpportunityRequest(Opportunity currentOpp){
        
        reqWrapperClass reqWrap = new reqWrapperClass();
        reqWrap.pipeline_object_type = 'Opportunity';
        
        propertyAddress addWrap = new propertyAddress();
        addWrap.street_address = currentOpp.Account.BillingStreet;
        addWrap.city = currentOpp.Account.BillingCity;
        addWrap.State = currentOpp.Account.BillingState;
        addWrap.zipcode = currentOpp.Account.BillingPostalCode;
        
        reqWrap.sf_object_id = currentOpp.Id == null ? 'blank':  currentOpp.Id;
        // reqWrap.property_full_address = 'blank';
        reqWrap.property_address = addWrap;
        reqWrap.start_date = currentOpp.createdDate.year()+'-'+currentOpp.createdDate.Month()+'-'+currentOpp.createdDate.Day(); //string.valueOf(currentOpp.createdDate); //string.ValueOf(date.newinstance(system.today().year(), system.today().month(), system.today().day()));
        reqWrap.last_touch_date = currentOpp.LastModifiedDate.year()+'-'+currentOpp.LastModifiedDate.Month()+'-'+currentOpp.LastModifiedDate.Day(); //string.valueOf(currentOpp.LastModifiedDate);// string.ValueOf(date.newinstance(system.today().year(), system.today().month(), system.today().day()));
        reqWrap.contact_name = currentOpp.Account.Name;
        reqWrap.campaign = new List<String>(); 
        reqWrap.campaign.add('blank');
        reqWrap.lead_source = currentOpp.leadsource==null?'blank':currentOpp.leadsource ;
        reqWrap.source_date = string.ValueOf(currentOpp.createdDate.year()+'-'+currentOpp.createdDate.Month()+'-'+currentOpp.createdDate.Day());
        reqWrap.lead_priority = 'blank';
        reqWrap.lead_status =  currentOpp.StageName ;
        reqWrap.notes =  'blank';
        reqWrap.property_condition = 'blank';
        reqWrap.mls_description = 'blank';
        reqWrap.mls_id = 'blank';
        reqWrap.photo_url = 'blank'; 
        
        List<reqWrapperClass> wrapClass = new List<reqWrapperClass>();
        wrapClass.add(reqWrap);
        string jsonData = JSON.serialize(wrapClass);
        return jsonData;
        
    }
    
    
    public static String getLeadRequest(Lead lead){
        reqWrapperClass reqWrap = new reqWrapperClass();
        reqWrap.pipeline_object_type = 'Lead';
        propertyAddress addWrap = new propertyAddress();
        addWrap.street_address = lead.Street==null?'blank':lead.Street;
        addWrap.city = lead.city==null?'blank':lead.city;
        addWrap.State = lead.State;
        addWrap.zipcode = lead.PostalCode==null?'blank':lead.PostalCode;
        reqWrap.sf_object_id = lead.Id;
        // reqWrap.property_full_address = lead.Street+','+lead.City+','+lead.State+' '+lead.PostalCode;
        reqWrap.property_address = addWrap;
        reqWrap.start_date = lead.createdDate.year()+'-'+lead.createdDate.Month()+'-'+lead.createdDate.Day();
        reqWrap.last_touch_date = lead.LastModifiedDate.year()+'-'+lead.LastModifiedDate.Month()+'-'+lead.LastModifiedDate.Day();  
        reqWrap.contact_name = lead.Name==null?'blank':lead.Name;
        reqWrap.campaign = new List<String>();
        reqWrap.campaign.add('blank');
        reqWrap.lead_source = lead.LeadSource==null?'blank':lead.LeadSource;
        reqWrap.source_date = string.valueOf(system.today());
        reqWrap.lead_priority = 'blank';
        reqWrap.lead_status = lead.Status==null?'blank':lead.Status;
        reqWrap.notes = 'Description : '+lead.Description;
        reqWrap.property_condition = 'blank';
        reqWrap.mls_description = 'blank';
        reqWrap.mls_id = 'blank';
        reqWrap.photo_url = 'blank'; 
        
        List<reqWrapperClass> wrapClass = new List<reqWrapperClass>();
        wrapClass.add(reqWrap);
        string jsonData = JSON.serialize(wrapClass);
        return jsonData;
    }
    
    public class OrgDetails{
        public string orgName;
        public String orgId;
        public String isSandbox;
        public string username;
    }
    
    public class AccessToken{
        public String access_token;
    }
    
}