import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank Loan Chatbot',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardColor: const Color(0xFF2D2D2D),
      ),
      home: const ChatbotScreen(),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  String? selectedLoanType;
  int currentStep = 0;
  Map<String, String> userInfo = {};

  // Loan Information Database
  final Map<String, Map<String, dynamic>> loanData = {
    'Personal Loan': {
      'Eligibility': {
        'age': '21-60 years',
        'Nationality': 'Indian',
        'income': '₹25,000 to ₹50,000 monthly',
        'credit_score': '650+',
      },
      'Documents Required': [
        'Aadhar Card',
        'Pan Card',
        'Passport size photograph',
        'Income Documents or Bank statements',
        'Employment proof'
      ],
      'process': [
        'Fill online application',
        'Submit Required Documents',
        'Loan disbursement'
      ],
      'schemes': [
        'Scheme A: 10.5% interest for 1-3 years',
        'Scheme B: 11.5% interest for 3-5 years',
      ]
    },
    'Education Loan': {
      'Eligibility': {
        'age': '16-35 years',
        'Nationality': 'Indian',
        'income': 'Parent/Guardian income ₹20,000+',
        'academic': 'Admission in Recognised Intitution',
        'Course': 'Graduate,Post-graduate,Professional,Vocasional',
      },
      'Documents Required': [
        'Aadhar Card',
        'Pan Card',
        'Passport size photograph',
        'Income Documents or Bank statements',
        'Academic proof'
      ],
      'process': [
        'Submit admission proof',
        'Provide academic records',
        'Parent/Guardian documents',
        'College fee structure'
      ],
      'schemes': [
        'Domestic: 8.5% interest with 5-15 years tenure',
        'International: 9.5% interest with 5-15 years tenure',
      ]
    },
    'Business Loan': {
      'Eligibility': {
        'age': '21-65 years',
        'business_age': '3+ years',
        'turnover': '₹10 lakhs annually',
        'profitability': 'consistent',
      },
      'Documents Required': [
        'Aadhar Card',
        'Pan Card',
        'Passport size photograph',
        'Financial statements - profit,loss statement',
        'Business document - Registeration GST certificate',
        'Bank statements',
        'Address proof'
      ],
      'process': [
        'Submit business documents',
        'Provide financial statements',
        'Business verification',
        'Loan approval'
      ],
      'schemes': [
        'Term Loan: 12% interest for 1-7 years',
        'Working Capital: 11% interest, renewable yearly',
      ]
    },
    'Gold Loan': {
      'Eligibility': {
        'age': '18+ years',
        'Income': 'No minimum income',
        'gold_purity': '18-24 karat',
      },
      'Documents Required': [
        'Aadhar Card',
        'Pan Card',
        'Passport size photograph',
        'Income Documents or Bank statements',
        'Employment proof'
      ],
      'process': [
        'Gold assessment',
        'Document verification',
        'Value calculation',
        'Immediate disbursement'
      ],
      'schemes': [
        'Regular: 7.5% interest for 3-12 months',
        'Flexi: 8.5% interest for 12-24 months',
      ]
    },
    'Home Loan': {
      'Eligibility': {
        'age': '21-65 years',
        'income': '₹25k-50k monthly',
        'property': 'Approved project',
      },
      'Documents Required': [
        'Aadhar Card',
        'Pan Card',
        'Passport size photograph',
        'Income Documents or Bank statements',
        'Address proof',
        'Property Documents - Registeration papers'
      ],
      'process': [
        'Property selection',
        'Document submission',
        'Property verification',
        'Loan disbursement'
      ],
      'schemes': [
        'Salaried: 8% interest for 5-30 years',
        'Self-employed: 8.5% interest for 5-30 years',
      ]
    },
    'Vehicle Loan': {
      'Eligibility': {
        'age': '21-65 years',
        'income': '₹25k-50k monthly',
        'vehicle': 'New/Used up to 5 years',
      },
      'Documents Required': [
        'Aadhar Card',
        'Pan Card',
        'Passport size photograph',
        'Income Documents or Bank statements',
        'Address proof',
        'Vehicle Quotation'
      ],
      'process': [
        'Choose vehicle',
        'Submit documents',
        'Vehicle inspection',
        'Loan processing'
      ],
      'schemes': [
        'New Vehicle: 7.5% interest for 1-7 years',
        'Used Vehicle: 9% interest for 1-5 years',
      ]
    },
  };

  void addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
      ));
    });
  }

  void handleUserInput(String input) {
    if (input.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: input, isUser: true));
      _controller.clear();

      // Process user input based on current step
      switch (currentStep) {
        case 1: // Age input
          if (input.contains(RegExp(r'\d+'))) {
            userInfo['age'] = input.replaceAll(RegExp(r'[^\d]'), '');
            addBotMessage(
                "What is your monthly income? (Please specify the amount)");
            currentStep = 2;
          } else {
            addBotMessage("Please provide your age as a number.");
          }
          break;

        case 2: // Income input
          if (input.contains(RegExp(r'\d+'))) {
            userInfo['income'] = input.replaceAll(RegExp(r'[^\d]'), '');
            checkEligibility();
          } else {
            addBotMessage("Please provide your income as a number.");
          }
          break;

        default:
          processGeneralInput(input);
      }
    });
  }

  void selectLoanType(String type) {
    setState(() {
      selectedLoanType = type;
      _messages.add(ChatMessage(
        text: "You've selected $type. Let me help you check your eligibility.",
        isUser: false,
      ));
      _messages.add(ChatMessage(
        text: "Please provide your age:",
        isUser: false,
      ));
      currentStep = 1;
    });
  }

  // ... (previous imports and class definitions remain the same until checkEligibility function)

  // ... (previous imports and class definitions remain the same until checkEligibility function)

  void checkEligibility() {
    if (selectedLoanType == null ||
        userInfo['age'] == null ||
        userInfo['income'] == null) {
      return;
    }

    int age = int.parse(userInfo['age']!);
    int income = int.parse(userInfo['income']!);
    bool isEligible = false;

    // Updated eligibility check based on new criteria
    switch (selectedLoanType) {
      case 'Personal Loan':
        // Using previous updated criteria
        isEligible = age >= 21 && age <= 60 && income >= 25000;
        break;
      case 'Education Loan':
        // Updated criteria for students (assuming student application)
        isEligible = age >= 16 &&
            age <= 35; // Income not a primary factor for education loans
        break;
      case 'Business Loan':
        // Using previous updated criteria
        isEligible = age >= 21 && age <= 65 && income >= (10 * 100000 / 12);
        break;
      case 'Gold Loan':
        // Updated criteria - mainly age based since no income requirement
        isEligible = age >= 18 && age <= 70;
        break;
      case 'Home Loan':
        // Updated criteria
        isEligible =
            age >= 21 && age <= 65 && income >= 25000; // Using salaried minimum
        break;
      case 'Vehicle Loan':
        // Using previous updated criteria
        isEligible = age >= 21 && age <= 60 && income >= 25000;
        break;
    }

    // Update the loan requirements in the database
    loanData['Home Loan']?['requirements'] = {
      'age': '21-65 years',
      'nationality': 'Indian resident',
      'income': '₹25,000/month (salaried), ₹50,000/month (self-employed)',
      'credit_score': '650+',
      'employment': '2+ years (salaried), 3+ years (self-employed)',
      'property': 'New or resale residential property',
    };

    loanData['Education Loan']?['requirements'] = {
      'age': '16-35 years (students), 21-55 years (co-borrowers)',
      'nationality': 'Indian resident',
      'academic': 'Secured admission to recognized institution',
      'course':
          'Approved courses (graduate, postgraduate, professional, vocational)',
      'institution': 'Recognized institutions in India or abroad',
      'credit_score': 'Good credit history (for co-borrowers)',
    };

    loanData['Gold Loan']?['requirements'] = {
      'age': '18-70 years',
      'residency': 'Indian resident',
      'income': 'No minimum requirement',
      'credit_score': 'No requirement',
      'gold_ownership': 'Must own gold ornaments/jewelry to be pledged',
    };

    // Maintain previous updated requirements for other loan types
    loanData['Personal Loan']?['requirements'] = {
      'age': '21-60 years',
      'nationality': 'Indian resident',
      'income': '₹25,000/month (salaried), ₹50,000/month (self-employed)',
      'credit_score': '650+',
      'employment': '2+ years (salaried), 3+ years (self-employed)',
      'debt_ratio': 'Less than 50%',
    };

    loanData['Business Loan']?['requirements'] = {
      'age': '21-65 years',
      'nationality': 'Indian resident',
      'business': 'Minimum 3 years or viable new venture',
      'credit_score': '650+',
      'turnover': 'Minimum ₹10 lakhs annually',
      'profitability': 'Consistent profitability required',
    };

    loanData['Vehicle Loan']?['requirements'] = {
      'age': '21-60 years',
      'nationality': 'Indian resident',
      'income': '₹25,000/month (salaried), ₹50,000/month (self-employed)',
      'credit_score': '650+',
      'employment': '2+ years (salaried), 3+ years (self-employed)',
      'vehicle': 'New or used cars, SUVs, motorcycles',
    };

    var loanInfo = loanData[selectedLoanType!]!;

    if (isEligible) {
      addBotMessage(
          "Good news! Based on your profile, you are eligible for the ${selectedLoanType}!");
      addBotMessage(
          "Documents Required:\n${loanInfo['Documents Required'].join('\n')}");
      addBotMessage("Loan Process:\n${loanInfo['process'].join('\n')}");
      addBotMessage("Available Schemes:\n${loanInfo['schemes'].join('\n')}");
    } else {
      addBotMessage(
          "Based on our assessment, you might not be eligible for ${selectedLoanType} at this time.");
      addBotMessage("Requirements for ${selectedLoanType}:\n" +
          loanInfo['Eligibility']
              .entries
              .map((e) => "${e.key}: ${e.value}")
              .join('\n'));
    }

    currentStep = 0;
  }

