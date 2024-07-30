import 'package:pdf/pdf.dart';

double toolbarHeight = 100;

double barcodeHeight = PdfPageFormat.cm * 1.5;

class Constants {
  static const timeoutDuration = Duration(seconds: 4);
  static const noConnectionExceptionMessage = "[cloud_firestore/unavailable] The service is currently unavailable. This is a most likely a transient condition and may be corrected by retrying with a backoff.";
}

class CompanyTypeConstants {
  static const ccc = "CCC";
  static const loc = "LOC";
  static const ppc = "PPC";

  static const companyTypeList = [ccc, loc, ppc];
}

class SampleStatusConstants {
  static const userSubmitted = "User Submitted";
  static const labWaiting = "Lab Waiting";
  static const labReceived = "Lab Received";
  static const labStarted = "Lab Started";
  static const labCancelled = "Lab Cancelled";
  static const labCompleted = "Lab Completed";
  static const sampleStatusList = [
    userSubmitted,
    labWaiting,
    labReceived,
    labStarted,
    labCancelled,
    labCompleted
  ];
}

class Provinces {
  static List<String> getProvinces(String country) {
    switch (country) {
      case 'United States':
        return usaStates;
      case 'Canada':
        return canadaProvinces;
      case 'Australia':
        return australiaStates;
      case 'South Africa':
        return southAfricaProvinces;
      case 'Mexico':
        return mexicoStates;
      default:
        return [];
    }
  }

  static List<String> canadaProvinces = [
    'Alberta',
    'British Columbia',
    'Manitoba',
    'New Brunswick',
    'Newfoundland and Labrador',
    'Northwest Territories',
    'Nova Scotia',
    'Nunavut',
    'Ontario',
    'Prince Edward Island',
    'Quebec',
    'Saskatchewan',
    'Yukon'
  ];

  static List<String> australiaStates = [
    'Australian Capital Territory',
    'New South Wales',
    'Northern Territory',
    'Queensland',
    'South Australia',
    'Tasmania',
    'Victoria',
    'Western Australia'
  ];

  static List<String> southAfricaProvinces = [
    'Eastern Cape',
    'Free State',
    'Gauteng',
    'KwaZulu-Natal',
    'Limpopo',
    'Mpumalanga',
    'North West',
    'Northern Cape',
    'Western Cape'
  ];

  static List<String> mexicoStates = [
    'Aguascalientes',
    'Baja California',
    'Baja California Sur',
    'Campeche',
    'Chiapas',
    'Chihuahua',
    'Coahuila',
    'Colima',
    'Durango',
    'Guanajuato',
    'Guerrero',
    'Hidalgo',
    'Jalisco',
    'Mexico City',
    'Mexico State',
    'Michoacán',
    'Morelos',
    'Nayarit',
    'Nuevo León',
    'Oaxaca',
    'Puebla',
    'Querétaro',
    'Quintana Roo',
    'San Luis Potosí',
    'Sinaloa',
    'Sonora',
    'Tabasco',
    'Tamaulipas',
    'Tlaxcala',
    'Veracruz',
    'Yucatán',
    'Zacatecas'
  ];

  static const List<String> usaStates = [
  "Alabama",
  "Alaska",
  "Arizona",
  "Arkansas",
  "California",
  "Colorado",
  "Connecticut",
  "Delaware",
  "Florida",
  "Georgia",
  "Hawaii",
  "Idaho",
  "Illinois",
  "Indiana",
  "Iowa",
  "Kansas",
  "Kentucky",
  "Louisiana",
  "Maine",
  "Maryland",
  "Massachusetts",
  "Michigan",
  "Minnesota",
  "Mississippi",
  "Missouri",
  "Montana",
  "Nebraska",
  "Nevada",
  "New Hampshire",
  "New Jersey",
  "New Mexico",
  "New York",
  "North Carolina",
  "North Dakota",
  "Ohio",
  "Oklahoma",
  "Oregon",
  "Pennsylvania",
  "Rhode",
  "Island",
  "South Carolina",
  "South Dakota",
  "Tennessee",
  "Texas",
  "Utah",
  "Vermont",
  "Virginia",
  "Washington",
  "West Virginia",
  "Wisconsin",
  "Wyoming"
  ];
}