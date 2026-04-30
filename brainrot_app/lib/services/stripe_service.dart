import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Encapsulates all Stripe PaymentSheet logic.
///
/// Invokes the Supabase Edge Function `payment-sheet` to generate a
/// PaymentIntent server-side, then presents the native Stripe PaymentSheet
/// for card collection and confirmation.
class StripeService {
  /// Calls the `payment-sheet` Edge Function with a dynamic [amountInCents],
  /// initializes the Stripe PaymentSheet, and presents it to the user.
  ///
  /// Returns `true` if the payment completed successfully.
  /// Returns `false` if the user cancelled or an error occurred.
  static Future<bool> presentPaymentSheet({required int amountInCents}) async {
    try {
      // 1. Call Supabase Edge Function to create a PaymentIntent.
      final response = await Supabase.instance.client.functions.invoke(
        'payment-sheet',
        body: {'amount': amountInCents},
      );

      final data = response.data as Map<String, dynamic>;
      final clientSecret = data['paymentIntent'] as String?;

      if (clientSecret == null || clientSecret.isEmpty) {
        debugPrint('StripeService: No client secret returned from Edge Function');
        return false;
      }

      // 2. Initialize the PaymentSheet with the client secret.
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Dopamine Tax',
          style: ThemeMode.dark,
        ),
      );

      // 3. Present the PaymentSheet to the user.
      await Stripe.instance.presentPaymentSheet();

      // If we reach here, payment was successful (no exception thrown).
      debugPrint('StripeService: Payment completed successfully');
      return true;
    } on StripeException catch (e) {
      // User cancelled or Stripe-specific error.
      debugPrint('StripeService: StripeException — ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      // Network or Edge Function error.
      debugPrint('StripeService: Unexpected error — $e');
      return false;
    }
  }
}
