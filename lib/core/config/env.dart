class Env {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://pymes-erp-api.onrender.com',
  );
}
