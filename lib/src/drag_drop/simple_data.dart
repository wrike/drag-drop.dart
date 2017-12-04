import 'dart:html';


class DragDropSimpleData {

  static const String _RICH_TEXT_TYPE = 'text/plain';
  static const String _SIMPLIFIED_TEXT_TYPE = 'text';
  static const String _LINK_TYPE = 'text/uri-list';

  final DataTransfer _dataTransfer;

  DragDropSimpleData(this._dataTransfer);

  void clearData([String format]) => _dataTransfer.clearData(_simplifyFormat(format));

  void setData(String format, String value) => _dataTransfer.setData(_simplifyFormat(format), value);

  void setText(String value) => _dataTransfer.setData(_SIMPLIFIED_TEXT_TYPE, value);

  void setLink(String value) {
    _dataTransfer.setData(_LINK_TYPE, value);
    _dataTransfer.setData(_SIMPLIFIED_TEXT_TYPE, value);
  }

  String getData(String format) => _dataTransfer.getData(_simplifyFormat(format));

  String getLink() => _dataTransfer.getData(_LINK_TYPE);

  String getText() => _dataTransfer.getData(_SIMPLIFIED_TEXT_TYPE);

  String _simplifyFormat(String format) {
    if (format != null && format.toLowerCase() == _RICH_TEXT_TYPE) {
      return _SIMPLIFIED_TEXT_TYPE;
    }
    return format;
  }

}
