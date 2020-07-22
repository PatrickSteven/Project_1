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
                            montoOriginal = reader.GetInt64(0),
                            saldo =  reader.GetInt64(1),
                            tasaInteres = reader.GetSqlDecimal(2),
                            plazoOriginal = reader.GetInt32(3),
                            plazoResta = reader.GetInt32(4),
                            cuota = reader.GetInt64(5),
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
    
        public static int CrearAP(int numeroFinca, int meses, List<int> idsRecibos)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SP_CrearAP";
                SqlParameter param = new SqlParameter();
                param.ParameterName = "@ReciboSelect";
                param.Value = Recibo_Conexion.ListToDataTable(idsRecibos, "id", "idRecibo");
                cmd.Parameters.Add(param);
                cmd.Connection = connection;
                cmd.Parameters.Add("@retValue", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;
                cmd.Parameters.Add("@meses", SqlDbType.Int).Value = meses;
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;

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

        public static List<AP> Select(int numeroFinca)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_AP_de_Propieadad";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;
                cmd.Connection = connection;
                List<AP> APs = new List<AP>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            APs.Add(new AP()
                            {
                                montoOriginal = reader.GetInt64(0),
                                saldo = reader.GetInt64(1),
                                tasaInteres = reader.GetSqlDecimal(2),
                                plazoOriginal = reader.GetInt32(3),
                                plazoResta = reader.GetInt32(4),
                                cuota = reader.GetInt64(5),
                                insertedAt = reader.GetDateTime(6),
                                idComprobante = reader.GetInt32(7),
                                totalRecibos = reader.GetInt32(8)

                            });
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

                return APs; // execute not accomplish
            }
        }
    }
}