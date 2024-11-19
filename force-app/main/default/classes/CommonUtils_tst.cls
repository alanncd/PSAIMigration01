@isTest
public class CommonUtils_tst {
    @isTest static void test_method_UpperCase(){
        List<String> texto = new List<String>();
        texto.add('some test to test');
        List<String> lsts = CommonUtils.toProperCase(texto);
        system.assertEquals(lsts[0],'Some Test To Test');
    }
}