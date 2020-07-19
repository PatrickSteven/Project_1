using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
// imports
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Drawing.Printing;
using System.Net.Http.Headers;
using System.Runtime.Remoting.Messaging;

namespace Project_1.Models.Recibo
{
    public class Recibo_Conexion
    {

        public static List<Recibo> Select(int numeroFinca, string nombreConceptoCobro, int estado)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Recibos";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;
                cmd.Parameters.Add("@nombreConceptoCobro", SqlDbType.VarChar).Value = nombreConceptoCobro;
                cmd.Parameters.Add("@estado", SqlDbType.Int).Value = estado;

                cmd.Connection = connection;
                List<Recibo> recibos = new List<Recibo>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        while (reader.Read())
                            recibos.Add(new Recibo()
                            {
                                idConceptoCobro = reader.GetInt32(0),
                                monto = reader.GetInt32(1),
                                fecha = reader.GetDateTime(2),
                                fechaVencimiento = reader.GetDateTime(3),
                                id = reader.GetInt32(4)

                            });
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

                return recibos; // execute not accomplish
            }
        }

        public static int PagarRecibos(List<int> idsRecibos)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SP_PagarSeleccion";
                SqlParameter param = new SqlParameter();
                param.ParameterName = "@ReciboSelect";
                param.Value = ListToDataTable(idsRecibos, "id", "idRecibo");
                cmd.Parameters.Add(param);
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

        public static void CancelarPagoRecibos()
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {   
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SP_AnularIntereses";
                cmd.Connection = connection;

                try
                {
                    connection.Open();
                    cmd.ExecuteNonQuery();

                }
                catch (Exception ex)
                {
                    throw;

                }
                finally
                {
                    connection.Close();
                }

            }
        
        }

        public static int PagarConceptoCobro(int numeroFinca, int idConceptoCobro)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SP_Pagado_Multiple";
                cmd.Parameters.Add("@numFinca", SqlDbType.Int).Value = numeroFinca;
                cmd.Parameters.Add("@tipoRecibo", SqlDbType.Int).Value = idConceptoCobro;
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

        public static List<ReciboPorComprobante> SelectMontosRecibos(List<int> idsRecibos)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_RecibosIntereses";
                SqlParameter param = new SqlParameter();
                param.ParameterName = "@ReciboSelect";
                param.Value = ListToDataTable(idsRecibos, "id", "idRecibo");
                cmd.Parameters.Add(param);

                cmd.Connection = connection;
                List<ReciboPorComprobante> montosRecibos = new List<ReciboPorComprobante>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        while (reader.Read())
                            montosRecibos.Add(new ReciboPorComprobante()
                            {
                                nombreConceptoCobro = reader.GetString(0),
                                monto = reader.GetInt32(1),
                                fecha = reader.GetDateTime(2),
                                fechaVencimiento = reader.GetDateTime(3)                               

                            });
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

                return montosRecibos; // execute not accomplish
            }
        }

        public static List<ComprobanteDePago> SelectComprobantePago(int numeroFinca, string nombreConceptoCobro)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_ComprobanteDePago";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;
                cmd.Parameters.Add("@nombreConceptoCobro", SqlDbType.VarChar).Value = nombreConceptoCobro;

                cmd.Connection = connection;
                List<ComprobanteDePago> comprobantesDePago = new List<ComprobanteDePago>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        while (reader.Read())
                            comprobantesDePago.Add(new ComprobanteDePago()
                            {   
                                idComprobante = reader.GetInt32(0),
                                fecha = reader.GetDateTime(1),
                                total = reader.GetInt32(2)

                            });
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

                return comprobantesDePago; // execute not accomplish
            }
        }

        public static List<ReciboPorComprobante> SelectReciboPorComprobante(int idComprobante, DateTime fechaPago, int numeroFinca)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_RecibosPorComprobante";
                cmd.Parameters.Add("@idComprobante", SqlDbType.Int).Value = idComprobante;
                cmd.Parameters.Add("@fechaPago", SqlDbType.DateTime).Value = System.Data.SqlTypes.SqlDateTime.Parse(fechaPago.ToString("yyyy-MM-dd")); ;
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;

                cmd.Connection = connection;
                List<ReciboPorComprobante> recibosPorComprobante= new List<ReciboPorComprobante>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        while (reader.Read())
                            recibosPorComprobante.Add(new ReciboPorComprobante()
                            {

                                nombreConceptoCobro = reader.GetString(0),
                                diaDeCobro = reader.GetInt32(1),
                                fecha = reader.GetDateTime(2),
                                tasaInteresMoratorio = reader.GetDouble(3),
                                monto = reader.GetInt32(4)

                            });
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

                return recibosPorComprobante; // execute not accomplish
            }
        }

        public static DataTable ListToDataTable(List<int> ids, String idColumn, String column)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add(idColumn);
            dt.Columns.Add(column);
            var identity = 1;
            foreach(int id in ids) {
                dt.Rows.Add(identity, id);
                identity++;
            }

            return dt;
        }
    }
}