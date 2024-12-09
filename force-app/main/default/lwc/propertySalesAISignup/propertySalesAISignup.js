import { LightningElement } from 'lwc';
import leftmainclouds from "@salesforce/resourceUrl/LeftMainClouds";
import leftmainlogo from "@salesforce/resourceUrl/LeftMainLogo";
import sendEmail from '@salesforce/apex/SignUpController.sendEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PropertySalesAISignup extends LightningElement {
    currentStep = 1; // Track the current step
    cloudsUrl = leftmainclouds;
    logoUrl = leftmainlogo;
    
    selectedFunction = '';
    selectedExpectations = [];
    selectedPlaces= [];
    
    showOtherExpectationsTextField = false;
    otherExpectationsValue = '';

    showOtherFunctionsTextField = false;
    otherFunctionsValue = '';

    expectations = [
        { label: 'Improved database hygiene', value: 'Improved database hygiene', checked: false },
        { label: 'Reduce lead follow up costs', value: 'Reduce lead follow up costs', checked: false },
        { label: 'Improve follow up strategy', value: 'Improve follow up strategy', checked: false },
        { label: 'Evaluate competition', value: 'Evaluate competition', checked: false },
        { label: 'Other', value: 'Other', checked: false }
    ];

    // Handle checkbox change
    handleExpectationCheckboxChange(event) {
        const value = event.target.value;
        const isChecked = event.target.checked;
        // Update the expectations array
        this.expectations = this.expectations.map(expectation => {
            if (expectation.value === value) {
                expectation.checked = isChecked;
            }
            return expectation;
        });
        // Update the selected expectations
        this.selectedExpectations = this.expectations
            .filter(expectation => expectation.checked);

        this.showOtherExpectationsTextField = this.expectations.some(
            expectation => expectation.value === 'Other' && expectation.checked
        );

        console.log('Selected Expectations:', JSON.stringify(this.selectedExpectations));
    }

    handleOtherTextExpectationsChange(event) {
        this.otherExpectationsValue = event.target.value;
    }

    handleOtherTextFunctionsChange(event) {
        this.otherFunctionsValue = event.target.value;
    }

    places = [
        { label: 'Facebook', value: 'Facebook', checked: false },
        { label: 'Google', value: 'Google', checked: false },
        { label: 'Instagram', value: 'Instagram', checked: false },
        { label: 'Left Main CRM', value: 'Left Main CRM', checked: false },
        { label: 'LinkedIn', value: 'LinkedIn', checked: false },
        { label: 'News Outlet', value: 'News Outlet', checked: false },
        { label: 'Webinar', value: 'Webinar', checked: false },
        { label: 'Word of Mouth', value: 'Word of Mouth', checked: false }
    ];
    // Handle checkbox change
    handlePlaceCheckboxChange(event) {
        const value = event.target.value;
        // Update the places array
        this.places = this.places.map(place => {
            if (place.value === value) {
                place.checked = true;
            } 
            return place;
        });
        // Update the selected places
        this.selectedPlaces = this.places
            .filter(place => place.checked);
        console.log('Selected Places:', this.selectedPlaces);
    }

    subSteps = [
        { number: 1, label: "Step 1", isCompleted: false },
        { number: 2, label: "Step 2", isCompleted: false },
        { number: 3, label: "Step 3", isCompleted: false },
        { number: 4, label: "Step 4", isCompleted: false },
        { number: 5, label: "Step 5", isCompleted: false }
    ];

    teamFunctionOptions = [
        { label: 'Acquisitions', value: 'Acquisitions', checked: this.selectedFunction ==='Acquisitions'},
        { label: 'CEO', value: 'CEO' , checked: this.selectedFunction === 'CEO'},
        { label: 'COO', value: 'COO' , checked: this.selectedFunction === 'COO'},
        { label: 'Dispositions', value: 'Dispositions' , checked: this.selectedFunction === 'Dispositions'},
        { label: 'Lead Management', value: 'Lead Management', checked: this.selectedFunction === 'Lead Management' },
        { label: 'System Administrator', value: 'System Administrator', checked: this.selectedFunction === 'System Administrator' },
        { label: 'Transaction Management', value: 'Transaction Management', checked: this.selectedFunction === 'Transaction Management'  },
        { label: 'Other', value: 'Other' ,  checked: this.selectedFunction === 'Other'},
    ];

    isSelectedFunction(value) {
        if (this.selectedFunction === value) {
            return true;
        } else {
            return false;
        }
    }

    handleCheckboxChange(event) {
        console.log(JSON.stringify(event.target.name));
        if (event.target.name === 'places') {
            this.handlePlaceCheckboxChange(event)
        } else {
            this.handleExpectationCheckboxChange(event);
        }
    }
    
    // Handle checkbox change
    handleFunctionRadioChange(event) {
        const value = event.target.value;
        this.selectedFunction = value;
        this.showOtherFunctionsTextField = value === 'Other';
        console.log('Selected Function:', JSON.stringify(this.selectedExpectations));
    }

    handleNext() {
        const currentIndex = this.subSteps.findIndex((step) => step.number === this.currentStep);
        if (currentIndex < this.subSteps.length - 1) {
            // Mark the current step as completed
            this.subSteps[currentIndex].isCompleted = true;

            // Move to the next step
            this.currentStep = this.subSteps[currentIndex + 1].number;
        }
        console.log("Current step:", this.currentStep);
    }

    handlePrevious() {
        const currentIndex = this.subSteps.findIndex((step) => step.number === this.currentStep);
        if (currentIndex > 0 ) {
            // Mark the current step not completed
            this.subSteps[currentIndex].isCompleted = false;

            // Move to the next step
            this.currentStep = this.subSteps[currentIndex - 1].number;
        }
        console.log("Current step:", this.currentStep);
    }

    handleCountMeIn() {
        const params = {
            expectations: this.selectedExpectations.map(expectation => expectation.value).join(', '),
            places: this.selectedPlaces.map(place => place.value).join(', '),            
            functionRole: this.selectedFunction
        };

        if (params.expectations.includes('Other')) {
            params.expectations = params.expectations.replace('Other', 'Other: ' + this.otherExpectationsValue);
        }
        
        if (params.functionRole === 'Other') {
            params.functionRole += ': ' + this.otherFunctionsValue;
        }
    
        console.log('Expectations:', params.expectations);
        console.log('Places:', params.places);
        console.log('Function Role:', params.functionRole);
        console.log('Other Expectation:', params.otherExpectation);
        console.log('Other Function Text:', params.otherFunctionText);

        // Call the Apex method
        sendEmail(params)
            .then(() => {
                this.showToast('Success', 'Email sent successfully!', 'success');
                console.log('Email sent successfully');
                setTimeout(() => {
                    window.location.href = "https://leftmain.document360.io/docs/property-sales-ai-desk-reference";
                }, 1000);
            })
            .catch(error => {
                this.showToast('Error', 'Failed to send email.' + error.message);
                console.error('Error sending email: ', JSON.stringify(error));
            });


    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }


    get isStep1() {
        return this.currentStep === 1;
    }

    get isStep2() {
        return this.currentStep === 2;
    }

    get isStep3() {
        return this.currentStep === 3;
    }

    get isStep4() {
        return this.currentStep === 4;
    }

    get isStep5() {
        return this.currentStep === 5;
    }
}