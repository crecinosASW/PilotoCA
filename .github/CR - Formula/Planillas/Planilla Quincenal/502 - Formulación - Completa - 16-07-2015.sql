/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

begin transaction

delete from [sal].[fat_factores_tipo_planilla] where [fat_codtpl] = 1;
delete from [sal].[ftp_formulacion_tipos_planilla] where [ftp_codtpl] = 1;


/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '138584C5-182B-407A-834E-1CACD3726900';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('138584C5-182B-407A-834E-1CACD3726900','FiltroEmpleados','Determina que empleado participa en la planilla','Function FiltroEmpleados()

FiltroEmpleados = (Empleados.Fields("emp_fecha_ingreso").Value <= Periodos.Fields("ppl_fecha_fin").Value) And Empleados.Fields("emp_codtpl").Value = Periodos.Fields("ppl_codtpl").Value

End Function ','boolean','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '24B03A26-2304-404D-8AB0-E05B66944507';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('24B03A26-2304-404D-8AB0-E05B66944507','DiasDelMes','Dias del Mes sera 30 o los dias desde la fecha de ingreso en el mes hasta 30 Mensual','Function DiasDelMes()

dias = 0.00

If Empleados.Fields("emp_fecha_ingreso").Value > Periodos.Fields("ppl_fecha_ini").Value And _
	Empleados.Fields("emp_fecha_ingreso").Value <= Periodos.Fields("ppl_fecha_fin").Value Then
	dias = 30.00 - day(Empleados.Fields("emp_fecha_ingreso").Value) + 1.00
Else
	dias = 30.00
End If
   
DiasDelMes = dias

End Function','double','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '8be13de3-d771-48b6-8104-c4ed0fb3f346';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('8be13de3-d771-48b6-8104-c4ed0fb3f346','DiasDeLaQuincena','Días de la quincena del empleado','Function DiasDeLaQuincena

dias = 0.00

If Empleados.Fields("emp_fecha_ingreso").Value > Periodos.Fields("ppl_fecha_ini").Value And _
	Empleados.Fields("emp_fecha_ingreso").Value <= Periodos.Fields("ppl_fecha_fin").Value Then
	dias = DateDiff("d", Empleados.Fields("emp_fecha_ingreso").Value, Periodos.Fields("ppl_fecha_fin").Value) + 1
Else
	dias = 15.00
End If
   
DiasDeLaQuincena = dias

End Function','double','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '26322A5C-2E2C-4E43-B245-9795A8EC2B24';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('26322A5C-2E2C-4E43-B245-9795A8EC2B24','SalarioActual','Determina la parte del Salario Nominal del Empleado Mensual','Function SalarioActual()

valor = 0.00

'' Calcula Salario Actual
If Not (RubrosSalario.Bof And RubrosSalario.Eof) Then
	If IsNull(RubrosSalario.Fields("ese_valor").Value ) Then
		valor = 0.00
	Else
		If RubrosSalario.Fields("ese_exp_valor").Value = "Diario" Then
			valor = RubrosSalario.Fields("ese_valor").Value * 30.00
		Else
			valor = RubrosSalario.Fields("ese_valor").Value
		End If
	End If
End If
   
SalarioActual = valor

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'BA92629E-E0FD-439C-BAA9-74415954B58F';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('BA92629E-E0FD-439C-BAA9-74415954B58F','SalarioMensual','Sueldo Mensual ajustado por si hubo incrementos o si el ingreso fue en el mes Mensual','Function SalarioMensual()

salmensual = 0.00
salanterior = 0.00 

diasanterior = 0.00
diasactual = 0.00

'' --- Salario Mensual Actual
salmensual = Round(Factores("SalarioActual").Value,2)

'' --- Fecha inicial y final de la planilla
fini = Periodos.Fields("ppl_fecha_ini").Value
ffin = Periodos.Fields("ppl_fecha_fin").Value

'' --- Calcula el Salario anterior si tuvo aumentos
If Not (RubrosSalarioHistorial.Bof And RubrosSalarioHistorial.Eof) Then
	RubrosSalarioHistorial.MoveFirst
	
	salmensual = 0.00
	
	Do Until RubrosSalarioHistorial.Eof
		salanterior = CDbl(RubrosSalarioHistorial.Fields("ese_valor").Value)
		
		fechaini = RubrosSalarioHistorial.Fields("ese_fecha_inicio").Value
		fechafin = RubrosSalarioHistorial.Fields("ese_fecha_fin").Value
		
		If fechaini < fini Then
			fechaini = fini
		End If
		
		If IsNull(fechafin) Or fechafin > ffin Then
			fechafin = ffin
		End If
		
		diasanterior = DateDiff("d", fechaini, fechafin) + 1
		
		salanterior = salanterior / 30.00 * CDbl(diasanterior)
		
		salmensual = salmensual + salanterior
		
		RubrosSalarioHistorial.MoveNext
	Loop
End If   

SalarioMensual = Round(salmensual, 2)

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'D2091928-4505-43C4-ACA4-022CCFE1E5FB';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('D2091928-4505-43C4-ACA4-022CCFE1E5FB','DiasVacacion','Determina la cantidad de Dias a pagar al empleado por encontrarse de vacaciones Mensual','Function DiasVacacion()

dias = 0.00

If Not (DiasVacaciones.Bof And DiasVacaciones.Eof) Then
	Do While Not DiasVacaciones.Eof
	
		dias = dias + DiasVacaciones.Fields("vac_dias").Value 
		DiasVacaciones.MoveNext
	
	Loop

End If

DiasVacacion = dias

End Function','double','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'A17F3A43-305C-4CDB-AA15-A1790D6B483D';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('A17F3A43-305C-4CDB-AA15-A1790D6B483D','DiasIncapacidad','Determina la Cantidad de Dias a Descontar producto de una Accion de Incapacidad (suspension del IGSS Mensual','Function DiasIncapacidad()

dias = 0.00

If Not (DiasIncapacidades.Bof And DiasIncapacidades.Eof) Then 

	Do While Not DiasIncapacidades.Eof                                    

		dias = dias + CDbl(DiasIncapacidades.Fields("ixe_dias").Value)

		DiasIncapacidades.MoveNext       

	Loop         

End If               

DiasIncapacidad = dias

End Function','double','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '6682FB47-7243-45E7-9C35-23F4F5CCFF53';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('6682FB47-7243-45E7-9C35-23F4F5CCFF53','DiasAmonestacion','Dias Amonestacion para este periodo Mensual','Function DiasAmonestacion()

dias = 0.00       

If Amonestaciones.RecordCount > 0 Then              

	Amonestaciones.MoveFirst

	Do While Not Amonestaciones.Eof            

		dias = dias + Amonestaciones.Fields("amo_dias").Value 
	  
		Amonestaciones.MoveNext
		
	Loop  

End If   
		  
DiasAmonestacion = dias

End Function ','double','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '97DF903D-46A1-477D-921F-8E325484FF3C';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('97DF903D-46A1-477D-921F-8E325484FF3C','DiasNoTrabajados','Obtiene el Tiempo No Trabajado por el Empleado Mensual','Function DiasNoTrabajados()

dias = 0.00

If TiemposNoTrabajados.RecordCount > 0 Then         
	
	TiemposNoTrabajados.MoveFirst         
	
	Do Until TiemposNoTrabajados.Eof      

		If CDbl(TiemposNoTrabajados.Fields("tnt_porcentaje_descuento").Value) > 0.00 Then
			dias = dias + CDbl(TiemposNoTrabajados.Fields("dias").Value)
		End If	

		TiemposNoTrabajados.MoveNext  
		
	Loop         

End If

DiasNoTrabajados = dias  

End Function','double','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'AEF1DE9A-77AC-4B4A-B977-5EB3195C01CF';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('AEF1DE9A-77AC-4B4A-B977-5EB3195C01CF','DiasTrabajados','Determina la Cantidad de Dias Efectivamente trabajados por el empleado en el periodo Mensual','Function DiasTrabajados()

dias = 0  
diasiniciales = 0    
diaslimite = 0

fecha_ingreso = Empleados.Fields("emp_fecha_ingreso").Value
fecha_retiro = Empleados.Fields("emp_fecha_retiro").Value								 

fecha_ini = Periodos.Fields("ppl_fecha_ini").Value 
fecha_fin = Periodos.Fields("ppl_fecha_fin").Value 

diaslimite = 15

If Empleados.Fields("plz_es_temporal").Value = 0 Then 

	If fecha_ingreso >= fecha_ini And fecha_ingreso <= fecha_fin Then  
		If Not IsNull(fecha_retiro) Then
			diasiniciales = DateDiff("d", fecha_ingreso, fecha_retiro) + 1
		Else
			diasiniciales = DateDiff("d", fecha_ingreso, fecha_fin) + 1
		End If
	ElseIf fecha_ingreso > fecha_fin Then                   
		diasiniciales = 0               
	Else   
		If Not IsNull(fecha_retiro) Then
			diasiniciales = DateDiff("d", fecha_ini, fecha_retiro) + 1
		Else
			diasiniciales = diaslimite
		End If		
	End If  

Else       
	If fecha_ingreso >= fecha_ini And fecha_ingreso <= fecha_fin Then
		If fecha_ingreso > Empleados.Fields("plz_fecha_fin").Value Then                   
			diasiniciales = 0              
		ElseIf Empleados.Fields("plz_fecha_fin").Value > fecha_fin Then
			If Not IsNull(fecha_retiro) Then
				diasiniciales = DateDiff("d", fecha_ingreso, fecha_retiro) + 1
			Else
				diasiniciales = DateDiff("d", fecha_ingreso, fecha_fin) + 1
			End If
		Else                   
			If Not IsNull(fecha_retiro) Then
				diasiniciales = DateDiff("d", fecha_ingreso, fecha_retiro) + 1
			Else
				diasiniciales = datediff("d", fecha_ingreso, Empleados.Fields("plz_fecha_fin").Value) + 1 
			End If
		End If         
	ElseIf fecha_ingreso > fecha_fin Then                   
		diasiniciales = 0               
	Else              
		If Empleados.Fields("plz_fecha_fin").Value > fecha_fin Then                   
			If Not IsNull(fecha_retiro) Then
				diasiniciales = DateDiff("d", fecha_ini, fecha_retiro) + 1
			Else
				diasiniciales = diaslimite
			End If
		Else                   
			If Not IsNull(fecha_retiro) Then
				diasiniciales = DateDiff("d", fecha_ini, fecha_retiro) + 1
			Else
				diasiniciales = datediff("d", fecha_ini, Empleados.Fields("plz_fecha_fin").Value) + 1
			End If
		End If       
	End If  
End If                  

dias = diasiniciales - _
	Factores("DiasNoTrabajados").Value - _
	Factores("DiasAmonestacion").Value - _
	Factores("DiasIncapacidad").Value - _
	Factores("DiasVacacion").Value

If dias < 0 Then       
	dias = 0  
Else       
	If dias > diaslimite Then            
		dias = diaslimite  
	End If  
End If          

DiasTrabajados = dias  

End Function','double','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'EE32616B-288B-4D37-A1BC-9F3BB4A28C33';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('EE32616B-288B-4D37-A1BC-9F3BB4A28C33','Salario','Salario Correspondiente a esta quincena Mensual','Function Salario()

sal = 0.00  
diasMes = 0.00
dias = 0.00

diasMes = Factores("DiasDeLaQuincena").Value

If diasMes > 0 Then     
	sal = Factores("SalarioMensual").Value 
	dias = Factores("DiasTrabajados").Value                         

	If sal > 0 Then       
		sal = sal / diasMes * dias  
	End If 
	
End If                   


If Not IsNull(Factores("Salario").CodTipoIngreso) And sal > 0.00 Then    
	agrega_ingresos_historial Agrupadores, _
								IngresosEstaPlanilla, _
								Empleados.Fields("emp_codigo").Value, _
								Periodos.Fields("ppl_codigo").Value, _
								Factores("Salario").CodTipoIngreso, _
								sal, Periodos.Fields("tpl_codmon").Value, dias, "Dias"
End If

Salario = sal

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '10521867-ECDF-4116-92CB-D7A2C8958A0E';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('10521867-ECDF-4116-92CB-D7A2C8958A0E','ComplementoSalario','Complemento de Salario a Empleados nuevos en el periodo Anterior y que no tienen pago efectuado Mensual','Function ComplementoSalario()

'' calcula los complementos de Empleados que ingresaron en el periodo anterior siempre y cuando el anterior
'' sea el segundo periodo y que no haya tenido pago en ese periodo.
'' los dias que se toman son de la fecha de ingreso hasta el dia 30 del mes, dado que el Salario es en base
'' a 30 dias.

valor = 0.00
sal = 0.00
dias = 0.00

If Not(ComplementosSalario.Bof And ComplementosSalario.Eof) Then
  
  dias = ComplementosSalario.Fields("eni_dias").Value  
  sal = Factores("SalarioActual").Value

  valor = Round((salario / 30.00) * dias, 2)

End If

If Not IsNull(Factores("ComplementoSalario").CodTipoIngreso) And valor > 0.00 Then
  agrega_ingresos_historial Agrupadores, _
							IngresosEstaPlanilla, _
							Empleados.Fields("emp_codigo").Value, _
							Periodos.Fields("ppl_codigo").Value, _
							Factores("ComplementoSalario").CodTipoIngreso, _
							valor, Periodos.Fields("tpl_codmon").Value, dias, "Dias"
End If

ComplementoSalario = valor

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '38BF0B7A-152F-4798-BD8A-099939CB84B8';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('38BF0B7A-152F-4798-BD8A-099939CB84B8','RetroactivoSalario','Determina el valor del Retroactivo de Incremento sobre Salario Otorgado al Empleado Mensual','Function RetroactivoSalario()

valor = 0.00
dias = 0.00

If Not (RetroactivosSalario.Bof And RetroactivosSalario.Eof) Then
	Do While Not RetroactivosSalario.Eof
                                         
		dias = dias + RetroactivosSalario.Fields("idr_dias").Value 
        
		valor = valor + Cdbl(RetroactivosSalario.Fields("idr_valor").Value)

		RetroactivosSalario.MoveNext
	Loop
End If   
 
If Not IsNull(Factores("RetroactivoSalario").CodTipoIngreso) And valor > 0.00 Then
	agrega_ingresos_historial Agrupadores, _
								IngresosEstaPlanilla, _
								empleados.Fields("emp_codigo").Value, _
								periodos.Fields("ppl_codigo").Value, _
								Factores("RetroactivoSalario").CodTipoIngreso, _
								valor, Periodos.Fields("tpl_codmon").Value, dias, "Dias"
End If

RetroactivoSalario = valor

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'FAE2287C-FF22-4466-927E-AAE805E36ECA';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('FAE2287C-FF22-4466-927E-AAE805E36ECA','PrestacionEmpleado','Prestaciones del Empleado Mensual','Function PrestacionEmpleado()

valor = 0.00
total = 0.00

If PrestacionesEmpleado.RecordCount > 0 Then
	PrestacionesEmpleado.MoveFirst
	Do Until PrestacionesEmpleado.Eof

		valor = Round(PrestacionesEmpleado.Fields("ppp_valor").Value, 2)

		If Not IsNull(PrestacionesEmpleado.Fields("pre_codtig").Value) And valor > 0.00 Then
			agrega_ingresos_historial Agrupadores, _ 
						IngresosEstaPlanilla, _
						Empleados.Fields("emp_codigo").Value, _
						Periodos.Fields("ppl_codigo").Value, _
						PrestacionesEmpleado.Fields("pre_codtig").Value , _
						valor, _
						Periodos.Fields("tpl_codmon").Value, 0.00, "Dias"

			total = total + valor
		End If

		PrestacionesEmpleado.MoveNext
	Loop
End If

PrestacionEmpleado = total

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'BEFA07C4-F284-4DF6-8B76-57417CD8A65A';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('BEFA07C4-F284-4DF6-8B76-57417CD8A65A','Extraordinario','Determina el Monto devengado el empleado por Horas Extras Mensual','Function Extraordinario()

valor = 0.00
total = 0.00
horas = 0

If HorasExtras.RecordCount > 0 Then
  
  HorasExtras.MoveFirst

  Do Until HorasExtras.Eof

	valor = Round(HorasExtras.Fields("ext_valor_a_pagar").Value, 2)
	
	horas = Round(HorasExtras.Fields("ext_num_horas").Value, 2)
	
	total = total + valor
	
	HorasExtras.Fields("ext_aplicado_planilla").Value = 1
	
	If Not IsNull(HorasExtras.Fields("the_codtig").Value) And valor > 0.00 Then
   		agrega_ingresos_historial Agrupadores, _
								IngresosEstaPlanilla, _
								Empleados.Fields("emp_codigo").Value, _
								Periodos.Fields("ppl_codigo").Value, _
								HorasExtras.Fields("the_codtig").Value, _
								Round(valor, 2), _
								Periodos.Fields("tpl_codmon").Value, _
								Round(horas, 2), "Horas"		
	End If
	
	HorasExtras.MoveNext
  Loop

End If

Extraordinario = total

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '8B1822AA-600A-4BF7-BA79-2C727613F8C5';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('8B1822AA-600A-4BF7-BA79-2C727613F8C5','PrestacionIncapacidad','Complemento por suspension del seguro social Mensual','Function PrestacionIncapacidad()

valor = 0.00
total = 0.00
dias = 0.00
  
If Incapacidades.RecordCount > 0 Then
 
  Incapacidades.MoveFirst

  If Not (Incapacidades.Bof And Incapacidades.Eof) Then 

     Do While Not Incapacidades.Eof   

        dias = CDbl(Incapacidades.Fields("pie_dias").Value)
        valor = CDbl(Incapacidades.Fields("pie_valor_a_pagar").Value)

        total = total + valor

         If Not IsNull(Incapacidades.Fields("txi_codtig").Value) And valor > 0.00 Then
            agrega_ingresos_historial Agrupadores, _
                                IngresosEstaPlanilla, _
                                Empleados.Fields("emp_codigo").Value, _
                                Periodos.Fields("ppl_codigo").Value, _
                                Incapacidades.Fields("txi_codtig").Value, _
                                valor, RubrosSalario.Fields("ese_codmon").Value, dias, "Dias"

         End If

        Incapacidades.MoveNext

     Loop

  End If

End If

PrestacionIncapacidad = total

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'E4DF7856-77BE-49B8-BD75-65E5E13BD14C';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('E4DF7856-77BE-49B8-BD75-65E5E13BD14C','Vacacion','Determina el monto a pagar al empleado por los días que está de vacaciones durante la planilla Mensual','Function Vacacion()

montovac = 0.00
diasvac = 0.00
valor_total = 0.00
dias_total = 0.00

If Vacaciones.RecordCount > 0 Then
	
	Vacaciones.MoveFirst

	If Not (Vacaciones.Bof And Vacaciones.Eof) Then 
	
		Do While Not Vacaciones.Eof   
		
		diasvac = CDbl(Vacaciones.Fields("vca_tiempo").Value)
		montovac = CDbl(Vacaciones.Fields("vca_valor").Value)
		
		dias_total = dias_total + diasvac
		valor_total = valor_total + montovac
		
		Vacaciones.MoveNext
		
		Loop
	End If
End If

If Not IsNull(Factores("Vacacion").CodTipoIngreso) And valor_total > 0.00 Then
      agrega_ingresos_historial Agrupadores, _
                                IngresosEstaPlanilla, _
                                Empleados.Fields("emp_codigo").Value, _
                                Periodos.Fields("ppl_codigo").Value, _
                                Factores("Vacacion").CodTipoIngreso, _
                                valor_total, Periodos.Fields("tpl_codmon").Value, dias_total, "Dias"

End If

Vacacion= valor_total

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'a1f666e2-3cb0-4df9-85d4-2d6c40cbdcc6';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('a1f666e2-3cb0-4df9-85d4-2d6c40cbdcc6','Sustitucion','Monto de la sustitucions o coberturas','Function Sustitucion()

monto = 0.00
dias = 0.00
valor_total = 0.00
dias_total = 0.00

If Sustituciones.RecordCount > 0 Then
	Sustituciones.MoveFirst

	If Not (Sustituciones.Bof And Sustituciones.Eof) Then 
	
	Do While Not Sustituciones.Eof   
	
	dias = CDbl(Sustituciones.Fields("ste_dias").Value)
	monto = CDbl(Sustituciones.Fields("ste_valor").Value)
	
	dias_total = dias_total + dias
	valor_total = valor_total + monto
	
	Sustituciones.MoveNext
	
	Loop
	
	End If
End If	

If Not isnull(Factores("Sustitucion").CodTipoIngreso) And valor_total > 0 Then
      agrega_ingresos_historial Agrupadores, _
                                IngresosEstaPlanilla, _
                                Empleados.Fields("emp_codigo").Value, _
                                Periodos.Fields("ppl_codigo").Value, _
                                Factores("Sustitucion").CodTipoIngreso, _
                                valor_total, Periodos.Fields("tpl_codmon").Value, dias_total, "Dias"

End If

Sustitucion = valor_total

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '5938B934-34DA-4A2C-BD98-88C56B09FA8C';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('5938B934-34DA-4A2C-BD98-88C56B09FA8C','IngresoCiclico','Pagos Fijos realizados al empleado mensualmente Mensual','Function IngresoCiclico()

valor = 0.00
dias = 0.00

dias = Factores("DiasTrabajados").Value

''''debemos garantizarnos que el cursor tiene por lo menos un registro para este empleado
If Not (IngresosCiclicos.Bof And IngresosCiclicos.Eof)Then
	IngresosCiclicos.MoveFirst
	
	Do Until IngresosCiclicos.Eof
		
		valor = valor + IngresosCiclicos.Fields("cic_valor_cuota").Value
		
		IngresosCiclicos.Fields("cic_aplicado_planilla").Value = 1
		
		If valor > 0 Then
			agrega_ingresos_historial Agrupadores, _
										IngresosEstaPlanilla, _
										Empleados.Fields("emp_codigo").Value, _
										Periodos.Fields("ppl_codigo").Value, _
										IngresosCiclicos.Fields("igc_codtig").Value, _
										Round(IngresosCiclicos.Fields("cic_valor_cuota").Value, 0), _
										Periodos.Fields("tpl_codmon").Value, dias, "dias"
		End If

		IngresosCiclicos.MoveNext
	Loop

End If

IngresoCiclico = Round(valor, 0)
	
End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'A5161DEB-42C0-4E0E-8175-84ACDC79C626';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('A5161DEB-42C0-4E0E-8175-84ACDC79C626','IngresoEventual','Pago de Ingresos Eventuales Mensual','Function IngresoEventual()

total = 0.00
valor = 0.00

If IngresosEventuales.RecordCount > 0 Then
	IngresosEventuales.MoveFirst
	
	Do Until IngresosEventuales.Eof
	
		valor = Round(IngresosEventuales.Fields("oin_valor_a_pagar").Value, 2)
		
		IngresosEventuales.Fields("oin_aplicado_planilla").Value = 1
		
		agrega_ingresos_historial Agrupadores, _
									IngresosEstaPlanilla, _
									Empleados.Fields("emp_codigo").Value, _
									Periodos.Fields("ppl_codigo").Value, _
									IngresosEventuales.Fields("oin_codtig").Value, _
									valor, Periodos.Fields("tpl_codmon").Value, 0.00, "Dias"
									
		total = total + valor
		
		IngresosEventuales.MoveNext
	Loop
End If

IngresoEventual = total

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '814219DD-1ED1-415F-BCAD-2ACFC7B3AB6B';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('814219DD-1ED1-415F-BCAD-2ACFC7B3AB6B','TotalIngresos','Suma de Todos los Ingresos Devengados por el Empleado en el periodo Mensual','Function TotalIngresos()

valor = 0.00

valor = Round(Factores("Salario").Value + _        
			   Factores("ComplementoSalario").Value + _                
              Factores("RetroactivoSalario").Value + _
              Factores("PrestacionEmpleado").Value + _
              Factores("Extraordinario").Value + _          
              Factores("PrestacionIncapacidad").Value + _	 		  
              Factores("Vacacion").Value + _
              Factores("Sustitucion").Value + _
              Factores("IngresoCiclico").Value + _
              Factores("IngresoEventual").Value, 2) 

TotalIngresos = valor

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'C032648D-F89E-4361-9722-AC9748783521';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('C032648D-F89E-4361-9722-AC9748783521','SeguroSocial','Determina el Monto a Descontar por concepto de IGSS al empleado en el periodo Mensual','Function SeguroSocial()

afecto = 0.00
cuota = 0.00
patronal = 0.00
por_cuota = 0.00
pat_cuota = 0.00
codtdc = 0
liquido = Factores("TotalIngresos").Value

If Empleados.Fields("aplica_seguro_social").Value Then
	
	If Empleados.Fields("emp_es_jubilado").Value Then
		por_cuota = ParametrosAplicacion.Fields("porc_jubilado_seguro_social").Value
		codtdc = ParametrosAplicacion.Fields("codtdc_ccss_jubilado").Value
	Else
		por_cuota = ParametrosAplicacion.Fields("porc_empleado_seguro_social").Value
		codtdc = ParametrosAplicacion.Fields("codtdc_ccss").Value
	End If
	
	pat_cuota = ParametrosAplicacion.Fields("porc_patrono_seguro_social").Value

	afecto = Agrupadores("CRBaseCalculoCCSS").Value
  
	cuota = por_cuota / 100.00 * afecto
	
	If cuota < 0.00 Then 
		cuota = 0.00       
	End If
	
	patronal = Round(pat_cuota / 100.00 * afecto,2)
	
	If patronal < 0.00 Then  
		patronal = 0.00  
	End If                                   
	
	'' inserta el registro en la tabla de descuentos  
	If codtdc > 0 And cuota > 0.00 And liquido - cuota >= 0.00 Then       
	 agrega_descuentos_historial Agrupadores, _
								DescuentosEstaPlanilla, _
								Empleados.Fields("emp_codigo").Value, _
								Periodos.Fields("ppl_codigo").Value, _
								codtdc, _
								Round(cuota, 2), Round(patronal,2), afecto, Periodos.Fields("tpl_codmon").Value, _
								0.00, "Dias"
	End If
   
End If

SeguroSocial = Round(cuota, 2)

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'd5a7e9b3-72b6-4af0-bc42-0a3d4707d6e1';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('d5a7e9b3-72b6-4af0-bc42-0a3d4707d6e1','BancoPopular','Valor del descuento de banco popular','Function BancoPopular()

afecto = 0.00
cuota = 0.00
por_cuota = 0.00
liquido = Factores("TotalIngresos").Value - _
	Factores("SeguroSocial").Value

If Empleados.Fields("aplica_banco_popular").Value Then
	
	por_cuota = ParametrosAplicacion.Fields("banco_popular_porcentaje").Value

	afecto = Agrupadores("CRBaseCalculoBP").Value
  
	cuota = por_cuota / 100.00 * afecto
	
	If cuota < 0.00 Then 
		cuota = 0.00       
	End If
	
	'' inserta el registro en la tabla de descuentos  
	If Not isnull(Factores("BancoPopular").CodTipoDescuento) And cuota > 0.00 And liquido - cuota >= 0.00 Then       
	 agrega_descuentos_historial Agrupadores, _
								DescuentosEstaPlanilla, _
								Empleados.Fields("emp_codigo").Value, _
								Periodos.Fields("ppl_codigo").Value, _
								Factores("BancoPopular").CodTipoDescuento, _
								Round(cuota, 2), Round(patronal,2), afecto, Periodos.Fields("tpl_codmon").Value, _
								0.00, "Dias"
	End If
   
End If

BancoPopular = Round(cuota, 2)

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '179c928d-42ce-4807-8e9d-187136471953';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('179c928d-42ce-4807-8e9d-187136471953','CreditoISRConyuge','El monto que se descuenta al ISR del empleado si tiene conyugüe','Function CreditoISRConyuge

	valor = 0.00
	tasa_cambio = ParametrosAplicacion.Fields("tasa_cambio").Value
	
	If Empleados.Fields("aplica_isr_conyugue").Value Then
		valor = ParametrosAplicacion.Fields("isr_valor_conyugue").Value / tasa_cambio
	End If
	
	CreditoISRConyuge = valor

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'b83b0ff0-b3a6-45eb-a7c0-907f411ee4c2';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('b83b0ff0-b3a6-45eb-a7c0-907f411ee4c2','CreditoISRHijos','El monto que se descuenta al ISR del empleado por el número de hijos que tiene','Function CreditoISRHijos

valor = 0.00
tasa_cambio = ParametrosAplicacion.Fields("tasa_cambio").Value

numHijos = Empleados.Fields("emp_numero_hijos").Value
valor = ParametrosAplicacion.Fields("isr_valor_hijos").Value * numHijos / tasa_cambio
	
CreditoISRHijos = valor

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '4D6352C0-4CDF-4D5C-8035-7BE6B279F6B3';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('4D6352C0-4CDF-4D5C-8035-7BE6B279F6B3','ISR','Determina el Monto a Descontar al Empleado por concepto de ISR Mensual','Function ISR()
	
If Periodos.Fields("ppl_frecuencia").Value = 2 And Empleados.Fields("aplica_renta").Value Then	
	
	afecto_anterior = 0.00
	afecto = 0.00
	porc = 0.00
	excedente = 0.00
	valor = 0.00
	liquido = 0.00
	tasa_cambio = 0.00

	liquido = Factores("TotalIngresos").Value - _
		Factores("SeguroSocial").Value - _
		Factores("BancoPopular").Value
		
	tasa_cambio = ParametrosAplicacion.Fields("tasa_cambio").Value		
	
	''monto afecto al impuesto sobre la renta
	If Not (IngresosPlanillaAnteriorISR.Bof And IngresosPlanillaAnteriorISR.Eof) Then
		afecto_anterior = IngresosPlanillaAnteriorISR.Fields("inn_valor").Value
	End If
	
	afecto = Round((Agrupadores("CRBaseCalculoRenta").Value + afecto_anterior) * tasa_cambio, 2)
	
	''recorre la tabla para obtener el excedente y porcentaje correspondiente
	If Not (TablaISRMensual.Bof And TablaISRMensual.Eof) Then
		TablaISRMensual.MoveFirst
		
		Do Until TablaISRMensual.Eof Or valor > 0.00
			''calculo del ISR
			If afecto >= TablaISRMensual.Fields("inicio").Value And afecto <= TablaISRMensual.Fields("fin").Value Then
				excedente = TablaISRMensual.Fields("excedente").Value
				porc = TablaISRMensual.Fields("porcentaje").Value
				valor = ((afecto - TablaISRMensual.Fields("inicio").Value) * porc / 100.00) + excedente
			End If
			
			TablaISRMensual.MoveNext
		Loop	
	End If
	
	''resta el crédito por conyuges e hijos (si aplica)
	valor = (valor / tasa_cambio) - Factores("CreditoISRConyuge").Value - Factores("CreditoISRHijos").Value
	
	If valor < 0.00 Then 
		valor = 0.00
	End If
	
	If Not isnull(Factores("ISR").CodTipoDescuento) And valor > 0.00 And liquido - valor >= 0.00 Then       
		agrega_descuentos_historial Agrupadores, _
										DescuentosEstaPlanilla, _
										Empleados.Fields("emp_codigo").Value, _
										Periodos.Fields("ppl_codigo").Value, _
										Factores("ISR").CodTipoDescuento, _
										Round(valor, 2), 0.00, afecto, Periodos.Fields("tpl_codmon").Value, _
										0.00, "Dias"		
	End If
	
	ISR = valor	
	
End If

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '4D268117-9C6B-46BC-9146-60CCFD686DE3';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('4D268117-9C6B-46BC-9146-60CCFD686DE3','SeguroMedico','Determina el monto de Descuento por el Seguro Medico. Mensual','Function SeguroMedico()

valor = 0.00
patronal = 0.00

liquido = Factores("TotalIngresos").Value - _    
	Factores("SeguroSocial").Value - _       
	Factores("BancoPopular").Value - _	
	Factores("ISR").Value

If Not (SegurosMedicos.Bof And SegurosMedicos.Eof) Then
	patronal = SegurosMedicos.Fields("sem_cuota_patrono").Value 
	valor = SegurosMedicos.Fields("sem_cuota_empleado").Value 
End If

If Not IsNull(Factores("SeguroMedico").CodTipoDescuento) And valor > 0.00 And liquido - valor >= 0.00 Then       
	agrega_descuentos_historial Agrupadores, _
								DescuentosEstaPlanilla, _
								Empleados.Fields("emp_codigo").Value, _
								Periodos.Fields("ppl_codigo").Value, _
								Factores("SeguroMedico").CodTipoDescuento, _
								Round(valor, 2), patronal, 0, Periodos.Fields("tpl_codmon").Value, 0, "Dias"
End If 

SeguroMedico = valor

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'b9655754-cd27-4980-8749-94ad58c4d52f';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('b9655754-cd27-4980-8749-94ad58c4d52f','Asociacion','Valor por descuento de asociación','Function Asociacion

valor = 0.00
afecto = 0.00
total = 0.00
porcentaje = 0.00
liquido = 0.00

liquido = Factores("TotalIngresos").Value - _    
	Factores("SeguroSocial").Value - _         
	Factores("BancoPopular").Value - _		
	Factores("ISR").Value - _  
	Factores("SeguroMedico").Value
	
afecto = Agrupadores("CRBaseCalculoAsociaciones").Value

If Not (Asociaciones.Bof And Asociaciones.Eof) Then
	Asociaciones.MoveFirst
	
	Do Until Asociaciones.Eof

		porcentaje = Asociaciones.Fields("ase_porcentaje_pago").Value / 100.00
		valor = afecto * porcentaje

		If Not IsNull(Asociaciones.Fields("ase_codtdc").Value) And liquido - valor >= 0 And valor > 0.00 Then
			agrega_descuentos_historial Agrupadores, _
											DescuentosEstaPlanilla, _
											Empleados.Fields("emp_codigo").Value, _
											Periodos.Fields("ppl_codigo").Value, _
											Asociaciones.Fields("ase_codtdc").Value, _
											valor, 0, 0, Periodos.Fields("tpl_codmon").Value, 0.00, "Dias"	
		End If
		
		total = total + valor
		liquido = liquido - valor
		
		Asociaciones.MoveNext
	Loop	
End If

Asociacion = total

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '61281C0E-9C67-440B-9C1B-DC0BAE7397BD';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('61281C0E-9C67-440B-9C1B-DC0BAE7397BD','DescuentoCiclico','Determina el Monto a Descontar al empleado por Prestamos Mensual','Function DescuentoCiclico

total = 0.00
valor = 0.00
liquido = 0.00

liquido = Factores("TotalIngresos").Value - _    
	Factores("SeguroSocial").Value - _         
	Factores("BancoPopular").Value - _		
	Factores("ISR").Value - _  
	Factores("SeguroMedico").Value - _
	Factores("Asociacion").Value

If Not (DescuentosCiclicos.Bof And DescuentosCiclicos.Eof) Then

	DescuentosCiclicos.MoveFirst

	Do Until DescuentosCiclicos.Eof
	
		valor = Round(DescuentosCiclicos.Fields("cdc_valor_cobrado").Value, 2)
	
		If (liquido - valor) > 0 Then
			DescuentosCiclicos.Fields("cdc_fecha_descuento").Value = Periodos.Fields("ppl_fecha_pago").Value
			DescuentosCiclicos.Fields("cdc_aplicado_planilla").Value = 1
	
			agrega_descuentos_historial Agrupadores, _
											DescuentosEstaPlanilla, _
											Empleados.Fields("emp_codigo").Value, _
											Periodos.Fields("ppl_codigo").Value, _
											DescuentosCiclicos.Fields("dcc_codtdc").Value, _
											valor, 0, 0, Periodos.Fields("tpl_codmon").Value, 0, "dias"
		Else
			DescuentosCiclicos.Fields("cdc_aplicado_planilla").Value = 0
		End If
		
		total = total + valor	
		liquido = liquido - valor		
		
		DescuentosCiclicos.MoveNext
	Loop

End If

	
DescuentoCiclico = total
	
End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '3BD0298B-4CD9-47FB-A492-E1A626A61E28';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('3BD0298B-4CD9-47FB-A492-E1A626A61E28','DescuentoCiclicoPorcentaje','Determina el Monto a Descontar al empleado por Prestamos Mensual','Function DescuentoCiclicoPorcentaje

total = 0.00
valor = 0.00
liquido = 0.00
afecto = 0.00

liquido = Factores("TotalIngresos").Value - _    
	Factores("SeguroSocial").Value - _            
	Factores("BancoPopular").Value - _
	Factores("ISR").Value - _  
	Factores("SeguroMedico").Value - _
	Factores("Asociacion").Value - _
	Factores("DescuentoCiclico").Value

If Not (DescuentosCiclicosPorcentaje.Bof And DescuentosCiclicosPorcentaje.Eof) Then

	DescuentosCiclicosPorcentaje.MoveFirst

	Do Until DescuentosCiclicosPorcentaje.Eof
	
		If ccur(DescuentosCiclicosPorcentaje.Fields("dcc_porcentaje").Value) > 0.00 Then

			If DescuentosCiclicosPorcentaje.Fields("dcc_codagr").Value > 0 Then
				For i = 1 To Agrupadores.count
					If Agrupadores(i).codigo = DescuentosCiclicosPorcentaje.Fields("dcc_codagr").Value Then

						valor = Round(Agrupadores(i).Value * ccur(DescuentosCiclicosPorcentaje.Fields("dcc_porcentaje").Value) / 100.00, 2)
	
						Exit For
					End If
				Next
			Else
				valor = ccur(Factores("SalarioActual").Value) * ccur(DescuentosCiclicosPorcentaje.Fields("dcc_porcentaje").Value) / 100.00
			End If
			
			
			If valor > 0 Then
				If (ccur(liquido) - ccur(valor)) >= 0 Then
					agrega_descuentos_historial Agrupadores, _
											DescuentosEstaPlanilla, _
											Empleados.Fields("emp_codigo").Value, _
											Periodos.Fields("ppl_codigo").Value, _
											DescuentosCiclicosPorcentaje.Fields("dcc_codtdc").Value , _
											valor, 0.00, 0.00, Periodos.Fields("tpl_codmon").Value, 0, "dias"
				End If
			End If
			
			liquido = ccur(liquido) - ccur(valor)
			total = total + valor			
			
		End If
   
		DescuentosCiclicosPorcentaje.MoveNext
	Loop

End If

DescuentoCiclicoPorcentaje = total

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = 'A8FCD9E4-04EF-4DFD-B0E5-B9BB26C32BB7';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('A8FCD9E4-04EF-4DFD-B0E5-B9BB26C32BB7','DescuentoEventual','Determina el Monto a Descontar por Otros Descuentos al Empelado Mensual','Function DescuentoEventual()

valor = 0.00  
liquido = 0.00
total = 0.00

liquido = Factores("TotalIngresos").Value - _    
	Factores("SeguroSocial").Value - _     
	Factores("BancoPopular").Value - _	
	Factores("ISR").Value - _  
	Factores("SeguroMedico").Value - _
	Factores("Asociacion").Value - _
	Factores("DescuentoCiclico").Value - _
	Factores("DescuentoCiclicoPorcentaje").Value	

If DescuentosEventuales.RecordCount > 0 Then
	DescuentosEventuales.MoveFirst
	Do Until DescuentosEventuales.Eof
		valor = Round(DescuentosEventuales.Fields("ods_valor_a_descontar").Value, 2)
   
		If liquido > 0.00 And valor <= liquido Then
			liquido = liquido - valor
			DescuentosEventuales.Fields("ods_aplicado_planilla").Value = 1
			agrega_descuentos_historial Agrupadores, _
											DescuentosEstaPlanilla, _
											Empleados.Fields("emp_codigo").Value, _
											Periodos.Fields("ppl_codigo").Value, _
											DescuentosEventuales.Fields("ods_codtdc").Value, _
											valor, 0, 0, Periodos.Fields("tpl_codmon").Value, 0, "Dias"
		Else
			DescuentosEventuales.Fields("ods_aplicado_planilla").Value = 0			
		End If
		
		total = total + valor
   
		DescuentosEventuales.MoveNext
	Loop
End If
 
DescuentoEventual= total

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '6c75d732-8e35-4906-a9d7-ee750473ba29';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('6c75d732-8e35-4906-a9d7-ee750473ba29','TotalDescuentos','Total de descuentos del empleado','Function TotalDescuentos

TotalDescuentos = Round(Factores("SeguroSocial").Value + _
	Factores("BancoPopular").Value + _
	Factores("ISR").Value + _
	Factores("SeguroMedico").Value + _
	Factores("Asociacion").Value + _
	Factores("DescuentoCiclico").Value + _
	Factores("DescuentoCiclicoPorcentaje").Value + _
	Factores("DescuentoEventual").Value, 2)

End Function','money','cr',0);

/* Script Generado por Evolution - Editor de Formulación de Planillas. 16/07/2015 15:55 */

delete from [sal].[fac_factores] where [fac_codigo] = '892C71C1-98ED-45A2-B0B9-9FBCA7F0974C';

insert into [sal].[fac_factores] ([fac_codigo],[fac_id],[fac_descripcion],[fac_vbscript],[fac_codfld],[fac_codpai],[fac_size]) values ('892C71C1-98ED-45A2-B0B9-9FBCA7F0974C','Neto','Determina el Liquido a Percibir por el Empleado en el Periodo Mensual','Function Neto()

Neto = Factores("TotalIngresos").Value - _
       Factores("TotalDescuentos").Value

End Function','money','cr',0);


insert into [sal].[ftp_formulacion_tipos_planilla] ([ftp_codtpl],[ftp_prefijo],[ftp_table_name],[ftp_codfac_filtro],[ftp_codfcu_loop],[ftp_sp_inicializacion],[ftp_sp_finalizacion],[ftp_sp_autorizacion]) values (1,'nqu','cr.nqu_nomina_quincenal','138584C5-182B-407A-834E-1CACD3726900',31,'cr.Genpla_Inicializacion','cr.Genpla_Finalizacion','cr.Genpla_Autorizacion');

set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (376,1,'138584C5-182B-407A-834E-1CACD3726900',1,NULL,NULL,NULL,0);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (377,1,'24B03A26-2304-404D-8AB0-E05B66944507',2,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (378,1,'8be13de3-d771-48b6-8104-c4ed0fb3f346',3,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (379,1,'26322A5C-2E2C-4E43-B245-9795A8EC2B24',4,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (380,1,'BA92629E-E0FD-439C-BAA9-74415954B58F',5,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (381,1,'D2091928-4505-43C4-ACA4-022CCFE1E5FB',6,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (382,1,'A17F3A43-305C-4CDB-AA15-A1790D6B483D',7,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (383,1,'6682FB47-7243-45E7-9C35-23F4F5CCFF53',8,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (384,1,'97DF903D-46A1-477D-921F-8E325484FF3C',9,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (385,1,'AEF1DE9A-77AC-4B4A-B977-5EB3195C01CF',10,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (386,1,'EE32616B-288B-4D37-A1BC-9F3BB4A28C33',11,1,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (387,1,'10521867-ECDF-4116-92CB-D7A2C8958A0E',12,1,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (388,1,'38BF0B7A-152F-4798-BD8A-099939CB84B8',13,12,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (389,1,'FAE2287C-FF22-4466-927E-AAE805E36ECA',14,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (390,1,'BEFA07C4-F284-4DF6-8B76-57417CD8A65A',15,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (391,1,'8B1822AA-600A-4BF7-BA79-2C727613F8C5',16,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (392,1,'E4DF7856-77BE-49B8-BD75-65E5E13BD14C',17,10,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (393,1,'a1f666e2-3cb0-4df9-85d4-2d6c40cbdcc6',18,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (394,1,'5938B934-34DA-4A2C-BD98-88C56B09FA8C',19,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (395,1,'A5161DEB-42C0-4E0E-8175-84ACDC79C626',20,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (396,1,'814219DD-1ED1-415F-BCAD-2ACFC7B3AB6B',21,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (397,1,'C032648D-F89E-4361-9722-AC9748783521',22,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (398,1,'d5a7e9b3-72b6-4af0-bc42-0a3d4707d6e1',23,NULL,2,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (399,1,'179c928d-42ce-4807-8e9d-187136471953',24,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (400,1,'b83b0ff0-b3a6-45eb-a7c0-907f411ee4c2',25,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (401,1,'4D6352C0-4CDF-4D5C-8035-7BE6B279F6B3',26,NULL,4,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (402,1,'4D268117-9C6B-46BC-9146-60CCFD686DE3',27,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (403,1,'b9655754-cd27-4980-8749-94ad58c4d52f',28,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (404,1,'61281C0E-9C67-440B-9C1B-DC0BAE7397BD',29,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (405,1,'3BD0298B-4CD9-47FB-A492-E1A626A61E28',30,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (406,1,'A8FCD9E4-04EF-4DFD-B0E5-B9BB26C32BB7',31,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (407,1,'6c75d732-8e35-4906-a9d7-ee750473ba29',32,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;


set identity_insert [sal].[fat_factores_tipo_planilla] on;
insert into [sal].[fat_factores_tipo_planilla] ([fat_codigo],[fat_codtpl],[fat_codfac],[fat_precedencia],[fat_codtig],[fat_codtdc],[fat_codtrs],[fat_salva_en_tabla]) values (408,1,'892C71C1-98ED-45A2-B0B9-9FBCA7F0974C',33,NULL,NULL,NULL,1);
set identity_insert [sal].[fat_factores_tipo_planilla] off;



commit transaction;
