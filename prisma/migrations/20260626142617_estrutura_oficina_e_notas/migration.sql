-- CreateEnum
CREATE TYPE "Perfil" AS ENUM ('ADMINISTRADOR', 'ATENDENTE_MECANICO');

-- CreateEnum
CREATE TYPE "StatusOS" AS ENUM ('AGUARDANDO_PECA', 'EM_CONSERTO', 'FINALIZADA', 'CANCELADA');

-- CreateEnum
CREATE TYPE "TipoMovimentacao" AS ENUM ('ENTRADA', 'VENDA_DIRETA', 'USO_OS');

-- CreateTable
CREATE TABLE "usuarios" (
    "id" SERIAL NOT NULL,
    "nome" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "senha_hash" TEXT NOT NULL,
    "perfil" "Perfil" NOT NULL,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "clientes" (
    "id" SERIAL NOT NULL,
    "nome" TEXT NOT NULL,
    "telefone" TEXT NOT NULL,
    "cpf_cnpj" TEXT,
    "modelo_veiculo" TEXT NOT NULL,
    "placa_veiculo" TEXT NOT NULL,

    CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pecas" (
    "id" SERIAL NOT NULL,
    "codigo_identificacao" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "descricao" TEXT,
    "categoria" TEXT,
    "preco_custo" DOUBLE PRECISION NOT NULL,
    "preco_venda" DOUBLE PRECISION NOT NULL,
    "quantidade_estoque" INTEGER NOT NULL DEFAULT 0,
    "estoque_minimo" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "pecas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ordens_servico" (
    "id" SERIAL NOT NULL,
    "descricao_problema" TEXT NOT NULL,
    "status" "StatusOS" NOT NULL DEFAULT 'AGUARDANDO_PECA',
    "data_abertura" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "data_fechamento" TIMESTAMP(3),
    "nota_fiscal_numero" TEXT,
    "nota_fiscal_emitida" BOOLEAN NOT NULL DEFAULT false,
    "cliente_id" INTEGER NOT NULL,
    "usuario_id" INTEGER NOT NULL,

    CONSTRAINT "ordens_servico_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "movimentacoes_estoque" (
    "id" SERIAL NOT NULL,
    "tipo_movimento" "TipoMovimentacao" NOT NULL,
    "quantidade" INTEGER NOT NULL,
    "data_movimento" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "nota_fiscal_numero" TEXT,
    "peca_id" INTEGER NOT NULL,
    "os_id" INTEGER,

    CONSTRAINT "movimentacoes_estoque_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");

-- CreateIndex
CREATE UNIQUE INDEX "pecas_codigo_identificacao_key" ON "pecas"("codigo_identificacao");

-- CreateIndex
CREATE UNIQUE INDEX "ordens_servico_nota_fiscal_numero_key" ON "ordens_servico"("nota_fiscal_numero");

-- CreateIndex
CREATE UNIQUE INDEX "movimentacoes_estoque_nota_fiscal_numero_key" ON "movimentacoes_estoque"("nota_fiscal_numero");

-- AddForeignKey
ALTER TABLE "ordens_servico" ADD CONSTRAINT "ordens_servico_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "clientes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ordens_servico" ADD CONSTRAINT "ordens_servico_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimentacoes_estoque" ADD CONSTRAINT "movimentacoes_estoque_peca_id_fkey" FOREIGN KEY ("peca_id") REFERENCES "pecas"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimentacoes_estoque" ADD CONSTRAINT "movimentacoes_estoque_os_id_fkey" FOREIGN KEY ("os_id") REFERENCES "ordens_servico"("id") ON DELETE SET NULL ON UPDATE CASCADE;
