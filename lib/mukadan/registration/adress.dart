import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddressHierarchySection extends StatelessWidget {
  final String title;
  final TextEditingController stateName;
  final TextEditingController stateCode;
  final TextEditingController districtName;
  final TextEditingController districtCode;
  final TextEditingController talukaName;
  final TextEditingController talukaCode;
  final TextEditingController villageName;
  final TextEditingController villageCode;
  final List<Map<String, dynamic>> states;
  final List<Map<String, dynamic>> districts;
  final List<Map<String, dynamic>> talukas;
  final List<Map<String, dynamic>> villages;
  final Function(Map<String, dynamic>?) onStateChanged;
  final Function(Map<String, dynamic>?) onDistrictChanged;
  final Function(Map<String, dynamic>?) onTalukaChanged;
  final Function(Map<String, dynamic>?) onVillageChanged;
  final bool isLoading;

  const AddressHierarchySection({
    super.key,
    required this.title,
    required this.stateName,
    required this.stateCode,
    required this.districtName,
    required this.districtCode,
    required this.talukaName,
    required this.talukaCode,
    required this.villageName,
    required this.villageCode,
    required this.states,
    required this.districts,
    required this.talukas,
    required this.villages,
    required this.onStateChanged,
    required this.onDistrictChanged,
    required this.onTalukaChanged,
    required this.onVillageChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              if (isLoading)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                ),
            ],
          ),
          const SizedBox(height: 10),

          _buildSearchableLocationRow(context, "State", states, 'state_code', 'state_name_english', stateCode, onStateChanged),
          const SizedBox(height: 10),

          _buildSearchableLocationRow(context, "District", districts, 'districtcode', 'districtnameenglish', districtCode, onDistrictChanged, enabled: stateCode.text.isNotEmpty && !isLoading),
          const SizedBox(height: 10),

          _buildSearchableLocationRow(context, "Taluka", talukas, 'subdistrictcode', 'subdistrictnameenglish', talukaCode, onTalukaChanged, enabled: districtCode.text.isNotEmpty && !isLoading),
          const SizedBox(height: 10),

          _buildSearchableLocationRow(context, "Village", villages, 'villagecode', 'villagenameenglish', villageCode, onVillageChanged, enabled: talukaCode.text.isNotEmpty && !isLoading),
        ],
      ),
    );
  }

  Widget _buildSearchableLocationRow(
      BuildContext context,
      String label,
      List<Map<String, dynamic>> items,
      String codeKey,
      String nameKey,
      TextEditingController codeCtrl,
      Function(Map<String, dynamic>?) onChanged, {
        bool enabled = true,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find the currently selected item from the list based on the code controller to keep UI in sync
    Map<String, dynamic>? selectedItem;
    try {
      selectedItem = items.firstWhere((i) => i[codeKey].toString() == codeCtrl.text);
    } catch (_) {
      selectedItem = null;
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownSearch<Map<String, dynamic>>(
            enabled: enabled,
            items: (filter, loadProps) => items,
            selectedItem: selectedItem,
            itemAsString: (item) => item[nameKey]?.toString() ?? '',
            onChanged: onChanged,
            compareFn: (item1, item2) => item1[codeKey].toString() == item2[codeKey].toString(),
            filterFn: (item, filter) => item[nameKey].toString().toLowerCase().contains(filter.toLowerCase()),
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: "Select $label",
                filled: true,
                fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                isDense: true,
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search $label...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              menuProps: MenuProps(
                backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: codeCtrl,
            readOnly: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: "Code",
              border: const OutlineInputBorder(),
              fillColor: Colors.grey[100],
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';

class WorkHistorySection extends StatelessWidget {
  final TextEditingController locationController;
  final List<Map<String, dynamic>> states;
  final List<Map<String, dynamic>> districts;
  final List<Map<String, dynamic>> talukas;
  final List<Map<String, dynamic>> villages;
  final String? selectedStateCode;
  final String? selectedDistrictCode;
  final String? selectedTalukaCode;
  final String? selectedVillageCode;
  final Function(Map<String, dynamic>?) onStateChanged;
  final Function(Map<String, dynamic>?) onDistrictChanged;
  final Function(Map<String, dynamic>?) onTalukaChanged;
  final Function(Map<String, dynamic>?) onVillageChanged;
  final List<Map<String, dynamic>> currentList;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  final bool isLoading;

  const WorkHistorySection({
    super.key,
    required this.locationController,
    required this.states,
    required this.districts,
    required this.talukas,
    required this.villages,
    this.selectedStateCode,
    this.selectedDistrictCode,
    this.selectedTalukaCode,
    this.selectedVillageCode,
    required this.onStateChanged,
    required this.onDistrictChanged,
    required this.onTalukaChanged,
    required this.onVillageChanged,
    required this.currentList,
    required this.onAdd,
    required this.onRemove,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentList.isNotEmpty) ...[

            const Text("Added History:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentList.length,
              itemBuilder: (context, index) {
                final item = currentList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(item['location'] ?? 'Unknown Location'),
                    subtitle: Text(
                        "S: ${item['state']} (${item['state_code']}), D: ${item['district']} (${item['district_code']}), T: ${item['taluka']} (${item['taluka_code']}), V: ${item['village']} (${item['village_code']})"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onRemove(index),
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 30),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Add New Entry:", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
              if (isLoading)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: locationController,
            enabled: !isLoading,
            decoration: const InputDecoration(
              labelText: 'Previous Work Location Name',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),

          // Searchable State Row
          _buildSearchableLocationRow(context, "State", states, 'state_code', 'state_name_english', selectedStateCode, onStateChanged, enabled: !isLoading),
          const SizedBox(height: 10),

          // Searchable District Row
          _buildSearchableLocationRow(context, "District", districts, 'districtcode', 'districtnameenglish', selectedDistrictCode,
              onDistrictChanged,
              enabled: !isLoading && states.isNotEmpty && selectedStateCode != null),
          const SizedBox(height: 10),

          // Searchable Taluka Row
          _buildSearchableLocationRow(context, "Taluka", talukas, 'subdistrictcode', 'subdistrictnameenglish', selectedTalukaCode,
              onTalukaChanged,
              enabled: !isLoading && districts.isNotEmpty && selectedDistrictCode != null),
          const SizedBox(height: 10),

          // Searchable Village Row
          _buildSearchableLocationRow(context, "Village", villages, 'villagecode', 'villagenameenglish', selectedVillageCode,
              onVillageChanged,
              enabled: !isLoading && talukas.isNotEmpty && selectedTalukaCode != null),

          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onAdd,
              icon: const Icon(Icons.add),
              label: const Text("Add Work History"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchableLocationRow(
      BuildContext context,
      String label,
      List<Map<String, dynamic>> items,
      String codeKey,
      String nameKey,
      String? selectedValue,
      Function(Map<String, dynamic>?) onChanged, {
        bool enabled = true,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find the currently selected item from the list based on the selectedValue string
    Map<String, dynamic>? selectedItem;
    try {
      selectedItem = items.firstWhere((i) => i[codeKey].toString() == selectedValue);
    } catch (_) {
      selectedItem = null;
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownSearch<Map<String, dynamic>>(
            enabled: enabled,
            items: (filter, loadProps) => items,
            selectedItem: selectedItem,
            itemAsString: (item) => item[nameKey]?.toString() ?? '',
            onChanged: onChanged,
            compareFn: (item1, item2) => item1[codeKey].toString() == item2[codeKey].toString(),
            filterFn: (item, filter) => item[nameKey].toString().toLowerCase().contains(filter.toLowerCase()),
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: "Select $label",
                filled: true,
                fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                isDense: true,
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search $label...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              menuProps: MenuProps(
                backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFormField(
            key: ValueKey(selectedValue),
            initialValue: selectedValue ?? '',
            readOnly: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: "Code",
              border: const OutlineInputBorder(),
              fillColor: Colors.grey[100],
              isDense: true,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}





