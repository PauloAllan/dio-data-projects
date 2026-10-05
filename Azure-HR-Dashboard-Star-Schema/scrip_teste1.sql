USE azure_company;

-- ============================================================================
-- 1. E 3. VERIFICAÇÃO DE DADOS, TIPOS E NULOS
-- ============================================================================

-- Verificar cabeçalhos, tipos de dados e estrutura das tabelas
DESCRIBE employee;
DESCRIBE departament;
DESCRIBE dept_locations;
DESCRIBE project;
DESCRIBE works_on;
DESCRIBE dependent;

-- Checar registros com valores nulos em colunas críticas
SELECT * FROM employee WHERE Super_ssn IS NULL OR Address IS NULL;
SELECT * FROM works_on WHERE Hours IS NULL;

-- ============================================================================
-- 2. AJUSTE DE TIPOS DE DADOS MONETÁRIOS (DOUBLE / DECIMAL PRECIO)
-- ============================================================================

-- Garante que o campo de Salário utilize precisão decimal apropriada
ALTER TABLE employee 
MODIFY COLUMN Salary DECIMAL(10,2) NOT NULL DEFAULT 2000.00;

-- ============================================================================
-- 4. E 5. TRATAMENTO DE GERENTES E DEPARTAMENTOS SEM GERENTE
-- ============================================================================

-- Identificar funcionários sem gerente (Super_ssn nulo)
-- O funcionário com Super_ssn NULO geralmente é o cargo mais alto (Gerente Geral / CEO)
SELECT * FROM employee WHERE Super_ssn IS NULL;

-- Se houver algum departamento sem gerente atribuído, preenchemos o valor padrão (exemplo: James Borg - Ssn '888665555')
UPDATE departament 
SET Mgr_ssn = '888665555', Mgr_start_date = CURDATE() 
WHERE Mgr_ssn IS NULL;

-- ============================================================================
-- 6. E 7. VALIDAÇÃO DE PROJETOS E HORAS TRABALHADAS
-- ============================================================================

-- Checar se existem projetos sem horas registradas ou com zero horas
SELECT * FROM works_on WHERE Hours IS NULL OR Hours = 0;

-- Preencher horas nulas com 0.0 caso existam
UPDATE works_on SET Hours = 0.0 WHERE Hours IS NULL;

-- ============================================================================
-- 8. E 12. DIVISÃO E MESCLAGEM DE NOMES (NOME COMPLETO)
-- ============================================================================

-- Criar consulta com a junção das colunas de Nome e Sobrenome (Nome Completo)
SELECT 
    Ssn,
    CONCAT(Fname, ' ', IFNULL(CONCAT(Minit, '. '), ''), Lname) AS Name_Complete,
    Salary,
    Dno
FROM employee;

-- ============================================================================
-- 9. E 10. JUNÇÃO DE EMPLOYEE + DEPARTAMENT (COM ELIMINAÇÃO DE COLUNAS DESNECESSÁRIAS)
-- ============================================================================

-- Consulta trazendo o funcionário, salário e o nome do seu departamento associado
-- (Usa LEFT JOIN para garantir que nenhum colaborador seja excluído)
SELECT 
    e.Ssn AS Employee_SSN,
    CONCAT(e.Fname, ' ', e.Lname) AS Employee_Name,
    e.Salary,
    e.Address,
    d.Dnumber AS Dept_Number,
    d.Dname AS Department_Name
FROM employee e
LEFT JOIN departament d ON e.Dno = d.Dnumber;

-- ============================================================================
-- 11. JUNÇÃO DE COLABORADORES E SEUS RESPECTIVOS GERENTES
-- ============================================================================

-- Consulta auto-relacionada (Self-Join) para mapear quem é o gerente de cada funcionário
SELECT 
    e.Ssn AS Employee_SSN,
    CONCAT(e.Fname, ' ', e.Lname) AS Employee_Name,
    e.Salary,
    m.Ssn AS Manager_SSN,
    IFNULL(CONCAT(m.Fname, ' ', m.Lname), 'Top Management / CEO') AS Manager_Name
FROM employee e
LEFT JOIN employee m ON e.Super_ssn = m.Ssn;

-- ============================================================================
-- 13. MESCLAR NOME DO DEPARTAMENTO E LOCALIZAÇÃO (CHAVE ÚNICA DEPARTO-LOCAL)
-- ============================================================================

-- Cria a combinação Departamento + Localização útil para o Modelo Estrela no Power BI
SELECT 
    d.Dnumber,
    d.Dname AS Department_Name,
    dl.Dlocation AS Department_Location,
    CONCAT(d.Dname, ' - ', dl.Dlocation) AS Dept_Location_Unique
FROM departament d
INNER JOIN dept_locations dl ON d.Dnumber = dl.Dnumber;