// ... (rest of the code remains the same)

  void processGeneralInput(String input) {
    input = input.toLowerCase();

    if (input.contains('hello') || input.contains('hi')) {
      addBotMessage(
          "Hello! Please select a loan type to check your eligibility.");
    } else if (input.contains('help')) {
      addBotMessage(
          "I can help you check loan eligibility and provide information about different loan types. Please select a loan type from the options above.");
    } else if (input.contains('reset')) {
      resetChat();
    } else {
      addBotMessage(
          "Please select a loan type from the options above to proceed.");
    }
  }

  void resetChat() {
    setState(() {
      _messages.clear();
      selectedLoanType = null;
      currentStep = 0;
      userInfo.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LoanOk Assistant',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: resetChat,
                  ),
                ],
              ),
            ),

            // Loan Type Selection
            if (_messages.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Loan Type',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.amber,
                          ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: loanData.length,
                      itemBuilder: (context, index) {
                        String loanType = loanData.keys.elementAt(index);
                        return Card(
                          child: InkWell(
                            onTap: () => selectLoanType(loanType),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getLoanIcon(loanType),
                                    size: 32,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    loanType,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            // Chat Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _messages[index],
              ),
            ),

            // Input Field
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: handleUserInput,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => handleUserInput(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Add this method to _ChatbotScreenState
  IconData _getLoanIcon(String loanType) {
    switch (loanType) {
      case 'Personal Loan':
        return Icons.person;
      case 'Education Loan':
        return Icons.school;
      case 'Business Loan':
        return Icons.business;
      case 'Gold Loan':
        return Icons.monetization_on;
      case 'Home Loan':
        return Icons.home;
      case 'Vehicle Loan':
        return Icons.directions_car;
      default:
        return Icons.attach_money;
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 12.0),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.android, color: Colors.white, size: 20),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.amber : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
