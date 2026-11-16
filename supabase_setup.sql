-- Hot Dog Show: armazenamento sincronizado inicial (uma lanchonete por projeto Supabase)
-- Execute no SQL Editor do seu projeto.
create table if not exists public.app_state (
  id text primary key check (id = 'main'),
  data jsonb not null,
  updated_at timestamptz not null default now()
);
alter table public.app_state enable row level security;
-- Apenas usuários autenticados podem ler e alterar o estado compartilhado desta lanchonete.
drop policy if exists "Authenticated users can read app state" on public.app_state;
create policy "Authenticated users can read app state" on public.app_state
  for select to authenticated using (true);
drop policy if exists "Authenticated users can insert app state" on public.app_state;
create policy "Authenticated users can insert app state" on public.app_state
  for insert to authenticated with check (true);
drop policy if exists "Authenticated users can update app state" on public.app_state;
create policy "Authenticated users can update app state" on public.app_state
  for update to authenticated using (true) with check (true);
-- Ativa eventos Realtime para a tabela, sem falhar se já estiver publicada.
do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'app_state'
  ) then
    alter publication supabase_realtime add table public.app_state;
  end if;
end $$;
