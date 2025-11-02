import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> createTables() async {
  try {
    await dotenv.load(fileName: ".env");

    // Inicializar conexión con Render
    await RenderDbClient.init();

    // 🟢 Tabla de perfiles
    const createProfilesSQL = '''
    CREATE TABLE IF NOT EXISTS public.profiles (
      id uuid PRIMARY KEY,
      role text NOT NULL DEFAULT 'cliente'
        CHECK (role IN ('cliente','empresario','empleado','soporte','admin')),
      display_name text,
      phone text UNIQUE,
      verification_status text DEFAULT 'pendiente'
        CHECK (verification_status IN ('pendiente','en_revision','verificado','rechazado')),
      email text NOT NULL UNIQUE,
      passwd varchar(255) NOT NULL,
      dui_number text,
      license_number text,
      date_of_birth date,
      email_verified boolean DEFAULT false,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    );
    ''';
    await RenderDbClient.query(createProfilesSQL);
    print('✅ Tabla "profiles" creada o existente.');

    // 🕐 Tabla de registros pendientes (para OTP)
    const createRegisterPendingSQL = '''
    CREATE TABLE IF NOT EXISTS public.register_pending (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      email text NOT NULL UNIQUE,
      passwd varchar(255) NOT NULL,
      otp_code text NOT NULL,
      otp_created_at timestamptz NOT NULL DEFAULT now(),
      otp_expires_at timestamptz NOT NULL DEFAULT (now() + interval '10 minutes'),
      verified boolean NOT NULL DEFAULT false,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    );
    ''';
    await RenderDbClient.query(createRegisterPendingSQL);
    print('✅ Tabla "register_pending" creada o existente.');

    // 🔄 Asegurar que las columnas sean TIMESTAMPTZ con UTC correcto
    const alterRegisterPendingSQL = '''
    ALTER TABLE register_pending
      ALTER COLUMN otp_created_at TYPE timestamptz USING otp_created_at AT TIME ZONE 'UTC',
      ALTER COLUMN otp_expires_at TYPE timestamptz USING otp_expires_at AT TIME ZONE 'UTC',
      ALTER COLUMN created_at TYPE timestamptz USING created_at AT TIME ZONE 'UTC',
      ALTER COLUMN updated_at TYPE timestamptz USING updated_at AT TIME ZONE 'UTC';
    ''';
    await RenderDbClient.query(alterRegisterPendingSQL);
    print('✅ Columnas de fecha de "register_pending" convertidas a UTC.');

    // 🏢 Tabla de empresas
    const createEmpresasSQL = '''
    CREATE TABLE IF NOT EXISTS public.empresas (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
      nombre TEXT NOT NULL,
      nit TEXT,
      nrc TEXT,
      direccion TEXT,
      telefono TEXT,
      estado_verificacion TEXT DEFAULT 'pendiente'
        CHECK (estado_verificacion IN ('pendiente','en_revision','verificado','rechazado')),
      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      UNIQUE(owner_id, nombre)
    );
    ''';
    await RenderDbClient.query(createEmpresasSQL);
    print('✅ Tabla "empresas" creada o existente.');

    // 🚗 Tabla de vehículos
    const createVehiculosSQL = '''
    CREATE TABLE IF NOT EXISTS public.vehiculos (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      empresa_id uuid REFERENCES public.empresas(id) ON DELETE CASCADE,
      marca text NOT NULL,
      modelo text NOT NULL,
      anio int,
      placa text UNIQUE,
      color text,
      tipo text,
      estado text DEFAULT 'disponible'
        CHECK (estado IN ('disponible','en_renta','mantenimiento','inactivo')),
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    );
    ''';
    await RenderDbClient.query(createVehiculosSQL);
    print('✅ Tabla "vehiculos" creada o existente.');

    // 📄 Tabla de documentos
    const createDocumentosSQL = '''
    CREATE TABLE IF NOT EXISTS public.documentos (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      scope text NOT NULL
        CHECK (scope IN ('vehiculo','perfil','empresa')),
      empresa_id uuid REFERENCES public.empresas(id) ON DELETE CASCADE,
      vehiculo_id uuid REFERENCES public.vehiculos(id) ON DELETE CASCADE,
      perfil_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
      tipo_vehiculo text
        CHECK (tipo_vehiculo IN ('tarjeta_circulacion','soa','seguro','licencia_conducir','dui','pasaporte','contrato_renta','factura','otros')),
      tipo_empresa text
        CHECK (tipo_empresa IN ('tarjeta_circulacion','soa','seguro','licencia_conducir','dui','pasaporte','contrato_renta','factura','otros')),
      tipo_perfil text
        CHECK (tipo_perfil IN ('dui','licencia_conducir','pasaporte','otros')),
      file_path text NOT NULL,
      vence_en date,
      verification_status text DEFAULT 'pending'
        CHECK (verification_status IN ('pending','approved','rejected','expired')),
      ocr_data jsonb,
      ai_analysis_id uuid,
      created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
      created_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT documentos_scope_consistency CHECK (
        (scope = 'vehiculo' AND vehiculo_id IS NOT NULL AND empresa_id IS NULL AND perfil_id IS NULL AND tipo_vehiculo IS NOT NULL AND tipo_empresa IS NULL AND tipo_perfil IS NULL)
        OR
        (scope = 'empresa' AND empresa_id IS NOT NULL AND vehiculo_id IS NULL AND perfil_id IS NULL AND tipo_empresa IS NOT NULL AND tipo_vehiculo IS NULL AND tipo_perfil IS NULL)
        OR
        (scope = 'perfil' AND perfil_id IS NOT NULL AND empresa_id IS NULL AND vehiculo_id IS NULL AND tipo_perfil IS NOT NULL AND tipo_empresa IS NULL AND tipo_vehiculo IS NULL)
      )
    );
    ''';
    await RenderDbClient.query(createDocumentosSQL);
    print('✅ Tabla "documentos" creada o existente.');

    print('🎉 Todas las tablas fueron creadas y actualizadas correctamente (UTC listo).');
  } catch (e, stack) {
    print('❌ Error creando tablas: $e');
    print(stack);
  } finally {
    await RenderDbClient.close();
  }
}

void main() async {
  await createTables();
}
