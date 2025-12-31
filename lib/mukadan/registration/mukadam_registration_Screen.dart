// lib/main.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mukadam_bi/mukadan/registration/registration_Service.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart'; // Import the image_picker package


// --- Section Widgets (These remain the same as your previous optimized code) ---

class BasicDetailsSection extends StatelessWidget {
  final TextEditingController mukkadamNameController;
  final TextEditingController mobileNumbersController;
  final TextEditingController villageController;
  final TextEditingController crewSizeController;
  final bool isPermanent;
  final ValueChanged<bool?> onIsPermanentChanged;
  final String? hasSmartphone;
  final ValueChanged<String?> onHasSmartphoneChanged;

  const BasicDetailsSection({
    super.key,
    required this.mukkadamNameController,
    required this.mobileNumbersController,
    required this.villageController,
    required this.crewSizeController,
    required this.isPermanent,
    required this.onIsPermanentChanged,
    required this.hasSmartphone,
    required this.onHasSmartphoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: mukkadamNameController,
            decoration: const InputDecoration(labelText: 'Mukkadam Name *', border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter mukkadam name';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: mobileNumbersController,
            decoration: const InputDecoration(labelText: 'Mobile Numbers *', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter mobile numbers';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: villageController,
            decoration: const InputDecoration(labelText: 'Village *', border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter village';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: crewSizeController,
            decoration: const InputDecoration(labelText: 'Crew Size', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            title: const Text('Is Permanent'),
            value: isPermanent,
            onChanged: onIsPermanentChanged,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const Text('Has Smartphone?'),
          Row(
            children: [
              Radio<String>(
                value: 'yes',
                groupValue: hasSmartphone,
                onChanged: onHasSmartphoneChanged,
              ),
              const Text('Yes'),
              Radio<String>(
                value: 'no',
                groupValue: hasSmartphone,
                onChanged: onHasSmartphoneChanged,
              ),
              const Text('No'),
            ],
          ),
        ],
      ),
    );
  }
}

class CrewDetailsSection extends StatelessWidget {
  final TextEditingController maxCrewCapacityController;
  final TextEditingController splittingLogicController;
  final TextEditingController deputyMukkadamNameController;
  final TextEditingController deputyMukkadamMobileController;
  final TextEditingController teamMemberNameController;
  final TextEditingController teamMemberAgeController;
  final String? teamMemberGender;
  final ValueChanged<String?> onTeamMemberGenderChanged;
  final TextEditingController teamMemberMobileController;
  final TextEditingController teamMemberAadharController;

  const CrewDetailsSection({
    super.key,
    required this.maxCrewCapacityController,
    required this.splittingLogicController,
    required this.deputyMukkadamNameController,
    required this.deputyMukkadamMobileController,
    required this.teamMemberNameController,
    required this.teamMemberAgeController,
    required this.teamMemberGender,
    required this.onTeamMemberGenderChanged,
    required this.teamMemberMobileController,
    required this.teamMemberAadharController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: maxCrewCapacityController,
            decoration: const InputDecoration(labelText: 'Max Crew Capacity', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: splittingLogicController,
            decoration: const InputDecoration(labelText: 'Splitting Logic', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: deputyMukkadamNameController,
            decoration: const InputDecoration(labelText: 'Deputy Mukkadam Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: deputyMukkadamMobileController,
            decoration: const InputDecoration(labelText: 'Deputy Mukkadam Mobile', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          const Text('Team Member (Simplified - for dynamic lists, consider `ListView.builder`)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextFormField(
            controller: teamMemberNameController,
            decoration: const InputDecoration(labelText: 'Member Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: teamMemberAgeController,
            decoration: const InputDecoration(labelText: 'Member Age', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: teamMemberGender,
            decoration: const InputDecoration(labelText: 'Member Gender', border: OutlineInputBorder()),
            items: const <String>['Male', 'Female', 'Other']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onTeamMemberGenderChanged,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: teamMemberMobileController,
            decoration: const InputDecoration(labelText: 'Member Mobile', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: teamMemberAadharController,
            decoration: const InputDecoration(labelText: 'Member Aadhar (Optional)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class ChildrenDetailsSection extends StatelessWidget {
  final TextEditingController numberOfChildrenController;
  final TextEditingController childrenCaretakerController;

  const ChildrenDetailsSection({
    super.key,
    required this.numberOfChildrenController,
    required this.childrenCaretakerController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: numberOfChildrenController,
            decoration: const InputDecoration(labelText: 'Number of Children', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: childrenCaretakerController,
            decoration: const InputDecoration(labelText: 'Children Caretaker', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}

class AvailabilitySection extends StatelessWidget {
  // Changed to TextEditingController
  final TextEditingController startDateController;
  final VoidCallback onSelectStartDate;
  // Changed to TextEditingController
  final TextEditingController endDateController;
  final VoidCallback onSelectEndDate;
  final TextEditingController dailyWorkTimingController;

  const AvailabilitySection({
    super.key,
    required this.startDateController, // Updated constructor
    required this.onSelectStartDate,
    required this.endDateController, // Updated constructor
    required this.onSelectEndDate,
    required this.dailyWorkTimingController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onSelectStartDate,
            child: AbsorbPointer(
              child: TextFormField(
                controller: startDateController, // Assigned controller
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  hintText: 'Select Start Date', // Hint text for initial state
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onSelectEndDate,
            child: AbsorbPointer(
              child: TextFormField(
                controller: endDateController, // Assigned controller
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  hintText: 'Select End Date', // Hint text for initial state
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: dailyWorkTimingController,
            decoration: const InputDecoration(labelText: 'Daily Work Timing', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}

class RateCardSection extends StatelessWidget {
  final TextEditingController pruningRateController;
  final TextEditingController pastingRateController;
  final TextEditingController harvestingRateController;
  final TextEditingController defaultRateController;

  const RateCardSection({
    super.key,
    required this.pruningRateController,
    required this.pastingRateController,
    required this.harvestingRateController,
    required this.defaultRateController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: pruningRateController,
            decoration: const InputDecoration(labelText: 'Pruning Rate', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: pastingRateController,
            decoration: const InputDecoration(labelText: 'Pasting Rate', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: harvestingRateController,
            decoration: const InputDecoration(labelText: 'Harvesting Rate', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: defaultRateController,
            decoration: const InputDecoration(labelText: 'Default Rate', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class LocationIssuesSection extends StatelessWidget {
  final TextEditingController issueVillageController;
  final TextEditingController issueDistrictController;
  final TextEditingController issueReasonController;
  final String? issueSeverity;
  final ValueChanged<String?> onIssueSeverityChanged;

  const LocationIssuesSection({
    super.key,
    required this.issueVillageController,
    required this.issueDistrictController,
    required this.issueReasonController,
    required this.issueSeverity,
    required this.onIssueSeverityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: issueVillageController,
            decoration: const InputDecoration(labelText: 'Issue Village', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: issueDistrictController,
            decoration: const InputDecoration(labelText: 'Issue District', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: issueReasonController,
            decoration: const InputDecoration(labelText: 'Issue Reason', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: issueSeverity,
            decoration: const InputDecoration(labelText: 'Issue Severity', border: OutlineInputBorder()),
            items: const <String>['Low', 'Medium', 'High']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onIssueSeverityChanged,
          ),
        ],
      ),
    );
  }
}

class WorkAreaPreferenceSection extends StatelessWidget {
  final TextEditingController homeLocationController;
  final TextEditingController preferredWorkLocationsController;
  final TextEditingController maxTravelDistanceController;

  const WorkAreaPreferenceSection({
    super.key,
    required this.homeLocationController,
    required this.preferredWorkLocationsController,
    required this.maxTravelDistanceController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: homeLocationController,
            decoration: const InputDecoration(labelText: 'Home Location', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: preferredWorkLocationsController,
            decoration: const InputDecoration(labelText: 'Preferred Work Locations', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: maxTravelDistanceController,
            decoration: const InputDecoration(labelText: 'Max Travel Distance', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class TransportDetailsSection extends StatelessWidget {
  final String? transportMode;
  final ValueChanged<String?> onTransportModeChanged;
  final String? transportArrangedBy;
  final ValueChanged<String?> onTransportArrangedByChanged;
  final TextEditingController perKmChargeController;
  final TextEditingController dailyRateChargeController;
  final bool includesFuel;
  final ValueChanged<bool?> onIncludesFuelChanged;

  const TransportDetailsSection({
    super.key,
    required this.transportMode,
    required this.onTransportModeChanged,
    required this.transportArrangedBy,
    required this.onTransportArrangedByChanged,
    required this.perKmChargeController,
    required this.dailyRateChargeController,
    required this.includesFuel,
    required this.onIncludesFuelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: transportMode,
            decoration: const InputDecoration(labelText: 'Transport Mode', border: OutlineInputBorder()),
            items: const <String>['own_vehicle', 'no_vehicle', 'public_transport']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onTransportModeChanged,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: transportArrangedBy,
            decoration: const InputDecoration(labelText: 'Transport Arranged By', border: OutlineInputBorder()),
            items: const <String>['mukkadam', 'company', 'self']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onTransportArrangedByChanged,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: perKmChargeController,
            decoration: const InputDecoration(labelText: 'Charges Per KM', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: dailyRateChargeController,
            decoration: const InputDecoration(labelText: 'Daily Rate Charges', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            title: const Text('Includes Fuel'),
            value: includesFuel,
            onChanged: onIncludesFuelChanged,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class PaymentDetailsSection extends StatelessWidget {
  final String? paymentMode;
  final ValueChanged<String?> onPaymentModeChanged;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final TextEditingController ifscCodeController;
  final TextEditingController upiIdController;
  final String? paymentFrequency;
  final ValueChanged<String?> onPaymentFrequencyChanged;
  final bool advanceRequired;
  final ValueChanged<bool?> onAdvanceRequiredChanged;

  const PaymentDetailsSection({
    super.key,
    required this.paymentMode,
    required this.onPaymentModeChanged,
    required this.bankNameController,
    required this.accountNumberController,
    required this.ifscCodeController,
    required this.upiIdController,
    required this.paymentFrequency,
    required this.onPaymentFrequencyChanged,
    required this.advanceRequired,
    required this.onAdvanceRequiredChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: paymentMode,
            decoration: const InputDecoration(labelText: 'Payment Mode', border: OutlineInputBorder()),
            items: const <String>['bank_transfer', 'cash', 'upi']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onPaymentModeChanged,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: bankNameController,
            decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: accountNumberController,
            decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: ifscCodeController,
            decoration: const InputDecoration(labelText: 'IFSC Code', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: upiIdController,
            decoration: const InputDecoration(labelText: 'UPI ID', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: paymentFrequency,
            decoration: const InputDecoration(labelText: 'Payment Frequency', border: OutlineInputBorder()),
            items: const <String>['weekly', 'monthly', 'daily', 'per_project']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onPaymentFrequencyChanged,
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            title: const Text('Advance Required'),
            value: advanceRequired,
            onChanged: onAdvanceRequiredChanged,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class WorkModeSection extends StatelessWidget {
  final String? workMode;
  final ValueChanged<String?> onWorkModeChanged;
  final TextEditingController moveInPreferredRegionController;

  const WorkModeSection({
    super.key,
    required this.workMode,
    required this.onWorkModeChanged,
    required this.moveInPreferredRegionController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: workMode,
            decoration: const InputDecoration(labelText: 'Work Mode', border: OutlineInputBorder()),
            items: const <String>['move_in', 'daily_up_down']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onWorkModeChanged,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: moveInPreferredRegionController,
            decoration: const InputDecoration(labelText: 'Move-in Preferred Region', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}

class ReferralSection extends StatelessWidget {
  final List<dynamic> referralOptions;
  final dynamic selectedReferral;
  final ValueChanged<dynamic> onReferralChanged;
  final TextEditingController referredByController;
  final TextEditingController referralSourceTextController;

  const ReferralSection({
    super.key,
    required this.referralOptions,
    required this.selectedReferral,
    required this.onReferralChanged,
    required this.referredByController,
    required this.referralSourceTextController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<dynamic>(
            value: selectedReferral,
            hint: const Text("Select Referral Source"),
            decoration: const InputDecoration(
                labelText: 'Referral Source',
                border: OutlineInputBorder()
            ),
            items: referralOptions.map<DropdownMenuItem<dynamic>>((dynamic item) {
              return DropdownMenuItem<dynamic>(
                value: item,
                child: Text(item['name']?.toString() ?? 'Unknown'),
              );
            }).toList(),
            onChanged: onReferralChanged,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: referredByController,
            decoration: const InputDecoration(
                labelText: 'Referred By (Mukkadam ID)',
                border: OutlineInputBorder()
            ),
            keyboardType: TextInputType.number,
            readOnly: true, // Set to true since it's auto-filled by dropdown
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: referralSourceTextController,
            decoration: const InputDecoration(
                labelText: 'Referral Source Text',
                border: OutlineInputBorder()
            ),
          ),
        ],
      ),
    );
  }
}


class NotificationPreferencesSection extends StatelessWidget {
  final bool whatsappNotifications;
  final ValueChanged<bool?> onWhatsappNotificationsChanged;
  final bool smsNotifications;
  final ValueChanged<bool?> onSmsNotificationsChanged;
  final bool callNotifications;
  final ValueChanged<bool?> onCallNotificationsChanged;
  final TextEditingController preferredTimeController;
  final TextEditingController languageController;

  const NotificationPreferencesSection({
    super.key,
    required this.whatsappNotifications,
    required this.onWhatsappNotificationsChanged,
    required this.smsNotifications,
    required this.onSmsNotificationsChanged,
    required this.callNotifications,
    required this.onCallNotificationsChanged,
    required this.preferredTimeController,
    required this.languageController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: whatsappNotifications,
                onChanged: onWhatsappNotificationsChanged,
              ),
              const Text('WhatsApp'),
              Checkbox(
                value: smsNotifications,
                onChanged: onSmsNotificationsChanged,
              ),
              const Text('SMS'),
              Checkbox(
                value: callNotifications,
                onChanged: onCallNotificationsChanged,
              ),
              const Text('Call'),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: preferredTimeController,
            decoration: const InputDecoration(labelText: 'Preferred Time for Notifications', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: languageController,
            decoration: const InputDecoration(labelText: 'Notification Language', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}


class CaptureLocationSection extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final VoidCallback onFetchLocation;
  final VoidCallback onCapturePhoto;
  final String? capturedImagePath;

  const CaptureLocationSection({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    required this.onFetchLocation,
    required this.onCapturePhoto,
    this.capturedImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onFetchLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Fetch GPS'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: onCapturePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Photo'),
              ),
            ],
          ),
          if (capturedImagePath != null) ...[
            const SizedBox(height: 10),
            Text(
              'Photo captured: ${capturedImagePath!.split('/').last}',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}


class OtherInfoSection extends StatelessWidget {
  final TextEditingController otherCommitmentsController;

  const OtherInfoSection({
    super.key,
    required this.otherCommitmentsController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: otherCommitmentsController,
            decoration: const InputDecoration(labelText: 'Other Commitments', border: OutlineInputBorder()),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}




class IDNumbersSection extends StatelessWidget {
  final TextEditingController aadharNumberController;
  final TextEditingController panNumberController;

  const IDNumbersSection({
    super.key,
    required this.aadharNumberController,
    required this.panNumberController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: aadharNumberController,
            decoration: const InputDecoration(labelText: 'Aadhar Number', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: panNumberController,
            decoration: const InputDecoration(labelText: 'PAN Number', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}

class FileUploadsSection extends StatelessWidget {
  final VoidCallback onUploadProfilePhoto;
  final VoidCallback onUploadAadharCard;
  final VoidCallback onUploadPanCard;
  final VoidCallback onUploadBankProof;

  const FileUploadsSection({
    super.key,
    required this.onUploadProfilePhoto,
    required this.onUploadAadharCard,
    required this.onUploadPanCard,
    required this.onUploadBankProof,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: onUploadProfilePhoto,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Profile Photo'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onUploadAadharCard,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Aadhar Card'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onUploadPanCard,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload PAN Card'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onUploadBankProof,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Bank Proof'),
          ),
        ],
      ),
    );
  }
}


// --- Main Registration Screen ---

class MukkadamRegistrationScreen extends StatefulWidget {
  const MukkadamRegistrationScreen({super.key});

  @override
  State<MukkadamRegistrationScreen> createState() => _MukkadamRegistrationScreenState();
}

class _MukkadamRegistrationScreenState extends State<MukkadamRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Basic Details
  final TextEditingController _mukkadamNameController = TextEditingController();
  final TextEditingController _mobileNumbersController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _crewSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReferralSources();
  }

  Future<void> _fetchReferralSources() async {
    try {
      final response = await http.get(
        Uri.parse('https://furtive-chrissy-reparably.ngrok-free.dev/api/mukkadam/dropdown_list/'),
        headers: {
          'Authorization': 'Token e8fa8310c9af344ca22ec6bd23960d609b09c704',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _referralOptions = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Error fetching referrals: $e");
    }
  }




  bool _isPermanent = false;
  String? _hasSmartphone = 'yes';

  List<dynamic> _referralOptions = [];
  dynamic _selectedReferral;


  String? _locationCapturePath;
  double? _capturedLat;
  double? _capturedLong;

  //caputure location

  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  // Controllers for Crew Details
  final TextEditingController _maxCrewCapacityController = TextEditingController();
  final TextEditingController _splittingLogicController = TextEditingController();
  final TextEditingController _deputyMukkadamNameController = TextEditingController();
  final TextEditingController _deputyMukkadamMobileController = TextEditingController();
  final TextEditingController _teamMemberNameController = TextEditingController();
  final TextEditingController _teamMemberAgeController = TextEditingController();
  String? _teamMemberGender;
  final TextEditingController _teamMemberMobileController = TextEditingController();
  final TextEditingController _teamMemberAadharController = TextEditingController();
  // For multiple team members, you'd manage a List of objects/controllers
  final List<Map<String, dynamic>> _teamMembers = [];
  final List<Map<String, dynamic>> _workHistory = []; // Placeholder for work history
  final List<Map<String, dynamic>> _teamAvailabilities = []; // Placeholder for team availabilities

  // Controllers for Children Details
  final TextEditingController _numberOfChildrenController = TextEditingController();
  final TextEditingController _childrenCaretakerController = TextEditingController();

  // Controllers for Availability
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _startDateTextController = TextEditingController(); // New controller
  final TextEditingController _endDateTextController = TextEditingController();   // New controller
  final TextEditingController _dailyWorkTimingController = TextEditingController();

  // Controllers for Rate Card
  final TextEditingController _pruningRateController = TextEditingController();
  final TextEditingController _pastingRateController = TextEditingController();
  final TextEditingController _harvestingRateController = TextEditingController();
  final TextEditingController _defaultRateController = TextEditingController();

  // Controllers for Location Issues (individual fields, but will be aggregated into an array for API)
  final TextEditingController _issueVillageController = TextEditingController();
  final TextEditingController _issueDistrictController = TextEditingController();
  final TextEditingController _issueReasonController = TextEditingController();
  String? _issueSeverity;
  final List<Map<String, dynamic>> _locationIssues = []; // Placeholder for multiple location issues

  // Controllers for Work Area Preference
  final TextEditingController _homeLocationController = TextEditingController();
  final TextEditingController _preferredWorkLocationsController = TextEditingController();
  final TextEditingController _maxTravelDistanceController = TextEditingController();

  // Controllers for Transport Details
  String? _transportMode;
  String? _transportArrangedBy;
  final TextEditingController _perKmChargeController = TextEditingController();
  final TextEditingController _dailyRateChargeController = TextEditingController();
  bool _includesFuel = false;

  // Controllers for Payment Details
  String? _paymentMode;
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  String? _paymentFrequency;
  bool _advanceRequired = false;

  // Controllers for Work Mode
  String? _workMode;
  final TextEditingController _moveInPreferredRegionController = TextEditingController();

  // Controllers for Referral
  final TextEditingController _referralSourceController = TextEditingController();
  final TextEditingController _referredByController = TextEditingController();
  final TextEditingController _referralSourceTextController = TextEditingController();

  // Controllers for Notification Preferences
  bool _whatsappNotifications = false;
  bool _smsNotifications = false;
  bool _callNotifications = false;
  final TextEditingController _preferredTimeController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  // Controllers for Other Info
  final TextEditingController _otherCommitmentsController = TextEditingController();

  // Controllers for ID Numbers
  final TextEditingController _aadharNumberController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();

  // File paths (will be populated by a file picker, currently placeholders)
  String? _profilePhotoPath;
  String? _aadharCardPath;
  String? _panCardPath;
  String? _bankProofPath;

  @override
  void dispose() {
    _mukkadamNameController.dispose();
    _mobileNumbersController.dispose();
    _villageController.dispose();
    _crewSizeController.dispose();
    _maxCrewCapacityController.dispose();
    _splittingLogicController.dispose();
    _deputyMukkadamNameController.dispose();
    _deputyMukkadamMobileController.dispose();
    _teamMemberNameController.dispose();
    _teamMemberAgeController.dispose();
    _teamMemberMobileController.dispose();
    _teamMemberAadharController.dispose();
    _numberOfChildrenController.dispose();
    _childrenCaretakerController.dispose();
    _startDateTextController.dispose(); // Dispose new controller
    _endDateTextController.dispose();   // Dispose new controller
    _dailyWorkTimingController.dispose();
    _pruningRateController.dispose();
    _pastingRateController.dispose();
    _harvestingRateController.dispose();
    _defaultRateController.dispose();
    _issueVillageController.dispose();
    _issueDistrictController.dispose();
    _issueReasonController.dispose();
    _homeLocationController.dispose();
    _preferredWorkLocationsController.dispose();
    _maxTravelDistanceController.dispose();
    _perKmChargeController.dispose();
    _dailyRateChargeController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _upiIdController.dispose();
    _moveInPreferredRegionController.dispose();
    _referralSourceController.dispose();
    _referredByController.dispose();
    _referralSourceTextController.dispose();
    _preferredTimeController.dispose();
    _languageController.dispose();
    _otherCommitmentsController.dispose();
    _aadharNumberController.dispose();
    _panNumberController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }


  Future<void> _fetchGPSCoordinates() async {
    try {
      // Calling your existing function to determine position
      final position = await determinePosition();
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
        _capturedLat = position.latitude;
        _capturedLong = position.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordinates fetched successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
    }
  }

  Future<void> _captureLocationPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      setState(() {
        _locationCapturePath = file.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location photo captured!')),
      );
    }
  }








  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateTextController.text = '${_startDate!.toLocal()}'.split(' ')[0]; // Update controller text
        } else {
          _endDate = picked;
          _endDateTextController.text = '${_endDate!.toLocal()}'.split(' ')[0];     // Update controller text
        }
      });
    }
  }

  // Modified _pickFile function to use image_picker
  Future<void> _pickFile(String fileType) async {
    final ImagePicker _picker = ImagePicker();
    XFile? file;

    // Determine the source based on fileType if needed, or always use gallery for these cases
    // For this example, we'll assume ImageSource.gallery for all.
    file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        if (fileType == 'profile_photo') {
          _profilePhotoPath = file!.path; // Using null assertion operator
        } else if (fileType == 'aadhar_card') {
          _aadharCardPath = file!.path; // Using null assertion operator
        } else if (fileType == 'pan_card') {
          _panCardPath = file!.path; // Using null assertion operator
        } else if (fileType == 'bank_proof') {
          _bankProofPath = file!.path; // Using null assertion operator
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$fileType selected: ${file!.path.split('/').last}')), // Using null assertion operator
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No $fileType selected.')),
      );
    }
  }


  Future<void> _handleLocationCapture() async {
    try {
      // Get Coordinates
      final position = await determinePosition();

      // Open Camera
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.camera);

      if (file != null) {
        setState(() {
          _locationCapturePath = file.path;
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
          _capturedLat = position.latitude;
          _capturedLong = position.longitude;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo and GPS coordinates captured successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }




  // Inside _MukkadamRegistrationScreenState class in lib/main.dart
// This is the modified _submitForm function.
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting Mukkadam Registration Data...')),
      );

      // 1. Aggregate all form data into a map matching the API's JSON 'data' structure
      final Map<String, dynamic> mukkadamData = {
        "mukkadam_name": _mukkadamNameController.text,
        "mobile_numbers": _mobileNumbersController.text,



        "village": _villageController.text,
        "crew_size": int.tryParse(_crewSizeController.text) ?? 0, // Convert to int, default to 0 if parsing fails
        "is_permanent": _isPermanent,
        "has_smartphone": _hasSmartphone,
        "max_crew_capacity": int.tryParse(_maxCrewCapacityController.text) ?? 0,
        "splitting_logic": _splittingLogicController.text,
        "deputy_mukkadam_name": _deputyMukkadamNameController.text,
        "deputy_mukkadam_mobile": _deputyMukkadamMobileController.text,
        // For 'team_members', 'work_history', 'team_availabilities', 'location_issues':
        // If your UI supports multiple entries, you'd have Lists of controllers/models
        // and map them here. For now, we'll use the single text fields and wrap them in a list.
        "team_members": _teamMembers.isNotEmpty ? _teamMembers : [ // Example for a single team member from current UI
          if (_teamMemberNameController.text.isNotEmpty) {
            "name": _teamMemberNameController.text,
            "age": int.tryParse(_teamMemberAgeController.text) ?? 0,
            "gender": _teamMemberGender,
            "mobile": _teamMemberMobileController.text,
            "aadhar": _teamMemberAadharController.text.isNotEmpty ? _teamMemberAadharController.text : null,
          }
        ],
        "work_history": _workHistory, // Needs to be populated from a dynamic part of your form
        "number_of_children": int.tryParse(_numberOfChildrenController.text) ?? 0,
        "children_caretaker": _childrenCaretakerController.text,
        "start_date": _startDate?.toIso8601String().split('T')[0], // Format date to YYYY-MM-DD
        "end_date": _endDate?.toIso8601String().split('T')[0],   // Format date to YYYY-MM-DD
        "daily_work_timing": _dailyWorkTimingController.text,
        "team_availabilities": _teamAvailabilities, // Needs to be populated from a dynamic part of your form
        "rate_card": {
          "pruning": double.tryParse(_pruningRateController.text) ?? 0.0,
          "pasting": double.tryParse(_pastingRateController.text) ?? 0.0,
          "harvesting": double.tryParse(_harvestingRateController.text) ?? 0.0,
          "default_rate": double.tryParse(_defaultRateController.text) ?? 0.0,
          // Add other rate card activities here
        },
        "location_issues": _locationIssues.isNotEmpty ? _locationIssues : [ // Example for a single location issue
          if (_issueVillageController.text.isNotEmpty ||
              _issueDistrictController.text.isNotEmpty ||
              _issueReasonController.text.isNotEmpty ||
              _issueSeverity != null)
            {
              "village": _issueVillageController.text,
              "district": _issueDistrictController.text,
              "reason": _issueReasonController.text,
              "severity": _issueSeverity,
            }
        ],
        "home_location": _homeLocationController.text,
        "preferred_work_locations": _preferredWorkLocationsController.text,
        "max_travel_distance": _maxTravelDistanceController.text,
        "current_latitude": _latitudeController.text,
        "current_longitude": _longitudeController.text,
        "transport_mode": _transportMode,
        "transport_arranged_by": _transportArrangedBy,
        "transport_charges": {
          "per_km": double.tryParse(_perKmChargeController.text) ?? 0.0,
          "daily_rate": double.tryParse(_dailyRateChargeController.text) ?? 0.0,
          "includes_fuel": _includesFuel,
        },
        "payment_details": {
          "payment_mode": _paymentMode,
          "bank_name": _bankNameController.text,
          "account_number": _accountNumberController.text,
          "ifsc_code": _ifscCodeController.text,
          "upi_id": _upiIdController.text,
          "payment_frequency": _paymentFrequency,
          "advance_required": _advanceRequired,
        },
        "work_mode": _workMode,
        "move_in_preferred_region": _moveInPreferredRegionController.text,
        "referral_source": _referralSourceController.text,
        "referred_by": _referredByController.text.isNotEmpty ? _referredByController.text : null, // Mukkadam ID might be int or string
        "referral_source_text": _referralSourceTextController.text,
        "notification_preferences": {
          "whatsapp": _whatsappNotifications,
          "sms": _smsNotifications,
          "call": _callNotifications,
          "preferred_time": _preferredTimeController.text,
          "language": _languageController.text,
        },
        "other_commitments": _otherCommitmentsController.text,
        "aadhar_number": _aadharNumberController.text,
        "pan_number": _panNumberController.text,
      };

      final String authToken = 'e8fa8310c9af344ca22ec6bd23960d609b09c704'; // Your provided authorization token

      // 2. Call the RegistrationService to send data to the backend
      final response = await RegistrationService().registerMukkadam(
        mukkadamData: mukkadamData,
        authToken: authToken, // Pass the authorization token
        profilePhotoPath: _profilePhotoPath,
        aadharCardPath: _aadharCardPath,
        panCardPath: _panCardPath,
        bankProofPath: _bankProofPath,
        locationCapturePath: _locationCapturePath,
      );

      // 3. Handle the response
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful! ID: ${response['data']['id']}')),
        );
        print('Registration successful: ${response['data']}');
        // You might want to clear the form fields or navigate to another screen here
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response['message']}')),
        );
        print('Registration failed: ${response['message']}');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mukkadam Registration'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ExpansionTile(
              title: const Text('Basic Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                BasicDetailsSection(
                  mukkadamNameController: _mukkadamNameController,
                  mobileNumbersController: _mobileNumbersController,
                  villageController: _villageController,
                  crewSizeController: _crewSizeController,
                  isPermanent: _isPermanent,
                  onIsPermanentChanged: (bool? value) {
                    setState(() {
                      _isPermanent = value ?? false;
                    });
                  },
                  hasSmartphone: _hasSmartphone,
                  onHasSmartphoneChanged: (String? value) {
                    setState(() {
                      _hasSmartphone = value;
                    });
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Crew Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                CrewDetailsSection(
                  maxCrewCapacityController: _maxCrewCapacityController,
                  splittingLogicController: _splittingLogicController,
                  deputyMukkadamNameController: _deputyMukkadamNameController,
                  deputyMukkadamMobileController: _deputyMukkadamMobileController,
                  teamMemberNameController: _teamMemberNameController,
                  teamMemberAgeController: _teamMemberAgeController,
                  teamMemberGender: _teamMemberGender,
                  onTeamMemberGenderChanged: (String? value) {
                    setState(() {
                      _teamMemberGender = value;
                    });
                  },
                  teamMemberMobileController: _teamMemberMobileController,
                  teamMemberAadharController: _teamMemberAadharController,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Children Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                ChildrenDetailsSection(
                  numberOfChildrenController: _numberOfChildrenController,
                  childrenCaretakerController: _childrenCaretakerController,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Availability', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                AvailabilitySection(
                  startDateController: _startDateTextController, // Pass the new controller
                  onSelectStartDate: () => _selectDate(context, isStart: true),
                  endDateController: _endDateTextController,     // Pass the new controller
                  onSelectEndDate: () => _selectDate(context, isStart: false),
                  dailyWorkTimingController: _dailyWorkTimingController,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Rate Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                RateCardSection(
                  pruningRateController: _pruningRateController,
                  pastingRateController: _pastingRateController,
                  harvestingRateController: _harvestingRateController,
                  defaultRateController: _defaultRateController,
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Capture Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                CaptureLocationSection(
                  latitudeController: _latitudeController,
                  longitudeController: _longitudeController,
                  onFetchLocation: _fetchGPSCoordinates,
                  onCapturePhoto: _captureLocationPhoto,
                  capturedImagePath: _locationCapturePath,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Location Issues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                LocationIssuesSection(
                  issueVillageController: _issueVillageController,
                  issueDistrictController: _issueDistrictController,
                  issueReasonController: _issueReasonController,
                  issueSeverity: _issueSeverity,
                  onIssueSeverityChanged: (String? value) {
                    setState(() {
                      _issueSeverity = value;
                    });
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Work Area Preference', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                WorkAreaPreferenceSection(
                  homeLocationController: _homeLocationController,
                  preferredWorkLocationsController: _preferredWorkLocationsController,
                  maxTravelDistanceController: _maxTravelDistanceController,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Transport Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                TransportDetailsSection(
                  transportMode: _transportMode,
                  onTransportModeChanged: (String? value) {
                    setState(() {
                      _transportMode = value;
                    });
                  },
                  transportArrangedBy: _transportArrangedBy,
                  onTransportArrangedByChanged: (String? value) {
                    setState(() {
                      _transportArrangedBy = value;
                    });
                  },
                  perKmChargeController: _perKmChargeController,
                  dailyRateChargeController: _dailyRateChargeController,
                  includesFuel: _includesFuel,
                  onIncludesFuelChanged: (bool? value) {
                    setState(() {
                      _includesFuel = value ?? false;
                    });
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Payment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                PaymentDetailsSection(
                  paymentMode: _paymentMode,
                  onPaymentModeChanged: (String? value) {
                    setState(() {
                      _paymentMode = value;
                    });
                  },
                  bankNameController: _bankNameController,
                  accountNumberController: _accountNumberController,
                  ifscCodeController: _ifscCodeController,
                  upiIdController: _upiIdController,
                  paymentFrequency: _paymentFrequency,
                  onPaymentFrequencyChanged: (String? value) {
                    setState(() {
                      _paymentFrequency = value;
                    });
                  },
                  advanceRequired: _advanceRequired,
                  onAdvanceRequiredChanged: (bool? value) {
                    setState(() {
                      _advanceRequired = value ?? false;
                    });
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Work Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                WorkModeSection(
                  workMode: _workMode,
                  onWorkModeChanged: (String? value) {
                    setState(() {
                      _workMode = value;
                    });
                  },
                  moveInPreferredRegionController: _moveInPreferredRegionController,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Referral', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                ReferralSection(
                  referralOptions: _referralOptions,
                  selectedReferral: _selectedReferral,
                  referredByController: _referredByController,
                  referralSourceTextController: _referralSourceTextController,
                  onReferralChanged: (dynamic newValue) {
                    setState(() {
                      _selectedReferral = newValue;
                      // Fill Referral Source Name
                      _referralSourceController.text = newValue['name']?.toString() ?? '';
                      // Fill Referred By ID from response
                      _referredByController.text = newValue['id']?.toString() ?? '';
                    });
                  },
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                NotificationPreferencesSection(
                  whatsappNotifications: _whatsappNotifications,
                  onWhatsappNotificationsChanged: (bool? value) {
                    setState(() {
                      _whatsappNotifications = value ?? false;
                    });
                  },
                  smsNotifications: _smsNotifications,
                  onSmsNotificationsChanged: (bool? value) {
                    setState(() {
                      _smsNotifications = value ?? false;
                    });
                  },
                  callNotifications: _callNotifications,
                  onCallNotificationsChanged: (bool? value) {
                    setState(() {
                      _callNotifications = value ?? false;
                    });
                  },
                  preferredTimeController: _preferredTimeController,
                  languageController: _languageController,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Other Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                OtherInfoSection(
                  otherCommitmentsController: _otherCommitmentsController,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('ID Numbers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                IDNumbersSection(
                  aadharNumberController: _aadharNumberController,
                  panNumberController: _panNumberController,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('File Uploads (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                FileUploadsSection(
                  onUploadProfilePhoto: () => _pickFile('profile_photo'),
                  onUploadAadharCard: () => _pickFile('aadhar_card'),
                  onUploadPanCard: () => _pickFile('pan_card'),
                  onUploadBankProof: () => _pickFile('bank_proof'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Register Mukkadam'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
