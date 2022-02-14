trigger DE_Quote_SubmitForApproval on Quote(After update)
{

    for (Integer i = 0; i < Trigger.new.size(); i++)
    {
     try       
        {if (Trigger.new[i].Status == 'Needs Review')  submitQuoteForApproval(Trigger.new[i]);}
        catch(Exception e) {Trigger.new[i].addError(e.getMessage());  }
    
    }


  /**  This method will submit the Quote automatically   **/
    public void submitQuoteForApproval(Quote quot)
    {
        // Create an approval request for the Quote
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically.');
        req1.setObjectId(quot.id); 

        // Submit the approval request for the Quote
        Approval.ProcessResult result = Approval.process(req1);
    }
}