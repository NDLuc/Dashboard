-- Chạy script này trong Supabase Dashboard → SQL Editor

create table if not exists public.users (
  id text primary key,
  name text not null,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.events (
  id text primary key,
  user_id text not null references public.users (id) on delete cascade,
  occurred_at timestamptz not null,
  address_line text not null,
  district_line text not null,
  speed_kmh double precision not null,
  g_force double precision not null,
  synced boolean not null default false,
  severity text not null check (severity in ('low', 'medium', 'high')),
  lat double precision not null,
  lng double precision not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists events_occurred_at_idx on public.events (occurred_at desc);
create index if not exists events_user_id_idx on public.events (user_id);

alter table public.users enable row level security;
alter table public.events enable row level security;

create policy "Allow public read users"
  on public.users for select
  using (true);

create policy "Allow public read events"
  on public.events for select
  using (true);

-- Dữ liệu mẫu (có thể xóa sau khi có dữ liệu thật)
insert into public.users (id, name, email)
values ('u_01', 'Tài xế', null)
on conflict (id) do nothing;

insert into public.events (
  id, user_id, occurred_at, address_line, district_line,
  speed_kmh, g_force, synced, severity, lat, lng
) values
  (
    'EVT-20240520-1015', 'u_01', now() - interval '2 hours',
    'Đường Nguyễn Văn Linh', 'Quận 7, TP. HCM',
    42, 0.86, true, 'high', 10.729, 106.721
  ),
  (
    'EVT-sample-002', 'u_01', now() - interval '1 day',
    'Quốc lộ 1A, P. Thạnh Xuân', 'Quận 12, TP. HCM',
    35, 0.62, true, 'medium', 10.864, 106.663
  ),
  (
    'EVT-sample-003', 'u_01', now() - interval '3 days',
    'Đường Võ Văn Kiệt', 'Quận 5, TP. HCM',
    31, 0.41, false, 'low', 10.753, 106.645
  )
on conflict (id) do nothing;
