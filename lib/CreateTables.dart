import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> createTables() async {
  try {
    await dotenv.load(fileName: ".env");
    await RenderDbClient.init();

    print('⚙️ Creando tablas con restricciones únicas...');

    // ===========================================================
    // 👤 Tabla de perfiles (usuarios del sistema)
    // ===========================================================
    const createProfilesSQL = '''
    CREATE TABLE IF NOT EXISTS public.profiles (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      role text NOT NULL DEFAULT 'cliente'
        CHECK (role IN ('cliente','empresario','empleado','soporte','admin')),
      display_name text,
      phone text UNIQUE, -- 🔒 único (no puede repetirse)
      verification_status text DEFAULT 'pendiente'
        CHECK (verification_status IN ('pendiente','en_revision','verificado','rechazado')),
      email text NOT NULL UNIQUE, -- 🔒 único
      passwd varchar(255) NOT NULL,
      dui_number text UNIQUE, -- 🔒 único
      license_number text UNIQUE, -- 🔒 puede ser único si lo deseas
      date_of_birth date,
      email_verified boolean DEFAULT false,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    );
    ''';
    await RenderDbClient.query(createProfilesSQL);
    print('✅ Tabla "profiles" creada o existente.');

    // ===========================================================
    // 📩 Tabla temporal de registro pendiente (OTP)
    // ===========================================================
    const createRegisterPendingSQL = '''
    CREATE TABLE IF NOT EXISTS public.register_pending (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      email text NOT NULL UNIQUE, -- 🔒 único (no duplicar registro pendiente)
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

    // ===========================================================
    // 🏢 Tabla de empresas
    // ===========================================================
    const createEmpresasSQL = '''
CREATE TABLE IF NOT EXISTS public.empresas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  nombre text NOT NULL,
  nit text UNIQUE,
  nrc text UNIQUE,
  direccion text,
  telefono text UNIQUE,
  estado_verificacion text DEFAULT 'pendiente'
    CHECK (estado_verificacion IN ('pendiente','en_revision','verificado','rechazado')),
  email text UNIQUE,
  latitud float8,
  longitud float8,
  
  -- ✅ NUEVAS COLUMNAS
  imagen_perfil text,
  imagen_banner text,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(owner_id, nombre)
);
''';

    await RenderDbClient.query(createEmpresasSQL);
    print('✅ Tabla "empresas" creada o existente.');

    // ===========================================================
    // 🚗 Tabla de vehículos
    // ===========================================================
    const createVehiculosSQL = '''
CREATE TABLE IF NOT EXISTS public.vehiculos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id uuid REFERENCES public.empresas(id) ON DELETE CASCADE,
  marca text NOT NULL,
  modelo text NOT NULL,
  anio int,  -- Nuevo campo para el año del vehículo
  placa text UNIQUE NOT NULL,
  color text,
  tipo text,
  estado text DEFAULT 'disponible'  -- Estado del vehículo: 'disponible', 'en_renta', 'mantenimiento', 'inactivo'
    CHECK (estado IN ('disponible', 'reservado','en_renta', 'mantenimiento', 'inactivo')),

  -- ✅ Nuevas columnas
  imagen1 text,
  imagen2 text,
  titulo text,  -- Agregado el campo título

  -- Agregar precio por día
  precio_por_dia numeric NOT NULL,

  -- Capacidad, transmisión, combustible, puertas, SOA Number, vencimientos
  capacidad int DEFAULT 5,
  transmision text DEFAULT 'automatica',
  combustible text DEFAULT 'gasolina',
  puertas int DEFAULT 4,
  soa_number text,
  circulacion_vence timestamptz,
  soa_vence timestamptz,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  -- Restricción de unicidad para empresa_id y placa
  UNIQUE(empresa_id, placa)
);
''';

    await RenderDbClient.query(createVehiculosSQL);
    print('✅ Tabla "vehiculos" creada o existente.');

    // ===========================================================
    // 📄 Tabla de documentos
    // ===========================================================
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

      -- 🔒 Reglas de consistencia y unicidad
      CONSTRAINT documentos_scope_consistency CHECK (
        (scope = 'vehiculo' AND vehiculo_id IS NOT NULL AND empresa_id IS NULL AND perfil_id IS NULL AND tipo_vehiculo IS NOT NULL AND tipo_empresa IS NULL AND tipo_perfil IS NULL)
        OR
        (scope = 'empresa' AND empresa_id IS NOT NULL AND vehiculo_id IS NULL AND perfil_id IS NULL AND tipo_empresa IS NOT NULL AND tipo_vehiculo IS NULL AND tipo_perfil IS NULL)
        OR
        (scope = 'perfil' AND perfil_id IS NOT NULL AND empresa_id IS NULL AND vehiculo_id IS NULL AND tipo_perfil IS NOT NULL AND tipo_empresa IS NULL AND tipo_vehiculo IS NULL)
      ),

      -- 🔒 No permitir documentos duplicados del mismo tipo para el mismo recurso
      UNIQUE(scope, empresa_id, vehiculo_id, perfil_id, tipo_vehiculo, tipo_empresa, tipo_perfil)
    );
    ''';
    await RenderDbClient.query(createDocumentosSQL);
    print('✅ Tabla "documentos" creada o existente.');

