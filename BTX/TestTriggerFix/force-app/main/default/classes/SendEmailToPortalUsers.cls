public class SendEmailToPortalUsers {
    public void sendEmail(SET<Id> TestIds){
        SET<Id> orderCreatedByUserIds = new SET<Id>();
        SET<Id> orderOncIds = new SET<Id>();
        Map<String, String> userIdMap = new Map<String, String>();
        Map<String, String> orderUserMap = new Map<String, String>();
        Map<String, String> orderOncMap = new Map<String, String>();
        Map<String, String> accountContactRelMap = new Map<String, String>();
        Map<String, String> userEMailMap = new Map<String, String>();
        Map<String, String> userContactMap = new Map<String, String>();
        Map<String, String> userContactEmailMap = new Map<String, String>();
        Map<String, String> contactUserMap = new Map<String, String>();
        Map<String, Boolean> userEmailOptMap = new Map<String, Boolean>();
        Map<String, Boolean> testUpdatedMap = new Map<String, Boolean>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        List<String> toAddresses = new List<String>();
        List<String> bccAddresses = new List<String>();
        List<Test__c> testsList = [SELECT Id,
                                            Name,
                                            Oncologist__c,
                                            Oncologist__r.Name,
                                            Oncologist__r.Email,
                                            Orders__c,
                                            Orders__r.CreatedById,
                                   			Orders__r.Oncologist_Facility__c,
                                   			Orders__r.Oncologist__c,
                                            Is_Updated_First_Time__c
                                            FROM Test__c where id IN: TestIds];  
        for(Test__c test : testsList){
            if(test.Orders__r.Oncologist_Facility__c != null){
            	accountIds.add(test.Orders__r.Oncologist_Facility__c);	    
            }
            orderCreatedByUserIds.add(test.Orders__r.CreatedById);
            orderOncIds.add(test.Orders__r.Oncologist__c);
            orderUserMap.put(test.Id, test.Orders__r.CreatedById);
            orderOncMap.put(test.Id, test.Orders__r.Oncologist__c);
            testUpdatedMap.put(test.Id, test.Is_Updated_First_Time__c);
        }
        if(accountIds.size() > 0){
        	List<AccountContactRelation> ACRs = [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE AccountId IN: accountIds];
            for(AccountContactRelation ACR : ACRs){
            	contactIds.add(ACR.ContactId);    
            }
            if(contactIds.size() > 0){
            	List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE Id IN: contactIds AND RecordType.Name = 'Provider Delegate'];
                if(contacts.size() > 0){
                	for(Contact con : contacts){
                        if(con.Email != null && con.Email != ''){
                        	bccAddresses.add(con.Email);    
                        }	
                	}    
                }
            }
        }
        if(orderCreatedByUserIds.size() > 0){
            List<User> users = [SELECT Id, Profile.Name, Email, ContactId, Contact.Email, Email_Opt_Out__c FROM User];  
            if(users.size() > 0){
                for(User usr : users){
                    userIdMap.put(usr.Id, usr.Profile.Name);
                    userEMailMap.put(usr.Id, usr.Email);
                    userContactMap.put(usr.Id, usr.ContactId);
                    contactUserMap.put(usr.ContactId, usr.Id);
                    userContactEmailMap.put(usr.ContactId, usr.Email);
                    userEmailOptMap.put(usr.Id, usr.Email_Opt_Out__c);
                }    
            }
        }
        
        String templateId = [SELECT Id FROM EmailTemplate WHERE Name='BTX Completed Tests Email'].Id;
        String updatedTemplateId = [SELECT Id FROM EmailTemplate WHERE Name='BTX Updated Completed Tests Email'].Id;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        system.debug('templateId -------> '+templateId);
        system.debug('testsList -------> '+testsList);
        Boolean sendEmail = false;
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for(Test__c test : testsList){
            
            if(userIdMap.get(orderUserMap.get(test.Id)) != null){
                //if(userIdMap.get(orderUserMap.get(test.Id)) == 'BTX Ordering Physician Community Plus Login'){
                    //if(userEMailMap.get(orderUserMap.get(test.Id)) != null && !userEmailOptMap.get(orderUserMap.get(test.Id))){
                        //toAddresses.add(userEMailMap.get(orderUserMap.get(test.Id)));    
                    //}   
                //}else if(userIdMap.get(orderUserMap.get(test.Id)) == 'BTX Provider Delegate Community Plus Login'){
                    system.debug('userEMail ------> '+userEMailMap.get(orderUserMap.get(test.Id)));
                    system.debug('user id ------> '+contactUserMap.get(test.Oncologist__c));
                    system.debug('user contact id ------> '+userContactMap.get(contactUserMap.get(test.Oncologist__c)));
                    system.debug('user email ------> '+userContactEmailMap.get(userContactMap.get(contactUserMap.get(test.Oncologist__c))));
                    system.debug('contactEMail ------> '+userContactEmailMap.get(userContactMap.get(contactUserMap.get(test.Oncologist__c))));
                    system.debug('user opt out ------> '+userEmailOptMap.get(orderUserMap.get(test.Id)));
                    system.debug('contact user opt out ------> '+userEmailOptMap.get(contactUserMap.get(test.Oncologist__c)));
                    if(userEMailMap.get(orderUserMap.get(test.Id)) != null && !userEmailOptMap.get(orderUserMap.get(test.Id))){
                        toAddresses.add(userEMailMap.get(orderUserMap.get(test.Id)));    
                    }
                    if(contactUserMap.get(test.Oncologist__c) != null){
                        if(userContactMap.get(contactUserMap.get(test.Oncologist__c)) != null){
                            if(userContactEmailMap.get(userContactMap.get(contactUserMap.get(test.Oncologist__c))) != null && !userEmailOptMap.get(contactUserMap.get(test.Oncologist__c))){
                                toAddresses.add(userContactEmailMap.get(userContactMap.get(contactUserMap.get(test.Oncologist__c))));    
                            }    
                        }    
                    }
                    /*if(userContactEmailMap.get(test.Oncologist__c) != null){
                        toAddresses.add(userContactEmailMap.get(test.Oncologist__c));
                    }*/
                //}
                else{
                    if(userEMailMap.get(orderUserMap.get(test.Id)) != null && !userEmailOptMap.get(orderUserMap.get(test.Id))){
                        toAddresses.add(userEMailMap.get(orderUserMap.get(test.Id)));    
                    }    
                }
            }
            
            system.debug('toAddresses -------> '+toAddresses);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            if(toAddresses.size() > 0 &&
                (userContactEmailMap.get(test.Oncologist__c) != null || userContactMap.get(orderUserMap.get(test.Id)) != null)){
                    if(testUpdatedMap.get(test.Id) == false){
                        email.setTemplateID(templateId);    
                    }else{
                        email.setTemplateID(updatedTemplateId);
                    }
                email.setToAddresses(toAddresses);
                    if(bccAddresses.size() > 0){
                    	email.setBccAddresses(bccAddresses);   
                    }
                    if(test.Oncologist__c != null){
                        email.setTargetObjectId(orderUserMap.get(test.Id));    
                    }else if(userContactMap.get(orderUserMap.get(test.Id)) != null){
                        email.setTargetObjectId(userContactMap.get(orderUserMap.get(test.Id)));    
                    }
                email.setWhatId(test.Id); 
                email.setSaveAsActivity(false);
                mails.add(email);
                sendEmail = true;
            }  
        }
        system.debug('sendEmail --------> '+sendEmail);
        if(sendEmail){
            Savepoint sp = Database.setSavepoint();
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails); 
            Database.rollback(sp);
            
            List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
    
            // loop through the previous message list and set the email fields
            //toAddresses.add('pavan.uddarraju@diligentforcelabs.com');
            for (Messaging.SingleEmailMessage email : mails) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(toAddresses);
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                emailToSend.setFileAttachments(email.getFileAttachments());
                emailToSend.setSaveAsActivity(true);
                actualMessageList.add(emailToSend);
                
                string toAddress= '';
                integer i = 0;
                for(String Str : toAddresses){
                    toAddress += Str;
                    if(toAddresses.size() > i){
                        toAddress += ';';
                    }
                    i++;
                }
                EmailMessage caseEmailMessage = new EmailMessage();
                caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                caseEmailMessage.ToAddress = toAddress;
                caseEmailMessage.FromName = UserInfo.getUserName();
                caseEmailMessage.Subject = email.getSubject();
                caseEmailMessage.HtmlBody = email.getHTMLBody();
                caseEmailMessage.Incoming= False;
                caseEmailMessage.MessageDate = system.now();
                caseEmailMessage.TextBody = email.getHTMLBody().replaceAll('<br/>', '\n');
                caseEmailMessage.status = '5';
                caseEmailMessage.RelatedToId = email.getWhatId();
                emailMessages.add(caseEmailMessage);
            }
            if(toAddresses.size() > 0){
                Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList); 
                system.debug('serList -------> '+serList);
                if(serList.size() > 0){
                    if (serList[0].isSuccess()) {
                        if(emailMessages.size() > 0){
                            insert emailMessages; 
                            for(Test__c test : testsList){
                                test.Is_Updated_First_Time__c = true;    
                            }
                            update testsList;
                        }
                    }
                }
            }
        }
    }
}