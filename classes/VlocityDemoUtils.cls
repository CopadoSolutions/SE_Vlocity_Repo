global with sharing class VlocityDemoUtils {

    public static void cleanupAbandonedBaskets() {

        List<Account> purgeList = new List<Account>();

        List<Account> accounts = [SELECT Id, Name, RecordType.Name, Type FROM Account];
        Iterator<Account> accIter = accounts.iterator();
        while (accIter.hasNext()) {

            Account acc    = accIter.next();
            String accName = (String)acc.get('Name');
            String accType = (String)acc.get('Type');
            String recType = (String)acc.getSObject('RecordType').get('Name');

            // Digital Commerce Account Names are 10 characters in length
            if (accName.length() == 10 && 
                accType == 'Eligibility Context Account' &&
                recType == 'Billing' &&
                !accName.containsWhitespace()) {

                System.debug(accName);
                purgeList.add(acc);
            }
        }

        // Delete the Accounts
        try {
            delete purgeList;
        }
        catch (DmlException e) {
            System.debug(LoggingLevel.ERROR, 'Error occured while purging abandoned Digital Commerce baskets');
        }
    }
}