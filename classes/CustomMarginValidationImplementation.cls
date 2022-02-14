/*
This Custom Margin Validation Implementation checks only the lower margin bound and generates the appropriate message.
Upper margin is ignored. 
*/
global class CustomMarginValidationImplementation implements vlocity_cmt.VlocityOpenInterface
{
    private static String ONE_TIME_MARGIN_PREFIX = 'OneTimeMargin';
    private static String RECURRING_MARGIN_PREFIX = 'RecurringMargin';
    private static String nsp = 'vlocity_cmt__';
    /*
     * invoke method.
     */
    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output,
                                Map<String, Object> options)
    {
        if (methodName.equals('validateMarginRange'))
        {
            validateMarginRange(input, output, options);
            return true;
        }
        return false;
    }
 
    /*
     * validate margin ranges.
     *
     */
    private void validateMarginRange(Map<String, Object> input, Map<String, Object> output,
                                     Map<String, Object> options)
    {
        List<SObject> lineItemList = (List<SObject>) input.get('lineItemList');
        //map, which has margin range details.
        Map<Id, Map<String, Object>> itemIdTomarginRangeMap = (Map<Id, Map<String, Object>>)
                input.get('lineItemIdToMarginRangeMap');
        for (SObject item : lineItemList)
        {
            String oneTimeMarginMessage = null;
            String recurringMarginMessage = null;
            Id lineItemId = (Id) item.get('Id');
            //margin range map also has all output columns of martix.
            Map<String, Object> marginRangeMap = itemIdTomarginRangeMap.get(lineItemId);
            if (marginRangeMap != null)
            {
                Decimal oneTimeMargin = (Decimal) item.get(nsp + 'OneTimeMargin__c');
                Decimal recurringMargin = (Decimal) item.get(nsp + 'RecurringMargin__c');
                Decimal oneTimeMarginLowerBound = (Decimal) marginRangeMap.get('OneTimeMarginLowerBound');
                Decimal oneTimeMarginUpperBound = (Decimal) marginRangeMap.get('OneTimeMarginUpperBound');
                Decimal recurringMarginLowerBound = (Decimal) marginRangeMap.get('RecurringMarginLowerBound');
                Decimal recurringMarginUpperBound = (Decimal) marginRangeMap.get('RecurringMarginUpperBound');
/*
                if (oneTimeMarginLowerBound != null && oneTimeMarginUpperBound != null &&
                        (oneTimeMargin > oneTimeMarginUpperBound || oneTimeMargin < oneTimeMarginLowerBound))
                {
                    oneTimeMarginMessage = ONE_TIME_MARGIN_PREFIX + ':' + 'One time margin must be between ' + oneTimeMarginLowerBound +
                                           ' and ' + oneTimeMarginUpperBound + '.';
*/
                if (oneTimeMarginLowerBound != null && oneTimeMargin < oneTimeMarginLowerBound)
                {
                    oneTimeMarginMessage = ONE_TIME_MARGIN_PREFIX + ':' + 'One time margin must be greater than ' + oneTimeMarginLowerBound + '.';
                }
/*                
                if (recurringMarginLowerBound != null && recurringMarginUpperBound != null &&
                        (recurringMargin > recurringMarginUpperBound || recurringMargin < recurringMarginLowerBound))
                {
                    recurringMarginMessage = RECURRING_MARGIN_PREFIX + ':' + 'Recurring margin must be between ' + recurringMarginLowerBound
                                             + ' and ' + recurringMarginUpperBound + '.';
*/
                if (recurringMarginLowerBound != null && recurringMargin < recurringMarginLowerBound)
                {
                    recurringMarginMessage = RECURRING_MARGIN_PREFIX + ':' + 'Recurring margin must be greater than ' + recurringMarginLowerBound + '.';
                }
            }
 
            //read previous message and update
            String message = (String) item.get(nsp + 'CpqPricingMessage__c');
            List<String> errorList = new List<String>();
            if (String.isNotBlank(message))
            {
                List<String> messageList = message.split('\\|');
                for (String m : messageList)
                {
                    List<String> mList = m.split(':');
                    if (mList.size() > 1)
                    {
                        if (!mList[0].equals(ONE_TIME_MARGIN_PREFIX) &&
                                !mList[0].equals(RECURRING_MARGIN_PREFIX))
                        {
                            errorList.add(m);
                        }
                    }
                }
            }
            if (oneTimeMarginMessage != null)
            {
                errorList.add(oneTimeMarginMessage);
            }
            if (recurringMarginMessage != null)
            {
                errorList.add(recurringMarginMessage);
            }
            //update pricing message.
            if (errorList.isEmpty())
            {
                item.put(nsp + 'CpqPricingMessage__c', null);
            }
            else
            {
                item.put(nsp + 'CpqPricingMessage__c', String.join(errorList, '|'));
            }
        }
    }
}