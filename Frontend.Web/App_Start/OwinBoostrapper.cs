using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using GoldenEye.Frontend.Core.Web;
using GoldenEye.Frontend.Web;
using Microsoft.Owin;

[assembly: OwinStartup(typeof(OwinBoostrapper))]
namespace GoldenEye.Frontend.Web
{
    public class OwinBoostrapper : OwinBoostrapperBase
    {
    }
}