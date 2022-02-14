global class VPLPushNotification implements vlocity_cmt.VlocityOpenInterface { 
    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
        if (methodName.equals('Notification')){
            Notification(input, outMap, options);
        }
        return true;
    }

    public void Notification(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
        Map<String, Object> entermessage = (Map<String, Object>)input.get('EnterMessage');
        String message = String.valueOf(entermessage.get('Message'));
        Map<String, Object> getuserid = (Map<String, Object>)input.get('TransformIds');
        String userId = String.valueOf(getuserid.get('UserId'));
        String contactId = String.valueOf(getuserid.get('ContactId'));
        Map<String, Object> applePayload =  Messaging.PushNotificationPayload.apple(Message, '', null, null);
        Map<String, Object> androidPayload = new Map<String, Object>();
        androidPayload.put('message', Message);
        Set<String> users = new Set<String>();
        users.add(userId);
        System.debug('userId= ' + userId);
        System.debug('contactId= ' + contactId);
        System.debug('message= ' + Message);
        
        if(contactId != null) {
            vlocity_mobile.VlocityMobileNotification.send(applePayload, androidPayload, users);
            outMap.put('contactId', contactId);
        }
        else {
            vlocity_mobile.VlocityMobileNotification.send(applePayload, androidPayload, users);
            outMap.put('userId', userId);
        }

    }
}