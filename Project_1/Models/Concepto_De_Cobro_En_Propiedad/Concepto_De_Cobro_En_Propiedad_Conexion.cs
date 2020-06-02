using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Collections.Generic;
using System.Configuration;
// imports
using System.Data;
using System.Data.SqlClient;
using Project_1.Models.Coneptos_De_Cobro;

namespace Project_1.Models.Concepto_De_Cobro_En_Propiedad
{
    public class Concepto_De_Cobro_En_Propiedad_Conexion
    {
        public static int Insert(Concepto_De_Cobro_En_Propiedad conexion)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPI_Concepto_Cobro_En_Propiedad";
                cmd.Parameters.Add("@nombreCC", SqlDbType.VarChar).Value = conexion.nombreCC;
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = conexion.numeroFinca;
                cmd.Connection = connection;
                cmd.Parameters.Add("@retValue", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;

                try
                {
                    connection.Open();
                    cmd.ExecuteNonQuery();
                    retval = (int)cmd.Parameters["@retValue"].Value;

                }
                catch (Exception ex)
                {
                    retval = -1;
                    throw;

                }
                finally
                {
                    connection.Close();
                }

                return retval; // execute not accomplish
            }
        }


        public static int Delete(Concepto_De_Cobro_En_Propiedad conexion)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPD_Concepto_De_Cobro_En_Propiedad";
                cmd.Parameters.Add("@nombreCC", SqlDbType.VarChar).Value = conexion.nombreCC;
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = conexion.numeroFinca;
                cmd.Connection = connection;
                cmd.Parameters.Add("@retValue", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;

                try
                {
                    connection.Open();
                    cmd.ExecuteNonQuery();
                    retval = (int)cmd.Parameters["@retValue"].Value;

                }
                catch (Exception ex)
                {
                    retval = -1;
                    throw;

                }
                finally
                {
                    connection.Close();
                }

                return retval; // execute not accomplish
            }
        }

        public static List<Concepto_De_Cobro_En_Propiedad> Select(int numeroFinca, String tipoCC)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Concepto_De_Cobro_En_Propiedad";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;
                cmd.Parameters.Add("@TipoCC", SqlDbType.VarChar).Value = tipoCC;
                cmd.Connection = connection;
                var listaConceptoDeCobro = new List<Concepto_De_Cobro_En_Propiedad>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (tipoCC == Tipo_CC.Fijo)
                        {
                            while (reader.Read())
                            {// [fechaLeido], CC.nombre, CC.tasaInteresesMoratorios, CC.DiaDeCobro, CC.qDiasVencidos,CC.EsFijo, CC.EsRecurrente, CCO.monto

                                listaConceptoDeCobro.Add(new Concepto_De_Cobro_En_Propiedad()
                                {
                                    nombreCC = reader.GetString(0),
                                    interesesMoratorios = reader.GetDouble(1),
                                    diaCobro = reader.GetInt32(2),
                                    diasVencidos = reader.GetInt32(3),
                                    esFijo = reader.GetString(4),
                                    esRecurrente = reader.GetString(5),
                                    monto = reader.GetInt32(6),
                                });
                            }
                        }
                        if (tipoCC == Tipo_CC.Consumo)
                        {
                            while (reader.Read())
                            {
                                listaConceptoDeCobro.Add(new Concepto_De_Cobro_En_Propiedad()
                                {
                                    nombreCC = reader.GetString(0),
                                    interesesMoratorios = reader.GetDouble(1),
                                    diaCobro = reader.GetInt32(2),
                                    diasVencidos = reader.GetInt32(3), 
                                    esFijo = reader.GetString(4),
                                    esRecurrente = reader.GetString(5),
                                    monto = reader.GetInt32(6),
                                });
                            }
                        }

                        if (tipoCC == Tipo_CC.Porcentaje)
                        {
                            while (reader.Read())
                            {
                                listaConceptoDeCobro.Add(new Concepto_De_Cobro_En_Propiedad()
                                {
                                    nombreCC = reader.GetString(0),
                                    interesesMoratorios = reader.GetDouble(1),
                                    diaCobro = reader.GetInt32(2),
                                    diasVencidos = reader.GetInt32(3),
                                    esFijo = reader.GetString(4),
                                    esRecurrente = reader.GetString(5),
                                    porcentaje = reader.GetDouble(6),
                                });
                            }
                        }
                        else
                        {
                            while (reader.Read())
                            {
                                listaConceptoDeCobro.Add(new Concepto_De_Cobro_En_Propiedad()
                                {
                                    nombreCC = reader.GetString(0),
                                    interesesMoratorios = reader.GetFloat(1),
                                    diaCobro = reader.GetInt32(2),
                                    diasVencidos = reader.GetInt32(3),
                                    esFijo = reader.GetString(4),
                                    esRecurrente = reader.GetString(5)
                                });
                            }
                        }

                    }
                }
                catch (Exception ex)
                {
                    throw;

                }
                finally
                {
                    connection.Close();
                }

                return listaConceptoDeCobro; // execute not accomplish
            }
        }
    }
}