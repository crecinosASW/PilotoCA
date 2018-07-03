BEGIN TRANSACTION

UPDATE exp.emp_empleos SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'descuentaSeguroSocial', 'true')
UPDATE exp.emp_empleos SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'AplicaBancoPopular', 'true')
UPDATE exp.emp_empleos SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'descuentaRenta', 'true')
UPDATE exp.emp_empleos SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'AplicaISRConyugue', 'false')
UPDATE exp.emp_empleos SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'NumeroHijos', '0')
UPDATE exp.emp_empleos SET emp_property_bag_data = gen.set_pb_field_data(emp_property_bag_data, 'Empleos', 'EsJubilado', 'false')

--ROLLBACK
COMMIT