import 'package:_12sale_app/core/styles/style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class DropdownSearchCustom<T> extends StatefulWidget {
  final String label;
  final String? hint;
  final String titleText;
  final Future<List<T>> Function(String) fetchItems; // Function to fetch items
  final ValueChanged<T?> onChanged; // Callback when item is selected
  final T? initialSelectedValue; // Initial selected value
  final String Function(T)
      itemAsString; // Converts item to a displayable string
  final Widget Function(BuildContext, T, bool) itemBuilder; // Custom item UI
  final bool showSearchBox;
  final bool enabled;
  final Icon? icon;

  const DropdownSearchCustom({
    Key? key,
    required this.label,
    this.hint,
    required this.titleText,
    required this.fetchItems,
    required this.onChanged,
    required this.itemAsString,
    required this.itemBuilder,
    this.initialSelectedValue,
    this.showSearchBox = true,
    this.enabled = false,
    this.icon,
  }) : super(key: key);

  @override
  _DropdownSearchCustomState<T> createState() =>
      _DropdownSearchCustomState<T>();
}

class _DropdownSearchCustomState<T> extends State<DropdownSearchCustom<T>> {
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialSelectedValue;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return DropdownSearch<T>(
      enabled: !widget.enabled,
      dropdownButtonProps: DropdownButtonProps(
        icon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.arrow_drop_down,
            size: screenWidth / 20,
            color: Colors.black54,
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: Styles.black18(context),
        dropdownSearchDecoration: InputDecoration(
          // isCollapsed: true,
          // isDense: true,
          prefixIcon: widget.icon,
          // fillColor: widget.enabled ? Colors.grey[200] : Colors.white,
          labelText: widget.label,
          // hintTextDirection: ,
          // helperText: 'dawd',
          labelStyle: Styles.grey18(context),
          hintText: widget.hint,
          hintStyle: Styles.grey18(context),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
        ),
      ),
      selectedItem: _selectedItem,
      itemAsString: widget.itemAsString,
      asyncItems: widget.fetchItems,
      onChanged: (T? data) {
        setState(() {
          _selectedItem = data;
        });
        widget.onChanged(data);
      },
      popupProps: PopupPropsMultiSelection.modalBottomSheet(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: screenWidth * 0.95, // Set maximum width
        ),
        title: Container(
          decoration: const BoxDecoration(
            color: Styles.primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(widget.titleText, style: Styles.white18(context)),
        ),
        showSearchBox: widget.showSearchBox,
        itemBuilder: widget.itemBuilder,
        searchFieldProps: TextFieldProps(
          style: Styles.black18(context),
          autofocus: true,
        ),
      ),
    );
  }
}
