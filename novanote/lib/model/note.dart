class Note {
  late int _id;
  late String _title;
  late String _priority;
  late String _content;
  late bool _secret;
  late String _date;

  Note(this._id, this._title, this._content, this._date,
      [this._secret = false, this._priority = "Medium"]);

  int get id => _id;

  String get title => _title;

  String get priority => _priority;

  String get content => _content;

  bool get secret => _secret;

  String get date => _date;

  set title(String newTitle) {
    _title = newTitle;
  }

  set priority(String newPriority) {
    _priority = newPriority;
  }

  set content(String newContent) {
    _content = newContent;
  }

  set secret(bool newState) {
    _secret = newState;
  }

  set date(String newDate) {
    _date = newDate;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["id"] = _id;
    map["title"] = _title;
    if (_priority == "Low") {
      map["priority"] = 2;
    } else if (_priority == "Medium") {
      map["priority"] = 1;
    } else {
      map["priority"] = 0;
    }
    map["content"] = _content;
    map["secret"] = _secret ? 1 : 0;
    map["date"] = _date;
    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map) {
    _id = map["id"];
    _title = map["title"];
    var priority = map["priority"];
    if (priority == 0) {
      _priority = "High";
    } else if (priority == 1) {
      _priority = "Medium";
    } else {
      _priority = "Low";
    }
    _content = map["content"];
    _secret = map["secret"] == 0 ? false : true;
    _date = map["date"];
  }
}
