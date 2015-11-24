using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Shared.Core.DTOs;

namespace Shared.Business.DTOs
{
    public class ClientDTO: DTOBase
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }
}