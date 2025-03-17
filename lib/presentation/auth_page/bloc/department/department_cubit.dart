import 'package:budgeit/presentation/auth_page/bloc/department/department_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentCubit extends Cubit<DepartmentState> {
  DepartmentCubit()
      : super(DepartmentState(
    departments: [
      {
        "name": "College of Allied Medical Sciences",
        "programs": [
          "Bachelor of Science in Medical Technology / Medical Laboratory Science",
          "Bachelor of Science in Radiologic Technology",
          "Bachelor of Science in Physical Therapy",
          "Bachelor of Science in Occupational Therapy",
          "Bachelor of Science in Respiratory Therapy",
          "Bachelor of Science in Pharmacy",
          "Bachelor of Science in Nutrition and Dietetics",
          "Others"
        ]
      },
      {
        "name": "College of Arts and Sciences",
        "programs": [
          "Bachelor of Arts in Communication",
          "Bachelor of Arts in Political Science",
          "Bachelor of Arts in Psychology",
          "Bachelor of Arts in Sociology",
          "Bachelor of Arts in Philosophy",
          "Bachelor of Arts in Literature",
          "Bachelor of Arts in History",
          "Bachelor of Arts in International Studies",
          "Bachelor of Science in Biology",
          "Bachelor of Science in Mathematics",
          "Bachelor of Science in Environmental Science",
          "Others"
        ]
      },
      {
        "name": "College of Business, Accountancy and Hospitality Management",
        "programs": [
          "Bachelor of Science in Accountancy (BSA)",
          "Bachelor of Science in Business Administration (BSBA) (majors: Marketing, Financial Management, Human Resource Management, Operations Management)",
          "Bachelor of Science in Management Accounting (BSMA)",
          "Bachelor of Science in Hospitality Management",
          "Bachelor of Science in Tourism Management",
          "Bachelor of Science in Entrepreneurship",
          "Bachelor of Science in Customs Administration",
          "Others"
        ]
      },
      {
        "name": "College of Criminal Justice Education",
        "programs": [
          "Bachelor of Science in Criminology",
          "Bachelor of Forensic Science",
          "Bachelor of Science in Industrial Security Management",
          "Bachelor of Science in Security Administration and Management",
          "Bachelor of Science in Cyber Criminology",
          "Bachelor of Science in Disaster Risk Management",
          "Others"
        ]
      },
      {
        "name": "College of Education",
        "programs": [
          "Bachelor of Elementary Education (BEEd)",
          "Bachelor of Secondary Education (BSEd) (majors: English, Math, Science, Social Studies, Filipino, etc.)",
          "Bachelor of Early Childhood Education",
          "Bachelor of Special Needs Education",
          "Bachelor of Physical Education",
          "Bachelor of Technical-Vocational Teacher Education",
          "Others"
        ]
      },
      {
        "name": "College of Engineering",
        "programs": [
          "Bachelor of Science in Mechanical Engineering",
          "Bachelor of Science in Electrical Engineering",
          "Bachelor of Science in Electronics Engineering",
          "Bachelor of Science in Computer Engineering",
          "Bachelor of Science in Industrial Engineering",
          "Bachelor of Science in Chemical Engineering",
          "Bachelor of Science in Mechatronics Engineering",
          "Bachelor of Science in Biomedical Engineering",
          "Others"
        ]
      },
      {
        "name": "College of Industrial Technology",
        "programs": [
          "Bachelor of Science in Industrial Technology (majors: Automotive, Electrical, Mechanical, Electronics, Civil, Drafting, Welding, etc.)",
          "Bachelor of Technical-Vocational Teacher Education (BTTE)",
          "Associate in Industrial Technology",
          "Bachelor of Science in Heating, Ventilation, and Air Conditioning (HVAC) Technology",
          "Bachelor of Science in Automotive Technology",
          "Bachelor of Science in Welding and Fabrication Technology",
          "Bachelor of Science in Garments, Fashion, and Design Technology",
          "Others"
        ]
      },
      {
        "name": "College of Information and Communications Technology",
        "programs": [
          "Bachelor of Science in Information Technology (BSIT)",
          "Bachelor of Science in Computer Science (BSCS)",
          "Bachelor of Science in Information Systems (BSIS)",
          "Bachelor of Science in Data Science",
          "Bachelor of Science in Entertainment and Multimedia Computing",
          "Bachelor of Science in Cybersecurity",
          "Bachelor of Science in Software Engineering",
          "Bachelor of Science in Artificial Intelligence and Machine Learning",
          "Bachelor of Science in Game Development and Animation",
          "Bachelor of Science in Cloud Computing and Virtualization",
          "Others"
        ]
      },
      {
        "name": "College of Nursing and Midwifery",
        "programs": [
          "Bachelor of Science in Nursing (BSN)",
          "Bachelor of Science in Midwifery",
          "Bachelor of Science in Community Health Nursing",
          "Bachelor of Science in Gerontology Nursing",
          "Bachelor of Science in Psychiatric Nursing",
          "Bachelor of Science in Emergency and Trauma Nursing",
          "Others"
        ]
      }
    ],
    selectedDepartment: null,
  ));

  void selectDepartment(String department) {
    emit(state.copyWith(selectedDepartment: department));
  }
}