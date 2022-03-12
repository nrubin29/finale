import 'package:finale/services/lastfm/common.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/widgets/base/error_component.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:flutter/material.dart';

class FutureBuilderView<T> extends StatefulWidget {
  final Future<T> future;
  final Object? baseEntity;
  final bool isView;
  final Widget Function(T value) builder;

  const FutureBuilderView({
    required this.future,
    this.baseEntity,
    this.isView = true,
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() => _FutureBuilderViewState<T>();
}

class _FutureBuilderViewState<T> extends State<FutureBuilderView<T>> {
  late T _value;
  Object? _exception;
  StackTrace? _stackTrace;
  var _showSendFeedbackButton = true;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolveValue();
  }

  Future<void> _resolveValue() async {
    try {
      _value = await widget.future;

      setState(() {
        _isLoading = false;
      });
    } on Exception catch (e, st) {
      final isNotFoundError = e is LException && e.code == 6;

      setState(() {
        _exception = isNotFoundError ? 'Item not found' : e;
        _stackTrace = st;
        _showSendFeedbackButton = !isNotFoundError;
        _isLoading = false;
      });

      if (isDebug) {
        rethrow;
      }
    }
  }

  Widget get _loadingView => widget.isView
      ? Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Loading'),
          ),
          body: const LoadingComponent(),
        )
      : const LoadingComponent();

  Widget get _errorView {
    final errorComponent = ErrorComponent(
      error: _exception!,
      stackTrace: _stackTrace!,
      entity: widget.baseEntity,
      showSendFeedbackButton: _showSendFeedbackButton,
    );

    return widget.isView
        ? Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Error'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: errorComponent,
            ),
          )
        : errorComponent;
  }

  @override
  Widget build(BuildContext context) => _isLoading
      ? _loadingView
      : _exception != null && _stackTrace != null
          ? _errorView
          : widget.builder(_value);
}
