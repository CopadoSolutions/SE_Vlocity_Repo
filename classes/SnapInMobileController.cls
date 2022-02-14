public with sharing class SnapInMobileController {
    public String userid{get;set;}
    public String userFirstName{get;set;}
    public String userLastName{get;set;}
    public String emailAddress{get;set;}
    
    public SnapInMobileController(){
        try{
            userid = Userinfo.getUserId();
            if(String.isNotBlank(userid)){
                User userDetail =  [Select Id, FirstName, LastName, Email from user where Id=:userid Limit : (Limits.getLimitQueryRows() - Limits.getQueryRows())];
                if(userDetail!=null){
                    userFirstName = userDetail.FirstName;
                    userLastName = userDetail.LastName;
                    emailAddress = userDetail.Email;       
                }
            }
        }
        catch (Exception ex){
            
        }
    }
}