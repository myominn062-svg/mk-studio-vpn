/// MK Studio VPN identifiers — must not overlap with Hiddify (app.hiddify.com / com.hiddify.app).
abstract final class MkStudioIdentifiers {
  static const packageId = 'com.mkstudio.vpn';
  static const channelPrefix = packageId;

  static const methodChannel = '$channelPrefix/method';
  static const platformChannel = '$channelPrefix/platform';
  static const serviceStatusChannel = '$channelPrefix/service.status';
  static const serviceAlertsChannel = '$channelPrefix/service.alerts';

  static const defaultGrpcFrontPort = 27178;
  static const defaultGrpcBackPort = 27179;
}
