import 'package:finale/widgets/base/loading_component.dart';
import 'package:flutter/material.dart';

class CollapsibleFormView extends StatefulWidget {
  final List<Widget> formWidgets;
  final String submitButtonText;
  final Widget? body;
  final Future<bool> Function() onFormSubmit;

  const CollapsibleFormView({
    Key? key,
    required this.formWidgets,
    this.submitButtonText = 'Submit',
    required this.body,
    required this.onFormSubmit,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CollapsibleFormViewState();
}

class CollapsibleFormViewState extends State<CollapsibleFormView> {
  final _formKey = GlobalKey<FormState>();
  var _isSettingsExpanded = true;
  bool? _loadingStatus;

  Future<void> onFormSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSettingsExpanded = false;
        _loadingStatus = true;
      });

      final success = await widget.onFormSubmit();
      _isSettingsExpanded = !success;

      setState(() {
        _loadingStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          ExpansionPanelList(
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (_, __) {
              setState(() {
                _isSettingsExpanded = !_isSettingsExpanded;
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (_, __) =>
                    const ListTile(title: Text('Settings')),
                canTapOnHeader: true,
                isExpanded: _isSettingsExpanded,
                body: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      ...widget.formWidgets,
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: OutlinedButton(
                          onPressed: onFormSubmit,
                          child: Text(widget.submitButtonText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_loadingStatus == true)
            const LoadingComponent()
          else if (_loadingStatus == false && widget.body != null)
            widget.body!,
        ],
      );
}
