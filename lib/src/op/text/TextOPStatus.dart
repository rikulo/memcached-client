part of memcached_client;

/**
 * Operation response status.
 */
class TextOPStatus {
  /** indicate data was stored successfully */
  static final STORED = new TextOPStatus(0, "STORED");
  /** indicate data was not stored but not because of an error.
   * e.g. trying to "add" an already existing item or trying to "replace" an
   * inexisting item.
   */
  static final NOT_STORED = new TextOPStatus(0x0005, "NOT_STORED");
  /** indicate that an item you are trying to "cas", "delete", "incr" or "decr"
   *  , "touch" did not exist.
   */
  static final NOT_FOUND = new TextOPStatus(1, "NOT_FOUND");
  /** indicate that the item you are trying to store with a "cas" command has
   * been modified since you last fetch it.
   */
  static final EXISTS = new TextOPStatus(2, "EXISTS");
  /** indicate that all items have been transmitted successfully */
  static final END = new TextOPStatus(0, "END");
  /** indicate that the item was deleted successfully */
  static final DELETED = new TextOPStatus(0, "DELETED");
  /** indicate that the item was touched successfully */
  static final TOUCHED = new TextOPStatus(0, "TOUCHED");

  final int code;
  final String message;

  TextOPStatus(this.code, this.message);

  //@override
  String toString() => "{TextOPStatus: $code: $message}";

  bool match(String resp) => message == resp.substring(0, resp.length - 1);

  static Map _statusMap =
    { 'STORED' : TextOPStatus.STORED,
      'NOT_STORED' : TextOPStatus.NOT_STORED,
      'NOT_FOUND' : TextOPStatus.NOT_FOUND,
      'EXISTS' : TextOPStatus.EXISTS,
      'END' : TextOPStatus.END,
      'DELETED' : TextOPStatus.DELETED,
      'TOUCHED' : TextOPStatus.TOUCHED
    };

  static OPStatus valueOf(String resp) {
    final TextOPStatus status = _statusMap[resp];
    final int code = status == null ? 0 : status.code;
    return code != 0 ? OPStatus.valueOf(code) : null;
  }

  static OPStatus valueOfError(String resp) => //internal error
      matchError(resp) ? new OPStatus(0x0084, resp) : null;

  static bool matchError(String resp) =>
      resp.startsWith("ERROR") ||
      resp.startsWith("CLIENT_ERROR") ||
      resp.startsWith("SERVER_ERROR");
}
