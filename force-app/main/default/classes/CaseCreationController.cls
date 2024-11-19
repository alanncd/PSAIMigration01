/**
* 
* This class contains the method to create case in LM org using the details filled in by used in CaseCreationPage, 
* The destination org in which case needs to be created should have custom fileds - sourceOrgId, sourceCompanyName 
* and sourceUserName in order to use below case creation utilities.
* 
* @author : Sebulu.issac.babu
* 
* */
public class CaseCreationController {
    
    private String subject;
    private String description;
    private String email;
    private String sourceOrgId;
    private String sourceCompanyName;
    private String userName;
    private String ticketType;
    private String attachmentLink;
    public Boolean showSuccess{get;set;}
    public Boolean isError{get;set;}
    public String toastTitle{get;set;}
    public String toastMessage{get;set;}
    public String name{get;set;}
    public String phone{get;set;}
    
    /**
     * Initializing source org,source company and username using user info
     * 
     * */
    public CaseCreationController(){
        ticketType = '';
        showSuccess=false;
        isError=false;
        sourceOrgId = UserInfo.getOrganizationId();
        sourceCompanyName=UserInfo.getOrganizationName();
        userName=UserInfo.getName();
        
    }
    
    public String getphone(){
        return phone;
    }

    public void setphone(String phone){ 
        this.phone=phone;
    }
    
     public String getname(){
        return name;
    }

    public void setname(String name){ 
        this.name=name;
    }

    public String getattachmentLink(){
        return attachmentLink;
    }

    public void setattachmentLink(String attachmentLink){ 
        this.attachmentLink=attachmentLink;
    }

    public String getticketType(){
        return ticketType;
    }

    public void setticketType(String ticketType){ 
        this.ticketType=ticketType;
    }

    public String getSubject(){
        return subject;
    }
    public String getDescription(){
        return description;
    }
    public String getEmail(){
        return email;
    }
    
    public void setSubject(String subject){
        this.subject=subject;
    }
    public void setDescription(String description){
        this.description=description;
    }
    public void setUserName(String userName){
        this.userName=userName;
    }
    
    public void setSourceOrgId(String sourceOrgId){
        this.sourceOrgId=sourceOrgId;
    }
    public void setSourceCompanyName(String sourceCompanyName){
        this.sourceCompanyName=sourceCompanyName;
    }
    public void setEmail(String email){
        this.email=email;
    }
    
    public void saveCase() { 
        /*try{*/
            Http http=new Http();
            HttpRequest req = new HttpRequest();
            //Retriving email id from userinfo if email is not provided by user
            if(!String.isNotEmpty(email)){
                email=UserInfo.getUserEmail();
            }
            String caseCreationURL;
            ticketType = String.isNotBlank(ticketType) ? ticketType : '';
            attachmentLink = String.isNotBlank(attachmentLink) ? attachmentLink : '';

            //Contactinating the values recieved from user form and constructing WebToCase URL
            if(!Test.isRunningTest()){
                //Production case creation URL
                //+'&priority='+EncodingUtil.urlEncode(casepriority,'UTF-8')
                caseCreationURL='https://webto.salesforce.com/servlet/servlet.WebToCase?encoding=UTF-8&orgid=00D6g000002gRaH&00N6g00000UTdHs='+EncodingUtil.urlEncode(sourceCompanyName,'UTF-8')+'&00N6g00000UTdHt='+EncodingUtil.urlEncode(sourceOrgId,'UTF-8')+'&00N6g00000UTe05='+EncodingUtil.urlEncode(userName,'UTF-8')+'&subject='+EncodingUtil.urlEncode(subject,'UTF-8')+'&description='+EncodingUtil.urlEncode(description,'UTF-8')+'&email='+email+'&phone='+EncodingUtil.urlEncode(phone,'UTF-8')+'&name='+EncodingUtil.urlEncode(name,'UTF-8')+'&00N6g00000V6xbF='+EncodingUtil.urlEncode(ticketType,'UTF-8')+'&00N6g00000VAWat='+EncodingUtil.urlEncode(attachmentLink,'UTF-8')+'&submit=Submit';
            }else{ 
                //Sandbox case creation URL
                caseCreationURL='https://cs200.salesforce.com/servlet/servlet.WebToCase?encoding=UTF-8&orgid=00D7g0000008mQq&00N7g00000ABNmy='+EncodingUtil.urlEncode(sourceCompanyName,'UTF-8')+'&00N7g00000ABNhU='+EncodingUtil.urlEncode(sourceOrgId,'UTF-8')+'&00N7g00000ABObS='+EncodingUtil.urlEncode(userName,'UTF-8')+'&subject='+EncodingUtil.urlEncode(subject,'UTF-8')+'&description='+EncodingUtil.urlEncode(description,'UTF-8')+'&email='+email+'&phone='+EncodingUtil.urlEncode(phone,'UTF-8')+'&name='+EncodingUtil.urlEncode(name,'UTF-8')+'&00N6g00000V6xbF='+EncodingUtil.urlEncode(ticketType,'UTF-8')+'&00N6g00000VAWat='+EncodingUtil.urlEncode(attachmentLink,'UTF-8')+'&submit=Submit';
            } 
            //Invoking rest service to create case using WebToCase end point
            req.setEndpoint(caseCreationURL); 
            req.setMethod('POST'); 
            req.setHeader('Content-Type','application/x-www-form-urlencoded'); 
            req.setTimeout(120000);
            HttpResponse res = new HttpResponse(); 
            res = http.send(req);
            System.debug('Response -'+res);
            showSuccess=true;
            toastTitle='Thank you for contacting support';
            toastMessage='Your Case is succesfully created, Please check your email for further details.';
        /*}Catch (Exception ex){
            System.debug('Exception while creating case from support - '+ex);
            isError=true;
            showSuccess=true;
            toastTitle='Something went wrong!';
            toastMessage=ex.getMessage();
        }*/
        
    }
}