public with sharing class ATGDemoFunctions implements vlocity_cmt.VlocityOpenInterface, vlocity_cmt.VlocityOpenInterface2{

    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){

       system.debug('In formula methodName: ' + methodName);
    system.debug(':::inputs: ' + input);
        List<Object> arguments = (List<Object>) input.get('arguments');
        if(methodName == 'updateAssetRefId'){
            return updateAssetRefId(input, output, options);
        }
        else if (methodName == 'timestamp_Siebel')
        {
            output.put('result', timeStamp_Siebel(arguments));
        }
        else if (methodName == 'leftChar')
        {
            output.put('result', leftChar(arguments));
        }
        else if (methodName == 'numericPhone')
        {
            output.put('result', numericPhone(arguments));
        }

        return false;
    }

    private Boolean updateAssetRefId (Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        Id accountId;
        if(input.get('accountId') != null){
            accountId = (Id)input.get('accountId');
        }

        List<Asset> lstAsset = [SELECT Id, vlocity_cmt__AssetReferenceId__c FROM Asset WHERE AccountId = :accountId
          AND vlocity_cmt__AssetReferenceId__c = null];
        for(Asset item : lstAsset)
        {
            item.vlocity_cmt__AssetReferenceId__c = item.Id;
        }
system.debug(':::lstAsset: ' + lstAsset);
        update lstAsset;

        return true;
    }

    private string timeStamp_Siebel(List<Object> arguments) {
        //function name: TIMESTAMP_SIEBEL
        Datetime dTime = datetime.now();
        String dTImeStr = dTime.format('MM/dd/yyyy HH:mm:ss', 'America/New_York');
system.debug(':::dTImeStr: ' + dTimeStr);

        return dTimeStr;
    }

    private string leftChar(List<Object> arguments) {
        //function name: LEFTCHAR
system.debug(':::arg0: ' + arguments[0]);

        String charStr = (String)arguments[0];
        if(charStr == null)
        {
            return '';
        }
        Integer len = (Integer)arguments[1];

        if (charStr.length() == len){
            return charStr;
        }
        else{
          //  Integer cutLen = (charstr.length() - len);
            charStr = charStr.left(len);
system.debug(':::charStr: ' + charStr);
            return charStr;
        }
    }

    public String numericPhone(List<Object> arguments){

system.debug(':::arguments[0]: ' + arguments[0]);
        String phoneNumIn = '';
        String phoneNumOut = '';
        String typ = getType(arguments[0]);
        // if SF stores the phone number as just numbers (9153141497 as opposed to (925) 314-1497)
        // when the DR code picks it up, it is a double (9.153141497E9)
        if(typ == 'Double')
        {
            phoneNumIn = String.valueOf(arguments[0]);
            phoneNumIn = phoneNumIn.substringBefore('E');
        }
        else {
            phoneNumIn = (String) arguments[0];
        }
system.debug(':::phoneNumIn:' + phoneNumIn);

        if(phoneNumIn == null)
        // this check so don't get null pointer in next step
        {
            return phoneNumOut;
        }
        for (Integer i = 0; i < phoneNumIn.length(); i++)
        {
             String chr = phoneNumIn.mid(i, 1);
             if (chr.isNumeric() )
             {
                    phoneNumOut += chr;
             }
        }
        return phoneNumOut;
    }

    public static string getType(Object o) {
        String typ;
        
        if(o instanceof SObject){   
    system.debug(':::SObject');        
            typ =  ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        }
        else if(o instanceof String){            
            typ = 'String';
        }
        else if(o instanceof Double) {  
    system.debug(':::Double');        
            typ = 'Double';
        }
        else if(o==null) { 
            typ =  '';              
        }
        return typ;
    }

}