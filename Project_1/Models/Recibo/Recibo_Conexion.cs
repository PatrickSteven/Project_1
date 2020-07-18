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

        public static int PagarRecibos(int numeroFinca, int idConceptoCobro)
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

    }
}