{
 "QueryResponse": {
  "Purchase": [ 
   {
    "AccountRef": {
     "value": "41",
     "name": "Mastercard"
    },
    "PaymentType": "CreditCard",
    "EntityRef": {
     "value": "57",
     "name": "Lee Advertising",
     "type": "Vendor"
    },
    "Credit": false,
    "TotalAmt": 74.86,
    "PurchaseEx": {
     "any": [
      {
       "name": "{http://schema.intuit.com/finance/v3}NameValue",
       "declaredType": "com.intuit.schema.finance.v3.NameValue",
       "scope": "javax.xml.bind.JAXBElement$GlobalScope",
       "value": {
        "Name": "TxnType",
        "Value": "54"
       },
       "nil": false,
       "globalScope": true,
       "typeSubstituted": false
      }
     ]
    },
    "domain": "QBO",
    "sparse": false,
    "Id": "55",
    "SyncToken": "2",
    "MetaData": {
     "CreateTime": "2020-10-21T14:20:35-07:00",
     "LastUpdatedTime": "2020-11-19T01:24:28-08:00"
    },
    "TxnDate": "2020-10-21",
    "CurrencyRef": {
     "value": "USD",
     "name": "United States Dollar"
    },
    "Line": [
     {
      "Id": "1",
      "Amount": 74.86,
      "DetailType": "AccountBasedExpenseLineDetail",
      "AccountBasedExpenseLineDetail": {
       "AccountRef": {
        "value": "55",
        "name": "Automobile"
       },
       "BillableStatus": "NotBillable",
       "TaxCodeRef": {
        "value": "NON"
       }
      }
     }
    ]
   },
   
   {
    "AccountRef": {
     "value": "35",
     "name": "Checking"
    },
    "PaymentType": "Check",
    "EntityRef": {
     "value": "57",
     "name": "Mahoney Mugs",
     "type": "Vendor"
    },
    "TotalAmt": 18.08,
    "PrintStatus": "NotSet",
    "PurchaseEx": {
     "any": [
      {
       "name": "{http://schema.intuit.com/finance/v3}NameValue",
       "declaredType": "com.intuit.schema.finance.v3.NameValue",
       "scope": "javax.xml.bind.JAXBElement$GlobalScope",
       "value": {
        "Name": "TxnType",
        "Value": "3"
       },
       "nil": false,
       "globalScope": true,
       "typeSubstituted": false
      }
     ]
    },
    "domain": "QBO",
    "sparse": false,
    "Id": "36",
    "SyncToken": "0",
    "MetaData": {
     "CreateTime": "2020-10-21T11:12:45-07:00",
     "LastUpdatedTime": "2020-10-21T11:12:45-07:00"
    },
    "DocNumber": "2",
    "TxnDate": "2020-10-17",
    "CurrencyRef": {
     "value": "USD",
     "name": "United States Dollar"
    },
    "Line": [
     {
      "Id": "1",
      "Description": "Office Supplies",
      "Amount": 18.08,
      "DetailType": "AccountBasedExpenseLineDetail",
      "AccountBasedExpenseLineDetail": {
       "AccountRef": {
        "value": "15",
        "name": "Advertising & Marketing"
       },
       "BillableStatus": "NotBillable",
       "TaxCodeRef": {
        "value": "NON"
       }
      }
     }
    ]
   }
  ],
      
  "Vendor": [
   {
    "Balance": 0,
    "Vendor1099": false,
    "CurrencyRef": {
     "value": "USD",
     "name": "United States Dollar"
    },
    "domain": "QBO",
    "sparse": false,
    "Id": "57",
    "SyncToken": "0",
    "MetaData": {
     "CreateTime": "2020-11-06T14:29:35-08:00",
     "LastUpdatedTime": "2020-11-06T14:29:35-08:00"
    },
    "DisplayName": "Squeaky Kleen Car Wash",
    "PrintOnCheckName": "Squeaky Kleen Car Wash",
    "Active": true
   },
   {
    "BillAddr": {
     "Id": "98",
     "Line1": "Website",
     "Line2": "Dianne Bradley",
     "Line3": "29834 Mustang Ave.",
     "City": "Millbrae",
     "Country": "U.S.A",
     "CountrySubDivisionCode": "CA",
     "PostalCode": "94030"
    },
    "TaxIdentifier": "XXXXXX8293",
    "Balance": 0,
    "AcctNum": "35372649",
    "Vendor1099": false,
    "CurrencyRef": {
     "value": "USD",
     "name": "United States Dollar"
    },
    "domain": "QBO",
    "sparse": false,
    "Id": "15",
    "SyncToken": "0",
    "MetaData": {
     "CreateTime": "2020-10-30T10:00:48-07:00",
     "LastUpdatedTime": "2020-10-30T10:00:48-07:00"
    },
    "Title": "Ms.",
    "GivenName": "Website",
    "FamilyName": "Bradley",
    "Suffix": "Sr.",
    "CompanyName": "Website",
    "DisplayName": "Website",
    "PrintOnCheckName": "Website",
    "Active": true,
    "PrimaryPhone": {
     "FreeFormNumber": "(650) 555-2342"
    },
    "Mobile": {
     "FreeFormNumber": "(650) 555-2000"
    },
    "PrimaryEmailAddr": {
     "Address": "Website@myemail.com"
    },
    "WebAddr": {
     "URI": "http://WebsiteWebsite.com"
    }
   }
  ],
  "startPosition": 1,
  "maxResults": 37
 },
 "time": "2020-11-19T21:46:07.570-08:00"
}