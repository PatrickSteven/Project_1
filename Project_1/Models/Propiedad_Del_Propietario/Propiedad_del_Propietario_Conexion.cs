using System;
using System.Collections.Generic;
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
    public class Propiedad_del_Propietario_Conexion
    {
        public static int Insert(Propiedad_Del_Propietario conexion)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPI_Propiedad_Del_Propietario";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = conexion.numeroFinca;
                cmd.Parameters.Add("@valorDocId", SqlDbType.BigInt).Value = conexion.valorDocId;
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

        public static int Delete (Propiedad_Del_Propietario conexion)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPD_Propiedad_Del_Propietario";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = conexion.numeroFinca;
                cmd.Parameters.Add("@valorDocId", SqlDbType.BigInt).Value = conexion.valorDocId;
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

        public static List<Propietario> SelectPropiedadDetail(int numeroFinca)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Propiedad_Del_Propietario_Detail";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;
                cmd.Connection = connection;
                List<Propietario> propietarios = new List<Propietario>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while(reader.Read())
                        {
                            propietarios.Add(new Propietario()
                            {
                                nombre = reader.GetString(0),
                                valorDocId = reader.GetInt64(1),
                                nombreDocId = reader.GetString(2)

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

                return propietarios; // execute not accomplish
            }
        }

        public static List<Propiedad> SelectPropietarioDetail(double valorDocId)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Propiedad_Del_Propietario_Detail";
                cmd.Parameters.Add("@valorDocId", SqlDbType.BigInt).Value = valorDocId;
                cmd.Connection = connection;
                List<Propiedad> propiedades = new List<Propiedad>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            propiedades.Add(new Propiedad()
                            {
                                numeroFinca = reader.GetInt32(0),
                                valor = reader.GetInt32(1),
                                direccion = reader.GetString(2)

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

                return propiedades; // execute not accomplish
            }
        }
    }
}