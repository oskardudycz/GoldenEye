using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.Context.SaveChangesHandler.Base
{
    public interface ISaveChangesHandler
    {
        void Handle(DbContext context);
    }
}
