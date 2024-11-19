public class TwnsqrResponseWrapper {
	public cls_data data;
	public class cls_data {
		public cls_MatchingDemands[] MatchingDemands;
	}
	public class cls_MatchingDemands {
		public cls_args args;
		public boolean success;
        public String error;
		public Integer contacts;	//9159
		public Integer buyBoxes;	//1
	}
	public class cls_args {
		public String address;	//1119 North Euclid Ave Pittsburgh
		public String addressFormatted;	//1119 N Euclid Ave, Pittsburgh, PA 15206, USA
        public String idempotencyKey;
	}
}