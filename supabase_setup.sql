-- Script de Configuração do Banco de Dados para FinanceFlow
-- Cole este script no SQL EDITOR do seu painel do Supabase e clique em RUN.

-- 1. Criar a tabela de transações
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- Vincula ao usuário logado
    description TEXT NOT NULL,
    value DECIMAL(12,2) NOT NULL,
    type TEXT CHECK (type IN ('receita', 'despesa')),
    category_id TEXT,
    account_name TEXT,
    card_id UUID DEFAULT NULL, -- Vincula a um cartão de crédito (opcional)
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. Habilitar Segurança em Nível de Linha (RLS)
-- Isso impede que um usuário veja os dados de outro.
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- 3. Criar Políticas de Acesso
-- Permitir que usuários visualizem apenas as PRÓPRIAS transações
CREATE POLICY "Users can view their own transactions" ON transactions
    FOR SELECT USING (auth.uid() = user_id);

-- Permitir que usuários insiram as PRÓPRIAS transações
CREATE POLICY "Users can insert their own transactions" ON transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Permitir que usuários atualizem as PRÓPRIAS transações
CREATE POLICY "Users can update their own transactions" ON transactions
    FOR UPDATE USING (auth.uid() = user_id);

-- Permitir que usuários apaguem as PRÓPRIAS transações
CREATE POLICY "Users can delete their own transactions" ON transactions
    FOR DELETE USING (auth.uid() = user_id);
    
-- 4. Criar a tabela de cartões
CREATE TABLE IF NOT EXISTS cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    digits TEXT,
    limit_val DECIMAL(12,2),
    due_day INTEGER, -- Dia de vencimento (1-31)
    color TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Habilitar RLS para cartões
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own cards" ON cards FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own cards" ON cards FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own cards" ON cards FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own cards" ON cards FOR DELETE USING (auth.uid() = user_id);

