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
                "message": "Something went wrong.  Please contact CMU."
            });
            toastEvent.fire();
            var elements = document.getElementsByClassName("prefpage");
            elements[0].style.display = 'none';
            return;
        }          
        
        var action = component.get('c.getAllFieldsNew');
        action.setParams({
            "guid" : guid
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){  
                if($A.util.isEmpty(response.getReturnValue().errorMessage)){
                    component.set("v.conId", response.getReturnValue().conId);                    
                    component.set("v.accId", response.getReturnValue().accId);
                    debugger;
                    component.set("v.account.Id", response.getReturnValue().accId);
                    component.set("v.email",response.getReturnValue().conEmail);
                    if(response.getReturnValue().isGuest == true) {
                        helper.getMaskedEmail(component, event, helper);
                    }
                    else{
                        component.set("v.emailMasked",response.getReturnValue().conEmail);
                    }
                    if(!($A.util.isEmpty(response.getReturnValue().preference))){
                        component.set("v.pref",response.getReturnValue().preference);
                    }
                }
            }

        });
        $A.enqueueAction(action);
    },
    
    handleSubmit : function(component, event, helper) {
        debugger; 
        
        var action = component.get('c.updatePrefNew');
        action.setParams({
            "m" : component.get("v.pref")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var tempStr;
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')) {                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "duration" : "5000",
                    "type" : "success",
                    "title": "Success!",
                    "message": "Your Email Preferences have been recorded."
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
                debugger;
                var state = response.getState();
                if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){                
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "duration" : "5000",
                        "type" : "success",
                        "title": "Success!",
                        "message": "Your request to change your preferred email address has been received.  CMU's Bio Records Team will make this change as soon as possible."
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
    
})