class AppConstants {
  const AppConstants._();

  static const appName = 'QR Attendance Scanner';
  static const purpose = 'Transport';
  static const loginUrl =
      'http://10.70.9.183:3300/api/employeelogin/verifylogin';
  static const purposeUrl = 'https://w.aditya.ac.in/qrscanapi/purpose/';
  static const scanPostUrl =
      'https://apis.aditya.ac.in/kafka/producer/qrscanner';
  static const trackUrl = 'https://apis.aditya.ac.in/kafka/producer/bustracker';
  static const studentInfoBaseUrl =
      'https://apis.aditya.ac.in/analysis/student/studenttransportinfo';
  static const analysisOrigin = 'https://analysis.aditya.ac.in';
  static const studentInfoReferer = 'https://analysis.aditya.ac.in/checkbus/';
  static const successSoundAsset = 'audio/scan_success.wav';
}
