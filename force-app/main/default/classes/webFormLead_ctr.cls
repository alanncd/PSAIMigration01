public with sharing class webFormLead_ctr {
        private String firstName;
        private String lastName;
        private String email;
        private String Phone;
        private String street;
        private String city;
        private String state;
        private String zipCode;
        private String country;
        private String MobilePhone;
        private String items;
        private String leadSource;
        private String submited;
        private String recordType;
        private String qp;
        
        public webFormLead_ctr(){
            this.qp = ApexPages.currentPage().getParameters().get('qp');
            this.recordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            //this.leadSource='web';
        }
        public List<Selectoption> getItemsList(){
            List<SelectOption> options = new List<SelectOption>(); 
            List<Schema.Picklistentry> fieldResult = Lead.LeadSource.getDescribe().getPicklistValues();
            options.add(new SelectOption('', '-- select -- '));
            for(Schema.PicklistEntry f : fieldResult) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            return options;
          }
        public String getStreet(){return this.street;}
        public void setStreet(String street) {this.street = street;}
        public String getCity(){return this.city;}
        public void setCity(String city) {this.city = city;}
        public String getState(){return this.state;}
        public void setState(String state) {this.state = state;}
        public String getZipCode(){return this.zipCode;}
        public void setZipCode(String zipCode) {this.zipCode = zipCode;}
        public String getCountry(){return this.country;}
        public void setCountry(String country) {this.country = country;}
        public String getSubmited() {
            return this.submited;
         }
         public void setSubmited(String submited) {
             this.submited = submited;
         }         
         /*public String getItems() {
            return this.items;
         }
         public void setItems(String items) {
             this.items = items;
         }     */     
          public String getFirstName() {
            return this.firstName;
         }
         public void setFirstName(String firstName) {
             this.firstName = firstName;
         }
         public String getLastName() {
            return this.lastName;
         }
         public void setLastName(String lastName) {
             this.lastName = lastName;
         }    
         public String getEmail() {
            return this.email;
         }
         public void setEmail(String email) {
             this.email = email;
         }
        
         public String getPhone() {
            return this.phone;
         }
         public void setPhone(String phone) {
             this.phone = phone;
         }    
         public String getMobilePhone() {
            return this.mobilePhone;
         }
         public void setMobilePhone(String mobilePhone) {
             this.mobilePhone = mobilePhone;
         }
         
         public String getLeadSource() {
            return this.leadSource;
         }
         public void setLeadSource(String leadSource) {
             this.leadSource = leadSource;
         }    
         public String getRecordType() {
            return this.recordType;
         }
         public void setRecordType(String recordType) {
             this.recordType = recordType;
         }
         
        public PageReference save() {
             PageReference p = null;
             AssignmentRule AR = new AssignmentRule();
             AR=[select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
             //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                    try {
                            Lead newlead = new Lead(
                                                    FirstName=this.firstName,
                                                    LastName=this.lastName,
                                                    Email=this.email,
                                                    Phone=this.phone,
                                                    MobilePhone=this.mobilePhone,
                                                    LeadSource=this.leadSource,
                                                    street=this.street,
                                                    city=this.city,
                                                    PostalCode =this.zipCode,
                                                    country=this.country,
                                                    state=this.state,
                                                    RecordTypeId=this.recordType
                                                    );
                            newlead.setOptions(dmlOpts);
                            insert newlead;
                            PageReference home = new PageReference('/');
                            home.setRedirect(true);
                            return home;  
                        } catch (Exception ex) {
                             ApexPages.addMessages(ex);
                             return null;
                        }
        }
    
    }