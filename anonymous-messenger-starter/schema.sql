create extension if not exists "uuid-ossp";

create table public.messages (
  id uuid primary key default uuid_generate_v4(),
  recipient uuid not null references auth.users(id) on delete cascade,
  sender uuid references auth.users(id),
  sender_name_hint text,
  body text not null,
  anonymous boolean not null default false,
  created_at timestamptz not null default now(),
  is_read boolean not null default false,
  archived boolean not null default false
);

create index on public.messages (recipient, created_at desc);
create index on public.messages (sender, created_at desc);

alter table public.messages enable row level security;

create policy "recipient_can_select" on public.messages
  for select using (auth.uid() = recipient);

create policy "recipient_can_update" on public.messages
  for update using (auth.uid() = recipient);

create policy "authenticated_insert_sender" on public.messages
  for insert with check ((auth.uid() = sender) or (sender is null));
