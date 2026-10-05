class NgombiSupabaseConfig {
  // Valeurs par défaut pour le build officiel NGOMBI.
  // La clé utilisée ici est une publishable key, jamais une secret/service_role key.
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://llmpcwgfithyrdeeuxoe.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_PIH3XDqPfIrLlzJR66hLcQ_gLNQs',
  );

  static bool get isConfigured =>
      url.isNotEmpty && publishableKey.isNotEmpty;
}
