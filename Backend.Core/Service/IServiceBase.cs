using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Shared.Core;

namespace Backend.Core.Service
{
    public interface IServiceBase<Contract> where Contract : Validatable
    {
    }
}
