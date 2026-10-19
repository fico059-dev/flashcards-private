import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class PurchaseService {
  static const successMessage = 'Success';

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _sub;
  final _controller = StreamController<String>.broadcast();

  Stream<String> get statusStream => _controller.stream;

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  Future<void> init(Set<String> productIds) async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      _controller.add('المتجر غير متاح');
      return;
    }

    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _sub.cancel(),
      onError: (e) => _controller.add('Purchase stream error: $e'),
    );

    final response = await _iap.queryProductDetails(productIds);
    if (response.error != null) {
      _controller.add('Query error: ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      _controller.add('Missing products: ${response.notFoundIDs.join(', ')}');
    }
    _products = response.productDetails.toList();
  }

  Future<void> dispose() async {
    await _sub.cancel();
    await _controller.close();
  }

  Future<void> buy(ProductDetails product) async {
    if (!_isAvailable) {
      _controller.add('المتجر غير متاح');
      return;
    }
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    if (!_isAvailable) {
      _controller.add('المتجر غير متاح');
      return;
    }
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _controller.add('جارٍ المعالجة...');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _controller.add('جارٍ التحقق...');
          try {
            await _verifyOnServer(p);
            await _complete(p);
            await FirebaseAuth.instance.currentUser?.getIdToken(true);
            _controller.add(successMessage);
          } catch (e) {
            _controller.add('فشل التحقق: $e');
          }
          break;

        case PurchaseStatus.error:
          _controller.add('فشلت العملية: ${p.error}');
          await _complete(p);
          break;

        case PurchaseStatus.canceled:
          _controller.add('أُلغيت العملية');
          await _complete(p);
          break;
      }
    }
  }

  Future<void> _verifyOnServer(PurchaseDetails p) async {
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    String source = p.verificationData.source;
    if (source == 'play_store') source = 'google_play';

    final payload = <String, dynamic>{
      'source': source,
      'productId': p.productID,
      'verificationData': p.verificationData.serverVerificationData,
      if (p is GooglePlayPurchaseDetails)
        'orderId': p.billingClientPurchase.orderId,
    };

    final res = await functions.httpsCallable('verifyPurchase').call(payload);
    final ok = (res.data?['success'] == true);
    if (!ok) {
      throw Exception(res.data?['message'] ?? 'Verification failed');
    }
  }

  Future<void> _complete(PurchaseDetails p) async {
    if (p.pendingCompletePurchase) {
      await _iap.completePurchase(p);
    }
  }
}
