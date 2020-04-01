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
    public class Usuario_Conexion
    {
        public static int Insert(Usuario usuario)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPI_Usuario";
                cmd.Parameters.Add("@nombre", SqlDbType.VarChar).Value = usuario.nombre;
                cmd.Parameters.Add("@password", SqlDbType.VarChar).Value = usuario.password;
                cmd.Parameters.Add("@tipoUsuario", SqlDbType.VarChar).Value = usuario.tipoUsuario;
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

        public static int Delete(string nombre)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPD_Usuario";
                cmd.Parameters.Add("@nombre", SqlDbType.VarChar).Value = nombre;
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

        public static List<Usuario> select()
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Usuario";
                cmd.Connection = connection;
                List<Usuario> usuarios = new List<Usuario>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        while (reader.Read())
                            usuarios.Add(new Usuario()
                            {
                                nombre = reader.GetString(0),
                                password = reader.GetString(1),
                                tipoUsuario = reader.GetString(2)
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

                return usuarios; // execute not accomplish
            }
        }


        public static int Validate(UsuarioLogIn usuario)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Usuario_Validate";
                cmd.Parameters.Add("@nombre", SqlDbType.VarChar).Value = usuario.nombre;
                cmd.Parameters.Add("@password", SqlDbType.VarChar).Value = usuario.password;
                cmd.Parameters.Add("@retValue", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;
                cmd.Connection = connection;

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

        public static Usuario Detail(UsuarioLogIn usuario)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Usuario_Detail";
                cmd.Parameters.Add("@nombre", SqlDbType.VarChar).Value = usuario.nombre;
                cmd.Parameters.Add("@password", SqlDbType.VarChar).Value = usuario.password;
                cmd.Connection = connection;
                Usuario newUsuario;
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                            reader.Read();
                            newUsuario = new  Usuario()
                            {
                                nombre = reader.GetString(0),
                                password = reader.GetString(1),
                                tipoUsuario = reader.GetString(2)

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

                return newUsuario; // execute not accomplish
            }
        }
    }
}