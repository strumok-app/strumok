class SemVer implements Comparable {
  static const zero = SemVer(major: 0, minor: 0, inc: 0);

  final int major;
  final int minor;
  final int inc;

  const SemVer({
    required this.major,
    required this.minor,
    required this.inc,
  });

  factory SemVer.fromString(String version) {
    if (version.startsWith("v")) {
      version = version.substring(1);
    }

    final versionParts = version.split(".");

    return SemVer(
      major: int.tryParse(versionParts[0]) ?? 0,
      minor: int.tryParse(versionParts[1]) ?? 0,
      inc: int.tryParse(versionParts[2]) ?? 0,
    );
  }

  factory SemVer.fromJson(dynamic json) {
    return SemVer.fromString(json);
  }

  String toJson() => toString();

  @override
  int compareTo(other) {
    SemVer otherSemVer = other as SemVer;

    var res = major - otherSemVer.major;

    if (res == 0) {
      res = minor - otherSemVer.minor;
    }

    if (res == 0) {
      res = inc - otherSemVer.inc;
    }

    return res;
  }

  @override
  String toString() {
    return "$major.$minor.$inc";
  }
}
