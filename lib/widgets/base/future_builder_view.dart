import 'package:finale/util/constants.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/error_component.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:flutter/material.dart';

typedef FutureFactory<T> = Future<T> Function();

class FutureBuilderView<T> extends StatefulWidget {
  final FutureFactory<T> futureFactory;
  final Object? baseEntity;
  final bool isView;
  final Widget Function(T value) builder;

  const FutureBuilderView({
    required this.futureFactory,
    this.baseEntity,
    this.isView = true,
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() => _FutureBuilderViewState<T>();
}

class _FutureBuilderViewState<T> extends State<FutureBuilderView<T>> {
  late T _value;
  Exception? _exception;
  StackTrace? _stackTrace;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolveValue();
  }

  Future<void> _resolveValue() async {
    setState(() {
      _isLoading = true;
      _exception = null;
      _stackTrace = null;
    });

    try {
      _value = await widget.futureFactory();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on Exception catch (e, st) {
      if (mounted) {
        setState(() {
          _exception = e;
          _stackTrace = st;
          _isLoading = false;
        });
      }

      if (isDebug) {
        rethrow;
      }
    }
  }

  Widget get _loadingView => widget.isView
      ? Scaffold(
          appBar: createAppBar('Loading'),
          body: const LoadingComponent(),
        )
      : const LoadingComponent();

  Widget get _errorView {
    final errorComponent = ErrorComponent(
      error: _exception!,
      stackTrace: _stackTrace!,
      entity: widget.baseEntity,
      onRetry: _resolveValue,
    );

    return widget.isView
        ? Scaffold(
            appBar: createAppBar('Error'),
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
