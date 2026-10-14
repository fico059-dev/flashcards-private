/// Switches for parts of the app that aren't offered yet.
abstract final class Features {
  /// Buying a subscription. While off, the subscription screens are hidden
  /// and premium content just says it isn't available yet (admins can make
  /// packs and OSCE stations free so everyone can use them).
  static const subscriptions = false;
}
