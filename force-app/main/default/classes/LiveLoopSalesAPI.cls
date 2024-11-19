@RestResource(urlMapping='/sales/*')
global with sharing class LiveLoopSalesAPI{
    
    @HTTPPost
    global static void soldProperty() {
        RestResponse res = RestContext.response;
        RestRequest request = RestContext.request;
        // String accessToken = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        List<SalesIdAndPipelineLiveloopConnectIdWrapper> lstOfSalesIdAndPipelineLiveloopConnectId = new List<SalesIdAndPipelineLiveloopConnectIdWrapper>(); // Newly Added
        
        Map<String, String> header = request.headers;
        
        if(header.get('token') == System.Label.Access_Token){
            system.debug('Access Token Match Found@@@');
            String requestBody = request.requestBody.toString();
            List<LiveLoopResponeWrapper> liveLoopResponeWrapperList=LiveLoopResponeWrapper.parse(requestBody);            
            
            list<buyer__c> newBuyerList = new list<buyer__c>();
            list<sale__c> newSaleList = new list<sale__c>();
            list<buyer__c> buyerListToUpdate = new list<buyer__c>();
            list<sale__c> saleListToUpdate = new list<sale__c>();
            
            List<String> buyerIdList=new List<String>();
            List<String> salesIdList=new List<String>();
            for(LiveLoopResponeWrapper resWraper:liveLoopResponeWrapperList){
                buyerIdList.add(resWraper.buyer.buyer_id);
                salesIdList.add(resWraper.sale_id);
            }
            
            list<buyer__c> existingBuyerList = [select id,Buyer_Id__c from buyer__c where Buyer_Id__c in :buyerIdList WITH USER_MODE];
            list<sale__c> existingSaleList = [select id,Sale_Id__c from sale__c where Sale_Id__c in :salesIdList WITH USER_MODE];
            //Commented on 15th December #1
            // Map<String,Set<Id>> buyerMap=new Map<String,Set<Id>>();
            //Commented on 15th December #1  - end
            
            Map<String,Id> buyerMap=new Map<String,Id>();
            Map<String,Set<Id>> salesMap=new Map<String,Set<Id>>();
            Set<Id> idsSet = new Set<Id>();

            for(buyer__c existingBuyer: existingBuyerList){
                buyerMap.put(existingBuyer.Buyer_Id__c, existingBuyer.id);
            }
            
            for(sale__c existingSale: existingSaleList){
                if(salesMap.containskey(existingSale.Sale_Id__c)){
                    salesMap.get(existingSale.Sale_Id__c).add(existingSale.id);
                }else{
                    salesMap.put(existingSale.Sale_Id__c, new Set<Id>{existingSale.id});
                }
            }
            
            for(LiveLoopResponeWrapper resWraper:liveLoopResponeWrapperList){
                Map<Id, String> idsMap = new Map<Id, String>();
                Map<String, String> idsMap1 = new Map<String, String>();
                if(null != resWraper.pipeline_objects_connected) // 30th Dec 2021
                {
                    for(LiveLoopResponeWrapper.pipelineObjectsConnected pipelineObjectsConnected: resWraper.pipeline_objects_connected){
                        idsMap.put(pipelineObjectsConnected.pipeline_object_id, pipelineObjectsConnected.pipeline_object_type);
                        //  idsMap1.put(LiveLoopResponeWrapper.pipeline_liveloop_connect_id, LiveLoopResponeWrapper.original_buyer_id); // Demo
                    }
                    /*   for(LiveLoopResponeWrapper resWraper1:liveLoopResponeWrapperList){
							idsMap1.put(resWraper1.previous_seller, resWraper1.pipeline_liveloop_connect_id); // Demo
					} */
                    
                } 
                for(Id i: idsMap.keySet()){
                    Buyer__c buyer = buyerRecordValues(resWraper);
                    if(idsMap.get(i) == 'Lead'){
                        buyer.Lead__c=i;
                    }
                    if(idsMap.get(i) == 'Opportunity'){
                        buyer.Opportunity__c=i;
                    }        

                    if(null !=buyerMap.get(resWraper.buyer.buyer_id)){
                        buyer.Id = buyerMap.get(resWraper.buyer.buyer_id);
                        buyerListToUpdate.add(buyer);
                    }else{
                        newBuyerList.add(buyer);
                    }
                    system.debug('buyer@@'+buyer.Id);
                    
                    SalesIdAndPipelineLiveloopConnectIdWrapper wrapperObj = new SalesIdAndPipelineLiveloopConnectIdWrapper();
                    if(!String.isEmpty(resWraper.pipeline_liveloop_connect_id)) // 30th Dec 2021
                    {
                        wrapperObj.sale_id = resWraper.sale_id;
                        wrapperObj.pipeline_liveloop_connect_id = resWraper.pipeline_liveloop_connect_id;
                        lstOfSalesIdAndPipelineLiveloopConnectId.add(wrapperObj);
                    }
                    
                    
                    Sale__c sale = saleRecordValues(resWraper);
                    if(idsMap.get(i) == 'Lead'){
                        sale.Lead__c=i;
                    }
                    if(idsMap.get(i) == 'Opportunity'){
                        sale.Opportunity__c=i;
                    }
                    //list<sale__c>existingSale = [select id from sale__c where Sale_Id__c =:resWraper.sale_id];
                    //if(existingSale.size()>0)
                    //    sale.Id = existingSale[0].Id;
                    if(salesMap.containsKey(resWraper.sale_id)){
                        system.debug('salesMap@@@'+salesMap);
                        system.debug('salesMap@@@'+salesMap.get(resWraper.sale_id));
                        for(Id ii : salesMap.get(resWraper.sale_id)){
                            if(idsSet.contains(ii)){
                                continue; 
                            }
                            sale.Id = ii;
                            saleListToUpdate.add(sale);
                            wrapperObj.sale_id = resWraper.sale_id;
                            wrapperObj.pipeline_liveloop_connect_id = ii;
                            lstOfSalesIdAndPipelineLiveloopConnectId.add(wrapperObj);
                            idsSet.add(ii);
                            break;
                        }
                        system.debug('saleListToUpdate>>'+saleListToUpdate);
                    }else{
                        newSaleList.add(sale);
                    }
                    //upsert sale;
                    system.debug('buyer@@@'+buyer.Id);
                    system.debug('sale@@@'+sale.Id);
                }
                system.debug('idsMap.keySet()>>'+idsMap.keySet());
                if(idsMap.keySet().isEmpty()){
                    system.debug('idsMap.keySet1()>>'+idsMap.keySet());
                    Buyer__c buyer = buyerRecordValues(resWraper);
                    if(null !=buyerMap.get(resWraper.buyer.buyer_id)){
                        buyer.Id = buyerMap.get(resWraper.buyer.buyer_id);
                        buyerListToUpdate.add(buyer);
                    }else{
                        newBuyerList.add(buyer);
                    }
                    SalesIdAndPipelineLiveloopConnectIdWrapper wrapperObj = new SalesIdAndPipelineLiveloopConnectIdWrapper();
                    if(!String.isEmpty(resWraper.pipeline_liveloop_connect_id)) // 30th Dec 2021
                    {
                        wrapperObj.sale_id = resWraper.sale_id;
                        wrapperObj.pipeline_liveloop_connect_id = resWraper.pipeline_liveloop_connect_id;
                        lstOfSalesIdAndPipelineLiveloopConnectId.add(wrapperObj);
                    }
                    Sale__c sale = saleRecordValues(resWraper);
                    if(null !=salesMap.get(resWraper.sale_id)){
                        for(Id ii : salesMap.get(resWraper.sale_id)){
                            sale.Id = ii;
                            saleListToUpdate.add(sale);
                            wrapperObj.sale_id = resWraper.sale_id;
                            wrapperObj.pipeline_liveloop_connect_id = ii;
                            lstOfSalesIdAndPipelineLiveloopConnectId.add(wrapperObj);
                        }
                        
                    }else{
                        newSaleList.add(sale);
                    }
                }
            
            }
            
            
            
            
            if(newBuyerList.size()>0){
                LeftMain_SecurityUtils.checkInsert(Buyer__c.SObjectType,new List<String> {
                    'Address__c',
                     'Buyer_Name__c',
                     'Buyer_Id__c',
                     'Buyer_Lender__c',
                     'cbsa_entries__c',
                     'cbsa_exits__c',
                     'lead__c',
                    'opportunity__c',
                    'cbsa_median_enter_discount__c',
                    'cbsa_median_exit_discount__c',
                    'cbsa_median_enter_sale_price__c',
                    'cbsa_median_exit_sale_price__c',
                    'cbsa_median_enter_tax_improvement_percen__c',
                    'cbsa_median_enter_tax_improvment_value__c',
                    'cbsa_median_enter_loo__c',
                    'cbsa_median_exit_loo__c',
                    'cbsa_median_square_footage__c',
                    'cbsa_median_year_built__c',
                    'national_entries__c',
                    'buyer_national_exits__c'
                });

                SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, newBuyerList);
                Database.insert(newBuyerList = decision3.getRecords());
            }
                            
            map<id,buyer__c> buyerMapToUpsert = new map<id,buyer__c>();
            
            //put all the values from the list to map. 
            buyerMapToUpsert.putall(buyerListToUpdate);
            if(buyerMapToUpsert.size()>0){
                LeftMain_SecurityUtils.checkUpdate(buyer__c.SObjectType,new List<String> {'Opportunity__c','Buyer_Id__c','Buyer_Lender__c','cbsa_entries__c','cbsa_exits__c','cbsa_median_enter_discount__c','cbsa_median_exit_discount__c','cbsa_median_enter_sale_price__c','cbsa_median_exit_sale_price__c','cbsa_median_enter_tax_improvement_percen__c','cbsa_median_enter_tax_improvment_value__c','cbsa_median_enter_loo__c','cbsa_median_exit_loo__c','cbsa_median_square_footage__c','cbsa_median_year_built__c','national_entries__c','buyer_national_exits__c'});
                LeftMain_SecurityUtils.checkInsert(Buyer__c.SObjectType,new List<String> {
                    'Address__c',
                     'Buyer_Name__c',
                     'Buyer_Id__c',
                     'Buyer_Lender__c',
                     'cbsa_entries__c',
                     'cbsa_exits__c',
                     'lead__c',
                    'opportunity__c',
                    'cbsa_median_enter_discount__c',
                    'cbsa_median_exit_discount__c',
                    'cbsa_median_enter_sale_price__c',
                    'cbsa_median_exit_sale_price__c',
                    'cbsa_median_enter_tax_improvement_percen__c',
                    'cbsa_median_enter_tax_improvment_value__c',
                    'cbsa_median_enter_loo__c',
                    'cbsa_median_exit_loo__c',
                    'cbsa_median_square_footage__c',
                    'cbsa_median_year_built__c',
                    'national_entries__c',
                    'buyer_national_exits__c'
                });
                List<buyer__c> listBuyers = new List<buyer__c>();
                listBuyers = buyerMapToUpsert.values();

                SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listBuyers);
                Database.upsert(listBuyers = decision3.getRecords());
            }
            if(newSaleList.size()>0){
                //Creating Buyer ID map to map buyer to sale
                list<buyer__c> buyerList = [select id,Buyer_Id__c from buyer__c where Buyer_Id__c in :buyerIdList WITH USER_MODE LIMIT 10000];
                Map<String,Id> buyerIdMap=new Map<String,Id>();
                
                for(buyer__c buyer: buyerList){
                    buyerMap.put(buyer.Buyer_Id__c, buyer.id);
                }
                
                for(sale__c sale:newSaleList){
                    sale.Buyer__c=buyerMap.get(sale.Buyer_Id__c);
                }
                
                LeftMain_SecurityUtils.checkInsert(sale__c.SObjectType,new List<String> {
                    'lead__c',
                     'opportunity__c',
                     'Pipeline_Live_Loop_Connect_Id__c',
                     'Sale_Id__c',
                     'seller__c',
                     'Buyer_owner_occupied__c',
                     'Property_Address__c',
                    'recording_date__c',
                    'sale_price__c',
                    'Estimated_Value_Low__c',
                    'Estimated_Value__c',
                    'Estimated_value_high__c',
                    'Tax_assessed_value__c',
                    'Discount__c',
                    'Property_Type__c',
                    'Previous_seller__c',
                    'Previous_recording_date__c',
                    'Previous_sale_price__c',
                    'Buyer_id__c',
                    'Status__c'
                });

                SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, newSaleList);
                Database.insert(newSaleList = decision3.getRecords());

                for(Sale__c saleTemp : newSaleList){
                    SalesIdAndPipelineLiveloopConnectIdWrapper wrapperObj = new SalesIdAndPipelineLiveloopConnectIdWrapper();
                    wrapperObj.sale_id = saleTemp.Sale_Id__c;
                    wrapperObj.pipeline_liveloop_connect_id = saleTemp.Id;
                    lstOfSalesIdAndPipelineLiveloopConnectId.add(wrapperObj);
                }
            }
            map<id,sale__c> sellerMapToUpsert = new map<id,sale__c>();
            //put all the values from the list to map. 
            sellerMapToUpsert.putall(saleListToUpdate);
            if(sellerMapToUpsert.size()>0){
                LeftMain_SecurityUtils.checkUpdate(sale__c.SObjectType,new List<String> {
                    'lead__c',
                     'opportunity__c',
                     'Pipeline_Live_Loop_Connect_Id__c',
                     'Sale_Id__c',
                     'seller__c',
                     'Buyer_owner_occupied__c',
                     'Property_Address__c',
                    'recording_date__c',
                    'sale_price__c',
                    'Estimated_Value_Low__c',
                    'Estimated_Value__c',
                    'Estimated_value_high__c',
                    'Tax_assessed_value__c',
                    'Discount__c',
                    'Property_Type__c',
                    'Previous_seller__c',
                    'Previous_recording_date__c',
                    'Previous_sale_price__c',
                    'Buyer_id__c',
                    'Status__c'
                });
                LeftMain_SecurityUtils.checkInsert(sale__c.SObjectType,new List<String> {
                    'lead__c',
                     'opportunity__c',
                     'Pipeline_Live_Loop_Connect_Id__c',
                     'Sale_Id__c',
                     'seller__c',
                     'Buyer_owner_occupied__c',
                     'Property_Address__c',
                    'recording_date__c',
                    'sale_price__c',
                    'Estimated_Value_Low__c',
                    'Estimated_Value__c',
                    'Estimated_value_high__c',
                    'Tax_assessed_value__c',
                    'Discount__c',
                    'Property_Type__c',
                    'Previous_seller__c',
                    'Previous_recording_date__c',
                    'Previous_sale_price__c',
                    'Buyer_id__c',
                    'Status__c'
                });
                List<sale__c> salesList = new List<sale__c>();
                salesList = sellerMapToUpsert.values();
                SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.CREATABLE, salesList);
                Database.upsert(salesList = decision2.getRecords());

            }   
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(lstOfSalesIdAndPipelineLiveloopConnectId));
        }else{
            res.statusCode = 401;
            res.responseBody = Blob.valueOf('Invalid Access token');
        }
        
        
    } 
    
    public static Buyer__c buyerRecordValues(LiveLoopResponeWrapper resWraper){
        Buyer__c buyer = new buyer__c();
        if(null !=resWraper.buyer){
            buyer.Buyer_Name__c= resWraper.buyer.buyer_name;
            buyer.Buyer_Id__c=resWraper.Buyer.buyer_id;
            buyer.Buyer_Lender__c=resWraper.buyer.buyer_lender;
            buyer.cbsa_entries__c = resWraper.buyer.buyer_cbsa_entries;
            buyer.cbsa_exits__c = resWraper.buyer.buyer_cbsa_exits;
            buyer.cbsa_median_enter_discount__c= resWraper.buyer.buyer_cbsa_median_enter_discount;
            buyer.cbsa_median_exit_discount__c = resWraper.buyer.buyer_cbsa_median_exit_discount;
            buyer.cbsa_median_enter_sale_price__c = resWraper.buyer.buyer_cbsa_median_enter_sale_price;
            buyer.cbsa_median_exit_sale_price__c = resWraper.buyer.buyer_cbsa_median_exit_sale_price;
            buyer.cbsa_median_enter_tax_improvement_percen__c = resWraper.buyer.buyer_cbsa_median_enter_tax_improvement_percent;
            buyer.cbsa_median_enter_tax_improvment_value__c =resWraper.buyer.buyer_cbsa_median_enter_tax_improvement_value;
            buyer.cbsa_median_enter_loo__c = resWraper.buyer.buyer_cbsa_median_enter_loo;
            buyer.cbsa_median_exit_loo__c = resWraper.buyer.buyer_cbsa_median_exit_loo;
            buyer.cbsa_median_square_footage__c = resWraper.buyer.buyer_cbsa_median_square_footage;
            buyer.cbsa_median_year_built__c = resWraper.buyer.buyer_cbsa_median_year_built;
            buyer.national_entries__c = resWraper.Buyer.buyer_national_entries;
            buyer.buyer_national_exits__c = resWraper.Buyer.buyer_national_exits;
        }
        if(null !=resWraper.buyer_mailing_address){
            buyer.Address__c = resWraper.buyer_mailing_address.street_address_line_1 +', '+  resWraper.buyer_mailing_address.street_address_line_2 +', '+  resWraper.buyer_mailing_address.city +', '+  resWraper.buyer_mailing_address.state +', '+  resWraper.buyer_mailing_address.zipCode;
        }
        return buyer;
    }
    public static Sale__c saleRecordValues(LiveLoopResponeWrapper resWraper){
        Sale__c sale = new sale__c();
        sale.Pipeline_Live_Loop_Connect_Id__c=resWraper.pipeline_liveloop_connect_id;
        sale.Sale_Id__c = resWraper.sale_id;
        sale.seller__c =  resWraper.seller;
        sale.Buyer_owner_occupied__c = null != resWraper.buyer_owner_occupied&& resWraper.buyer_owner_occupied == 1 ? true:false;
        if(null != resWraper.property_address){
            sale.Property_Address__c = resWraper.property_address.street_address_line_1 +', '+  resWraper.property_address.street_address_line_2 +', '+  resWraper.property_address.city +', '+  resWraper.property_address.state +', '+  resWraper.property_address.zipCode;
        }
        sale.recording_date__c = resWraper.recording_date;
        sale.sale_price__c = resWraper.sale_price;
        sale.Estimated_Value_Low__c = resWraper.estimated_value_low;
        sale.Estimated_Value__c = resWraper.estimated_value;
        sale.Estimated_value_high__c = resWraper.estimated_value_high;
        sale.Tax_assessed_value__c = resWraper.tax_assessed_value;
        sale.Discount__c = resWraper.discount;
        sale.Property_Type__c = resWraper.property_type;
        sale.Previous_seller__c = resWraper.previous_seller;
        if(null != resWraper.previous_seller_mail_address){
            sale.Previous_seller_mail_address__c = resWraper.previous_seller_mail_address.street_address_line_1 +', '+  resWraper.previous_seller_mail_address.street_address_line_2 +', '+  resWraper.previous_seller_mail_address.city +', '+  resWraper.previous_seller_mail_address.state +', '+  resWraper.previous_seller_mail_address.zipCode;
        }
        sale.Previous_recording_date__c = resWraper.previous_recording_date;
        sale.Previous_sale_price__c= resWraper.previous_sale_price;
        sale.Buyer_id__c = resWraper.buyer.buyer_id;
        sale.Status__c='Sold';
        
        return sale;
    }
    class SalesIdAndPipelineLiveloopConnectIdWrapper{
        public String sale_id;
        public String pipeline_liveloop_connect_id;
    }
}