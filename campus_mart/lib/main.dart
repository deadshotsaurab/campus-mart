import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://iaeyijgzpwghevhiksah.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlhZXlpamd6cHdnaGV2aGlrc2FoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUzNzc3MDEsImV4cCI6MjA5MDk1MzcwMX0.X6-c5nwPU3jTpzNFynAqfBr5bTM9haLOy8tqzpSylGo',
  );
  runApp(const CampusMartApp());
}