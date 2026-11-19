-- Vishwakarma Tools & Dies: enquiry storage
create extension if not exists pgcrypto;

create table if not exists public.enquiries (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null check (char_length(trim(customer_name)) between 2 and 120),
  phone text not null check (char_length(trim(phone)) between 7 and 25),
  company text check (company is null or char_length(company) <= 160),
  city text check (city is null or char_length(city) <= 100),
  machine_requirement text check (machine_requirement is null or char_length(machine_requirement) <= 500),
  message text check (message is null or char_length(message) <= 3000),
  status text not null default 'New' check (status in ('New','Contacted','Quoted','Completed')),
  follow_up_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.enquiries enable row level security;

-- Public website visitors may submit enquiries, but cannot read or modify them.
drop policy if exists "Public can submit enquiries" on public.enquiries;
create policy "Public can submit enquiries"
on public.enquiries
for insert
to anon
with check (
  status = 'New'
  and follow_up_date is null
);

-- No public SELECT/UPDATE/DELETE policies are created.
-- Manage/read enquiries only through an authenticated admin workflow.
