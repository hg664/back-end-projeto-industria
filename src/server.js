require('dotenv').config();
const express = require('express');
const { PrismaClient } = require('@prisma/client');

const app = express();
// No Prisma 6, ele lê o DATABASE_URL automaticamente do seu .env através do schema!
const prisma = new PrismaClient();

// Middleware para entender JSON
app.use(express.json());

// ==========================================
// ROTAS DE PEÇAS E ACESSÓRIOS (Card 03)
// ==========================================

// 1. CADASTRAR UMA NOVA PEÇA (POST)
app.post('/api/v1/pecas', async (req, res) => {
  try {
    const { 
      codigo_identificacao, 
      nome, 
      descricao, 
      categoria, 
      preco_custo, 
      preco_venda, 
      quantidade_estoque, 
      estoque_minimo 
    } = req.body;

    const novaPeca = await prisma.peca.create({
      data: {
        codigo_identificacao,
        nome,
        descricao,
        categoria,
        preco_custo,
        preco_venda,
        quantidade_estoque: quantidade_estoque || 0,
        estoque_minimo: estoque_minimo || 0
      }
    });

    return res.status(201).json(novaPeca);

  } catch (error) {
    console.error(error);
    if (error.code === 'P2002') {
      return res.status(400).json({ erro: 'Já existe uma peça cadastrada com este código de identificação.' });
    }
    return res.status(500).json({ erro: 'Erro interno ao cadastrar a peça.' });
  }
});

// 2. LISTAR TODAS AS PEÇAS (GET)
app.get('/api/v1/pecas', async (req, res) => {
  try {
    const pecas = await prisma.peca.findMany();
    return res.status(200).json(pecas);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ erro: 'Erro ao buscar as peças.' });
  }
});

// ==========================================
// INICIALIZAÇÃO DO SERVIDOR
// ==========================================
// 3. BUSCAR UMA PEÇA ESPECÍFICA POR ID (GET)
app.get('/api/v1/pecas/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const peca = await prisma.peca.findUnique({
      where: { id: parseInt(id) }
    });

    if (!peca) {
      return res.status(404).json({ erro: 'Peça não encontrada.' });
    }

    return res.status(200).json(peca);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ erro: 'Erro ao buscar a peça.' });
  }
});

// 4. ATUALIZAR UMA PEÇA (PUT)
app.put('/api/v1/pecas/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { preco_custo, preco_venda, quantidade_estoque, estoque_minimo } = req.body;

    const pecaAtualizada = await prisma.peca.update({
      where: { id: parseInt(id) },
      data: {
        preco_custo,
        preco_venda,
        quantidade_estoque,
        estoque_minimo
      }
    });

    return res.status(200).json(pecaAtualizada);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ erro: 'Erro ao atualizar a peça.' });
  }
});

// 5. DELETAR UMA PEÇA (DELETE)
app.delete('/api/v1/pecas/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await prisma.peca.delete({
      where: { id: parseInt(id) }
    });

    return res.status(204).send(); // 204 significa sucesso, mas sem conteúdo de retorno
  } catch (error) {
    console.error(error);
    return res.status(500).json({ erro: 'Erro ao deletar a peça.' });
  }
});

// ==========================================
// ROTAS DE CLIENTES E VEÍCULOS (Opção 2)
// ==========================================

// 1. CADASTRAR UM NOVO CLIENTE (POST)
app.post('/api/v1/clientes', async (req, res) => {
  try {
    const { nome, telefone, cpf_cnpj, modelo_veiculo, placa_veiculo } = req.body;

    // Validação básica
    if (!nome || !telefone || !modelo_veiculo || !placa_veiculo) {
      return res.status(400).json({ erro: 'Nome, telefone, modelo e placa do veículo são obrigatórios.' });
    }

    const novoCliente = await prisma.cliente.create({
      data: {
        nome,
        telefone,
        cpf_cnpj,
        modelo_veiculo,
        placa_veiculo
      }
    });

    return res.status(201).json(novoCliente);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ erro: 'Erro ao cadastrar o cliente.' });
  }
});

// 2. LISTAR TODOS OS CLIENTES (GET)
app.get('/api/v1/clientes', async (req, res) => {
  try {
    const clientes = await prisma.cliente.findMany();
    return res.status(200).json(clientes);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ erro: 'Erro ao buscar os clientes.' });
  }
});
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚗 Servidor PICK-UP-CAR rodando na porta ${PORT}`);
});