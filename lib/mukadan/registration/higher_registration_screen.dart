import "package:flutter/material.dart";


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
          // TextFormField(
          //   controller: villageController,
          //   decoration: const InputDecoration(labelText: 'Village *', border: OutlineInputBorder()),
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please enter village';
          //     }
          //     return null;
          //   },
          // ),
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

  // New parameters for handling the array
  final List<Map<String, dynamic>> teamMembers;
  final VoidCallback onAddMember;
  final Function(int) onRemoveMember;

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
    required this.teamMembers,
    required this.onAddMember,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        const Divider(height: 30),
        const Text('Add Team Members (Nested Array)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 10),

        // Input fields for a single member
        TextFormField(
          controller: teamMemberNameController,
          decoration: const InputDecoration(labelText: 'Member Name', border: OutlineInputBorder(), isDense: true),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: teamMemberAgeController,
                decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder(), isDense: true),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: teamMemberGender,
                decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder(), isDense: true),
                items: ['Male', 'Female', 'Other'].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: onTeamMemberGenderChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: teamMemberMobileController,
          decoration: const InputDecoration(labelText: 'Member Mobile', border: OutlineInputBorder(), isDense: true),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: teamMemberAadharController,
          decoration: const InputDecoration(labelText: 'Member Aadhar', border: OutlineInputBorder(), isDense: true),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddMember,
            icon: const Icon(Icons.person_add),
            label: const Text("Add Member to List"),
          ),
        ),

        const SizedBox(height: 20),
        if (teamMembers.isNotEmpty) ...[
          const Text("Team Members List:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: teamMembers.length,
            itemBuilder: (context, index) {
              final member = teamMembers[index];
              return Card(
                child: ListTile(
                  dense: true,
                  title: Text(member['name'] ?? ''),
                  subtitle: Text("${member['gender']}, ${member['age']} yrs | Mob: ${member['mobile']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => onRemoveMember(index),
                  ),
                ),
              );
            },
          ),
        ],
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
  final TextEditingController aprilPruningController;
  final TextEditingController bagalBaliFutRemovalController;
  final TextEditingController berryThinningController;
  final TextEditingController bunchSelectionController;
  final TextEditingController bunchThinningController;
  final TextEditingController bunchTyingController;
  final TextEditingController bunchVariationController;
  final TextEditingController defaultRateController;
  final TextEditingController fingerThinningController;
  final TextEditingController firstDippingController;
  final TextEditingController firstFailFutRemovalController;
  final TextEditingController harvestingController;
  final TextEditingController newPlantationController;
  final TextEditingController otherRateController;
  final TextEditingController paperRemovalController;
  final TextEditingController paperWrappingController;
  final TextEditingController pastingController;
  final TextEditingController pruningController;
  final TextEditingController secondDippingController;
  final TextEditingController secondFailFutRemovalController;
  final TextEditingController shendaToppingController;
  final TextEditingController shootTyingClipsController;
  final TextEditingController shootTyingStringsController;
  final TextEditingController thirdDippingController;

  const RateCardSection({
    super.key,
    required this.aprilPruningController,
    required this.bagalBaliFutRemovalController,
    required this.berryThinningController,
    required this.bunchSelectionController,
    required this.bunchThinningController,
    required this.bunchTyingController,
    required this.bunchVariationController,
    required this.defaultRateController,
    required this.fingerThinningController,
    required this.firstDippingController,
    required this.firstFailFutRemovalController,
    required this.harvestingController,
    required this.newPlantationController,
    required this.otherRateController,
    required this.paperRemovalController,
    required this.paperWrappingController,
    required this.pastingController,
    required this.pruningController,
    required this.secondDippingController,
    required this.secondFailFutRemovalController,
    required this.shendaToppingController,
    required this.shootTyingClipsController,
    required this.shootTyingStringsController,
    required this.thirdDippingController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          _buildTwoFieldRow(defaultRateController, 'Default Rate', pruningController, 'Pruning Rate'),
          _buildTwoFieldRow(pastingController, 'Pasting Rate', harvestingController, 'Harvesting Rate'),
          _buildTwoFieldRow(aprilPruningController, 'April Pruning', bagalBaliFutRemovalController, 'Bagal Bali Fut'),
          _buildTwoFieldRow(berryThinningController, 'Berry Thinning', bunchSelectionController, 'Bunch Selection'),
          _buildTwoFieldRow(bunchThinningController, 'Bunch Thinning', bunchTyingController, 'Bunch Tying'),
          _buildTwoFieldRow(bunchVariationController, 'Bunch Variation', fingerThinningController, 'Finger Thinning'),
          _buildTwoFieldRow(firstDippingController, 'First Dipping', firstFailFutRemovalController, '1st Fail Fut Rem'),
          _buildTwoFieldRow(newPlantationController, 'New Plantation', paperRemovalController, 'Paper Removal'),
          _buildTwoFieldRow(paperWrappingController, 'Paper Wrapping', secondDippingController, 'Second Dipping'),
          _buildTwoFieldRow(secondFailFutRemovalController, '2nd Fail Fut Rem', shendaToppingController, 'Shenda Topping'),
          _buildTwoFieldRow(shootTyingClipsController, 'Shoot Tying Clips', shootTyingStringsController, 'Shoot Tying Str'),
          _buildTwoFieldRow(thirdDippingController, 'Third Dipping', otherRateController, 'Other'),
        ],
      ),
    );
  }

  Widget _buildTwoFieldRow(TextEditingController c1, String l1, TextEditingController c2, String l2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildRateField(c1, l1)),
          const SizedBox(width: 12),
          Expanded(child: _buildRateField(c2, l2)),
        ],
      ),
    );
  }

  Widget _buildRateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
      keyboardType: TextInputType.number,
    );
  }
}






