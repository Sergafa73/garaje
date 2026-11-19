-- GARAJE · Base de datos en castellano. Se ejecuta UNA vez en Supabase > SQL Editor.
create table if not exists vehiculos(
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nombre text not null, marca_modelo text, matricula text, anio int,
  combustible text default 'Gasoil', km_actuales int default 0,
  creado timestamptz default now());

create table if not exists repostajes(
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  vehiculo_id uuid not null references vehiculos(id) on delete cascade,
  fecha date not null, km int, litros numeric(8,2), precio_litro numeric(6,3),
  importe numeric(10,2), gasolinera text, lleno boolean default true,
  creado timestamptz default now());

create table if not exists lecturas_km(
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  vehiculo_id uuid not null references vehiculos(id) on delete cascade,
  fecha date not null, km int not null, creado timestamptz default now());

create table if not exists reparaciones(
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  vehiculo_id uuid not null references vehiculos(id) on delete cascade,
  fecha date not null, km int, taller text, descripcion text, importe numeric(10,2),
  creado timestamptz default now());

create table if not exists mantenimientos(
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  vehiculo_id uuid not null references vehiculos(id) on delete cascade,
  fecha date not null, km int, tipo text not null, proximo_km int, importe numeric(10,2),
  creado timestamptz default now());

create table if not exists gastos(
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  vehiculo_id uuid not null references vehiculos(id) on delete cascade,
  fecha date not null, concepto text not null, categoria text, importe numeric(10,2),
  creado timestamptz default now());

create table if not exists documentos(
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  vehiculo_id uuid not null references vehiculos(id) on delete cascade,
  tipo text not null, nombre text, vencimiento date not null,
  creado timestamptz default now());

-- Seguridad: cada usuario solo ve y toca SUS datos
do $$ declare t text; begin
  foreach t in array array['vehiculos','repostajes','lecturas_km','reparaciones','mantenimientos','gastos','documentos'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists "solo_mis_datos" on %I', t);
    execute format('create policy "solo_mis_datos" on %I for all to authenticated using (usuario_id = auth.uid()) with check (usuario_id = auth.uid())', t);
  end loop;
end $$;
