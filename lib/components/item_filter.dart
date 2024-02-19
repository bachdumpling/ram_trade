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
        return 'Price - Low to High';
      case SortOption.priceHighToLow:
        return 'Price - High to Low';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Ensure the column takes minimum space
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonHideUnderline(
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: List.of([
                      const BoxShadow(
                        color: Colors.white,
                        spreadRadius: 0,
                        blurRadius: 0,
                        offset: Offset(0, 0),
                      ),
                    ]),
                  ),
                  child: DropdownButton<SortOption>(
                    value: _selectedSortOption,
                    icon: const Icon(CupertinoIcons.chevron_down,
                        color: Colors.black87),
                    hint: const Text('Sort By',
                        style: TextStyle(color: Colors.grey)),
                    onChanged: (SortOption? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedSortOption = newValue;
                        });
                        widget.onSortChanged(newValue);
                      }
                    },
                    items: SortOption.values.map((SortOption value) {
                      return DropdownMenuItem<SortOption>(
                        value: value,
                        // Apply custom styles to the dropdown menu items here.
                        child: Container(
                          // padding: const EdgeInsets.symmetric(
                          //     vertical: 10.0, horizontal: 15.0),
                          decoration: BoxDecoration(
                            // You can add more styling to the container here.
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: Text(
                            value.displayTitle,
                            style: const TextStyle(
                              // Customize text style
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    elevation: 0,
                    dropdownColor: Colors.white,
                  )),
            ),
          ],
        ),
      ],
    );
  }
}
