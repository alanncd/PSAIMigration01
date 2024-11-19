public class CommonUtils {
 	@InvocableMethod(label='Text to Proper Case')        
	public static List<String> toProperCase(List<String> value) {
        List<String> newValues = new List<String>();
        for(String v:value){
            // Normalize - Convert to lowercase
        	v = v.toLowerCase();
        	// Hold each word
        	List<String> pieces = new List<String>();            
                // Split
        	for(String s : v.split(' ')) {
            	// Capitalize each piece
            	s = s.capitalize();
            	// Add to pieces
            	pieces.add(s);
        	}
            newValues.add(String.join(pieces, ' '));
        }
        // Join
        system.debug('returnJoinreturnJoinreturnJoin'+newValues);
        return newValues;
    }
}