import 'package:finale/widgets/base/loading_component.dart';
import 'package:flutter/material.dart';

typedef WidgetListBuilder = List<Widget> Function(BuildContext context);

typedef BodyWidgetBuilder<R> = Widget Function(BuildContext context, R result);

class CollapsibleFormView<R extends Object> extends StatefulWidget {
  final String submitButtonText;
  final Future<R?> Function() onFormSubmit;
  final WidgetBuilder? loadingWidgetBuilder;
  final WidgetListBuilder formWidgetsBuilder;
  final BodyWidgetBuilder<R> bodyBuilder;

  const CollapsibleFormView({
    super.key,
    this.submitButtonText = 'Submit',
    required this.onFormSubmit,
    this.loadingWidgetBuilder,
    required this.formWidgetsBuilder,
    required this.bodyBuilder,
  });

  @override
  State<StatefulWidget> createState() => CollapsibleFormViewState<R>();
}

class CollapsibleFormViewState<R extends Object>
    extends State<CollapsibleFormView<R>> {
  final _formKey = GlobalKey<FormState>();
  var _isSettingsExpanded = true;
  var _isLoading = false;
  R? _result;

  Future<void> onFormSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSettingsExpanded = false;
        _result = null;
        _isLoading = true;
      });

      final result = await widget.onFormSubmit();

      setState(() {
        _isSettingsExpanded = result == null;
        _result = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      _isLoading && widget.loadingWidgetBuilder != null
          ? Center(child: widget.loadingWidgetBuilder!.call(context))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.zero,
                    expansionCallback: (_, isExpanded) {
                      setState(() {
                        _isSettingsExpanded = isExpanded;
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
                              ...widget.formWidgetsBuilder(context),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
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
                ),
                if (_isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: widget.loadingWidgetBuilder?.call(context) ??
                        const LoadingComponent(),
                  )
                else if (_result case R result)
                  SliverSafeArea(
                    sliver: SliverToBoxAdapter(
                      child: widget.bodyBuilder(context, result),
                    ),
                  ),
              ],
            );
}
