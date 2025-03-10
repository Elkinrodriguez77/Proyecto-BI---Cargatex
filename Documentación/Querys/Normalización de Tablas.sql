--- NORMALIZACIÓN DE TABLAS

-- KPI2: Recaudo

--- Query principal: 

select
	contrato,
	PLACA,
	ABONO,
	'RENTAYA_D' as empresa,
	COBRO,
	FECHA
from renta_abonos
where contrato <> '' AND contrato IS NOT null

--- union de las subtablas:

select
	CONTRATO,
	placa,
	Recaudo - Total_Carta as Recaudo2,
	empresa,
	COBRO,
	FECHA,
	'his_abonos' as base
FROM (
    SELECT
        CONTRATO,
        placa,
        empresa,
        (ABONO + TRANSF + MULTA + REPUESTO) AS Recaudo,
        (PRONTOPAGO + CARTAREALQUILER + CARTAPERDIDA + CARTAREGRESODIARIO + CARTAADMINISTRACION) AS Total_Carta,
        COBRO,
        FECHA
    FROM np_his_abonos
    WHERE CARTA = 'NO' 
        AND (CONTRATO <> '' AND CONTRATO IS NOT NULL)
) AS consulta

union

select
	contrato,
	PLACA,
	ABONO,
	'RENTAYA_D' as empresa,
	COBRO,
	FECHA,
	'renta_abonos' as base
from renta_abonos
where contrato <> '' AND contrato IS NOT null


--- KPI4: Crecimiento Motos:

--- 1) RENTAYA:


select
	*
from
(
	select
		CONTRATO,
		FECHA,
		CONCEPTO,
		INGPARA,
		COMENTARIO,
		estado,
		CASE 
		    WHEN CONCEPTO = '071' THEN CAST('Entregadas' AS CHAR)
		    WHEN CONCEPTO = '070' AND INGPARA = '02' THEN CAST('Quitadas' AS CHAR)
		    WHEN CONCEPTO = '070' AND INGPARA = '06' THEN CAST('Voluntarias' AS CHAR)
		    ELSE NULL
		END AS tipo_entrega,
		"base_np_gestion_tar" as base
	from np_gestion_tar
) as consulta
where tipo_entrega is not null

union

select
	CONTRATO,
	FECHA,
	CONCEPTO,
	'NA' as "INGPARA",
	'NA' as "COMENTARIO",
	ESTADO,
	'Quitadas Semanal' as tipo_entrega,
	"base_np_his_abonos" as base
from np_his_abonos
where CARTAMOTIVO = 'CARTA REGRESO DIARIO'


--- MOTO HOY:

--- VENTAS:

select
	ID,
	ESTADO,
	CC,
	CONDUCTOR,
	BARRIO_CONDUCTOR,
	LABOR,
	MOTO_INTERES,
	VR_CUOTA,
	FECHA_CUOTAINICIAL_R,
	EMPRESA
from vis_tramite
where ESTADO = 'CUOTA INICIAL'

-- ADMINISTRACION: carta que estaba en semanal y pasa a diario (por mal comportamiento de pago)
--- Y REALQUILER: QUE UN PROPIETARIO CEDE SU CONTRATO A OTRO, tenia contrato semanal.

select
	CONTRATO,
	FECHA,
	CONCEPTO,
	INGPARA,
	COMENTARIO,
	estado,
	case
		when CONCEPTO = '050' then 'Administración'
		when CONCEPTO = '049' then 'Realquiler'
	else null
	end
from np_gestion_tar
where CONCEPTO IN ('050', '049') 

--- NORMAL (tabla rentabilidad_activos): La persona completo el pago de forma exitosa (se le hace carta "Normal" ya que saldo pago)

--- tabla con varios datos interantes para analizar.
select
	cobro,
	contrato,
	placa,
	arrendador,
	barrio,
	empresa,
	costo,
	Valor_moto,
	vlrabono,
	saldo,
	TotalTiempoPago,
	FechaRegistro 
from rentabilidad_activos
where CONCEPTO = 'NORMAL'



---- EN PROCESO (VALIDAR FECHAS DE PAGO)

select
	CONTRATO,
	FECHA,
	dia_canon as fecha_de_pago
from np_his_abonos
where dia_canon is not null

--- dia_canon: MES (pago mensual); Qui (Pago Quincenal); Días de la semana (pagos semanales)

--- en renta abonos el pago es a diario (incluido domingo ¿?)