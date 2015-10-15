using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Shared.Core.Contracts
{
    public abstract class BaseContract: Validatable, IBaseContract
    {
        public abstract int Id { get; set; }
    }
}