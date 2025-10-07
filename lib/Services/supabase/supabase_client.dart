import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static final SupabaseClient supabase = Supabase.instance.client;

  static SupabaseClient get client => supabase;
}
