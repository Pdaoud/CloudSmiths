import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saIdSearch from '@salesforce/apex/cloudSmithsDevAssignmentController.saIdSearch';
import getHolidays from '@salesforce/apex/cloudSmithsDevAssignmentController.getHolidays';
import saveHolidays from '@salesforce/apex/cloudSmithsDevAssignmentController.saveHolidays';

const columns = [
    { label: 'Holiday Name', fieldName: 'name' },
    { label: 'Description', fieldName: 'description'},
    { label: 'Holiday Date', fieldName: 'date_Z.iso'},
    { label: 'Holiday Type', fieldName: 'type' },
];

export default class CloudSmithsDevAssignment extends LightningElement {

    @api open = false;
    @track searchBtn = true;
    @track saID = '';
    error;
    holidays;
    columns = columns;
    _title = 'Sample Title';
    message = 'Sample Message';
    variant = 'error';



    get sectionClass() {
        return this.open ? 'slds-section slds-is-open' : 'slds-section';
    }
    //Invalid Id 9202204720082
    // Valid One 8001015009087
    handleClick() {
        this.open = !this.open;
    }

    handleValidation(event) {
        this.saID = event.target.value;
        console.log(this.saID);
        this.searchBtn = !this.validateSAID(event.target.value);
        console.log(this.searchBtn);

        if (this.searchBtn == true) {
            this._title = 'South African Id Validation';
            this.variant = 'error';
            this.message = 'Id not valid';
        }else {
            this._title = 'South African Id Validation';
            this.variant = 'success';
            this.message = 'Id validated';
        }
        this.showNotification();
    }

    validateSAID(value) {
        // Accept only digits, dashes or spaces
	    if (/[^0-9-\s]+/.test(value)) return false;

	    // The Luhn Algorithm. It's so pretty.
	    let nCheck = 0, bEven = false;
	    value = value.replace(/\D/g, "");

	    for (var n = value.length - 1; n >= 0; n--) {
		    var cDigit = value.charAt(n),
			    nDigit = parseInt(cDigit, 10);

		    if (bEven && (nDigit *= 2) > 9) nDigit -= 9;

		nCheck += nDigit;
		bEven = !bEven;
	    }

	    return (nCheck % 10) == 0;
    }


    showNotification() {
        const evt = new ShowToastEvent({
            title: this._title,
            message: this.message,
            variant: this.variant,
        });
        this.dispatchEvent(evt);
    }
    handleSearch(){
        saIdSearch({saID: this.saID})
        .then(result => {
        console.log('success');
        })
        .catch(error => {
            console.error(error);
            this.error = error;
        });

        getHolidays({saID: this.saID})
        .then(result => {
            this.holidays = result;
            saveHolidays({holidays: this.holidays, saID: this.saID})
            .then(result => {
                console.log("success");
            })
            .catch(error => {
                console.error(error);
                this.error = error;
            });
        })
        .catch(error => {
            console.error(error);
            this.error = error;
        });


    }
}