import 'package:flutter/material.dart';

abstract class BaseController {
  bool _isInitialized = false;
  bool _isVisible = false;
  bool _isDisposed = false;

  bool get isInitialized => _isInitialized;

  bool get isVisible => _isVisible;

  bool get isDisposed => _isDisposed;

  TickerProvider? _tickerProvider;

  void initTickerProvider(TickerProvider provider) {
    _tickerProvider = provider;
  }

  @mustCallSuper
  void onInit() {
    _isInitialized = true;
  }

  @mustCallSuper
  void onFirstFrameRendering() {}

  @mustCallSuper
  void onShow() {
    _isVisible = true;
  }

  @mustCallSuper
  void onHide() {
    _isVisible = false;
  }

  @mustCallSuper
  void onClose() {
    _isDisposed = true;
  }

  TickerProvider? get tickerProvider => _tickerProvider;

  void onUpdateVisible(bool visible) {
    if (visible) {
      onShow();
    } else {
      onHide();
    }
  }
}
