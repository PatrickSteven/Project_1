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

namespace Project_1.Models
{
    public class Propietario_Conexion
    {
        public static int Insert(Propietario porpietario)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPI_Propietario";
                cmd.Parameters.Add("@idDocId", SqlDbType.Int).Value = porpietario.idDocId;
                cmd.Parameters.Add("@valorDocId", SqlDbType.Int).Value = porpietario.valorDocId;
                cmd.Parameters.Add("@nombre", SqlDbType.VarChar).Value = porpietario.nombre;
                cmd.Connection = connection;
                cmd.Parameters.Add("@retValue", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;

                try
                {
                    connection.Open();
                    cmd.ExecuteNonQuery(); 
                    retval =  (int) cmd.Parameters["@retValue"].Value;  // Propietario ya registrado en la base de datos codigo: -11

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

        public static int Delete(Propietario porpietario)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPD_Propietario";
                cmd.Parameters.Add("@valorDocId", SqlDbType.Int).Value = porpietario.valorDocId;
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

        public static int Update(Propietario porpietario)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPU_Propietario";
                cmd.Parameters.Add("@valorDocId", SqlDbType.Int).Value = porpietario.valorDocId;
                cmd.Parameters.Add("@nombre", SqlDbType.VarChar).Value = porpietario.nombre;
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

        public static List<Propietario> Select()
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Propietario";
                cmd.Connection = connection;
                var list = new List<Propietario>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        while (reader.Read())
                            list.Add(new Propietario()
                            {
                                nombre = reader.GetString(0),
                                valorDocId = reader.GetInt32(1),
                                nombreDocId = reader.GetString(2)
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

        public static Propietario SelectPropietario(int valorDocId)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Propietario_Detail";
                cmd.Parameters.Add("@valorDocId", SqlDbType.Int).Value = valorDocId;
                cmd.Connection = connection;
                var propietario = new Propietario();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        reader.Read();
                        propietario.idDocId = reader.GetInt32(0);
                        propietario.nombre = reader.GetString(1);
                        propietario.valorDocId = reader.GetInt32(2);
                        propietario.nombreDocId = reader.GetString(3);

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


        //public int Select()
        //{

        //}


    }
}