({
    
    doInit : function(component, event, helper) { 
        helper.createMap(component, event, helper);
        var isTepper = false;
        var guid = '';
        try{
            var messageId = window.location.search.split("messageId=")[1];
            guid = window.location.search.split("guid=")[1];
            if(!($A.util.isEmpty(messageId))) {
                messageId = messageId.split("&")[0];
                component.set("v.messageId", messageId)
            }
            if(!($A.util.isEmpty(guid))) {
                guid = guid.split("&")[0];
            } 
            console.log('guid before : ' + guid);
            if ($A.util.isEmpty(guid) == false ) {//if guid is available in url
                
                sessionStorage.setItem("guid", guid);
                
            } else {
                if (sessionStorage.getItem("guid") != null) {
                    guid = sessionStorage.getItem("guid");
                }
            }
            console.log('guid after : ' + guid);
        } catch(err) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": 'sticky',
                "type" : "error",
                "title": "",
                "message": "Something went wrong please contact CMU."
            });
            toastEvent.fire();
            var elements = document.getElementsByClassName("prefpage");
            elements[0].style.display = 'none';
            return;
        }          
        
        var action = component.get('c.getAlumniPreference');
        action.setParams({
            "guid" : guid
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){                
                if($A.util.isEmpty(response.getReturnValue().errorMessage)){
                    component.set("v.conId", response.getReturnValue().conId);                    
                    component.set("v.accId", response.getReturnValue().accId);
                    component.set("v.account.Id", response.getReturnValue().accId);
                    component.set("v.email",response.getReturnValue().conEmail);
                    component.set("v.studentPref", response.getReturnValue().studentPerm);
                    component.set("v.recId", response.getReturnValue().prefId);
                    if(response.getReturnValue().isGuest == true) {
                        helper.getMaskedEmail(component, event, helper);
                    }
                    else{
                        component.set("v.emailMasked",response.getReturnValue().conEmail);
                    }
                    if(!($A.util.isEmpty(response.getReturnValue().region1))){
                        //component.find("region1").set("v.value",response.getReturnValue().region1);
                    }
                    if(!($A.util.isEmpty(response.getReturnValue().region2))){
                        //component.find("region2").set("v.value",response.getReturnValue().region2);
                        component.set("v.region2", response.getReturnValue().region2);
                    }
                    if(!($A.util.isEmpty(response.getReturnValue().region3))){
                        //component.find("region3").set("v.value", response.getReturnValue().region3);
                        component.set("v.region3", response.getReturnValue().region3);
                    }
                    
                    if(!($A.util.isEmpty(response.getReturnValue().BillingAddress))){
                        //if(response.getReturnValue().isGuest != true) {
                            component.find("paddress").set("v.street",response.getReturnValue().BillingAddress.street);
                            component.find("paddress").set("v.postalCode",response.getReturnValue().BillingAddress.postalCode);
                        //}
                        component.find("paddress").set("v.city",response.getReturnValue().BillingAddress.city);
                        component.find("paddress").set("v.country",response.getReturnValue().BillingAddress.country);
                        component.find("paddress").set("v.province",response.getReturnValue().BillingAddress.state);
                    }
                    if(!($A.util.isEmpty(response.getReturnValue().preference))){
                        component.find("editForm").set("v.recordId",response.getReturnValue().preference.Id);
                        
                        if(!($A.util.isEmpty(response.getReturnValue().preference.No_Communication__c))){
                            component.set("v.noCommunication", response.getReturnValue().preference.No_Communication__c);
                        }
                        if(!($A.util.isEmpty(response.getReturnValue().preference.No_Solicitations__c))){
                            component.set("v.noSolicitation", response.getReturnValue().preference.No_Solicitations__c);
                        }
                        if(!($A.util.isEmpty(response.getReturnValue().preference.Is_Tepper__c))){
                            component.set("v.tepperPref", response.getReturnValue().preference.Is_Tepper__c);
                            //component.find("tepperField").set("v.value",response.getReturnValue().preference.Is_Tepper__c);
                        }
                        
                        if(!($A.util.isEmpty(response.getReturnValue().isTepper))){
                            isTepper = response.getReturnValue().isTepper;
                            //component.set("v.tepperPref", response.getReturnValue().Is_Tepper__c);
                        }
                        if(!isTepper){
                            //component.find("tepperAccordion").set("v.activeSectionName","B");
                            //var elements1 = document.getElementsByClassName("tepperSchoolsSection");                        
                            //elements1[0].style.display = 'none';
                        }
                    }
                    else{
                        component.find("editForm").set("v.recordId","");
                    }
                    
                    helper.getCountryOptions(component, event, helper);
                    
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "type" : "error",
                        "title": "",
                        "message": response.getReturnValue().errorMessage
                    });
                    toastEvent.fire();
                    var elements = document.getElementsByClassName("prefpage");
                    elements[0].style.display = 'none';
                    return;
                }
                
            }
            else if(state ==='ERROR'){
                
                var msg = JSON.stringify(response.getError());
                if(response.getReturnValue() == null 
                   || response.getReturnValue() == '' 
                   || response.getReturnValue() == 'undefined'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "type" : "error",
                        "title": "",
                        "message": "Error"+msg
                    });
                    toastEvent.fire();
                    var elements = document.getElementsByClassName("prefpage");
                    elements[0].style.display = 'none';                    
                }
            }
        });
        $A.enqueueAction(action); 
        component.set("v.countryOptions", helper.getCountryOptions());
        component.set("v.provinceOptions", helper.getProvinceOptions(component.get("v.country")));
        
    },
    
    handleSubmit : function(component, event, helper) {
        var oldPrefId = component.find("editForm").get("v.recordId");
        
        //component.find("editForm").set("v.recordId",""); // Not in use as not using standard submit
        event.preventDefault();
        var fields = event.getParam('fields');
        
        console.log(JSON.stringify(event.getParams().fields));
        
        event.getParams().fields.Unsubscribe_from_all_email_subscriptions__c = component.find("unsubscribeAll").get("v.value");
        event.getParams().fields.Preferred_Region_2__c = component.find("region2").get("v.value");
        event.getParams().fields.Preferred_Region_3__c = component.find("region3").get("v.value");
        event.getParams().fields.Contact__c = component.get("v.conId");
        
        var action = component.get('c.getClonedRecord');
        action.setParams({
            "conId" : component.get("v.conId"),
            "oldPrefId" : oldPrefId,
            "mp1" : event.getParams().fields
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var tempStr;
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')) {                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "duration" : "3000",
                    "type" : "success",
                    "title": "Success!",
                    "message": "Your Email Preferences are updated successfully"
                });
                toastEvent.fire();
                setInterval(function(){ window.location.reload(); }, 3000);
            }
            else if(state ==='ERROR'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "mode": 'sticky',
                    "type" : "error",
                    "title": "",
                    "message": "Something went wrong please contact CMU."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);               
        //component.find('editForm').submit(fields);
    },
    handleSuccess: function(component, event) {    
        /*var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "duration" : "3000",
            "type" : "success",
            "title": "Success!",
            "message": "Your Email Preferences are updated successfully"
        });
        toastEvent.fire();
        setInterval(function(){ window.location.reload(); }, 3000);*/
    },
    handleError: function(component, event, helper) {
        
        var errors = event.getParams();
        console.log(errors);
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": 'sticky',
            "type" : "error",
            "title": "",
            "message": JSON.stringify(errors)
        });
        toastEvent.fire();
    },
    showNewAddress : function(component, event, helper) {
        debugger;
        var elements = document.getElementsByClassName("newAdd");
        elements[0].style.display = 'block';
    },
    hideNewAddress : function(component, event, helper) { 
        var elements = document.getElementsByClassName("newAdd");
        elements[0].style.display = 'none';
    },
    showNewEmail : function(component, event, helper) { 
        var elements = document.getElementsByClassName("newEmail");
        elements[0].style.display = 'block';
    },
    hideNewEmail : function(component, event, helper) { 
        var elements = document.getElementsByClassName("newEmail");
        elements[0].style.display = 'none';
    },
    handleEmailChange : function(component, event, helper) {
        var conId = component.get("v.conId");
        var accId = component.get("v.accId");
        var oldEmail = component.get("v.email");
        var newEmail = component.find("newEmail").get("v.value");
        
        var validity = component.find("newEmail").get("v.validity");
        if(oldEmail !== newEmail && validity.valid) {
            var action = component.get('c.updateAlumniBio');
            action.setParams({
                "newAddress" : newEmail,
                "oldAddress" : oldEmail,
                "conId" : conId,
                "accId" : accId
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){                
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "duration" : "3000",
                        "type" : "success",
                        "title": "Success!",
                        "message": "Your Request Is submitted successfully"
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action); 
            var elements = document.getElementsByClassName("newEmail");
            elements[0].style.display = 'none';
            var elements = document.getElementsByClassName("oldEmail");
            elements[0].style.display = 'block';
        }       
    },
    handleAddressTypeChange : function(component, event, helper) {
        var radioGroup = component.find("addressRadioGroup").get("v.value");
    },
    handlePrimaryAddressChange : function(component, event, helper) {
        alert('got in address');
        var conId = component.get("v.conId");
        var accId = component.get("v.accId");
        var newStreet = component.find("newAddress").get("v.street");
        var newCity = component.find("newAddress").get("v.city");
        var newProvince  = component.find("newAddress").get("v.province");
        var newCountry = component.find("newAddress").get("v.country");
        var newPostalCode = component.find("newAddress").get("v.postalCode");
        var oldStreet = component.find("paddress").get("v.street");
        var oldCity = component.find("paddress").get("v.city");
        var oldProvince = component.find("paddress").get("v.province");
        var oldCountry = component.find("paddress").get("v.country");
        var oldPostalCode = component.find("paddress").get("v.postalCode");
        var addType = component.find("addressRadioGroup").get("v.value");
        
        var action = component.get('c.updateAlumniAddress');
        action.setParams({
            "conId" : conId,
            "accId" : accId,
            "newStreet":newStreet,
            "newCity":newCity,
            "newProvince":newProvince,
            "newCountry":newCountry,
            "newPostalCode":newPostalCode,
            "oldStreet":oldStreet,
            "oldCity":oldCity,
            "oldProvince":oldProvince,
            "oldCountry":oldCountry,
            "oldPostalCode":oldPostalCode,
            "addType": addType
            
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "duration" : "3000",
                    "type" : "success",
                    "title": "Success!",
                    "message": "Your Request Is submitted successfully"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        var elements = document.getElementsByClassName("newAdd");
        elements[0].style.display = 'none';
        var elements = document.getElementsByClassName("oldAdd");
        elements[0].style.display = 'block';
        
    },
    updateProvinces: function(cmp, event, helper) {
        cmp.set("v.provinceOptions", helper.getProvinceOptions(cmp.get("v.country")));
    },

    updateStudentPreference : function(cmp, event, helper){
        var studpref = cmp.find("studentCheckbox").get("v.value");
        var prefid = cmp.get("v.recId");
        var action = cmp.get('c.updateStudentPref');
        action.setParams({
            "prefId":prefid,
            "pref":studpref

        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(cmp.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "duration" : "3000",
                    "type" : "success",
                    "title": "Success!",
                    "message": "Your email permission has been updated"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
    
})