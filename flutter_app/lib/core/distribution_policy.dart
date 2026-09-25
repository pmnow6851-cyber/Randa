enum RandaDistributionChannel {
  direct,
  googlePlay,
  appStore,
}

abstract final class RandaDistributionPolicy {
  static const _rawChannel = String.fromEnvironment(
    'RANDA_DISTRIBUTION_CHANNEL',
    defaultValue: 'direct',
  );

  static RandaDistributionChannel get channel => switch (_rawChannel) {
        'google_play' => RandaDistributionChannel.googlePlay,
        'app_store' => RandaDistributionChannel.appStore,
        _ => RandaDistributionChannel.direct,
      };

  /// Stripe remains available only for the direct/PWA distribution path.
  ///
  /// Google Play and App Store builds must use their approved native purchase
  /// flow and then verify the purchase server-side before entitlement is
  /// granted. This prevents a store build from accidentally shipping the
  /// direct web checkout path.
  static bool get externalStripeCheckoutAllowed =>
      channel == RandaDistributionChannel.direct;

  static bool get requiresNativeStoreBilling =>
      channel == RandaDistributionChannel.googlePlay ||
      channel == RandaDistributionChannel.appStore;
}
