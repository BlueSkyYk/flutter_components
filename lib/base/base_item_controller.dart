import 'base_controller.dart';

abstract class BaseItemController extends BaseController {
  bool _itemShowing = false;

  bool get itemShowing => _itemShowing;

  void updateItemShowStatus(bool showing) {
    if (_itemShowing == showing) {
      return;
    }
    _itemShowing = showing;
    super.onUpdateVisible(_itemShowing);
  }

  @override
  void onUpdateVisible(bool visible) {
    if (_itemShowing) {
      super.onUpdateVisible(visible);
    }
  }
}
