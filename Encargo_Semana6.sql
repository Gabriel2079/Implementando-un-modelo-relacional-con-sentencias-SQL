-- 0. BORRADO DE TABLAS PREVIAS
DROP TABLE PAGO CASCADE CONSTRAINTS;
DROP TABLE DOSIS CASCADE CONSTRAINTS;
DROP TABLE RECETA CASCADE CONSTRAINTS;
DROP TABLE MEDICAMENTO CASCADE CONSTRAINTS;
DROP TABLE PACIENTE CASCADE CONSTRAINTS;
DROP TABLE MEDICO CASCADE CONSTRAINTS;
DROP TABLE DIGITADOR CASCADE CONSTRAINTS;
DROP TABLE DIAGNOSTICO CASCADE CONSTRAINTS;
DROP TABLE BANCO CASCADE CONSTRAINTS;
DROP TABLE ESPECIALIDAD CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;
DROP TABLE CIUDAD CASCADE CONSTRAINTS;
DROP TABLE REGION CASCADE CONSTRAINTS;

-- 1. CASO 1: CREACIÓN DE TABLAS NORMALIZADAS Y REGLAS DE NEGOCIO
CREATE TABLE REGION (
    id_region   NUMBER(5) NOT NULL,
    nombre      VARCHAR2(50) NOT NULL,
    CONSTRAINT region_pk PRIMARY KEY (id_region)
);

CREATE TABLE CIUDAD (
    id_ciudad   NUMBER(5) NOT NULL,
    nombre      VARCHAR2(50) NOT NULL,
    id_region   NUMBER(5) NOT NULL,
    CONSTRAINT ciudad_pk PRIMARY KEY (id_ciudad),
    CONSTRAINT ciudad_region_fk FOREIGN KEY (id_region) REFERENCES REGION(id_region)
);

CREATE TABLE COMUNA (
    id_comuna   NUMBER(5) GENERATED ALWAYS AS IDENTITY (START WITH 1101 INCREMENT BY 1) NOT NULL,
    nombre      VARCHAR2(50) NOT NULL,
    id_ciudad   NUMBER(5) NOT NULL,
    CONSTRAINT comuna_pk PRIMARY KEY (id_comuna),
    CONSTRAINT comuna_ciudad_fk FOREIGN KEY (id_ciudad) REFERENCES CIUDAD(id_ciudad)
);

CREATE TABLE ESPECIALIDAD (
    id_especialidad NUMBER(4) GENERATED ALWAYS AS IDENTITY START WITH 1 INCREMENT BY 1 NOT NULL,
    nombre          VARCHAR2(50) NOT NULL,
    CONSTRAINT especialidad_pk PRIMARY KEY (id_especialidad)
);

CREATE TABLE BANCO (
    cod_banco   NUMBER(2) NOT NULL,
    nombre      VARCHAR2(25) NOT NULL,
    CONSTRAINT banco_pk PRIMARY KEY (cod_banco)
);

CREATE TABLE DIAGNOSTICO (
    cod_diagnostico NUMBER(3) NOT NULL,
    nombre          VARCHAR2(50) NOT NULL,
    CONSTRAINT diagnostico_pk PRIMARY KEY (cod_diagnostico)
);

CREATE TABLE DIGITADOR (
    id_digitador NUMBER(20) NOT NULL,
    dv_dig       CHAR(1) NOT NULL,
    pnombre      VARCHAR2(25) NOT NULL,
    papellido    VARCHAR2(25) NOT NULL,
    CONSTRAINT digitador_pk PRIMARY KEY (id_digitador),
    CONSTRAINT digitador_dv_chk CHECK (UPPER(dv_dig) IN ('0','1','2','3','4','5','6','7','8','9','K'))
);

CREATE TABLE MEDICO (
    rut_med         NUMBER(8) NOT NULL,
    dv_med          CHAR(1) NOT NULL,
    pnombre         VARCHAR2(25) NOT NULL,
    snombre         VARCHAR2(25),
    papellido       VARCHAR2(25) NOT NULL,
    sapellido       VARCHAR2(25),
    telefono        NUMBER(11) NOT NULL,
    id_especialidad NUMBER(4) NOT NULL,
    CONSTRAINT medico_pk PRIMARY KEY (rut_med),
    CONSTRAINT medico_telefono_un UNIQUE (telefono),
    CONSTRAINT medico_especialidad_fk FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD(id_especialidad),
    CONSTRAINT medico_dv_chk CHECK (UPPER(dv_med) IN ('0','1','2','3','4','5','6','7','8','9','K'))
);

