/* ********************************************************
 * (c) 2018 Appirio - A Wipro Company, Inc
 * Name: ContactHandler.cls
 * Description: Handler class for ContactTrigger
 * Created Date: Oct 08, 2018
 * Created By: Deepanshu Soni
 * Date Modified      Modified By       Description of the update
 * 
******************************************************** */
public without sharing class ContactHandler {
    
    
    /**
     * Method Name : followContact
     * Arguments: List<Contact>
     * Return : void    
     * Description: follow(Contact) the Contact record
    **/
    
    
    /*
    public void followContact(List<Contact> conList) {
        if (conList == null || conList.isEmpty()) {
            return;
        }
        else if (UserInfo.getUserType() != 'Standard' || CMU_Util.isRunningJob() || CMU_Util.isSystemUser()) {
            return;
        }
        else {
            for (Contact con: conList) {
                if (!Test.isRunningTest()) {
                    //ConnectApi.ChatterUsers.follow(null, con.OwnerId, con.Id);
                }
            }
        }
        
    }
    */

    public void followContact(List<Contact> conList) {
      if (conList == null || conList.isEmpty()) {
          return;
      }

      else if ( UserInfo.getUserType() != 'Standard' || CMU_Util.isRunningJob() || CMU_Util.isSystemUser() ) {
          return;
      } 
  }    










    public void createMarketingPreference(List<Contact> conList){
      if (!Test.isRunningTest()) {
        List<Marketing_Preference__c> mpInsert = new List<Marketing_Preference__c>();
        for(Contact c : conList){
          Marketing_Preference__c mp = new Marketing_Preference__c();
          mp.Contact__c = c.Id;
          mp.Active__c = true;
          if(c.AQB__DoNotContact__c){
            mp.No_Communication__c = true;
            mpInsert.add(mp);
          }
          else if(c.AQB__DoNotSolicit__c){
            mp.No_Solicitations__c = true;
            mpInsert.add(mp);
          }
          else{
          system.debug('ACCOUNT RECORD TYPE-> ' + c.Account.RecordType.Name + ' Account rt Id -> ' + c.Account.RecordTypeId);
            if(c.Account.RecordType.Name == 'Organization' || c.Account.RecordType.Name == 'Corporation'){
              mp.No_Solicitations__c = true;
              mp.Unsubscribe_from_all_email_subscriptions__c = true;
              mpInsert.add(mp);
            }
            else{
              mp.Carnegie_Mellon_News__c = true;
            mp.Research_News__c = true;
            mp.Alumni_Association_News__c = true;
            mp.Parents_and_Families_News__c = true;
            mp.Reunion__c = true;
            mp.Lifelong_Learning__c = true;
            mp.Events__c = true;
            mp.Professional_Career_Development__c = true;
            mp.Supporting_CMU__c = true;
            mp.Regional_Network_Emails__c = true;
              if(c.AQB__Type__c == 'Past Parent' || c.AQB__Type__c == 'Parent'){
                mp.Reunion__c = false;
                mpInsert.add(mp);
              }
              else if(c.AQB__Type__c == 'Student' || c.AQB__Type__c == 'Alumni'){
                mp.Parents_and_Families_News__c = false;
                mpInsert.add(mp);
              }
              else{
                mp.Parents_and_Families_News__c = false;
                mp.Reunion__c = false;    
                mpInsert.add(mp);
              }
            }
          }
        }
        insert mpInsert;
      }
    }










    

  public void primarySchoolCheck(List<Contact> conList, Map<Id,Contact> mOld) {
    List<Contact> cList = new List<Contact>();
    List<Contact> cList2 = new List<Contact>();
    List<Marketing_Preference__c> mpUpdate = new List<Marketing_Preference__c>();
    for (Contact c : conList) {
      system.debug('new ed link -> ' + c.AQB__EducationLink__c + ' old ed link -> ' + mOld.get(c.Id).AQB__EducationLink__c + ' edlink -> ' + c.AQB__EducationLink__r.Primary_School__c + ' old edlink -> ' + mOld.get(c.Id).AQB__EducationLink__r.AQB__School__c + ' Primary School -> ' + c.Primary_School__c);
      if (c.AQB__EducationLink__c != mOld.get(c.Id).AQB__EducationLink__c && c.Primary_School__c  == 'Tepper School of Business' && c.AQB__DoNotSolicit__c == false && c.AQB__DoNotContact__c == false) {
        system.debug('GOT IN HERE');
        cList.add(c);
      }
      else if (c.AQB__EducationLink__c != mOld.get(c.Id).AQB__EducationLink__c && c.Primary_School__c  != 'Tepper School of Business' && c.AQB__DoNotSolicit__c == false && c.AQB__DoNotContact__c == false) {
        system.debug('GOT IN HERE2');
        cList2.add(c);
      }
    }

    if(!cList.isEmpty()){
      List<Marketing_Preference__c> mpList = [SELECT Id, Supporting_Tepper__c, Tepper_Events__c, Tepper_Lifelong_Learning__c, Tepper_Magazine__c, Is_Tepper__c, Tepper_Regional_Chapter_Emails__c, Tepper_Reunion__c, Tepper_School_News__c from Marketing_Preference__c where Contact__c IN :cList AND Active__c = true];
      if(!mpList.isEmpty()){
        for(Marketing_Preference__c mp : mpList){
          mp.Supporting_Tepper__c = true;
          mp.Tepper_Events__c = true;
          mp.Tepper_Lifelong_Learning__c = true;
          mp.Tepper_Magazine__c = true;
          mp.Is_Tepper__c = true;
          mp.Tepper_Regional_Chapter_Emails__c = true;
          mp.Tepper_Reunion__c = true;
          mp.Tepper_School_News__c = true;
          mpUpdate.add(mp);
        }
      }
    }
    if(!cList2.isEmpty()){
      List<Marketing_Preference__c> mpList2 = [SELECT Id, Supporting_Tepper__c, Tepper_Events__c, Tepper_Lifelong_Learning__c, Tepper_Magazine__c, Is_Tepper__c, Tepper_Regional_Chapter_Emails__c, Tepper_Reunion__c, Tepper_School_News__c from Marketing_Preference__c where Contact__c IN :cList2 AND Active__c = true];
      if(!mpList2.isEmpty()){
        for(Marketing_Preference__c mp : mpList2){
          mp.Supporting_Tepper__c = false;
          mp.Tepper_Events__c = false;
          mp.Tepper_Lifelong_Learning__c = false;
          mp.Tepper_Magazine__c = false;
          mp.Is_Tepper__c = false;
          mp.Tepper_Regional_Chapter_Emails__c = false;
          mp.Tepper_Reunion__c = false;
          mp.Tepper_School_News__c = false;
          mpUpdate.add(mp);
        }
      }
    }
    if(!mpUpdate.isEmpty()){
      update mpUpdate;
    }
  }
    
    /**
     * Method Name : updateGUID for Contacts
     * Arguments: List<Contact>
     * Return : void    
     * Description: GUID(Contact) the Contact record
    **/
    public void updateGUID(List<Contact> conList) {
        if (conList != null) {
            for(Contact con: conList) {
                if (con.Public_GUID__c == null) {
                    con.Public_GUID__c = GUIDHelper.generateGUID();
                }
            }
        }
        
    }
    
}