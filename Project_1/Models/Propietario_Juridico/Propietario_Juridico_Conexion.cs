using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Project_1.Models.Propietario_Juridico
{
    public class Propietario_Juridico_Conexion
    {
        public static int Insert(Propietario_Juridico propietario)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPI_Propietario_Juridico";
                cmd.Parameters.Add("@idDocId", SqlDbType.Int).Value = propietario.jIdDocId;
                cmd.Parameters.Add("@valorDocId", SqlDbType.BigInt).Value = propietario.valorDocId;
                cmd.Parameters.Add("@responsable", SqlDbType.VarChar).Value = propietario.responsable;
                cmd.Parameters.Add("@idPropietario", SqlDbType.Int).Value = propietario.idPropietario;
                cmd.Connection = connection;
                cmd.Parameters.Add("@retValue", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;

                try
                {
                    connection.Open();
                    cmd.ExecuteNonQuery();
                    retval = (int)cmd.Parameters["@retValue"].Value;  // Propietario ya registrado en la base de datos codigo: -11

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

        public static Propietario_Juridico SelectPropietario(Double valorDocId)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Propietario_Juridico_Detail";
                cmd.Parameters.Add("@valorDocId", SqlDbType.BigInt).Value = valorDocId;
                cmd.Connection = connection;
                var propietario = new Propietario_Juridico();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        reader.Read();
                        propietario.responsable = reader.GetString(0);
                        propietario.valorDocId = reader.GetInt64(1);
                        propietario.jIdDocId = reader.GetInt32(2);

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