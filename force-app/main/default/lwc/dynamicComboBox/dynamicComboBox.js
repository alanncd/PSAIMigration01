import { LightningElement, api, track } from 'lwc';

export default class DynamicCombobox extends LightningElement {

    @api classes;
    @api placeholder;
    @api selectedValue;
    @api options;
    @api variant;
    @api label;
    @api selectedLabel;

    isFocussed = false;
    isOpen = false;

    _filterText;
    domElement;
    
    _handleOutsideClick;

    constructor() {
        super();
        this._handleOutsideClick = this.handleOutsideClick.bind(this);
    }

    connectedCallback() {
        this.filteredOptions = [...this.options];
        document.addEventListener('click', this._handleOutsideClick);
    }

    disconnectedCallback() {
        document.removeEventListener('click', this._handleOutsideClick);
    }
    
    renderedCallback() {
        if (this.selectedLabel) {
            this.refreshOptions(this.selectedLabel);
        }
    }

    filterOptions(event) {
        this.selectedValue = event.detail.value;
        this.selectedLabel = event.detail.value;
		if (this.selectedLabel) {
			this.filteredOptions = this.options.filter(option => {
				return option.label.toLowerCase().includes(this.selectedLabel.toLowerCase());
			});
        } else {
            this.filteredOptions = [...this.options];
        }
    }

    handleSelectOption(event) {
        const custEvent = new CustomEvent(
            'selectoption', {
                detail: {
                    value: event.currentTarget.dataset.value,
                    label: event.currentTarget.dataset.label
                }
            }
        );
        this.dispatchEvent(custEvent);

        this.selectedValue = event.currentTarget.dataset.value;
        this.selectedLabel = event.currentTarget.dataset.label;
        this.refreshOptions(this.selectedLabel);

        this.isFocussed = false;
        this.isOpen = false;
    }

    get noOptions() {
        return this.filteredOptions.length === 0;
    }

    get dropdownClasses() {
        let dropdownClasses = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        // Show dropdown list on focus
        if (this.isOpen) {
            dropdownClasses += ' slds-is-open';
        }

        return dropdownClasses;
    }

    handleOutsideClick(event) {

        if ((!this.isFocussed) && (this.isOpen)) { 
            //Fetch the dropdown DOM node
            let domElement = this.template.querySelector('div[data-id="resultBox"]');

            //Is the clicked element within the dropdown 
            if (domElement && !domElement.contains(event.target)) {
                this.isOpen = false;
            }
        }
    }
    
    handleFocus() {
        this.filteredOptions = this.filteredOptions.length === 0 ? [...this.options] : this.filteredOptions;
        this.isFocussed = true;
        this.isOpen = true;
    }
    
    handleBlur() {
        this.isFocussed = false;
    }
    
    @api
    getSelectedValue() {
        return this.selectedValue;
    }
    
    refreshOptions(value) {
        this.filteredOptions = this.options.filter(option => {
            return option.label.toLowerCase().includes(value.toLowerCase());
        });
    }
}