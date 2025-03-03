--- NORMALIZACIÓN DE TABLAS

-- KPI2: Recaudo Bruto

-- 1) TABLA: np_his_abonos | FACTS

select
	CONTRATO as "Contrato", --- ¿POR QUÉ HAY CONTRATOS EN NULO? -- PK (DE DOS COLUMNAS)
	FECHA as "Fecha", -- PK (DE DOS COLUMNAS)
	--FECHA_INI as "Fecha Inicial",
	-- ABONO, -- VALIDAR SI EL NÚMERO LO LEE DE FORMA CORRECTA LA BASE
	case
		when COBRO is null then "NA"
		else COBRO
	end as "Cobro",
	HORA as "Hora",
	detalle_abono as "Detalle Abono",
	CONSIGNACION as "Consignacion",
	FECHA_AFEC as "Fecha Afectacion",
	FECHA_CONS as "Fecha Consignacion",
	HORA_CONS as "Hora Consignacion",
	VALOR as "Valor Abono COP", ---- VALOR DE RECAUDO
	CONCEPTO as "Concepto",
	case
		when ESTADO is null then "NA"
		else ESTADO
	end as "Estado",
	CARTAMOTIVO as "Carta Motivo",
	empresa as "Empresa",
	case
		when tipopago is null then "NA"
		else tipopago
	end as "Tipo Pago",
	case
		when placa is null or placa = '' then "NA"
		else placa
	end as "Placa"
from np_his_abonos;

-- 2) Motos INV | DIMS & FACTS

--- a: DIM
select
	contrato as "Contrato",
	fiadora as "Fiadora",
	conductor as "Conductor",
	tipomoto as "Tipo Moto",
	case
		when consecionario is null or consecionario = '' then 'NA'
		else consecionario 
	end as "Concesionario",
	cobro as "Cobro",
	case
		when destino is null or destino = '' then 'NA'
		else destino
	end as "Destino"
from motos_inv;

--- b: FACT

select
	contrato,
	fecha,
	fact_ant,
	fact_fis,
	cuotaini,
	egreso,
	matysoat,
	comisionase,
	comisionase_ger,
	alistamiento,
	gps,
	totpreparacion,
	egrempfinl,
	FECH_HOR_REG,
	FECH_HOR_REG_A
from motos_inv;

-- KPI4: Crecimiento de las motos

-- 1) Motos INV | FACT: Conocer adquisición de nuevas motos por periodo

select
	contrato,
	fecha, --- FECHA ADQUISICIÓN
	fact_ant,
	fact_fis,
	cuotaini,
	egreso,
	matysoat,
	comisionase,
	comisionase_ger,
	alistamiento,
	gps,
	totpreparacion,
	egrempfinl,
	FECH_HOR_REG,
	FECH_HOR_REG_A
from motos_inv;


--- 2) renta_abonos | FACT: Conocer el último estado de las motos

-- parte de: 

select
	PLACA,
	FECHA,
	contrato, 
	NOVEDAD
from renta_abonos
where NOVEDAD <> '' and NOVEDAD is not null
order by PLACA ASC, FECHA asc 


-- ultimo estado conocido en la base: 

SELECT r.PLACA, r.FECHA, r.contrato, r.NOVEDAD
FROM renta_abonos r
JOIN (
    SELECT PLACA, MAX(FECHA) AS UltimaFecha
    FROM renta_abonos
    WHERE NOVEDAD <> '' AND NOVEDAD IS NOT NULL
    GROUP BY PLACA
) sub ON r.PLACA = sub.PLACA AND r.FECHA = sub.UltimaFecha;

