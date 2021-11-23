/**
 * RA , 28/07/2021
 * @description Controller class for HMACLeadTokenManger VisualForce Page
*/
public class HMACLeadTokenManager {
      public List<Lead> selLeadLst;
      public Set<String> setOfldIds;

      
      /**
     	* @description constructor
		*/
      public HMACLeadTokenManager(ApexPages.StandardSetController cntlr){
		//get selected records from Lead list view
          selLeadLst = cntlr.getSelected(); 
          setOfldIds = new Set<String>();
          for(Lead ld : selLeadLst){
              setOfldIds.add(ld.Id);                      
          }
         
      }
    
    /**
     * @description method to create token on leads
	*/
    public PageReference redirectToOrg(){
        List<Lead> ldList;
        if(setOfldIds.size() > 0){
            ldList = new List<Lead>([Select Company, email, Unique_Chewy_ID__c from Lead where id=:setOfldIds]);
            if(ldList != null && ldList.size() > 0){
                HMACTokenManager.generateTokens(ldList);
            }
        }
        String returnUrl = '/lightning/o/Lead/list?filterName=Recent';
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }


  }