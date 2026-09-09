// lib/core/localization/app_strings.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class AppStrings {
  final String selectRoleTitle;
  final String selectRoleSubtitle;
  final String continueAs;
  final String selectLanguage;
  final String selectLanguageSubtitle;
  final String continueBtn;
  final String loginTitle;
  final String loginSubtitle;
  final String mobileNumber;
  final String sendOtp;
  final String verifyLogin;
  final String enterOtp;
  final String resendOtp;
  final String driverProfile;
  final String fullName;
  final String drivingLicense;
  final String vehicleType;
  final String vehicleNumber;
  final String vehicleModel;
  final String upiId;
  final String saveProfile;
  final String online;
  final String offline;
  final String cvrpRunAssigned;
  final String guaranteedPayout;
  final String viewRoutePlan;
  final String routePlan;
  final String milestones;
  final String scanQr;
  final String callFarmer;
  final String proceedToDelivery;
  final String geofenceCheckPassed;
  final String producePhoto;
  final String buyerOtp;
  final String confirmDelivery;
  final String escrowBalance;
  final String instantWithdraw;
  final String tonKmFormulaTitle;
  final String tonKmFormulaDesc;
  final String listenAudio;

  // Navigation & New Sections
  final String home;
  final String history;
  final String earnings;
  final String profile;
  final String notifications;
  final String markAllRead;
  final String clearAll;
  final String bulkBuyerDelivery;
  final String razorpaySecured;

  const AppStrings({
    required this.selectRoleTitle,
    required this.selectRoleSubtitle,
    required this.continueAs,
    required this.selectLanguage,
    required this.selectLanguageSubtitle,
    required this.continueBtn,
    required this.loginTitle,
    required this.loginSubtitle,
    required this.mobileNumber,
    required this.sendOtp,
    required this.verifyLogin,
    required this.enterOtp,
    required this.resendOtp,
    required this.driverProfile,
    required this.fullName,
    required this.drivingLicense,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.upiId,
    required this.saveProfile,
    required this.online,
    required this.offline,
    required this.cvrpRunAssigned,
    required this.guaranteedPayout,
    required this.viewRoutePlan,
    required this.routePlan,
    required this.milestones,
    required this.scanQr,
    required this.callFarmer,
    required this.proceedToDelivery,
    required this.geofenceCheckPassed,
    required this.producePhoto,
    required this.buyerOtp,
    required this.confirmDelivery,
    required this.escrowBalance,
    required this.instantWithdraw,
    required this.tonKmFormulaTitle,
    required this.tonKmFormulaDesc,
    required this.listenAudio,
    required this.home,
    required this.history,
    required this.earnings,
    required this.profile,
    required this.notifications,
    required this.markAllRead,
    required this.clearAll,
    required this.bulkBuyerDelivery,
    required this.razorpaySecured,
  });

  static const english = AppStrings(
    selectRoleTitle: 'Choose Your Portal',
    selectRoleSubtitle: 'Select how you participate in the KrishiSetu ecosystem',
    continueAs: 'Continue as',
    selectLanguage: 'Choose Your Language',
    selectLanguageSubtitle: 'Select your preferred regional language',
    continueBtn: 'Continue',
    loginTitle: 'Login with Mobile',
    loginSubtitle: 'Enter your registered mobile number for OTP',
    mobileNumber: 'Mobile Number',
    sendOtp: 'Send OTP',
    verifyLogin: 'Verify & Login',
    enterOtp: 'Enter 4-Digit OTP',
    resendOtp: 'Resend OTP',
    driverProfile: 'Driver & Vehicle Profile',
    fullName: 'Full Name',
    drivingLicense: 'Driving License Number',
    vehicleType: 'Vehicle Type',
    vehicleNumber: 'Vehicle Plate Number',
    vehicleModel: 'Vehicle Model',
    upiId: 'UPI ID (for instant payouts)',
    saveProfile: 'Save Profile & Continue',
    online: 'Online',
    offline: 'Offline',
    cvrpRunAssigned: 'New Delivery Route Offer!',
    guaranteedPayout: 'Guaranteed Payout',
    viewRoutePlan: 'View Route & Farm Stops',
    routePlan: 'Delivery Route Plan',
    milestones: 'Sequential Farm Milestones',
    scanQr: 'Scan Batch QR',
    callFarmer: 'Call Farmer',
    proceedToDelivery: 'Proceed to Bulk Buyer Delivery',
    geofenceCheckPassed: 'Geofence Check Passed (Within 100m)',
    producePhoto: 'Mandatory Produce Proof Photo',
    buyerOtp: 'Enter Buyer 4-Digit Handover OTP',
    confirmDelivery: 'Confirm Handover & Settle Trip',
    escrowBalance: 'Escrow Wallet Balance',
    instantWithdraw: 'Instant Withdraw to UPI',
    tonKmFormulaTitle: 'Fair Shared-Route Payout (Ton-Km)',
    tonKmFormulaDesc: 'Cost is mathematically divided between farmers: Ci = Total Cost × (Wi × Di) / Σ (Wj × Dj)',
    listenAudio: 'Listen Instructions',
    home: 'Home',
    history: 'History',
    earnings: 'Earnings',
    profile: 'Profile',
    notifications: 'Notifications',
    markAllRead: 'Mark all read',
    clearAll: 'Clear all',
    bulkBuyerDelivery: 'Bulk Buyer Delivery',
    razorpaySecured: 'Instant Payouts Powered by RazorpayX Escrow',
  );

  static const hindi = AppStrings(
    selectRoleTitle: 'अपनी भूमिका चुनें',
    selectRoleSubtitle: 'कृषिसेतु प्लेटफॉर्म पर अपना खाता प्रकार चुनें',
    continueAs: 'के रूप में आगे बढ़ें',
    selectLanguage: 'अपनी भाषा चुनें',
    selectLanguageSubtitle: 'अपनी पसंदीदा क्षेत्रीय भाषा का चयन करें',
    continueBtn: 'आगे बढ़ें',
    loginTitle: 'मोबाइल नंबर से लॉगिन करें',
    loginSubtitle: 'ओटीपी प्राप्त करने के लिए अपना मोबाइल नंबर दर्ज करें',
    mobileNumber: 'मोबाइल नंबर',
    sendOtp: 'ओटीपी भेजें',
    verifyLogin: 'सत्यापित करें और लॉगिन करें',
    enterOtp: '4 अंकों का ओटीपी दर्ज करें',
    resendOtp: 'ओटीपी पुनः भेजें',
    driverProfile: 'चालक एवं वाहन विवरण',
    fullName: 'पूरा नाम',
    drivingLicense: 'ड्राइविंग लाइसेंस नंबर',
    vehicleType: 'वाहन का प्रकार',
    vehicleNumber: 'वाहन पंजीकरण संख्या',
    vehicleModel: 'वाहन मॉडल',
    upiId: 'यूपीआई आईडी (भुगतान हेतु)',
    saveProfile: 'विवरण सुरक्षित करें और आगे बढ़ें',
    online: 'ऑनलाइन',
    offline: 'ऑफलाइन',
    cvrpRunAssigned: 'नया डिलीवरी रूट ऑफर!',
    guaranteedPayout: 'गारंटीकृत भुगतान',
    viewRoutePlan: 'रूट और फार्म स्टॉप्स देखें',
    routePlan: 'डिलीवरी रूट योजना',
    milestones: 'खेतों के क्रमिक पड़ाव',
    scanQr: 'बैच QR स्कैन करें',
    callFarmer: 'किसान को कॉल करें',
    proceedToDelivery: 'थोक खरीदार डिलीवरी के लिए आगे बढ़ें',
    geofenceCheckPassed: 'जियोफेंस जांच सफल (100 मीटर के भीतर)',
    producePhoto: 'अनलोडेड माल की अनिवार्य फोटो',
    buyerOtp: 'खरीदार का 4 अंकों का हैंडओवर ओटीपी दर्ज करें',
    confirmDelivery: 'डिलीवरी सत्यापित करें और भुगतान प्राप्त करें',
    escrowBalance: 'एस्क्रो वॉलेट शेष',
    instantWithdraw: 'यूपीआई में तुरंत ट्रांसफर करें',
    tonKmFormulaTitle: 'साझा रूट भाड़ा विभाजन (टन-किमी)',
    tonKmFormulaDesc: 'किसानों में पारदर्शी लागत बंटवारा: Ci = Total Cost × (Wi × Di) / Σ (Wj × Dj)',
    listenAudio: 'आवाज में सुनें',
    home: 'होम',
    history: 'इतिहास',
    earnings: 'कमाई',
    profile: 'प्रोफाइल',
    notifications: 'सूचनाएं',
    markAllRead: 'सभी पढ़ें',
    clearAll: 'सभी हटाएं',
    bulkBuyerDelivery: 'थोक खरीदार डिलीवरी',
    razorpaySecured: 'रेज़रपेX एस्क्रो द्वारा संचालित त्वरित भुगतान',
  );

  static const marathi = AppStrings(
    selectRoleTitle: 'आपली भूमिका निवडा',
    selectRoleSubtitle: 'कृषीसेतू प्लॅटफॉर्मवर आपली भूमिका निवडा',
    continueAs: 'म्हणून पुढे जा',
    selectLanguage: 'आपली भाषा निवडा',
    selectLanguageSubtitle: 'आपल्या पसंतीची प्रादेशिक भाषा निवडा',
    continueBtn: 'पुढे जा',
    loginTitle: 'मोबाईल क्रमांकाने लॉगिन करा',
    loginSubtitle: 'ओटीपी मिळवण्यासाठी आपला मोबाईल नंबर प्रविष्ट करा',
    mobileNumber: 'मोबाईल नंबर',
    sendOtp: 'ओटीपी पाठवा',
    verifyLogin: 'पडताळणी करा आणि लॉगिन व्हा',
    enterOtp: '४ अंकी ओटीपी प्रविष्ट करा',
    resendOtp: 'पुन्हा ओटीपी पाठवा',
    driverProfile: 'चालक व वाहन माहिती',
    fullName: 'पूर्ण नाव',
    drivingLicense: 'वाहन चालवण्याचा परवाना क्रमांक',
    vehicleType: 'वाहनाचा प्रकार',
    vehicleNumber: 'वाहन क्रमांक',
    vehicleModel: 'वाहन मॉडेल',
    upiId: 'युपीआय आयडी (पैसे मिळवण्यासाठी)',
    saveProfile: 'माहिती जतन करा आणि पुढे जा',
    online: 'ऑनलाइन',
    offline: 'ऑफलाइन',
    cvrpRunAssigned: 'नवीन डिलिव्हरी मार्ग नियुक्त झाला!',
    guaranteedPayout: 'निश्चित मोबदला',
    viewRoutePlan: 'मार्ग आणि शेतातील थांबे पहा',
    routePlan: 'डिलिव्हरी मार्ग नियोजन',
    milestones: 'शेतकऱ्यांचे क्रमिक थांबे',
    scanQr: 'बॅच QR स्कॅन करा',
    callFarmer: 'शेतकऱ्याला कॉल करा',
    proceedToDelivery: 'मोठ्या खरेदीदार डिलिव्हरीसाठी पुढे जा',
    geofenceCheckPassed: 'जिओफेन्स तपासणी यशस्वी (१०० मीटरच्या आत)',
    producePhoto: 'उतरवलेल्या मालाचा अनिवार्य फोटो',
    buyerOtp: 'खरेदीदाराचा ४ अंकी ओटीपी प्रविष्ट करा',
    confirmDelivery: 'डिलिव्हरी निश्चित करा व मोबदला मिळवा',
    escrowBalance: 'एस्क्रो वॉलेट शिल्लक',
    instantWithdraw: 'युपीआयवर तत्काळ जमा करा',
    tonKmFormulaTitle: 'सामायिक मार्ग भाडे वाटप (टन-किमी)',
    tonKmFormulaDesc: 'मालाचे वजन व अंतराप्रमाणे पारदर्शी वाटप: Ci = Total Cost × (Wi × Di) / Σ (Wj × Dj)',
    listenAudio: 'आवाजात ऐका',
    home: 'होम',
    history: 'इतिहास',
    earnings: 'कमाई',
    profile: 'प्रोफाइल',
    notifications: 'सूचना',
    markAllRead: 'सर्व वाचले',
    clearAll: 'सर्व हटवा',
    bulkBuyerDelivery: 'मोठ्या खरेदीदार डिलिव्हरी',
    razorpaySecured: 'रेझरपेX एस्क्रो द्वारे त्वरित मोबदला',
  );

  static const tamil = AppStrings(
    selectRoleTitle: 'உங்கள் பங்கைத் தேர்வு செய்யவும்',
    selectRoleSubtitle: 'கிரிஷிசேது தளத்தில் உங்கள் கணக்கு வகையைத் தேர்வுசெய்க',
    continueAs: 'ஆக தொடரவும்',
    selectLanguage: 'மொழியைத் தேர்ந்தெடுக்கவும்',
    selectLanguageSubtitle: 'உங்கள் விருப்ப மொழியைத் தேர்ந்தெடுக்கவும்',
    continueBtn: 'தொடரவும்',
    loginTitle: 'மொபைல் மூலம் உள்நுழையவும்',
    loginSubtitle: 'OTP பெற உங்கள் மொபைல் எண்ணை உள்ளிடவும்',
    mobileNumber: 'மொபைல் எண்',
    sendOtp: 'OTP அனுப்பவும்',
    verifyLogin: 'சரிபார்த்து உள்நுழையவும்',
    enterOtp: '4 இலக்க OTP ஐ உள்ளிடவும்',
    resendOtp: 'OTP மீண்டும் அனுப்பவும்',
    driverProfile: 'ஓட்டுநர் & வாகன விவரக்குறிப்பு',
    fullName: 'முழு பெயர்',
    drivingLicense: 'ஓட்டுநர் உரிம எண்',
    vehicleType: 'வாகன வகை',
    vehicleNumber: 'வாகனப் பதிவு எண்',
    vehicleModel: 'வாகன மாதிரி',
    upiId: 'UPI முகவரி',
    saveProfile: 'சேமித்து தொடரவும்',
    online: 'ஆன்லைன்',
    offline: 'ஆஃப்லைன்',
    cvrpRunAssigned: 'புதிய டெலிவரி பாதை கிடைத்தது!',
    guaranteedPayout: 'உறுதிசெய்யப்பட்ட தொகை',
    viewRoutePlan: 'பாதை மற்றும் நிறுத்தங்களைக் காண்க',
    routePlan: 'டெலிவரி பாதை திட்டம்',
    milestones: 'பண்ணை நிறுத்தங்கள்',
    scanQr: 'தொகுதி QR ஸ்கேன்',
    callFarmer: 'விவசாயியை அழைக்கவும்',
    proceedToDelivery: 'மொத்த வாங்குபவர் டெலிவரிக்கு செல்லவும்',
    geofenceCheckPassed: 'ஜியோஃபென்ஸ் சரிபார்ப்பு வெற்றி (100மீ)',
    producePhoto: 'இறக்கப்பட்ட பயிர் புகைப்படம்',
    buyerOtp: 'வாங்குபவர் 4 இலக்க OTP',
    confirmDelivery: 'டெலிவரியை உறுதிசெய்க',
    escrowBalance: 'எஸ்க்ரோ பணப்பை இருப்பு',
    instantWithdraw: 'உடனடி UPI பரிமாற்றம்',
    tonKmFormulaTitle: 'நியாயமான கட்டணப் பகிர்வு (டன்-கிமீ)',
    tonKmFormulaDesc: 'விவசாயிகளிடையே நியாயமான கட்டணப் பகிர்வு: Ci = Total Cost × (Wi × Di) / Σ (Wj × Dj)',
    listenAudio: 'ஒலியில் கேட்கவும்',
    home: 'முகப்பு',
    history: 'வரலாறு',
    earnings: 'வருவாய்',
    profile: 'சுயவிவரம்',
    notifications: 'அறிவிப்புகள்',
    markAllRead: 'அனைத்தும் படி',
    clearAll: 'அனைத்தும் அழி',
    bulkBuyerDelivery: 'மொத்த வாங்குபவர் டெலிவரி',
    razorpaySecured: 'ரேசர்பேX எஸ்க்ரோ உடனடி பணப்பட்டுவாடா',
  );

  static const telugu = AppStrings(
    selectRoleTitle: 'మీ పాత్రను ఎంచుకోండి',
    selectRoleSubtitle: 'కృషిసేతు ప్లాట్‌ఫారమ్‌లో మీ ఖాతా రకాన్ని ఎంచుకోండి',
    continueAs: 'గా కొనసాగించండి',
    selectLanguage: 'మీ భాషను ఎంచుకోండి',
    selectLanguageSubtitle: 'మీకు నచ్చిన ప్రాంతీయ భాషను ఎంచుకోండి',
    continueBtn: 'కొనసాగించండి',
    loginTitle: 'మొబైల్ ద్వారా లాగిన్ అవ్వండి',
    loginSubtitle: 'OTP కోసం మీ మొబైల్ నంబర్ నమోదు చేయండి',
    mobileNumber: 'మొబైల్ నంబర్',
    sendOtp: 'OTP పంపండి',
    verifyLogin: 'ధృవీకరించి లాగిన్ అవ్వండి',
    enterOtp: '4 అంకెల OTP నమోదు చేయండి',
    resendOtp: 'OTP మళ్లీ పంపండి',
    driverProfile: 'డ్రైవర్ & వాహన వివరాలు',
    fullName: 'పూర్తి పేరు',
    drivingLicense: 'డ్రైవింగ్ లైసెన్స్ నంబర్',
    vehicleType: 'వాహన వర్గం',
    vehicleNumber: 'వాహనం నంబర్',
    vehicleModel: 'వాహనం మోడల్',
    upiId: 'UPI ID',
    saveProfile: 'సేవ్ చేసి కొనసాగించండి',
    online: 'ఆన్‌లైన్',
    offline: 'ఆఫ్‌లైన్',
    cvrpRunAssigned: 'కొత్త డెలివరీ రూట్ కేటాయించబడింది!',
    guaranteedPayout: 'హామీ చెల్లింపు',
    viewRoutePlan: 'రూట్ మరియు స్టాప్స్ చూడండి',
    routePlan: 'డెలివరీ రూట్ ప్రణాళిక',
    milestones: 'రైతు గేట్ స్టాప్‌లు',
    scanQr: 'బ్యాచ్ QR స్కాన్ చేయండి',
    callFarmer: 'రైతుకు కాల్ చేయండి',
    proceedToDelivery: 'బల్క్ కొనుగోలుదారు డెలివరీకి వెళ్లండి',
    geofenceCheckPassed: 'జియోఫెన్స్ తనిఖీ పాస్ (100 మీటర్లలోపు)',
    producePhoto: 'దిగుమతి చేసిన సరుకు ఫోటో',
    buyerOtp: 'కొనుగోలుదారు 4-అంకెల OTP',
    confirmDelivery: 'డెలివరీని ధృవీకరించండి',
    escrowBalance: 'ఎస్క్రో వాలెట్ బ్యాలెన్స్',
    instantWithdraw: 'తక్షణ UPI విత్‌డ్రా',
    tonKmFormulaTitle: 'న్యాయమైన ఛార్జీల విభజన (టన్-కిమీ)',
    tonKmFormulaDesc: 'రైతుల మధ్య పారదర్శక పంపిణీ: Ci = Total Cost × (Wi × Di) / Σ (Wj × Dj)',
    listenAudio: 'వాయిస్‌లో వినండి',
    home: 'హోమ్',
    history: 'చరిత్ర',
    earnings: 'ఆదాయం',
    profile: 'ప్రొఫైల్',
    notifications: 'నోటిఫికేషన్లు',
    markAllRead: 'అన్నీ చదివినట్లు',
    clearAll: 'అన్నీ తొలగించు',
    bulkBuyerDelivery: 'బల్క్ కొనుగోలుదారు డెలివరీ',
    razorpaySecured: 'రేజర్‌పేX ఎస్క్రో తక్షణ చెల్లింపులు',
  );

  static const kannada = AppStrings(
    selectRoleTitle: 'ನಿಮ್ಮ ಪಾತ್ರವನ್ನು ಆಯ್ಕೆಮಾಡಿ',
    selectRoleSubtitle: 'ಕೃಷಿಸೇತು ವೇದಿಕೆಯಲ್ಲಿ ನಿಮ್ಮ ಖಾತೆ ಪ್ರಕಾರವನ್ನು ಆಯ್ಕೆಮಾಡಿ',
    continueAs: 'ಆಗಿ ಮುಂದುವರಿಯಿರಿ',
    selectLanguage: 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
    selectLanguageSubtitle: 'ನಿಮ್ಮ ಆದ್ಯತೆಯ ಪ್ರಾದೇಶಿಕ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
    continueBtn: 'ಮುಂದುವರಿಯಿರಿ',
    loginTitle: 'ಮೊಬೈಲ್ ಮೂಲಕ ಲಾಗಿನ್ ಮಾಡಿ',
    loginSubtitle: 'OTP ಪಡೆಯಲು ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
    mobileNumber: 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ',
    sendOtp: 'OTP ಕಳುಹಿಸಿ',
    verifyLogin: 'ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಲಾಗಿನ್ ಮಾಡಿ',
    enterOtp: '4-ಅಂಕಿಯ OTP ನಮೂದಿಸಿ',
    resendOtp: 'OTP ಪುನಃ ಕಳುಹಿಸಿ',
    driverProfile: 'ಚಾಲಕ ಮತ್ತು ವಾಹನ ವಿವರ',
    fullName: 'ಪೂರ್ಣ ಹೆಸರು',
    drivingLicense: 'ಚಾಲನಾ ಪರವಾನಗಿ ಸಂಖ್ಯೆ',
    vehicleType: 'ವಾಹನ ವರ್ಗ',
    vehicleNumber: 'ವಾಹನ ನೋಂದಣಿ ಸಂಖ್ಯೆ',
    vehicleModel: 'ವಾಹನ ಮಾದರಿ',
    upiId: 'ಯುಪಿಐ ಐಡಿ',
    saveProfile: 'ಉಳಿಸಿ ಮತ್ತು ಮುಂದುವರಿಯಿರಿ',
    online: 'ಆನ್‌ಲೈನ್',
    offline: 'ಆಫ್‌ಲೈನ್',
    cvrpRunAssigned: 'ಹೊಸ ಡೆಲಿವರಿ ಮಾರ್ಗ ನಿಯೋಜಿಸಲಾಗಿದೆ!',
    guaranteedPayout: 'ಖಾತರಿಯ ಪಾವತಿ',
    viewRoutePlan: 'ಮಾರ್ಗ ಮತ್ತು ನಿಲುಗಡೆಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
    routePlan: 'ಡೆಲಿವರಿ ಮಾರ್ಗ ಯೋಜನೆ',
    milestones: 'ರೈತರ ನಿಲ್ದಾಣಗಳು',
    scanQr: 'ಬ್ಯಾಚ್ ಕ್ಯೂಆರ್ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ',
    callFarmer: 'ರೈತರಿಗೆ ಕರೆ ಮಾಡಿ',
    proceedToDelivery: 'ಬಲ್ಕ್ ಖರೀದಿದಾರರ ಡೆಲಿವರಿಗೆ ಮುಂದುವರಿಯಿರಿ',
    geofenceCheckPassed: 'ಜಿಯೋಫೆನ್ಸ್ ಪರಿಶೀಲನೆ ಯಶಸ್ವಿ (100 ಮೀ ಒಳಗೆ)',
    producePhoto: 'ಇಳಿಸಲಾದ ಬೆಳೆಯ ಕಡ್ಡಾಯ ಫೋಟೋ',
    buyerOtp: 'ಖರೀದಿದಾರರ 4-ಅಂಕಿಯ OTP',
    confirmDelivery: 'ವಿತರಣೆಯನ್ನು ದೃಢೀಕರಿಸಿ',
    escrowBalance: 'ಎಸ್ಕ್ರೋ ವಾಲೆಟ್ ಬ್ಯಾಲೆನ್ಸ್',
    instantWithdraw: 'ತಕ್ಷಣದ ಯುಪಿಐ ವಿತ್‌ಡ್ರಾ',
    tonKmFormulaTitle: 'ನ್ಯಾಯಯುತ ಶುಲ್ಕ ಹಂಚಿಕೆ (ಟನ್-ಕಿಮೀ)',
    tonKmFormulaDesc: 'ರೈತರ ನಡುವೆ ಪಾರದರ್ಶಕ ವೆಚ್ಚ ಹಂಚಿಕೆ: Ci = Total Cost × (Wi × Di) / Σ (Wj × Dj)',
    listenAudio: 'ಧ್ವನಿಯಲ್ಲಿ ಆಲಿಸಿ',
    home: 'ಮುಖಪುಟ',
    history: 'ಇತಿಹಾಸ',
    earnings: 'ಗಳಿಕೆ',
    profile: 'ಪ್ರೊಫೈಲ್',
    notifications: 'ಅಧಿಸೂಚನೆಗಳು',
    markAllRead: 'ಎಲ್ಲವನ್ನೂ ಓದಿದೆ',
    clearAll: 'ಎಲ್ಲವನ್ನೂ ತೆರವುಗೊಳಿಸಿ',
    bulkBuyerDelivery: 'ಬಲ್ಕ್ ಖರೀದಿದಾರರ ವಿತರಣೆ',
    razorpaySecured: 'ರೇಜರ್‌ಪೇX ಎಸ್ಕ್ರೋ ತಕ್ಷಣದ ಪಾವತಿಗಳು',
  );

  static AppStrings forLanguage(String code) {
    switch (code) {
      case 'hi':
        return hindi;
      case 'mr':
        return marathi;
      case 'ta':
        return tamil;
      case 'te':
        return telugu;
      case 'kn':
        return kannada;
      default:
        return english;
    }
  }
}

final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(selectedLanguageProvider);
  return AppStrings.forLanguage(lang.code);
});
