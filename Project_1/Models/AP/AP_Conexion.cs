using Project_1.Models.Recibo;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Project_1.Models.AP
{
    public class AP_Conexion
    {
        public static AP MostrarAP(int numeroFinca, int meses, List<int> idsRecibos)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_AP";
                SqlParameter param = new SqlParameter();
                param.ParameterName = "@ReciboSelect";
                param.Value = Recibo_Conexion.ListToDataTable(idsRecibos, "id", "idRecibo");
                cmd.Parameters.Add(param);
                cmd.Parameters.Add("@meses", SqlDbType.Int).Value = meses;
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;


                cmd.Connection = connection;
                AP ap;
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        reader.Read();
                        ap = new AP()
                        { 
                            montoOriginal = (decimal) reader.GetSqlMoney(0),
                            saldo = (decimal) reader.GetSqlMoney(1),
                            tasaInteres = reader.GetDecimal(2),
                            plazoOriginal = reader.GetInt32(3),
                            plazoResta = reader.GetInt32(4),
                            cuota = (decimal) reader.GetSqlMoney(5),
                            insertedAt = reader.GetDateTime(6)
                            
                        };

                    }

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

                return ap; // execute not accomplish
            }
        }
    }
}