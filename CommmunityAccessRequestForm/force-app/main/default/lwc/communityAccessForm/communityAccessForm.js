import { LightningElement, api, track} from 'lwc';
//import {refreshApex} from '@salesforce/apex';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASEID_FIELD from '@salesforce/schema/Case.Id';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';


export default class CommunityAccessForm extends LightningElement {
    // The record page provides recordId and objectApiName
    @api recordId;  
    @api objectApiName;
    @track hasId = false;


    case = CASE_OBJECT;
    fields = [CASEID_FIELD, SUBJECT_FIELD, DESCRIPTION_FIELD];

    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        //fields.Subject = 'Community Access Request'; // modify a field        
        this.template.querySelector('lightning-record-form').submit(fields);
        if(this.recordId !== ''){
           this.hasId = true;     
        }
        
        //this.recordId = CASEID_FIELD;      
     }

    get acceptedFormats() {
        return ['.pdf', '.png', '.doc', '.docx'];
    }

    handleUploadFinished() {

    }

    /*
    get caseId() {
        this.caseId = '5003I000001Ch8DQAS';
        return this.caseId;
    }
    */
}