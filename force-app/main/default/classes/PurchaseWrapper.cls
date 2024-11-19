/* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : used in QuickBooksController for QuickBook integration 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           : Tushar Sharma <>
* @modifiedBy       : Tushar Sharma <>
* @modifiedy        : Tushar Sharma <>
* @maintainedBy     : Tushar Sharma <>
* @version          : 1.0
* @created          : 
* @modified         : --
* @systemLayer      :
* @see              : ????
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class PurchaseWrapper {
    
	public QueryResponse QueryResponse;
    public String time1;
	public String status;
	
	public class QueryResponse{
		public list<Purchase> Purchase;
		public Integer maxResults; 
		public Integer startPosition;
		public Integer totalCount;
	}
	
	public class Purchase{
		public AccountRef AccountRef;
		public String PaymentType;
        public EntityRef EntityRef;
		public Boolean Credit;
		public String TotalAmt;
        public String PrintStatus;
		public String domain;
		public Boolean sparse;
		public String Id;
		public String SyncToken;
		public MetaData MetaData;
		public Date TxnDate;
        public CurrencyRef CurrencyRef;
        public String PrivateNote;
        public String DocNumber;
        public List<Line> Line;
	}
	
    public class AccountRef{
         public String value;
         public String name;
    }
    public class EntityRef {
		public String value; 
		public String name; 
		public String type;
    }
	
	public class value{
		public String Value;
		public String Name;
	}
	
	public class MetaData{
		public String LastUpdatedTime;
		public String CreateTime;
	}
	
	public class CurrencyRef{
		public String name;
		public String value;
	}
	
	public class Line{
		public String Id;
		public String Amount;
		public String DetailType;
		public AccountBasedExpenseLineDetail AccountBasedExpenseLineDetail;
	}
	public class AccountBasedExpenseLineDetail{
		public AccountRef AccountRef;
		public String BillableStatus;
        public TaxCodeRef TaxCodeRef;
	}
	public class TaxCodeRef{
		public String value;
	}
    public static PurchaseWrapper parse(String json) {
		return (PurchaseWrapper) System.JSON.deserialize(json, PurchaseWrapper.class);
	}
}