CREATE TABLE PACIENTE (
    rut_pac         VARCHAR2(25) NOT NULL,
    dv_pac          CHAR(1) NOT NULL,
    pnombre         VARCHAR2(25) NOT NULL,
    snombre         VARCHAR2(25),
    edad            DATE,
    telefono        NUMBER(11),
    calle           VARCHAR2(50),
    numeracion      NUMBER(5),
    comuna          NUMBER(5),
    ciudad          NUMBER(5),
    region          NUMBER(5),
    CONSTRAINT paciente_pk PRIMARY KEY (rut_pac),
    CONSTRAINT paciente_dv_chk CHECK (UPPER(dv_pac) IN ('0','1','2','3','4','5','6','7','8','9','K')),
    CONSTRAINT paciente_comuna_fk FOREIGN KEY (comuna) REFERENCES COMUNA(id_comuna),
    CONSTRAINT paciente_ciudad_fk FOREIGN KEY (ciudad) REFERENCES CIUDAD(id_ciudad),
    CONSTRAINT paciente_region_fk FOREIGN KEY (region) REFERENCES REGION(id_region)
);

CREATE TABLE MEDICAMENTO (
    cod_medicamento   NUMBER(7) NOT NULL,
    nombre            VARCHAR2(50) NOT NULL,
    dosis_recomendada VARCHAR2(100),
    stock_disponible  NUMBER(6) DEFAULT 0 NOT NULL,
    tipo_medicamento  NUMBER(3),
    via_administra    NUMBER(3),
    CONSTRAINT medicamento_pk PRIMARY KEY (cod_medicamento)
);

CREATE TABLE RECETA (
    cod_receta        NUMBER(7) NOT NULL,
    observaciones     VARCHAR2(500),
    fecha_emision     DATE NOT NULL,
    fecha_vencimiento VARCHAR2(25),
    tipo_receta       VARCHAR2(20) NOT NULL,
    id_digitador      NUMBER(20) NOT NULL,
    pac_rut           VARCHAR2(25) NOT NULL,
    id_diagnostico    NUMBER(3) NOT NULL,
    med_rut           NUMBER(8) NOT NULL,
    CONSTRAINT receta_pk PRIMARY KEY (cod_receta),
    CONSTRAINT receta_digitador_fk FOREIGN KEY (id_digitador) REFERENCES DIGITADOR(id_digitador),
    CONSTRAINT receta_paciente_fk FOREIGN KEY (pac_rut) REFERENCES PACIENTE(rut_pac),
    CONSTRAINT receta_diagnostico_fk FOREIGN KEY (id_diagnostico) REFERENCES DIAGNOSTICO(cod_diagnostico),
    CONSTRAINT receta_medico_fk FOREIGN KEY (med_rut) REFERENCES MEDICO(rut_med),
    CONSTRAINT receta_tipo_chk CHECK (LOWER(tipo_receta) IN ('digital', 'magistral', 'retenida', 'general', 'veterinaria'))
);

CREATE TABLE DOSIS (
    id_medicamento    NUMBER(7) NOT NULL,
    id_receta         NUMBER(7) NOT NULL,
    descripcion_dosis VARCHAR2(100),
    dias_tratamiento  NUMBER(3),
    unidades          NUMBER(4),
    CONSTRAINT dosis_pk PRIMARY KEY (id_medicamento, id_receta),
    CONSTRAINT dosis_medicamento_fk FOREIGN KEY (id_medicamento) REFERENCES MEDICAMENTO(cod_medicamento),
    CONSTRAINT dosis_receta_fk FOREIGN KEY (id_receta) REFERENCES RECETA(cod_receta)
);

CREATE TABLE PAGO (
    cod_boleta   NUMBER(6) NOT NULL,
    id_receta    NUMBER(7) NOT NULL,
    fecha_pago   DATE NOT NULL,
    monto_total  NUMBER(10) NOT NULL,
    metodo_pago  VARCHAR2(20) NOT NULL,
    id_banco     NUMBER(2),
    CONSTRAINT pago_pk PRIMARY KEY (cod_boleta),
    CONSTRAINT pago_receta_fk FOREIGN KEY (id_receta) REFERENCES RECETA(cod_receta),
    CONSTRAINT pago_banco_fk FOREIGN KEY (id_banco) REFERENCES BANCO(cod_banco)
);

-- 2. CASO 2: MODIFICACIONES CON ALTER TABLE
ALTER TABLE MEDICAMENTO 
ADD precio_unitario NUMBER(10) NOT NULL;

ALTER TABLE MEDICAMENTO 
ADD CONSTRAINT med_precio_chk CHECK (precio_unitario BETWEEN 1000 AND 2000000);

ALTER TABLE PAGO 
ADD CONSTRAINT pago_metodo_chk CHECK (UPPER(metodo_pago) IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA'));

ALTER TABLE PACIENTE 
DROP COLUMN edad;

ALTER TABLE PACIENTE 
ADD fecha_nacimiento DATE;