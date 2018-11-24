using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Script.Serialization;
using WSCodigoEco.Connection;

namespace WSCodigoEco.Controllers
{
    [RoutePrefix("api/login")]
    public class LoginController : ApiController
    {

        [AcceptVerbs("GET")]
        [Route("Login")]
        public string Login(string Usuario, string Senha)
        {
            string lstrMensagem;
            string lstrParametrosJson = @"{""login"" : """ + Usuario + @""", ""senha"" : """ + Senha + @""" }";
            string lstrResultadoConsulta;
            string lstrResultadoFinal = "";

            JavaScriptSerializer ljsSerial = new JavaScriptSerializer();
            dynamic lJson;

            try
            {
                ConexaoSqlServer lcnn = new ConexaoSqlServer();
                lcnn.Conectar();
                lstrResultadoConsulta = lcnn.ExecutarProcedure("spLogin", lstrParametrosJson);

                lJson = ljsSerial.DeserializeObject(lstrResultadoConsulta);

                foreach (KeyValuePair<string, object> entry in lJson)
                {
                    lstrResultadoFinal = entry.Value as string;
                }

                lstrMensagem = lstrResultadoFinal;
            }
            catch (Exception e)
            {
                lstrMensagem = e.Message;
            }

            return lstrMensagem;
        }
    }
}
