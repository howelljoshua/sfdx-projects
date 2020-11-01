/*
 *  Mass Email Generate CSV Search Controller -- supports the MassEmailSearch Visuaforce page
 *  adds additional functionality for generateing and emails a CSV to the user
 * 
 *  Author: Josh Howell  2/5/2019 
 * 
 * Updated 2/5/19 -- to include additional search parameters for Advance ID
 * 
 * Test Coverage -=  MassEmailSearchController_Test -- covers at 87%
 */



public class MassEmailGenerateCSV {
    
    
    public massEmailGenerateCSV(List<Contact> contacts){
        //System.debug('constructor reached');
        //System.debug('contacts list set to: ' + contacts);
        generate(contacts);    
    }
    

    public void generate(List<Contact> contacts) {
        //System.debug('generate method reached');
        String s = line(new String[] {
            
            
                format('Last Name'),
                format('First Name'),
                format('Account'),
                format('Email'),
                format('Advance Id'),
                format('Card Id'), 
                format('Institutional Suffix'),
                format('15 Digit Salesforce Id'),    
                format('18 Digit Salesforce Id') 
                });
        for (Contact c : contacts) {
            s += line(new String[] {
                    format(c.LastName),
                    format(c.FirstName),
                    format(c.Account.Name),
                    format(c.Email),
                    format(c.Contact_External_ID_Clean__c),
                    format(c.Card_ID__c),
                    format(c.Inst_Suffix__c),   
                    format(c.Contact_15_Digit_ID__c),
                    format(c.Contact_18_Digit_ID__c)                
                    });
        }
        //System.debug('your file contents are: ' + s);
        attach(s);
    }
    
    
    public void attach(String textData){ 
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(textData);
        string csvname= 'Contacts_Tartan360_' + system.now() +'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {UserInfo.getUserEmail()}; 
        String subject ='Your Contact List from Tartan 360 Mass Record Search';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Your file: ' + csvname + ' is attached');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});     
    }




    
   
    private String line(String[] cells) {
        return String.join(cells, ',') + '\n';
    }
    private String format(Date d)    {
        return d != null ? '"' + d.format().escapeCsv() + '"' : '""';
    }
    private String format(String s) {
        return s != null ? '"' + s.escapeCsv() + '"' : '""';
    }
    private String format(Decimal d, Integer scale) {
        return d != null ? String.valueOf(d.setScale(scale)) : '';
    }
    private String format(Decimal d) {
        return format(d, 2);
    }
    
    
    

    
    
    
    
    
    
    
}