import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In / Sign Up')),
      body: ListView( // Use ListView for better scrolling if needed
        padding: const EdgeInsets.all(24.0),
        children: [
          SupaEmailAuth(
            // Provide the required callbacks
            onSignInComplete: (response) {
              // AuthGate handles navigation. Called after sign in.
              // You could show a success message here if desired.
            },
            onSignUpComplete: (response) {
              // AuthGate handles navigation IF auto-confirm is on.
              // Called after sign up.
              // If email verification is required, show a message.
              if (response.user?.identities?.isEmpty ?? true) {
                 // This condition might indicate email verification is needed
                 // Adjust based on your Supabase email verification settings
                  ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Check email for verification link!')),
                   );
              }
            },
            onError: (error) {
              // Handle errors, e.g., show a SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${error.toString()}')),
              );
            },
            // Optional: Add metadata fields for signup
            // metadataFields: [
            //   MetaDataField(
            //     prefixIcon: const Icon(Icons.person),
            //     label: 'Username',
            //     key: 'username',
            //   ),
            // ],
          ),
          // You could add other providers like SupaSocialsAuth here too
          // const Divider(),
          // SupaSocialsAuth(
          //   socialProviders: const [SocialProviders.google, SocialProviders.apple],
          //   colored: true,
          //   onError: (error) { /* ... handle error ... */ },
          //   onSuccess: (session) { /* AuthGate handles navigation */ },
          // ),
        ],
      ),
    );
  }
} 