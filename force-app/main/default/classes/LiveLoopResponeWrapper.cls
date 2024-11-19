public class LiveLoopResponeWrapper {
    
    public class pipelineObjectsConnected{
        public string pipeline_object_type;
        public string pipeline_object_id;
    }
    
    public class address{
        public String street_address_line_1;
        public String street_address_line_2;
        public String city;
        public String state;
        public String zipcode; 
    }
    
    public class Buyer {
        public String buyer_name;
        public String buyer_id;
        public String buyer_lender;
        public Integer buyer_cbsa_entries;
        public Integer buyer_cbsa_exits;
        public Double buyer_cbsa_median_enter_discount;
        public Double buyer_cbsa_median_exit_discount;
        public Double buyer_cbsa_median_enter_sale_price;
        public Double buyer_cbsa_median_exit_sale_price;
        public Double buyer_cbsa_median_enter_tax_improvement_percent;
        public Double buyer_cbsa_median_enter_tax_improvement_value;
        public Double buyer_cbsa_median_enter_loo;
        public Double buyer_cbsa_median_exit_loo;
        public Double buyer_cbsa_median_square_footage;
        public Double buyer_cbsa_median_year_built;
        public Integer buyer_national_entries;
        public Integer buyer_national_exits;
        
 
    }
    
    public List<pipelineObjectsConnected> pipeline_objects_connected;
    public String pipeline_liveloop_connect_id;
    public String sale_id;
    public String seller;
    public Integer buyer_owner_occupied;
    public address property_address;
    public String recording_date;
    public Double sale_price;
    public Double estimated_value_low;
	public Double estimated_value;
	public Double estimated_value_high;
    public Double tax_assessed_value;
	public Double discount;
	public String property_type;
	public String previous_seller;
	public address previous_seller_mail_address;
	public String previous_recording_date;
	public Double previous_sale_price;
    
    public address buyer_mailing_address;
    public Buyer buyer;
    
   
    public static List<LiveLoopResponeWrapper> parse(String json) {
        //		return (LiveLoopResponeWrapper) System.JSON.deserialize(json, LiveLoopResponeWrapper.class);
        return (List<LiveLoopResponeWrapper>) System.JSON.deserialize(json, List<LiveLoopResponeWrapper>.class);

	}
    

    
}