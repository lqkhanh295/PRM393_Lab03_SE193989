/// Explicit Screen State Model
/// Implements Section 5 MVVM explicit state pattern for all data-loading views.
sealed class ScreenState<T> {
  const ScreenState();
}

class StateInitial<T> extends ScreenState<T> {
  const StateInitial();
}

class StateLoading<T> extends ScreenState<T> {
  final String? message;
  const StateLoading([this.message]);
}

class StateData<T> extends ScreenState<T> {
  final T data;
  const StateData(this.data);
}

class StateEmpty<T> extends ScreenState<T> {
  final String message;
  const StateEmpty(this.message);
}

class StateError<T> extends ScreenState<T> {
  final String error;
  const StateError(this.error);
}
