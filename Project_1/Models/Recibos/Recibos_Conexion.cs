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

namespace Project_1.Models.Recibos
{
    public class Recibos_Conexion
    {
        public static int Insert(Recibos recibo)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPI_Recibos";
                cmd.Parameters.Add("@fecha", SqlDbType.Date).Value = recibo.fecha;
                cmd.Parameters.Add("@fechaVencimiento", SqlDbType.Date).Value = recibo.fechaVencimiento;
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = recibo.numeroFinca;
                cmd.Parameters.Add("@idComprobantePago", SqlDbType.Int).Value = recibo.idComprobantePago;
                cmd.Parameters.Add("@monto", SqlDbType.Int).Value = recibo.monto;
                //cmd.Parameters.Add("@esPendiente", SqlDbType.Bit).Value = recibo.esPendiente;
                cmd.Parameters.Add("@nombreCC", SqlDbType.VarChar).Value = recibo.nombreCC;
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

        public static int Delete(Recibos recibo)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPD_Recibos";
                cmd.Parameters.Add("@valorDocId", SqlDbType.BigInt).Value = recibo.numeroFinca;
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

        //@id int,
        //@fecha date,
        //    @total int

        public static int Pagar(Recibos recibo)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SP_Pagar_Recibos";
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = recibo.id;
                cmd.Parameters.Add("@fecha", SqlDbType.Date).Value = recibo.fecha;
                cmd.Parameters.Add("@total", SqlDbType.Int).Value = recibo.monto;
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
    }
}