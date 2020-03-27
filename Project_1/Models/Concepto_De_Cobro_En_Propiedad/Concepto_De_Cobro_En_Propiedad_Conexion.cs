using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Collections.Generic;
using System.Configuration;
// imports
using System.Data;
using System.Data.SqlClient;

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
                cmd.Parameters.Add("@fechaInicio", SqlDbType.Date).Value = conexion.fechaInicio;
                cmd.Parameters.Add("@fechaFin", SqlDbType.Date).Value = conexion.fechaFin;
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

        public static Propietario Select(int numeroFinca, String tipoCC)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Concepto_De_Cobro_En_Propiedad";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;
                cmd.Parameters.Add("@TipoCC", SqlDbType.VarChar).Value = tipoCC;
                cmd.Connection = connection;
                var conceptoDeCobro = new Concepto_De_Cobro_En_Propiedad();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        reader.Read();
                        conceptoDeCobro.fechaInicio = reader.GetDateTime(0);
                        conceptoDeCobro.fechaFin = reader.GetDateTime(1);
                        conceptoDeCobro.nombreCC = reader.GetString(2);
                        conceptoDeCobro.interesesMoratorios = reader.GetInt32(3);
                        conceptoDeCobro.diaCobro = reader.GetInt32(4);
                        conceptoDeCobro.diaVencido = reader.GetInt32(5);
                        conceptoDeCobro.esFijo = reader.GetBoolean(6);
                        conceptoDeCobro.esRecurrete = reader.GetBoolean(7);
                        conceptoDeCobro.monto = reader.GetSqlMoney(8);

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

                return propietario; // execute not accomplish
            }
        }
    }
}