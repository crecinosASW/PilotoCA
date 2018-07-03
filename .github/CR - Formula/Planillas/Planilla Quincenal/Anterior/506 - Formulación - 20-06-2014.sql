declare @codcia int,
	@codtpl int,
	@codfcu_principal int,
	@codtdc_seguro int,
	@codtdc_renta int

select @codfcu_principal = fcu_codigo
from sal.fcu_formulacion_cursores
where fcu_codpai = 'gt'
	and fcu_nombre = 'Emp_Infosalario'

begin transaction

delete from sal.fat_factores_tipo_planilla 
WHERE EXISTS (SELECT 1 FROM sal.tpl_tipo_planilla WHERE tpl_codigo = fat_codtpl AND tpl_codigo_visual IN ('1'));
delete from sal.ftp_formulacion_tipos_planilla 
WHERE EXISTS (SELECT 1 FROM sal.tpl_tipo_planilla WHERE tpl_codigo = ftp_codtpl AND tpl_codigo_visual IN ('1'));

declare tipos_planillas cursor for
select tpl_codcia, tpl_codigo
from sal.tpl_tipo_planilla
WHERE tpl_codigo_visual IN ('1')

open tipos_planillas

fetch next from tipos_planillas into @codcia, @codtpl

WHILE @@FETCH_STATUS = 0
BEGIN
	insert into sal.ftp_formulacion_tipos_planilla (ftp_codtpl,ftp_prefijo,ftp_table_name,ftp_codfac_filtro,ftp_codfcu_loop,ftp_sp_inicializacion,ftp_sp_finalizacion,ftp_sp_autorizacion) 
	values (@codtpl,'MAQ','gt.GT_MAQ_MENSUAL_ANTICIPO_QUINCENAL','138584C5-182B-407A-834E-1CACD3726900',@codfcu_principal,'gt.Genpla_Inicializacion','gt.Genpla_Finalizacion','gt.Genpla_Autorizacion');

	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'A0A72C19-098F-496E-8A98-DE5A963AD621',13,NULL,NULL,NULL,1);

	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'814219DD-1ED1-415F-BCAD-2ACFC7B3AB6B',33,NULL,NULL,NULL,1);

	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'A5161DEB-42C0-4E0E-8175-84ACDC79C626',32,NULL,NULL,NULL,1);

	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'40F94D1F-E492-45DA-B062-7357505C5ADA',11,NULL,NULL,NULL,1);

	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'97DF903D-46A1-477D-921F-8E325484FF3C',17,NULL,NULL,NULL,1);

	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'4669FA17-9457-4618-9E79-20B352A3DB8F',22,NULL,NULL,NULL,1);

	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'BEFA07C4-F284-4DF6-8B76-57417CD8A65A',23,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'26322A5C-2E2C-4E43-B245-9795A8EC2B24',2,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'61281C0E-9C67-440B-9C1B-DC0BAE7397BD',41,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'138584C5-182B-407A-834E-1CACD3726900',1,NULL,NULL,NULL,0);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'D258CE6A-AFAB-4F7D-A199-D747A894F218',29,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'38BF0B7A-152F-4798-BD8A-099939CB84B8',6,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'AC7628BE-24E0-499A-80B2-51FB9685D141',26,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'AEF1DE9A-77AC-4B4A-B977-5EB3195C01CF',18,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'E4DF7856-77BE-49B8-BD75-65E5E13BD14C',28,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'CB917C21-2EC7-47F6-BEC6-5E67B242087A',37,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'5938B934-34DA-4A2C-BD98-88C56B09FA8C',31,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'0B0F5BE5-83ED-4CF4-9D77-B95E85466295',3,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'C032648D-F89E-4361-9722-AC9748783521',36,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'FE1BE314-0831-43A0-B557-2D003F980C35',35,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'4D268117-9C6B-46BC-9146-60CCFD686DE3',39,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'D2091928-4505-43C4-ACA4-022CCFE1E5FB',14,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'1FD70B43-6D35-4AC5-8ADB-4AFC7766C425',25,3,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'FAE2287C-FF22-4466-927E-AAE805E36ECA',12,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'EE32616B-288B-4D37-A1BC-9F3BB4A28C33',20,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'4D6352C0-4CDF-4D5C-8035-7BE6B279F6B3',38,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'3BD0298B-4CD9-47FB-A492-E1A626A61E28',40,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'988B4F9E-C51E-4BB1-94F8-FCE413C8B582',8,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'6682FB47-7243-45E7-9C35-23F4F5CCFF53',16,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'A17F3A43-305C-4CDB-AA15-A1790D6B483D',15,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'A8FCD9E4-04EF-4DFD-B0E5-B9BB26C32BB7',42,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'BC0D5EE6-3D2E-43D8-B8C7-17152031CCC6',7,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'892C71C1-98ED-45A2-B0B9-9FBCA7F0974C',43,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'10521867-ECDF-4116-92CB-D7A2C8958A0E',24,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'2736ADB0-E80A-4994-A54C-9367C04CAA59',21,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'C65A9D17-52B6-4764-9912-E48C24C9A60C',10,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'2C3D0726-3D4F-430C-8DF8-65BB6D1E3383',4,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'BA92629E-E0FD-439C-BAA9-74415954B58F',9,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'8B1822AA-600A-4BF7-BA79-2C727613F8C5',27,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'24B03A26-2304-404D-8AB0-E05B66944507',5,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'771272D6-ABE4-46D1-8904-FD92B09C9709',19,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'9AF92F8E-9E38-439E-AE48-C798574FE27F',34,NULL,NULL,NULL,1);




	insert into sal.fat_factores_tipo_planilla (fat_codtpl,fat_codfac,fat_precedencia,fat_codtig,fat_codtdc,fat_codtrs,fat_salva_en_tabla) 
	values (@codtpl,'a1f666e2-3cb0-4df9-85d4-2d6c40cbdcc6',30,NULL,NULL,NULL,1);


	fetch next from tipos_planillas into @codcia, @codtpl
end

close tipos_planillas
deallocate tipos_planillas


commit transaction;