using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using Project_1.ViewModels;

namespace Project_1.Models.TipoDocId
{
    public class TipoDocId_Conexion
    {
        public static IEnumerable<TipoDocId> select()
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Tipo_DocId";
                cmd.Connection = connection;
                List<TipoDocId> list = new List<TipoDocId>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        while (reader.Read())
                            list.Add(new TipoDocId()
                            {
                                id = reader.GetInt32(1),
                                nombre = reader.GetString(2)
                            });
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

                return list; // execute not accomplish
            }
        }
    }
}