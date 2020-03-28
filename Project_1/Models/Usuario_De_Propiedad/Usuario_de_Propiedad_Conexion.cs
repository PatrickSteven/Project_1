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
using Antlr.Runtime.Misc;
using Microsoft.SqlServer.Server;

namespace Project_1.Models
{
    public class Usuario_de_Propiedad_Conexion
    {
        public static int Insert(Usuario_de_Propiedad conexion)
        {
            using (SqlConnection connection =
                new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPI_Usuario_De_Propiedad";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = conexion.numeroFinca;
                cmd.Parameters.Add("@nombre", SqlDbType.VarChar).Value = conexion.nombre;
                cmd.Connection = connection;
                cmd.Parameters.Add("@retValue", System.Data.SqlDbType.Int).Direction =
                    System.Data.ParameterDirection.ReturnValue;

                try
                {
                    connection.Open();
                    cmd.ExecuteNonQuery();
                    retval = (int) cmd.Parameters["@retValue"]
                        .Value; // Propietario ya registrado en la base de datos codigo: -11

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

        public static int Delete(Usuario_de_Propiedad conexion)
        {
            using (SqlConnection connection =
                new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPD_Usuario_De_Propiedad";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = conexion.numeroFinca;
                cmd.Parameters.Add("@nombre", SqlDbType.VarChar).Value = conexion.nombre;
                cmd.Connection = connection;
                cmd.Parameters.Add("@retValue", System.Data.SqlDbType.Int).Direction =
                    System.Data.ParameterDirection.ReturnValue;

                try
                {
                    connection.Open();
                    cmd.ExecuteNonQuery();
                    retval = (int) cmd.Parameters["@retValue"].Value;

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

        public static List<Propiedad> SelectUsuarioDetail(string nombre)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Usuario_De_Propiedad_Detail_Usuario";
                cmd.Parameters.Add("@nombre", SqlDbType.NVarChar).Value = nombre;
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

        public static List<Usuario> SelectPropiedadDetail(int numeroFinca)
        {
            using (SqlConnection connection =
                new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Usuario_De_Propiedad_Detail_Propiedad";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;
                cmd.Connection = connection;
                List<Usuario> usuarios = new List<Usuario>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            usuarios.Add(new Usuario()
                            {
                                nombre = reader.GetString(0),
                                tipoUsuario = reader.GetString(1)
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

                return usuarios;
            }

        }
    }
}
    