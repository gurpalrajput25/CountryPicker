# CountryPicker

A lightweight country/phone metadata bundle for iOS with helpers to produce Twilio-ready E.164 phone numbers.

## Features
- JSON dataset of countries with `isoCode`, `phoneCode`, `callingCode` (with leading +), and min/max lengths
- Simple Swift model and loader
- E.164 formatting utility that validates length and returns strings like "+15551234567"

## Installation
- Add the package to your project (File > Add Packages...) or include the sources directly.
- Ensure the `countries.json` resource is included in your target or in a Swift Package resource bundle.

## Data format
Each entry in `countries.json` contains:
```json
{
  "phoneCode": "225",
  "callingCode": "+225",
  "isoCode": "CI",
  "minLength": 10,
  "maxLength": 10
}

