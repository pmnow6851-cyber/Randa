enum RandaDistributionChannel { unconfigured, direct, googlePlay, appStore }

/// A store build cannot expose the direct web checkout route.
///
/// Distribution must be chosen explicitly at build time. Unknown values
/// disable checkout instead of silently defaulting to the direct channel.
abstract final class RandaDistributionPolicy {
  static const _rawChannel = String.fromEnvironment(
    'RANDA_DISTRIBUTION_CHANNEL',
    defaultValue: 'unconfigured',
  );

  static RandaDistributionChannel get channel => switch (_rawChannel) {
        'direct' => RandaDistributionChannel.direct,
        'google_play' => RandaDistributionChannel.googlePlay,
        'app_store' => RandaDistributionChannel.appStore,
        _ => RandaDistributionChannel.unconfigured,
      };

  static bool get externalStripeCheckoutAllowed =>
      channel == RandaDistributionChannel.direct;
}
