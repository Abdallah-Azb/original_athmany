
import '../../services/session.dart';

class Session {
  FlutterSession _session = FlutterSession();

  Future<String> getId() async => await _session.get('sid');

  Future<void> setId(String id) async {
    assert(id != null);
    await _session.set('sid', id);
  }

  Future<void> clear() async {
    await _session.set('sid', '');
  }
}

class SessionData {
  String sessionId;
  String fullName;

  SessionData(this.sessionId, this.fullName);
}
