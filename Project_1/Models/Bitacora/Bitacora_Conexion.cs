using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Project_1.Models.Bitacora
{
    public class Bitacora_Conexion
    {

        public static List<Bitacora> select(int idTipoEntidad)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Bitacora";
                cmd.Parameters.Add("@idTipoEntidad", SqlDbType.Int).Value = idTipoEntidad;
                cmd.Connection = connection;
                List<Bitacora> bitacora_de_entidad = new List<Bitacora>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        while (reader.Read())
                            bitacora_de_entidad.Add(new Bitacora()
                            {
                                idEntidad = reader.GetInt32(0),
                                insertedAt = reader.GetDateTime(1),
                                insertedBy = reader.GetString(2),
                                insertedIn = reader.GetString(3),
                                jsonAntes = reader.GetString(4),
                                jsonDespues = reader.GetString(5)

                            });
                    }

                }
                catch (Exception)
                {
                    retval = -1;
                    throw;

                }
                finally
                {
                    connection.Close();
                }

                return bitacora_de_entidad; // execute not accomplish
            }
        }
    }
}