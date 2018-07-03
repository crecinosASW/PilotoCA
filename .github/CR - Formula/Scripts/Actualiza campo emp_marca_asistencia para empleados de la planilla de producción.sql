BEGIN TRANSACTION

UPDATE exp.emp_empleos
SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'emp_marca_asistencia', 'true')
WHERE emp_codtpl = 4

SELECT emp_codigo, gen.get_pb_field_data_bit(emp_property_bag_data, 'emp_marca_asistencia') emp_marca_asistencia
FROM exp.emp_empleos
WHERE emp_codtpl = 4

--ROLLBACK
COMMIT