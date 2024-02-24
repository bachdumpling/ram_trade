import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum SortOption {
  priceLowToHigh,
  priceHighToLow,
  newest,
  oldest,
}

extension SortOptionExtension on SortOption {
  String get displayTitle {
    switch (this) {
      case SortOption.priceLowToHigh:
        return 'Price ↑';
      case SortOption.priceHighToLow:
        return 'Price ↓';
      case SortOption.newest:
        return 'Newest';
      case SortOption.oldest:
        return 'Oldest';
    }
  }
}

class FilterComponent extends StatefulWidget {
  final void Function(SortOption) onSortChanged;

  const FilterComponent({super.key, required this.onSortChanged});

  @override
  State<FilterComponent> createState() => _FilterComponentState();
}

class _FilterComponentState extends State<FilterComponent> {
  SortOption? _selectedSortOption;
  bool _isDropdownOpened = false; // State to track if dropdown is open

  @override
  Widget build(BuildContext context) {
    // Determine the border color based on whether an option is selected or dropdown is open
    Color borderColor = _isDropdownOpened || _selectedSortOption != null
        ? Colors.black
        : Colors.grey.shade300;

    // Determine the dropdown button color based on whether the dropdown is open
    Color buttonColor = _isDropdownOpened ? Colors.black : Colors.grey;

    // Determine the icon based on whether the dropdown is open
    IconData dropdownIcon = _isDropdownOpened
        ? CupertinoIcons.chevron_up
        : CupertinoIcons.chevron_down;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            spreadRadius: 0,
            blurRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<SortOption>(
            value: _selectedSortOption,
            iconStyleData: IconStyleData(
              icon: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  dropdownIcon,
                  color: _isDropdownOpened ? Colors.black : Colors.grey,
                  size: 16,
                ),
              ),
            ),
            hint: Text(
              'Sort By',
              style: TextStyle(
                  fontSize: 12,
                  color:
                      _selectedSortOption != null ? Colors.black : Colors.grey),
            ),
            onChanged: (SortOption? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedSortOption = newValue;
                  _isDropdownOpened = false; // Close the dropdown
                });
                widget.onSortChanged(newValue);
              }
            },
            onMenuStateChange: (isOpen) {
              setState(() {
                _isDropdownOpened = isOpen;
              });
            },
            items: SortOption.values.map((SortOption value) {
              return DropdownMenuItem<SortOption>(
                alignment: AlignmentDirectional.center,
                value: value,
                child: Text(
                  value.displayTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),

            isDense: true, // Reduces the extra space inside the dropdown button
            buttonStyleData: const ButtonStyleData(
              height: 30,
              width: null,
            ),
            dropdownStyleData: const DropdownStyleData(
              offset: Offset(-20, -10),
              width: 110,
              maxHeight: 250,
              elevation: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
