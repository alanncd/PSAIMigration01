/* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : used in GetVendorsBatch for QuickBook integration 
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
public class QuickBookResponseWrapper {
    public class venderWrap{
        public QueryResponse QueryResponse;
		public String time1;	//2020-10-20T14:08:34.940-07:00
        public Integer statusCode;
    }
    public class WebAddr{
		public String URI;
	}
	public class Vendor{
		public MetaData MetaData;
		public String CompanyName;
		public String Suffix;
		public String DisplayName;
		public String FamilyName;
		public String PrintOnCheckName;
		public String GivenName;
		public Boolean Active;
		public String Title;
		public String Id;
		public String SyncToken;
		public Boolean sparse;
		public PrimaryPhone PrimaryPhone;
		public String domain;
		public Mobile Mobile;
		public CurrencyRef CurrencyRef;
		public PrimaryEmailAddr PrimaryEmailAddr;
		public Boolean Vendor1099;
		public WebAddr WebAddr;
		public String AcctNum;
		public String TaxIdentifier;
		public String Balance;
		public BillAddr BillAddr;
	}
	public class QueryResponse{
		public list<Vendor> Vendor;
		public Integer maxResults;
		public Integer startPosition;
	}
	public class PrimaryPhone{
		public String FreeFormNumber;
	}
	public class PrimaryEmailAddr{
		public String Address;
	}
	public class Mobile{
		public String FreeFormNumber;
	}
	public class MetaData{
		public String LastUpdatedTime;
		public String CreateTime;
	}
	public class CurrencyRef{
		public String name;
		public String value;
	}
	public class BillAddr{
		public String CountrySubDivisionCode;
		public String Line3;
		public String City;
		public String Line2;
		public String Country;
		public String Line1;
		public String PostalCode;
		public String Id;
	}
    public static QuickBookResponseWrapper parse(String json) {
		return (QuickBookResponseWrapper) System.JSON.deserialize(json, QuickBookResponseWrapper.class);
	}
}