--Função para aplicar máscara no CPF
CREATE OR REPLACE FUNCTION SF_CPF_FORMATADO(
                                            pCpf IN VARCHAR2, 
                                            pPrefixo IN VARCHAR2 := NULL, 
                                            pSufixo IN VARCHAR2 := NULL)
                                                RETURN VARCHAR2 AS sCpf VARCHAR2(20) := NULL;
BEGIN
    IF TRIM(pCpf) IS NOT NULL THEN
        sCpf := SubStr('00000000000' || TRIM(pCpf), -11);
        sCpf := pPrefixo || 
                SubStr(sCpf, 01, 3) || '.' ||
                SubStr(sCpf, 04, 3) || '.' ||
                SubStr(sCpf, 07, 3) || '-' ||
                SubStr(sCpf, 10, 2) || pSufixo;
    END IF;
    RETURN sCpf;
END SF_CPF_FORMATADO;

--Consultar resultado da função de máscara
SELECT SF_CPF_FORMATADO('12345678910') AS CPF FROM dual;

--Função para validar um CPF
CREATE OR REPLACE FUNCTION SF_VALIDAR_CPF (p_cpf IN CHAR) RETURN CHAR IS
    
    m_total NUMBER := 0;
    m_digito NUMBER := 0;
    m_validar NUMBER := 0;
    
BEGIN
    
    FOR i IN 1..10 LOOP
        IF SUBSTR(p_cpf, i, 1) = SUBSTR(p_cpf, i + 1, 1) THEN
            m_validar := m_validar + 1;
        END IF;
    END LOOP;
    
    IF m_validar = 10 THEN
        RETURN 'F';
    END IF;
    
    FOR i IN 1 .. 9 LOOP
        m_total := m_total + SUBSTR (p_cpf, i, 1) * (11 - i);
    END LOOP;
    
    m_digito := 11 - MOD (m_total, 11);
    
    IF m_digito > 9 THEN
        m_digito := 0;
    END IF;
    
    IF m_digito != SUBSTR (p_cpf, 10, 1) THEN
        RETURN 'F';
    END IF;
    
    m_digito := 0;
    m_total := 0;
    
    FOR i IN 1 .. 10 LOOP
        m_total := m_total + SUBSTR (p_cpf, i, 1) * (12 - i);
    END LOOP;
    
    m_digito := 11 - MOD (m_total, 11);
    
    IF m_digito > 9 THEN
        m_digito := 0;
    END IF;
    
    IF m_digito != SUBSTR (p_cpf, 11, 1) THEN
        RETURN 'F';
    END IF;
    
    RETURN 'V';

END SF_VALIDAR_CPF;

--Resultado da função de validação
SELECT SF_VALIDAR_CPF('') AS CPF FROM dual;



--Questão 01
CREATE TABLE clientes_prv(
   cli_iden int not null,
   cli_nome varchar(30) not null,
   cli_cpf varchar(11) not null,
   cli_cpf_formatado varchar(14),
   cli_cpf_status varchar(1)
);

--Questão 02
alter table clientes_prv add constraint cli_pk primary key(cli_iden);

--Questão 03
create sequence cliente_seq maxvalue 99999999999999 increment by 1 start with 1 cache 20 noorder nocycle;

create or replace trigger cliente_trg before insert on clientes_prv
for each row
when (new.cli_iden is null) begin
select cliente_seq.nextval into : new.cli_iden from dual;
end;

--Questão 04
create or replace trigger cpf_formatado_trg before insert on clientes_prv
for each row
when (new.cli_cpf_formatado is null) begin
select SF_CPF_FORMATADO(:new.cli_cpf) into: new.cli_cpf_formatado from dual;
end;

insert into clientes_prv(cli_nome, cli_cpf) values('teste', '70858261189');

select * from clientes_prv;

--Questão 05
create or replace trigger validar_cpf_trg before insert on clientes_prv
for each row
when (new.cli_cpf_status is null) begin
select SF_VALIDAR_CPF(:new.cli_cpf) into: new.cli_cpf_status from dual;
end;

--Questão 6
INSERT ALL 
INTO CLIENTES_PRV (CLI_NOME, CLI_CPF) VALUES('TIZZO' , 09954603611)
INTO CLIENTES_PRV (CLI_NOME, CLI_CPF) VALUES('Luana' , 70312213477)
INTO CLIENTES_PRV (CLI_NOME, CLI_CPF) VALUES('Tizzo' , 06523244105)
INTO CLIENTES_PRV (CLI_NOME, CLI_CPF) VALUES('Tizzo' , 70327604140)
INTO CLIENTES_PRV (CLI_NOME, CLI_CPF) VALUES('Gabigol_Na_Copa' , 15174642002)
INTO CLIENTES_PRV (CLI_NOME, CLI_CPF) VALUES('Johann' , 36606100423)
INTO CLIENTES_PRV (CLI_NOME, CLI_CPF) VALUES('Eduardo' , 70982291132)
INTO CLIENTES_PRV (CLI_NOME, CLI_CPF) VALUES('Teste' , 05874790195)
INTO CLIENTES_PRV (CLI_NOME, CLI_CPF) VALUES('Gustavo' , 15436945600)
INTO CLIENTES_PRV (CLI_NOME, CLI_CPF) VALUES('Almeida' , 70390051152)
select * from dual;

select * from clientes_prv;

--Questão 7
create table conta_a_receber_prv(
    cta_iden int not null,
    cta_vencto date not null,
    cta_valor number(9,2)
)

alter table conta_a_receber_prv add constraint cta_iden_pk primary key(cta_iden);

--Questão 8
create table boletos_prv(
    bol_cta_iden int not null,
    bol_cta_vencto date not null,
    bol_cta_valor number(9, 2),
    bol_status varchar(1)
)

alter table boletos_prv add constraint bol_iden_fk foreign key(bol_cta_iden) references conta_a_receber_prv(cta_iden);

create sequence conta_a_receber_seq maxvalue 99999999999999 increment by 1 start with 1 cache 20 noorder nocycle;

create or replace trigger conta_a_receber_trg before insert on conta_a_receber_prv
for each row
when (new.cta_iden is null) begin
select conta_a_receber_seq.nextval into : new.cta_iden from dual;
end;

--Questão 9
create or replace procedure cadastrar_boleto_prc(p_cta_id int, p_cta_vct date, p_cta_v number) is 

begin
    insert into boletos_prv(bol_cta_iden, bol_cta_vencto, bol_cta_valor, bol_status)
    values(p_cta_id, p_cta_vct, p_cta_v, 'A');
end cadastrar_boleto_prc;

create or replace trigger cadastrar_boleto_trg after insert on conta_a_receber_prv
for each row
when (new.cta_iden is not null) begin
cadastrar_boleto_prc(:new.cta_iden, :new.cta_vencto, :new.cta_valor);
end;

insert into conta_a_receber_prv(cta_vencto, cta_valor) 
values('20/12/2022', 1500);

select *  from conta_a_receber_prv;

select * from boletos_prv;

--Questão 10
create or replace trigger atualizar_boleto_trg after update on conta_a_receber_prv
for each row
begin
update boletos_prv set bol_status = 'I' where bol_cta_iden = :old.cta_iden;
cadastrar_boleto_prc(:old.cta_iden, :new.cta_vencto, :old.cta_valor);
end;

update conta_a_receber_prv set cta_vencto = '25/12/2022' where cta_iden = 22;