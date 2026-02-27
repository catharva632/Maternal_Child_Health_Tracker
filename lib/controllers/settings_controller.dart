import 'package:flutter/material.dart';

class SettingsController {
  static final SettingsController _instance = SettingsController._internal();
  factory SettingsController() => _instance;
  SettingsController._internal();

  final ValueNotifier<bool> notificationsEnabled = ValueNotifier(true);
  final ValueNotifier<String> language = ValueNotifier('English');

  static final Map<String, Map<String, String>> _translations = {
    'Profile': {
      'English': 'Profile',
      'Hindi': 'प्रोफ़ाइल',
      'Marathi': 'प्रोफाईल',
    },
    'My Contacts': {
      'English': 'My Contacts',
      'Hindi': 'मेरे संपर्क',
      'Marathi': 'माझे संपर्क',
    },
    'Generate Report': {
      'English': 'Generate Report',
      'Hindi': 'रिपोर्ट जनरेट करें',
      'Marathi': 'रिपोर्ट तयार करा',
    },
    'Settings': {
      'English': 'Settings',
      'Hindi': 'सेटिंग्स',
      'Marathi': 'सेटिंग्ज',
    },
    'About': {
      'English': 'About',
      'Hindi': 'के बारे में',
      'Marathi': 'च्याबद्दल',
    },
    'Logout': {
      'English': 'Logout',
      'Hindi': 'लोगआउट',
      'Marathi': 'बाहेर पडा',
    },
    'Personal Details': {
      'English': 'Personal Details',
      'Hindi': 'व्यक्तिगत विवरण',
      'Marathi': 'वैयक्तिक तपशील',
    },
    'Medical Details': {
      'English': 'Medical Details',
      'Hindi': 'चिकित्सा विवरण',
      'Marathi': 'वैद्यकीय तपशील',
    },
    'Doctor Details': {
      'English': 'Doctor Details',
      'Hindi': 'डॉक्टर का विवरण',
      'Marathi': 'डॉक्टरांचा तपशील',
    },
    'Save Profile': {
      'English': 'Save Profile',
      'Hindi': 'प्रोफ़ाइल सेव करें',
      'Marathi': 'प्रोफाईल जतन करा',
    },
    'Dark Theme': {
      'English': 'Dark Theme',
      'Hindi': 'डार्क थीम',
      'Marathi': 'डार्क थीम',
    },
    'Notifications': {
      'English': 'Notifications',
      'Hindi': 'सूचनाएं',
      'Marathi': 'सूचना',
    },
    'Language': {
      'English': 'Language',
      'Hindi': 'भाषा',
      'Marathi': 'भाषा',
    },
    'Medical Report': {
      'English': 'Medical Report',
      'Hindi': 'मेडिकल रिपोर्ट',
      'Marathi': 'वैद्यकीय अहवाल',
    },
    'Enter Decryption PIN': {
      'English': 'Enter Decryption PIN',
      'Hindi': 'डिक्रिप्शन पिन दर्ज करें',
      'Marathi': 'डिक्रिप्शन पिन प्रविष्ट करा',
    },
    'PIN is: First 3 letters of name + @ + 2 digits of age': {
      'English': 'PIN is: First 3 letters of name + @ + 2 digits of age',
      'Hindi': 'पिन है: नाम के पहले 3 अक्षर + @ + उम्र के 2 अंक',
      'Marathi': 'पिन आहे: नावाचे पहिले 3 अक्षरे + @ + वयाचे 2 अंक',
    },
    'Verify & Open Report': {
      'English': 'Verify & Open Report',
      'Hindi': 'सत्यापित करें और रिपोर्ट खोलें',
      'Marathi': 'सत्यापित करा आणि अहवाल उघडा',
    },
    'Invalid PIN. Access Denied.': {
      'English': 'Invalid PIN. Access Denied.',
      'Hindi': 'अमान्य पिन। पहुंच अस्वीकार कर दी गई।',
      'Marathi': 'अवैध पिन. प्रवेश नाकारला.',
    },
    'Age': {
      'English': 'Age',
      'Hindi': 'आयु',
      'Marathi': 'वय',
    },
    'Log Today\'s Meal': {
      'English': 'Log Today\'s Meal',
      'Hindi': 'आज का भोजन लॉग करें',
      'Marathi': 'आजचे जेवण लॉग करा',
    },
    'What did you eat?': {
      'English': 'What did you eat?',
      'Hindi': 'आपने क्या खाया?',
      'Marathi': 'तुम्ही काय खाल्ले?',
    },
    'Cancel': {
      'English': 'Cancel',
      'Hindi': 'रद्द करें',
      'Marathi': 'रद्द करा',
    },
    'Meal logged successfully!': {
      'English': 'Meal logged successfully!',
      'Hindi': 'भोजन सफलतापूर्वक लॉग किया गया!',
      'Marathi': 'जेवण यशस्वीरित्या लॉग केले!',
    },
    'Log Meal': {
      'English': 'Log Meal',
      'Hindi': 'भोजन लॉग करें',
      'Marathi': 'जेवण लॉग करा',
    },
    'Breakfast': {
      'English': 'Breakfast',
      'Hindi': 'नाश्ता',
      'Marathi': 'नाश्ता',
    },
    'Lunch': {
      'English': 'Lunch',
      'Hindi': 'दोपहर का भोजन',
      'Marathi': 'दुपारचे जेवण',
    },
    'Dinner': {
      'English': 'Dinner',
      'Hindi': 'रात का खाना',
      'Marathi': 'रात्रीचे जेवण',
    },
    'Snacks': {
      'English': 'Snacks',
      'Hindi': 'नाश्ता',
      'Marathi': 'अल्पोपहार',
    },
    'Pregnancy Progress': {
      'English': 'Pregnancy Progress',
      'Hindi': 'गर्भावस्था की प्रगति',
      'Marathi': 'गर्भधारणेची प्रगती',
    },
    'Weeks Pregnant': {
      'English': 'Weeks Pregnant',
      'Hindi': 'सप्ताह की गर्भवती',
      'Marathi': 'आठवड्याची गर्भवती',
    },
    'Trimester': {
      'English': 'Trimester',
      'Hindi': 'तिमाही',
      'Marathi': 'तिमाही',
    },
    'Doctor': {
      'English': 'Doctor',
      'Hindi': 'डॉक्टर',
      'Marathi': 'डॉक्टर',
    },
    'Weekly Development': {
      'English': 'Weekly Development',
      'Hindi': 'साप्ताहिक विकास',
      'Marathi': 'साप्ताहिक विकास',
    },
    'Milestones': {
      'English': 'Milestones',
      'Hindi': 'पड़ाव',
      'Marathi': 'महत्वाचे टप्पे',
    },
    'Cultural Wisdom': {
      'English': 'Cultural Wisdom',
      'Hindi': 'सांस्कृतिक ज्ञान',
      'Marathi': 'सांस्कृतिक ज्ञान',
    },
    'Emergency Map': {
      'English': 'Emergency Map',
      'Hindi': 'आपातकालीन मानचित्र',
      'Marathi': 'आणीबाणी नकाशा',
    },
    'Check Appointments': {
      'English': 'Check Appointments',
      'Hindi': 'नियुक्ति की जाँच करें',
      'Marathi': 'अपॉइंटमेंट तपासा',
    },
    'Ask AI Assistant': {
      'English': 'Ask AI Assistant',
      'Hindi': 'एआई सहायक से पूछें',
      'Marathi': 'AI सहाय्यकाला विचारा',
    },
    'Exercise & Diet': {
      'English': 'Exercise & Diet',
      'Hindi': 'व्यायाम और आहार',
      'Marathi': 'व्यायाम आणि आहार',
    },
    'Hospital Schedule': {
      'English': 'Hospital Schedule',
      'Hindi': 'अस्पताल की समय सारणी',
      'Marathi': 'रुग्णालय वेळापत्रक',
    },
    'DNA Mode': {
      'English': 'DNA Mode',
      'Hindi': 'डीएनए मोड',
      'Marathi': 'DNA मोड',
    },
    'Mood Tracker': {
      'English': 'Mood Tracker',
      'Hindi': 'मूड ट्रैकर',
      'Marathi': 'मूड ट्रॅकर',
    },
    'Badges': {
      'English': 'Badges',
      'Hindi': 'बैज',
      'Marathi': 'बॅज',
    },
    'Myths & Facts': {
      'English': 'Myths & Facts',
      'Hindi': 'मिथक और तथ्य',
      'Marathi': 'समजूत आणि तथ्य',
    },
    'Digital Library': {
      'English': 'Digital Library',
      'Hindi': 'डिजिटल लाइब्रेरी',
      'Marathi': 'डिजिटल लायब्ररी',
    },
    'Mantras for You': {
      'English': 'Mantras for You',
      'Hindi': 'आपके लिए मंत्र',
      'Marathi': 'तुमच्यासाठी मंत्र',
    },
    'Exercise & Diet Plan': {
      'English': 'Exercise & Diet Plan',
      'Hindi': 'व्यायाम और आहार योजना',
      'Marathi': 'व्यायाम आणि आहार योजना',
    },
    'Exercises': {
      'English': 'Exercises',
      'Hindi': 'व्यायाम',
      'Marathi': 'व्यायाम',
    },
    'Diet Plan': {
      'English': 'Diet Plan',
      'Hindi': 'आहार योजना',
      'Marathi': 'आहार योजना',
    },
    'Weekly Nutrition Roadmap': {
      'English': 'Weekly Nutrition Roadmap',
      'Hindi': 'साप्ताहिक पोषण रोडमैप',
      'Marathi': 'साप्ताहिक पोषण रोडमॅप',
    },
    'Meal Time': {
      'English': 'Meal Time',
      'Hindi': 'भोजन का समय',
      'Marathi': 'जेवणाची वेळ',
    },
    'Suggested Food': {
      'English': 'Suggested Food',
      'Hindi': 'सुझाया गया भोजन',
      'Marathi': 'सुचवलेले अन्न',
    },
    'Benefits': {
      'English': 'Benefits',
      'Hindi': 'लाभ',
      'Marathi': 'फायदे',
    },
    'Plan for your week': {
      'English': 'Plan for your week',
      'Hindi': 'अपने सप्ताह की योजना बनाएं',
      'Marathi': 'तुमच्या आठवड्याचे नियोजन करा',
    },
    'Nourish your baby': {
      'English': 'Nourish your baby',
      'Hindi': 'अपने बच्चे का पोषण करें',
      'Marathi': 'तुमच्या बाळाचे पोषण करा',
    },
    'Healthy Eating Tip': {
      'English': 'Healthy Eating Tip',
      'Hindi': 'स्वस्थ खाने की टिप',
      'Marathi': 'निरोगी आहार टीप',
    },
    'Drink at least 8-10 glasses of water daily to stay hydrated.': {
      'English': 'Drink at least 8-10 glasses of water daily to stay hydrated.',
      'Hindi': 'हाइड्रेटेड रहने के लिए रोजाना कम से कम 8-10 गिलास पानी पिएं।',
      'Marathi': 'हायड्रेटेड राहण्यासाठी दररोज किमान 8-10 ग्लास पाणी प्या.',
    },
    'Day': {
      'English': 'Day',
      'Hindi': 'दिन',
      'Marathi': 'दिवस',
    },
    'Breakfast': {
      'English': 'Breakfast',
      'Hindi': 'नाश्ता',
      'Marathi': 'न्याहारी',
    },
    'Lunch': {
      'English': 'Lunch',
      'Hindi': 'दोपहर का भोजन',
      'Marathi': 'दुपारचे जेवण',
    },
    'Dinner': {
      'English': 'Dinner',
      'Hindi': 'रात का खाना',
      'Marathi': 'रात्रीचे जेवण',
    },
    'Mon': {'English': 'Mon', 'Hindi': 'सोम', 'Marathi': 'सोम'},
    'Tue': {'English': 'Tue', 'Hindi': 'मंगल', 'Marathi': 'मंगळ'},
    'Wed': {'English': 'Wed', 'Hindi': 'बुध', 'Marathi': 'बुध'},
    'Thu': {'English': 'Thu', 'Hindi': 'गुरु', 'Marathi': 'गुरु'},
    'Fri': {'English': 'Fri', 'Hindi': 'शुक्र', 'Marathi': 'शुक्र'},
    'Sat': {'English': 'Sat', 'Hindi': 'शनि', 'Marathi': 'शनि'},
    'Sun': {'English': 'Sun', 'Hindi': 'रवि', 'Marathi': 'रवि'},
    'Mantras': {
      'English': 'Mantras',
      'Hindi': 'मंत्र',
      'Marathi': 'मंत्र',
    },
    'Myth vs Fact': {
      'English': 'Myth vs Fact',
      'Hindi': 'मिथक बनाम तथ्य',
      'Marathi': 'गैरसमज विरुद्ध तथ्य',
    },
    'Readings': {
      'English': 'Readings',
      'Hindi': 'पठन',
      'Marathi': 'वाचन',
    },
    'Myth': {
      'English': 'Myth',
      'Hindi': 'मिथक',
      'Marathi': 'समजूत/अफवा',
    },
    'Fact': {
      'English': 'Fact',
      'Hindi': 'तथ्य',
      'Marathi': 'तथ्य/सत्य',
    },
    'Myth:': {
      'English': 'Myth:',
      'Hindi': 'मिथक:',
      'Marathi': 'गैरसमज:',
    },
    'Fact:': {
      'English': 'Fact:',
      'Hindi': 'तथ्य:',
      'Marathi': 'सत्य:',
    },
    'Traditional Indian Literature': {
      'English': 'Traditional Indian Literature',
      'Hindi': 'पारंपरिक भारतीय साहित्य',
      'Marathi': 'पारंपारिक भारतीय साहित्य',
    },
    'Great Indian Personalities (Biographies)': {
      'English': 'Great Indian Personalities (Biographies)',
      'Hindi': 'महान भारतीय व्यक्तित्व (जीवनी)',
      'Marathi': 'महान भारतीय व्यक्ती (चरित्रे)',
    },
    'Listen & Meditate': {
      'English': 'Listen & Meditate',
      'Hindi': 'सुनें और ध्यान करें',
      'Marathi': 'ऐका आणि ध्यान करा',
    },
    'Digital Library for You': {
      'English': 'Digital Library for You',
      'Hindi': 'आपके लिए डिजिटल लाइब्रेरी',
      'Marathi': 'तुमच्यासाठी डिजिटल लायब्ररी',
    },
    'Maternal Health Tracker': {
      'English': 'Maternal Health Tracker',
      'Hindi': 'मातृ स्वास्थ्य ट्रैकर',
      'Marathi': 'मातृ आरोग्य ट्रॅकर',
    },
    'AI Assistant': {
      'English': 'AI Assistant',
      'Hindi': 'एआई सहायक',
      'Marathi': 'AI सहाय्यक',
    },
    'Type a message...': {
      'English': 'Type a message...',
      'Hindi': 'एक संदेश लिखें...',
      'Marathi': 'संदेश लिहा...',
    },
    'Assistant is typing...': {
      'English': 'Assistant is typing...',
      'Hindi': 'सहायक टाइप कर रहा है...',
      'Marathi': 'सहाय्यक टाइप करत आहे...',
    },
    'Copied to clipboard': {
      'English': 'Copied to clipboard',
      'Hindi': 'क्लिपबोर्ड पर कॉपी किया गया',
      'Marathi': 'क्लिपबोर्डवर कॉपी केले',
    },
    'Emergency Assistance': {
      'English': 'Emergency Assistance',
      'Hindi': 'आपातकालीन सहायता',
      'Marathi': 'आणीबाणी मदत',
    },
    'SOS Triggered': {
      'English': 'SOS Triggered',
      'Hindi': 'एसओएस ट्रिगर हुआ',
      'Marathi': 'SOS सक्रिय झाले',
    },
    'Help is being notified. We are contacting your doctor, family, and nearby hospitals.': {
      'English': 'Help is being notified. We are contacting your doctor, family, and nearby hospitals.',
      'Hindi': 'मदद के लिए सूचित किया जा रहा है। हम आपके डॉक्टर, परिवार और नजदीकी अस्पतालों से संपर्क कर रहे हैं।',
      'Marathi': 'मदतीसाठी सूचित केले जात आहे. आम्ही तुमचे डॉक्टर, कुटुंब आणि जवळील रुग्णालयांशी संपर्क साधत आहोत.',
    },
    'Quick Emergency Contacts': {
      'English': 'Quick Emergency Contacts',
      'Hindi': 'त्वरित आपातकालीन संपर्क',
      'Marathi': 'त्वरीत आणीबाणी संपर्क',
    },
    'Ambulance': {
      'English': 'Ambulance',
      'Hindi': 'एम्बुलेंस',
      'Marathi': 'रुग्णवाहिका',
    },
    'My Hospital': {
      'English': 'My Hospital',
      'Hindi': 'मेरा अस्पताल',
      'Marathi': 'माझे रुग्णालय',
    },
    'My Doctor': {
      'English': 'My Doctor',
      'Hindi': 'मेरे डॉक्टर',
      'Marathi': 'माझे डॉक्टर',
    },
    'Call Now': {
      'English': 'Call Now',
      'Hindi': 'अभी कॉल करें',
      'Marathi': 'आताच कॉल करा',
    },
    ' km away': {
      'English': ' km away',
      'Hindi': ' किमी दूर',
      'Marathi': ' किमी लांब',
    },
    'Development': {
      'English': 'Development',
      'Hindi': 'विकास',
      'Marathi': 'विकास/वाढ',
    },
    'Baby\'s Development': {
      'English': 'Baby\'s Development',
      'Hindi': 'बच्चे का विकास',
      'Marathi': 'बाळाचा विकास',
    },
    'Mother\'s Body Changes': {
      'English': 'Mother\'s Body Changes',
      'Hindi': 'माँ के शरीर में बदलाव',
      'Marathi': 'आईच्या शरीरातील बदल',
    },
    'Weekly Tips': {
      'English': 'Weekly Tips',
      'Hindi': 'साप्ताहिक सुझाव',
      'Marathi': 'साप्ताहिक टिप्स',
    },
    'AI Mood Tracker': {
      'English': 'AI Mood Tracker',
      'Hindi': 'एआई मूड ट्रैकर',
      'Marathi': 'AI मूड ट्रॅकर',
    },
    'How are you feeling Today?': {
      'English': 'How are you feeling Today?',
      'Hindi': 'आज आप कैसा महसूस कर रहे हैं?',
      'Marathi': 'तुम्हाला आज कसे वाटत आहे?',
    },
    'Scan your face for AI mood detection': {
      'English': 'Scan your face for AI mood detection',
      'Hindi': 'एआई मूड डिटेक्शन के लिए अपना चेहरा स्कैन करें',
      'Marathi': 'AI मूड डिटेक्शनसाठी तुमचा चेहरा स्कॅन करा',
    },
    'AI Scan Face': {
      'English': 'AI Scan Face',
      'Hindi': 'एआई चेहरा स्कैन',
      'Marathi': 'AI चेहरा स्कॅन',
    },
    'Use Sample Video': {
      'English': 'Use Sample Video',
      'Hindi': 'सैंपल वीडियो का उपयोग करें',
      'Marathi': 'नमुना व्हिडिओ वापरा',
    },
    'Face Detected! Analyzing...': {
      'English': 'Face Detected! Analyzing...',
      'Hindi': 'चेहरा मिल गया! विश्लेषण कर रहे हैं...',
      'Marathi': 'चेहरा आढळला! विश्लेषण करत आहे...',
    },
    'Center your face in the frame': {
      'English': 'Center your face in the frame',
      'Hindi': 'अपना चेहरा फ्रेम के बीच में रखें',
      'Marathi': 'तुमचा चेहरा फ्रेममध्ये मध्यभागी ठेवा',
    },
    'Keep still for a moment': {
      'English': 'Keep still for a moment',
      'Hindi': 'एक पल के लिए स्थिर रहें',
      'Marathi': 'क्षणभर स्थिर रहा',
    },
    'Analyzing Video Feed...': {
      'English': 'Analyzing Video Feed...',
      'Hindi': 'वीडियो फीड का विश्लेषण कर रहे हैं...',
      'Marathi': 'व्हिडिओ फीडचे विश्लेषण करत आहे...',
    },
    'AI processing in progress': {
      'English': 'AI processing in progress',
      'Hindi': 'एआई प्रोसेसिंग जारी है',
      'Marathi': 'AI प्रक्रिया सुरू आहे',
    },
    'Face scan done': {
      'English': 'Face scan done',
      'Hindi': 'चेहरा स्कैन हो गया',
      'Marathi': 'चेहरा स्कॅन झाला',
    },
    'You seem to be ': {
      'English': 'You seem to be ',
      'Hindi': 'आप लग रहे हैं ',
      'Marathi': 'तुम्ही वाटत आहात ',
    },
    'Effect on Body': {
      'English': 'Effect on Body',
      'Hindi': 'शरीर पर प्रभाव',
      'Marathi': 'शरीरावर परिणाम',
    },
    'How to Improve': {
      'English': 'How to Improve',
      'Hindi': 'कैसे सुधारें',
      'Marathi': 'कसे सुधारावे',
    },
    'Scan again': {
      'English': 'Scan again',
      'Hindi': 'दोबारा स्कैन करें',
      'Marathi': 'पुन्हा स्कॅन करा',
    },
    'Save & Finish': {
      'English': 'Save & Finish',
      'Hindi': 'सहेजें और समाप्त करें',
      'Marathi': 'जतन करा आणि समाप्त करा',
    },
    'Mood saved! Stay healthy. ✨': {
      'English': 'Mood saved! Stay healthy. ✨',
      'Hindi': 'मूड सहेजा गया! स्वस्थ रहें। ✨',
      'Marathi': 'मूड जतन केला! निरोगी रहा. ✨',
    },
    'Media not initialized': {
      'English': 'Media not initialized',
      'Hindi': 'मीडिया प्रारंभ नहीं हुआ',
      'Marathi': 'मीडिया सुरू झाला नाही',
    },
    'Happy': {'English': 'Happy', 'Hindi': 'खुश', 'Marathi': 'आनंदी'},
    'Sad': {'English': 'Sad', 'Hindi': 'दुखी', 'Marathi': 'दु:खी'},
    'Neutral': {'English': 'Neutral', 'Hindi': 'सामान्य', 'Marathi': 'तटस्थ'},
    'Angry': {'English': 'Angry', 'Hindi': 'गुस्सा', 'Marathi': 'रागावलेले'},
    'Fear': {'English': 'Fear', 'Hindi': 'डर', 'Marathi': 'भीती'},
    'Surprise': {'English': 'Surprise', 'Hindi': 'आश्चर्य', 'Marathi': 'आश्चर्य'},
    'Disgust': {'English': 'Disgust', 'Hindi': 'घृणा', 'Marathi': 'तिरस्कार'},
    'Unlocked!': {
      'English': 'Unlocked!',
      'Hindi': 'अनलॉक किया गया!',
      'Marathi': 'अनलॉक झाले!',
    },
    'Locked': {
      'English': 'Locked',
      'Hindi': 'लॉक किया गया',
      'Marathi': 'कुलूपबंद',
    },
    'Healthy Diet Week': {
      'English': 'Healthy Diet Week',
      'Hindi': 'स्वस्थ आहार सप्ताह',
      'Marathi': 'निरोगी आहार आठवडा',
    },
    'Kick Tracker Champion': {
      'English': 'Kick Tracker Champion',
      'Hindi': 'किक ट्रैकर चैंपियन',
      'Marathi': 'किक ट्रॅकर चॅम्पियन',
    },
    'Calm Mind Star': {
      'English': 'Calm Mind Star',
      'Hindi': 'शांत मन का तारा',
      'Marathi': 'शांत मन तारा',
    },
    'Mindful Mother': {
      'English': 'Mindful Mother',
      'Hindi': 'सचेत माँ',
      'Marathi': 'जागरूक माता',
    },
    'Pregnancy DNA Mode': {
      'English': 'Pregnancy DNA Mode',
      'Hindi': 'गर्भावस्था डीएनए मोड',
      'Marathi': 'गर्भावस्था DNA मोड',
    },
    'Personalized Pregnancy Path': {
      'English': 'Personalized Pregnancy Path',
      'Hindi': 'व्यक्तिगत गर्भावस्था पथ',
      'Marathi': 'वैयक्तिकृत गर्भधारणा पथ',
    },
    'Let\'s create your Personalized Pregnancy Path': {
      'English': 'Let\'s create your Personalized Pregnancy Path',
      'Hindi': 'आइए आपका व्यक्तिगत गर्भावस्था पथ बनाएं',
      'Marathi': 'चला तुमचा वैयक्तिकृत गर्भधारणा पथ तयार करूया',
    },
    'Every pregnancy is unique. Answer these quick questions to unlock a plan that works for you.': {
      'English': 'Every pregnancy is unique. Answer these quick questions to unlock a plan that works for you.',
      'Hindi': 'हर गर्भावस्था अद्वितीय होती है। अपने लिए काम करने वाली योजना को अनलॉक करने के लिए इन त्वरित प्रश्नों के उत्तर दें।',
      'Marathi': 'प्रत्येक गर्भधारणा अद्वितीय असते. तुमच्यासाठी उपयुक्त असलेली योजना अनलॉक करण्यासाठी या प्रश्नांची उत्तरे द्या.',
    },
    '1. Diet Preference': {
      'English': '1. Diet Preference',
      'Hindi': '1. आहार प्राथमिकता',
      'Marathi': '1. आहार प्राधान्य',
    },
    '2. Are you a working professional?': {
      'English': '2. Are you a working professional?',
      'Hindi': '2. क्या आप एक कामकाजी पेशेवर हैं?',
      'Marathi': '2. तुम्ही नोकरी/व्यवसाय करता का?',
    },
    '3. Is this a high-risk pregnancy?': {
      'English': '3. Is this a high-risk pregnancy?',
      'Hindi': '3. क्या यह एक उच्च जोखिम वाली गर्भावस्था है?',
      'Marathi': '3. ही उच्च जोखमीची गर्भधारणा आहे का?',
    },
    '4. Is this your first baby?': {
      'English': '4. Is this your first baby?',
      'Hindi': '4. क्या यह आपका पहला बच्चा है?',
      'Marathi': '4. हे तुमचे पहिले बाळ आहे का?',
    },
    'Vegetarian': {
      'English': 'Vegetarian',
      'Hindi': 'शाकाहारी',
      'Marathi': 'शाकाहारी',
    },
    'Non-Veg': {
      'English': 'Non-Veg',
      'Hindi': 'मांसाहारी',
      'Marathi': 'मांसाहारी',
    },
    'Yes': {'English': 'Yes', 'Hindi': 'हाँ', 'Marathi': 'हो'},
    'No': {'English': 'No', 'Hindi': 'नहीं', 'Marathi': 'नाही'},
    'Generate My Personalized Path': {
      'English': 'Generate My Personalized Path',
      'Hindi': 'मेरा व्यक्तिगत पथ उत्पन्न करें',
      'Marathi': 'माझा वैयक्तिकृत पथ तयार करा',
    },
    'This helps us tailor your milestones and tips.': {
      'English': 'This helps us tailor your milestones and tips.',
      'Hindi': 'यह हमें आपके मील के पत्थर और सुझावों को अनुकूलित करने में मदद करता है।',
      'Marathi': 'हे आम्हाला तुमचे टप्पे आणि टिप्स तयार करण्यात मदत करते.',
    },
    'Please answer all questions': {
      'English': 'Please answer all questions',
      'Hindi': 'कृपया सभी प्रश्नों के उत्तर दें',
      'Marathi': 'कृपया सर्व प्रश्नांची उत्तरे द्या',
    },
    'Profile Updated! Your path is being personalized.': {
      'English': 'Profile Updated! Your path is being personalized.',
      'Hindi': 'प्रोफ़ाइल अपडेट की गई! आपका पथ व्यक्तिगत किया जा रहा है।',
      'Marathi': 'प्रोफाइल अपडेट झाले! तुमचा पथ वैयक्तिकृत केला जात आहे.',
    },
    'Your Doctor': {
      'English': 'Your Doctor',
      'Hindi': 'आपके डॉक्टर',
      'Marathi': 'तुमचे डॉक्टर',
    },
    'Next Appointment': {
      'English': 'Next Appointment',
      'Hindi': 'अगली नियुक्ति',
      'Marathi': 'पुढील अपॉइंटमेंट',
    },
    'Call Doctor': {
      'English': 'Call Doctor',
      'Hindi': 'डॉक्टर को कॉल करें',
      'Marathi': 'डॉक्टरांना कॉल करा',
    },
    'View Hospital': {
      'English': 'View Hospital',
      'Hindi': 'अस्पताल देखें',
      'Marathi': 'रुग्णालय पहा',
    },
    'Doctor Visits': {
      'English': 'Doctor Visits',
      'Hindi': 'डॉक्टर के पास जाना',
      'Marathi': 'डॉक्टर भेटी',
    },
    'Vaccination': {
      'English': 'Vaccination',
      'Hindi': 'टीकाकरण',
      'Marathi': 'लसीकरण',
    },
    'Hospital Info': {
      'English': 'Hospital Info',
      'Hindi': 'अस्पताल की जानकारी',
      'Marathi': 'रुग्णालय माहिती',
    },
    'Doctor Name:': {
      'English': 'Doctor Name:',
      'Hindi': 'डॉक्टर का नाम:',
      'Marathi': 'डॉक्टरांचे नाव:',
    },
    'Hospital:': {
      'English': 'Hospital:',
      'Hindi': 'अस्पताल:',
      'Marathi': 'रुग्णालय:',
    },
    'Phone:': {
      'English': 'Phone:',
      'Hindi': 'फोन:',
      'Marathi': 'फोन:',
    },
    'Address:': {
      'English': 'Address:',
      'Hindi': 'पता:',
      'Marathi': 'पत्ता:',
    },
    'Call': {
      'English': 'Call',
      'Hindi': 'कॉल',
      'Marathi': 'कॉल',
    },
    'Open Map': {
      'English': 'Open Map',
      'Hindi': 'मैप खोलें',
      'Marathi': 'नकाशा उघडा',
    },
    'Scheduled Soon': {
      'English': 'Scheduled Soon',
      'Hindi': 'जल्द ही निर्धारित',
      'Marathi': 'लवकरच नियोजित',
    },
    'No Upcoming': {
      'English': 'No Upcoming',
      'Hindi': 'कोई आगामी नहीं',
      'Marathi': 'पुढील काही नाही',
    },
    'Completed': {
      'English': 'Completed',
      'Hindi': 'पूरा हुआ',
      'Marathi': 'पूर्ण झाले',
    },
    'Upcoming': {
      'English': 'Upcoming',
      'Hindi': 'आगामी',
      'Marathi': 'येणारे',
    },
    'Pending': {
      'English': 'Pending',
      'Hindi': 'लंबित',
      'Marathi': 'प्रलंबित',
    },
    'Doctor\'s Prescribed Vaccinations': {
      'English': 'Doctor\'s Prescribed Vaccinations',
      'Hindi': 'डॉक्टर द्वारा निर्धारित टीकाकरण',
      'Marathi': 'डॉक्टरांनी सुचवलेले लसीकरण',
    },
    'Mother\'s Vaccination Schedule': {
      'English': 'Mother\'s Vaccination Schedule',
      'Hindi': 'माँ का टीकाकरण कार्यक्रम',
      'Marathi': 'मातेचे लसीकरण वेळापत्रक',
    },
    'Child\'s Vaccination Schedule (Birth - 3 Months)': {
      'English': 'Child\'s Vaccination Schedule (Birth - 3 Months)',
      'Hindi': 'बच्चे का टीकाकरण कार्यक्रम (जन्म - 3 महीने)',
      'Marathi': 'बाळाचे लसीकरण वेळापत्रक (जन्म - ३ महिने)',
    },
    'Week 8 Visit': {
      'English': 'Week 8 Visit',
      'Hindi': 'सप्ताह 8 की जाँच',
      'Marathi': 'आठवडा ८ भेट',
    },
    'Week 12 Visit': {
      'English': 'Week 12 Visit',
      'Hindi': 'सप्ताह 12 की जाँच',
      'Marathi': 'आठवडा १२ भेट',
    },
    'Week 20 Anatomy Scan': {
      'English': 'Week 20 Anatomy Scan',
      'Hindi': 'सप्ताह 20 एनाटॉमी स्कैन',
      'Marathi': 'आठवडा २० ॲनाटॉमी स्कॅन',
    },
    'Week 28 Visit': {
      'English': 'Week 28 Visit',
      'Hindi': 'सप्ताह 28 की जाँच',
      'Marathi': 'आठवडा २८ भेट',
    },
    'Week 36 Visit': {
      'English': 'Week 36 Visit',
      'Hindi': 'सप्ताह 36 की जाँच',
      'Marathi': 'आठवडा ३६ भेट',
    },
    'Birth': {
      'English': 'Birth',
      'Hindi': 'जन्म',
      'Marathi': 'जन्म',
    },
    '6 Weeks': {
      'English': '6 Weeks',
      'Hindi': '6 सप्ताह',
      'Marathi': '६ आठवडे',
    },
    '10 Weeks': {
      'English': '10 Weeks',
      'Hindi': '10 सप्ताह',
      'Marathi': '१० आठवडे',
    },
    '1st Trimester': {
      'English': '1st Trimester',
      'Hindi': 'पहली तिमाही',
      'Marathi': 'पहिली तिमाही',
    },
    '2nd Trimester': {
      'English': '2nd Trimester',
      'Hindi': 'दूसरी तिमाही',
      'Marathi': 'दुसरी तिमाही',
    },
    '3rd Trimester': {
      'English': '3rd Trimester',
      'Hindi': 'तीसरी तिमाही',
      'Marathi': 'तिसरी तिमाही',
    },
    'Contact': {
      'English': 'Contact',
      'Hindi': 'संपर्क',
      'Marathi': 'संपर्क',
    },
    'Walking': {
      'English': 'Walking',
      'Hindi': 'पैदल चलना',
      'Marathi': 'चालणे',
    },
    'Swimming': {
      'English': 'Swimming',
      'Hindi': 'तैरना',
      'Marathi': 'पोहणे',
    },
    'Prenatal Yoga': {
      'English': 'Prenatal Yoga',
      'Hindi': 'प्रसवपूर्व योग',
      'Marathi': 'प्रसूतीपूर्व योग',
    },
    'Squats': {
      'English': 'Squats',
      'Hindi': 'उठक-बैठक',
      'Marathi': 'बैठका',
    },
    'Kegels': {
      'English': 'Kegels',
      'Hindi': 'कीगेल',
      'Marathi': 'कीगेल',
    },
    'Cat-Cow Stretch': {
      'English': 'Cat-Cow Stretch',
      'Hindi': 'बिल्ली-गाय स्ट्रेच',
      'Marathi': 'कॅट-काऊ स्ट्रेच',
    },
    'Modified Push-ups': {
      'English': 'Modified Push-ups',
      'Hindi': 'संशोधित पुश-अप्स',
      'Marathi': 'सुधारित पुश-अप्स',
    },
    '20-30 mins': {
      'English': '20-30 mins',
      'Hindi': '20-30 मिनट',
      'Marathi': '२०-३० मिनिटे',
    },
    '20 mins': {
      'English': '20 mins',
      'Hindi': '20 मिनट',
      'Marathi': '२० मिनिटे',
    },
    '15-20 mins': {
      'English': '15-20 mins',
      'Hindi': '15-20 मिनट',
      'Marathi': '१५-२० मिनिटे',
    },
    '3 sets of 10': {
      'English': '3 sets of 10',
      'Hindi': '10 के 3 सेट',
      'Marathi': '१० चे ३ संच',
    },
    '10 reps, 3 times': {
      'English': '10 reps, 3 times',
      'Hindi': '10 बार, 3 बार',
      'Marathi': '१० पुनरावृत्ती, ३ वेळा',
    },
    '10-12 reps': {
      'English': '10-12 reps',
      'Hindi': '10-12 बार',
      'Marathi': '१०-१२ पुनरावृत्ती',
    },
    '2 sets of 8': {
      'English': '2 sets of 8',
      'Hindi': '8 के 2 सेट',
      'Marathi': '८ चे २ संच',
    },
    'Baby size': {
      'English': 'Baby size',
      'Hindi': 'बच्चे का आकार',
      'Marathi': 'बाळाचा आकार',
    },
    'My Achievements': {
      'English': 'My Achievements',
      'Hindi': 'मेरी उपलब्धियां',
      'Marathi': 'माझ्या उपलब्धी',
    },
    'Pregnancy Milestones': {
      'English': 'Pregnancy Milestones',
      'Hindi': 'गर्भावस्था के पड़ाव',
      'Marathi': 'गर्भधारणेचे टप्पे',
    },
    'Traditional tips & facts': {
      'English': 'Traditional tips & facts',
      'Hindi': 'पारंपरिक सुझाव और तथ्य',
      'Marathi': 'पारंपारिक टिप्स आणि तथ्ये',
    },
    'View your badges & progress': {
      'English': 'View your badges & progress',
      'Hindi': 'अपने बैज और प्रगति देखें',
      'Marathi': 'तुमचे बॅज आणि प्रगती पहा',
    },
    'Emotional well-being': {
      'English': 'Emotional well-being',
      'Hindi': 'भावनात्मक कल्याण',
      'Marathi': 'भावनिक निरोगीपणा',
    },
    'Weekly details': {
      'English': 'Weekly details',
      'Hindi': 'साप्ताहिक विवरण',
      'Marathi': 'साप्ताहिक तपशील',
    },
  };

  String tr(String key) {
    if (!_translations.containsKey(key)) return key;
    return _translations[key]![language.value] ?? key;
  }

  void toggleNotifications(bool enabled) {
    notificationsEnabled.value = enabled;
  }

  void setLanguage(String lang) {
    language.value = lang;
  }
}