// ===========================================================
// 📋 Tabla de rentas
// ===========================================================
const createRentasSQL = '''
CREATE TABLE IF NOT EXISTS public.rentas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehiculo_id UUID NOT NULL REFERENCES public.vehiculos(id) ON DELETE RESTRICT,
  empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE RESTRICT,
  cliente_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  tipo TEXT NOT NULL DEFAULT 'reserva' CHECK (tipo IN ('reserva','renta')),
  fecha_reserva TIMESTAMPTZ NOT NULL DEFAULT now(),
  fecha_inicio_renta TIMESTAMPTZ NOT NULL,
  fecha_entrega_vehiculo TIMESTAMPTZ NOT NULL,
  pickup_method TEXT NOT NULL DEFAULT 'agencia' CHECK (pickup_method IN ('agencia','domicilio')),
  pickup_address TEXT,
  entrega_address TEXT,
  total NUMERIC(12,2) NOT NULL CHECK (total >= 0),
  status TEXT NOT NULL DEFAULT 'pendiente' CHECK (status IN ('pendiente','confirmada','en_curso','finalizada','cancelada','expirada','rechazada')),
  verification_code TEXT,
  pickup_photos TEXT[],
  return_photos TEXT[],
  damage_detected BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_rentas_time_order CHECK (fecha_entrega_vehiculo >= fecha_inicio_renta)
);
''';
await RenderDbClient.query(createRentasSQL);
print('✅ Tabla "rentas" creada o existente.');

    // ===========================================================
    // 🚗 INSERTAR VEHÍCULOS DE PRUEBA
    // ===========================================================
    print('🚀 Insertando vehículos de prueba...');

    const insertVehiculosSQL = '''
INSERT INTO public.vehiculos (
  id, empresa_id, marca, modelo, anio, placa, color, tipo, estado, 
  imagen1, imagen2, titulo, precio_por_dia, capacidad, transmision, 
  combustible, puertas, soa_number, circulacion_vence, soa_vence
) VALUES 
(
  'a1b2c3d4-e5f6-7890-abcd-ef1234567891',
  'c18704a4-cc41-44bb-8305-03bd94d5b565',
  'Toyota',
  'Corolla',
  2023,
  'P123456',
  'Blanco',
  'Sedan',
  'disponible',
  'https://example.com/toyota1.jpg',
  'https://example.com/toyota2.jpg',
  'Toyota Corolla 2023 - Automático',
  45.00,
  5,
  'automatica',
  'gasolina',
  4,
  'SOA-TOY-001',
  '2025-12-31 23:59:59',
  '2025-12-31 23:59:59'
),
(
  'b2c3d4e5-f6g7-8901-bcde-f23456789012',
  'c18704a4-cc41-44bb-8305-03bd94d5b565',
  'Honda',
  'Civic',
  2024,
  'P234567',
  'Negro',
  'Sedan',
  'disponible',
  'https://example.com/honda1.jpg',
  'https://example.com/honda2.jpg',
  'Honda Civic 2024 - Full Equipo',
  50.00,
  5,
  'automatica',
  'gasolina',
  4,
  'SOA-HON-002',
  '2025-12-31 23:59:59',
  '2025-12-31 23:59:59'
),
(
  'c3d4e5f6-g7h8-9012-cdef-345678901234',
  'c18704a4-cc41-44bb-8305-03bd94d5b565',
  'Mazda',
  'CX-5',
  2023,
  'P345678',
  'Rojo',
  'SUV',
  'disponible',
  'https://example.com/mazda1.jpg',
  'https://example.com/mazda2.jpg',
  'Mazda CX-5 2023 - SUV Familiar',
  65.00,
  7,
  'automatica',
  'gasolina',
  5,
  'SOA-MAZ-003',
  '2025-12-31 23:59:59',
  '2025-12-31 23:59:59'
),
(
  'd4e5f6g7-h8i9-0123-defg-456789012345',
  'c18704a4-cc41-44bb-8305-03bd94d5b565',
  'Hyundai',
  'Tucson',
  2024,
  'P456789',
  'Azul',
  'SUV',
  'disponible',
  'https://example.com/hyundai1.jpg',
  'https://example.com/hyundai2.jpg',
  'Hyundai Tucson 2024 - 4x4',
  70.00,
  5,
  'automatica',
  'diesel',
  5,
  'SOA-HYU-004',
  '2025-12-31 23:59:59',
  '2025-12-31 23:59:59'
),
(
  'e5f6g7h8-i9j0-1234-efgh-567890123456',
  'c18704a4-cc41-44bb-8305-03bd94d5b565',
  'Nissan',
  'Versa',
  2023,
  'P567890',
  'Gris',
  'Sedan',
  'disponible',
  'https://example.com/nissan1.jpg',
  'https://example.com/nissan2.jpg',
  'Nissan Versa 2023 - Económico',
  40.00,
  5,
  'automatica',
  'gasolina',
  4,
  'SOA-NIS-005',
  '2025-12-31 23:59:59',
  '2025-12-31 23:59:59'
)
ON CONFLICT (id) DO UPDATE SET
  empresa_id = EXCLUDED.empresa_id,
  marca = EXCLUDED.marca,
  modelo = EXCLUDED.modelo,
  anio = EXCLUDED.anio,
  placa = EXCLUDED.placa,
  color = EXCLUDED.color,
  tipo = EXCLUDED.tipo,
  estado = EXCLUDED.estado,
  imagen1 = EXCLUDED.imagen1,
  imagen2 = EXCLUDED.imagen2,
  titulo = EXCLUDED.titulo,
  precio_por_dia = EXCLUDED.precio_por_dia,
  capacidad = EXCLUDED.capacidad,
  transmision = EXCLUDED.transmision,
  combustible = EXCLUDED.combustible,
  puertas = EXCLUDED.puertas,
  soa_number = EXCLUDED.soa_number,
  circulacion_vence = EXCLUDED.circulacion_vence,
  soa_vence = EXCLUDED.soa_vence;
''';

    await RenderDbClient.query(insertVehiculosSQL);
    print('✅ 5 vehículos de prueba insertados/actualizados.');

    // ===========================================================
    // 📋 INSERTAR 3 RENTAS CON ESTADO PENDIENTE
    // ===========================================================
    print('🚀 Insertando rentas de prueba con estado pendiente...');

    const insertRentasSQL = '''
INSERT INTO public.rentas (
  vehiculo_id, empresa_id, cliente_id, tipo, fecha_reserva,
  fecha_inicio_renta, fecha_entrega_vehiculo, pickup_method,
  pickup_address, entrega_address, total, status, verification_code
) VALUES 
(
  'a1b2c3d4-e5f6-7890-abcd-ef1234567891',
  'c18704a4-cc41-44bb-8305-03bd94d5b565',
  '40aa5ce9-5561-4b5f-92e7-ff910e615759',
  'reserva',
  NOW(),
  NOW() + INTERVAL '2 days',
  NOW() + INTERVAL '5 days',
  'agencia',
  'Agencia Central, San Salvador',
  'Agencia Central, San Salvador',
  180.00,
  'pendiente',
  'ABC123'
),
(
  'b2c3d4e5-f6g7-8901-bcde-f23456789012',
  'c18704a4-cc41-44bb-8305-03bd94d5b565',
  '40aa5ce9-5561-4b5f-92e7-ff910e615759',
  'renta',
  NOW(),
  NOW() + INTERVAL '3 days',
  NOW() + INTERVAL '7 days',
  'domicilio',
  'Calle Principal #123, San Salvador',
  'Calle Principal #123, San Salvador',
  250.00,
  'pendiente',
  'DEF456'
),
(
  'c3d4e5f6-g7h8-9012-cdef-345678901234',
  'c18704a4-cc41-44bb-8305-03bd94d5b565',
  '40aa5ce9-5561-4b5f-92e7-ff910e615759',
  'reserva',
  NOW(),
  NOW() + INTERVAL '1 week',
  NOW() + INTERVAL '2 weeks',
  'agencia',
  'Agencia Norte, Santa Tecla',
  'Agencia Norte, Santa Tecla',
  455.00,
  'pendiente',
  'GHI789'
)
ON CONFLICT (id) DO NOTHING;
''';

    await RenderDbClient.query(insertRentasSQL);
    print('✅ 3 rentas con estado "pendiente" insertadas.');

    print('🎉 Todas las tablas y datos de prueba fueron creados correctamente.');
  } catch (e, stack) {
    print('❌ Error creando tablas: $e');
    print(stack);
  } finally {
    await RenderDbClient.close();
    print('🔒 Conexión cerrada correctamente.');
  }
}

void main() async {
  await createTables();
}