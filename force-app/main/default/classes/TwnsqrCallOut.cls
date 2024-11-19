public class TwnsqrCallOut {
  @future(callout=true)
  public static void TwnsqrGetConfig() {
    //Verify if was connected
    List<Twnsqr_Config__c> lstConfig = [
      SELECT Id, Sync__c
      FROM Twnsqr_Config__c
    ];
    if (lstConfig.size() > 0 && lstConfig[0].Sync__c == true) {
      system.debug('Twnsqr Sync is OK');
    }
    // Instantiate a get config
    HttpResponse res = TwnsqrcallOut('/api/v1/config', 'GET', null);
    if (res.getStatusCode() == 200) {
      if (lstConfig.size() > 0) {
        lstConfig[0].Sync__c = true;
        lstConfig[0].Last_Message__c = res.getStatus();
        update lstConfig;
      } else {
        Twnsqr_Config__c twnConfig = new Twnsqr_Config__c();
        twnConfig.Sync__c = true;
        twnConfig.Last_Message__c = res.getStatus();
        insert twnConfig;
      }
    } else {
      if (lstConfig.size() > 0) {
        lstConfig[0].Sync__c = false;
        lstConfig[0].Last_Message__c = res.getStatus();
        update lstConfig;
        insertError(res, 'TwnsqrCallOut.TwnsqrGetConfig');
      }
    }
    system.debug(res.getBody());
  }
  @future(callout=true)
  public static void TwnsqrPostConfig() {
    configWrapper cw = new configWrapper();
    List<Twnsqr_Config__c> lstConfig = [
      SELECT Id, Sync__c, org_name__c
      FROM Twnsqr_Config__c
    ];
    cw.crm = lstConfig[0].org_name__c; // Sent to the TwnSqrConfig?
    Id OrgId = UserInfo.getOrganizationId();
    config cf = new config();
    cf.salesforceOrgID = OrgId + '';
    cw.config = cf;
    // Instantiate a get config
    HttpResponse res = TwnsqrcallOut(
      '/api/v1/config',
      'POST',
      JSON.serialize(cw, true)
    );
    if (res.getStatusCode() != 200) {
      insertError(res, 'TwnsqrCallOut.TwnsqrPostConfig');
    }
    system.debug(res.getBody());
  }

  @InvocableMethod(label='Post Config')
  public static List<String> TwnsqrPostConfigtwo(List<String> config) {
    List<String> responseList = new List<String>();
    if (config.size() == 1) {
      configWrapper cw = (configWrapper) JSON.deserialize(
        config[0],
        configWrapper.class
      );
      // Handle the HTTP callout and error handling
      HttpResponse res = TwnsqrcallOut(
        '/api/v1/config',
        'POST',
        JSON.serialize(cw, true)
      );
      if (res.getStatusCode() != 200) {
        insertError(res, 'TwnsqrCallOut.TwnsqrPostConfig');
      }
      responseList.add(String.valueOf(res.getStatusCode()));
    }
    return responseList;
  }
  public static void TwnsqrPostDeal(Transactions__c trx) {
    dealRequest dr = dealMaker(trx);
    dr.expiresAt = Date.today().addDays(30) + '';

    HttpResponse res = TwnsqrcallOut(
      '/api/v1/deals',
      'POST',
      JSON.serialize(dr, true)
    );
    if (res.getStatusCode() == 200) {
      system.debug(res.getBody());
      Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );
      trx.Twnsqr_clientId__c = results.get('clientId') + '';
      update trx;
    } else {
      insertError(res, 'TwnsqrCallOut.TwnsqrPostDeal');
    }
    system.debug('resresres:::' + res);
  }
  public static void TwnsqrPutDeal(Transactions__c trx, String action) {
    dealRequest dr = dealMaker(trx);
    if (action == 'RECHECK') {
      system.debug('RECHECK');
      dr.expiresAt = Date.today().addDays(30) + '';
    }
    if (action == 'UNCHECK') {
      system.debug('UNCHECK');
      dr.expiresAt = Date.today() + '';
    }
    system.debug('JSON.serialize(dr):::' + JSON.serialize(dr));

    HttpResponse res = TwnsqrcallOut(
      '/api/v1/deals/' + dr.externalRef,
      'PUT',
      JSON.serialize(dr, true)
    );
    if (res.getStatusCode() != 200) {
      insertError(res, 'TwnsqrCallOut.TwnsqrPutDeal');
    }
  }
  public static HttpResponse TwnsqrcallOut(
    String endpoint,
    String method,
    String body
  ) {
    List<Twnsqr_Config__c> lstConfig = [
      SELECT Id, baseURL__c, token__c
      FROM Twnsqr_Config__c
    ];

    // Instantiate a new Http object
    Http h = new Http();
    // Instantiate a new HTTP request.
    HttpRequest req = new HttpRequest();
    req.setEndpoint(lstConfig[0].baseURL__c + endpoint);
    req.setMethod(method);

    if (body != null) {
      req.setBody(body);
    }
    // Add your custom header
    req.setHeader('x-api-key', lstConfig[0].token__c); // Replace with your actual custom header and value
    req.setHeader('Content-Type', 'application/json'); // Replace with your actual custom header and value

    // Send the request, and return a response
    HttpResponse res = h.send(req);
    return res;
  }
  public static void insertError(HttpResponse res, String method) {
    insert ErrorHandler_cls.insertErrorHandler(
      'The status code returned was not expected: ' +
        res.getStatusCode() +
        ' ' +
        res.getStatus() +
        res.getBody(),
      method
    );
  }
  public static dealRequest dealMaker(Transactions__c trx) {
    dealRequest dr = new dealRequest();
    dr.photosLink = trx.Photo_Link__c;
    dr.address =
      trx.Street_Address__c +
      ', ' +
      trx.City__c +
      ', ' +
      trx.State__c +
      ', ' +
      trx.Zipcode__c;
    dr.description =
      trx.Dispo_Notes__c +
      ', ' +
      trx.Opportunity__r.Comp_1__c +
      ', ' +
      trx.Opportunity__r.Comp_2_Address_Bed_Bath_Sqft__c +
      ', ' +
      trx.Opportunity__r.Comp_3_Address_Bed_Bath_Sqft__c;

    /*if(dr.description==NULL){dr.description='no description';}
        if(dr.address==NULL){dr.address='no address';}
        if(dr.photosLink==NULL){dr.photosLink='https://nophotolink.com';}   */
    dr.price = trx.Contract_Purchase_Price__c;
    dr.externalRef = trx.Id;
    Contactx dc = new Contactx();
    dc.name = trx.Dispositions_Rep__r.Name;
    dc.phone = trx.Dispositions_Rep__r.phone;
    dc.email = trx.Dispositions_Rep__r.email;
    dr.displayContact = dc;
    Contactx nc1 = new Contactx();
    Contactx nc2 = new Contactx();
    Contactx nc3 = new Contactx();
    List<Contactx> ncLst = new List<Contactx>();
    nc1.name = trx.Dispositions_Rep__r.Name;
    nc1.phone = trx.Dispositions_Rep__r.phone;
    nc1.email = trx.Dispositions_Rep__r.email;
    nc2.name = trx.Owner.Name;
    nc2.phone = trx.Owner.phone;
    nc2.email = trx.Owner.email;
    nc3.name = trx.LastModifiedBy.Name;
    nc3.phone = trx.LastModifiedBy.phone;
    nc3.email = trx.LastModifiedBy.email;
    ncLst.add(nc1);
    ncLst.add(nc2);
    ncLst.add(nc3);
    dr.notifyContacts = ncLst;
    return dr;
  }

  public class dealRequest {
    String description;
    Double price;
    String photosLink;
    String address;
    String externalRef;
    String expiresAt;
    Contactx displayContact;
    List<Contactx> notifyContacts;
  }
  public class Contactx {
    String name;
    String phone;
    String email;
    String avatar;
    String company;
  }
  public class configWrapper {
    String crm;
    config config;
  }
  public class config {
    String salesforceOrgID;
  }
}