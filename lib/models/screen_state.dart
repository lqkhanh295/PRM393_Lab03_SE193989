/// Định nghĩa trạng thái giao diện phân tầng (Explicit Screen State) cho kiến trúc MVVM.
///
/// Hỗ trợ kiểm soát tường minh 5 trạng thái vòng đời dữ liệu trên mọi màn hình:
/// khởi tạo ([StateInitial]), đang tải ([StateLoading]), có dữ liệu ([StateData]),
/// danh sách trống ([StateEmpty]), và phát sinh lỗi ([StateError]).
sealed class ScreenState<T> {
  /// Khởi tạo trạng thái màn hình cơ sở.
  const ScreenState();
}

/// Trạng thái ban đầu trước khi dữ liệu được kích hoạt tải.
class StateInitial<T> extends ScreenState<T> {
  /// Khởi tạo trạng thái ban đầu.
  const StateInitial();
}

/// Trạng thái đang tải dữ liệu với thông điệp tùy chọn [message].
class StateLoading<T> extends ScreenState<T> {
  /// Thông điệp mô tả tiến trình tải dữ liệu.
  final String? message;

  /// Khởi tạo trạng thái đang tải dữ liệu.
  const StateLoading([this.message]);
}

/// Trạng thái tải dữ liệu thành công chứa đối tượng dữ liệu [data].
class StateData<T> extends ScreenState<T> {
  /// Dữ liệu trả về thành công từ ViewModel hoặc Service.
  final T data;

  /// Khởi tạo trạng thái dữ liệu với [data].
  const StateData(this.data);
}

/// Trạng thái danh sách rỗng hoặc không tìm thấy dữ liệu kèm thông điệp [message].
class StateEmpty<T> extends ScreenState<T> {
  /// Thông điệp giải thích lý do dữ liệu trống.
  final String message;

  /// Khởi tạo trạng thái danh sách trống với [message].
  const StateEmpty(this.message);
}

/// Trạng thái xảy ra lỗi kèm chuỗi thông báo lỗi [error].
class StateError<T> extends ScreenState<T> {
  /// Nội dung lỗi chi tiết phục vụ hiển thị và xử lý ngoại lệ.
  final String error;

  /// Khởi tạo trạng thái lỗi với thông báo [error].
  const StateError(this.error);
}
